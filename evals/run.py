"""Run ten-choice F1 questions against the published analyst using Google ADC."""

import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
import json
from pathlib import Path
import random
import re
import sys
import time

from questions import QUESTIONS

HERE = Path(__file__).resolve().parent
LETTERS = 'ABCDEFGHIJ'


def load_questions():
    questions = QUESTIONS
    ids = [q['id'] for q in questions]
    if len(ids) != len(set(ids)):
        raise ValueError('Question IDs must be unique')
    for q in questions:
        if len(q['choices']) != 10 or len(set(q['choices'])) != 10:
            raise ValueError(f"{q['id']}: expected ten distinct choices")
        if q['answer'] not in q['choices']:
            raise ValueError(f"{q['id']}: answer must match one choice")
    return questions


def make_prompt(question, seed):
    choices = question['choices'].copy()
    random.Random(f"{seed}:{question['id']}").shuffle(choices)
    prompt = (
        'Answer this multiple-choice F1 question based exclusively on data retrieved '
        'from BigQuery, including document text stored there. Query BigQuery to obtain '
        'supporting evidence before answering. Do not use prior knowledge, external '
        'sources. You must select exactly one option: choose the answer best supported '
        'by the BigQuery data. Do not abstain or leave the question unanswered. '
        'End with a line in the exact format '
        'ANSWER: X, where X is a letter A through J. Do not produce a chart.\n\n'
        + question['question'] + '\n\n'
        + '\n'.join(f'{letter}. {choice}' for letter, choice in zip(LETTERS, choices))
    )
    return prompt, choices


def selected_answer(text):
    # Never guess a choice from prose, SQL, or an incidental letter.
    matches = re.findall(r'^ANSWER:\s*([A-J])\s*$', text.strip(), re.MULTILINE)
    if len(matches) == 1:
        return matches[0]
    if re.fullmatch(r'[A-J]', text.strip()):
        return text.strip()
    return None


def ask(session, api, parent, agent, prompt):
    response = session.post(
        f'{api}/{parent}:chat',
        json={
            'parent': parent,
            'messages': [{'userMessage': {'text': prompt}}],
            'data_agent_context': {'data_agent': agent},
        },
        headers={'x-server-timeout': '300'},
        timeout=(15, 330),
    )
    if not response.ok:
        raise RuntimeError(f'Chat HTTP {response.status_code}')
    messages = response.json()
    if not isinstance(messages, list):
        messages = [messages]
    if any('error' in m or 'error' in m.get('systemMessage', {}) for m in messages):
        raise RuntimeError('Chat returned an error event')
    texts = [
        ''.join(m['systemMessage']['text'].get('parts', []))
        for m in messages if 'text' in m.get('systemMessage', {})
        and m['systemMessage']['text'].get('textType') != 'THOUGHT'
    ]
    return '\n'.join(texts), messages


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='Validate questions without calling Google')
    parser.add_argument('--id', action='append', help='Run only this question ID; repeat to select several')
    parser.add_argument('--seed', type=int, default=42, help='Reproducible choice shuffle')
    parser.add_argument('--workers', type=int, default=4, help='Concurrent questions (default: 4; use 1 for serial)')
    parser.add_argument('--output', type=Path, help='JSONL report path (must not already exist)')
    args = parser.parse_args()
    if args.workers < 1:
        parser.error('--workers must be at least 1')
    questions = load_questions()
    if args.id:
        unknown = set(args.id) - {q['id'] for q in questions}
        if unknown:
            parser.error(f'Unknown IDs: {sorted(unknown)}')
        questions = [q for q in questions if q['id'] in args.id]
    if args.check:
        print(f'Validated {len(questions)} questions, each with ten distinct choices and one answer.')
        return 0

    import google.auth
    from google.auth.transport.requests import AuthorizedSession

    sys.path.insert(0, str(HERE.parent / 'agents'))
    from configure_data_agent import API, NAME, PARENT

    timestamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    output = args.output or HERE / 'results' / f'{timestamp}.jsonl'
    output.parent.mkdir(parents=True, exist_ok=True)
    counts = Counter()
    category_counts = {}
    def run_question(q):
        prompt, choices = make_prompt(q, args.seed)
        row = dict(id=q['id'], category=q['category'], question=q['question'],
                   choices=choices, expected=LETTERS[choices.index(q['answer'])],
                   seed=args.seed, agent=NAME,
                   started_at=datetime.now(timezone.utc).isoformat())
        started = time.monotonic()
        try:
            # Each request owns its credentials and HTTP session; neither is shared across threads.
            credentials, _ = google.auth.default(scopes=['https://www.googleapis.com/auth/cloud-platform'])
            with AuthorizedSession(credentials) as session:
                text, messages = ask(session, API, PARENT, NAME, prompt)
            answer = selected_answer(text)
            status = 'invalid' if answer is None else ('pass' if answer == row['expected'] else 'fail')
            row.update(answer=answer, response=text, messages=messages, status=status)
        except Exception as error:
            # Do not log auth exceptions or HTTP bodies that might contain credentials.
            row.update(status='error', error_type=type(error).__name__)
        row['seconds'] = round(time.monotonic() - started, 2)
        return row

    started = time.monotonic()
    with output.open('x') as handle, ThreadPoolExecutor(max_workers=args.workers) as pool:
        futures = [pool.submit(run_question, q) for q in questions]
        for future in as_completed(futures):
            row = future.result()
            counts[row['status']] += 1
            category_counts.setdefault(row['category'], Counter())[row['status']] += 1
            handle.write(json.dumps(row, ensure_ascii=False) + '\n')
            handle.flush()
            print(f"{row['id']}: {row['status']} ({row['seconds']}s)", flush=True)
    print(f'Elapsed: {time.monotonic() - started:.1f}s with {args.workers} workers')
    print(f'All questions: {counts["pass"]}/{len(questions)} correct; {dict(counts)}')
    for category, values in category_counts.items():
        print(f'{category}: {values["pass"]}/{sum(values.values())} correct; {dict(values)}')
    print(f'Results: {output}')
    return 1 if counts['fail'] or counts['invalid'] or counts['error'] else 0


if __name__ == '__main__':
    raise SystemExit(main())
