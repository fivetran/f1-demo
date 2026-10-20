# F1 answer evals

100 questions with ten choices (A–J), inspired by [MMLU-Pro](https://arxiv.org/abs/2406.01574).
This is a custom F1 suite, not the official benchmark or its evaluation protocol.
It scores answer correctness, with no LLM judge or SQL grading.

From the repository root, using the existing virtual environment and Google ADC:

```sh
# Install only if these existing operational dependencies are missing:
.venv/bin/python -m pip install -r scripts/requirements.txt

# Offline dataset validation:
.venv/bin/python evals/run.py --check

# Run all 100 against the published F1 Analyst (four concurrent requests):
.venv/bin/python evals/run.py

# Adjust concurrency (use --workers 1 for serial execution):
.venv/bin/python evals/run.py --workers 4

# Run one question, or change the reproducible option shuffle:
.venv/bin/python evals/run.py --id 03_monaco_margin --seed 42
```

The runner reuses the agent endpoint and name from [configure_data_agent.py](../scripts/configure_data_agent.py).
It creates a fresh stateless request for each question, with the published agent's normal tools.
Only the question, shuffled choices, and response-format instructions go to the agent;
answer keys and evidence never enter the prompt. Each request can take up to several minutes. A full run makes 100 agent calls, with four in flight by default. Each request has its own HTTP session.
Lower `--workers` if service quotas cause errors; concurrency does not reduce per-question usage.
Live runs incur normal agent and BigQuery usage. Nothing is deployed or rebuilt by the runner.

The agent must return `ANSWER: X` on its own line (a bare letter is also accepted).
One unambiguous letter is graded against the shuffled answer key. A missing or ambiguous
letter is `invalid`; request failures are `error`, separate from a wrong answer (`fail`).
All selected questions remain in the accuracy denominator, including errors and invalid output.
The process exits 1 for any non-pass result, otherwise 0.

Timestamped JSONL reports in ignored [results/](results/) save each response, API messages,
choice order, expected/selected letters, elapsed time, and status in completion order as soon as each question finishes. A single writer saves the results.
These are local debugging records and may contain private project references; do not publish them.
The console reports overall accuracy and structured/unstructured category scores.

## Questions and evidence

Edit the `QUESTIONS` list in [questions.py](questions.py). Each question has a stable ID,
category, question, ten distinct choices, and one exact answer string.
Evidence, source URLs, warehouse observations, and verification SQL are Python comments
beside the questions. The suite contains:

- 67 structured questions covering 2025 race classifications, finishing gaps, net positions
  gained, and sums or differences of race points. Race points exclude Sprints.
- 33 unstructured questions covering driver interviews, strategy, tyres, handling,
  aerodynamics, flags, race procedures, and the handsomest-driver question.

Charles Leclerc is the user-specified answer for question 01, graded like every other question.
The other 99 keys were checked against live BigQuery data on 2026-10-20 and public race
reporting, driver interviews, and explanatory articles. To rerun the commented verification
queries in BigQuery US, replace `{project}` with the configured project.
Verification is an authoring step, not an additional query on every eval run.
The driver interviews and glossary are also the source documents ingested into the warehouse:
checking their public versions confirms faithful ingestion, not independent corroboration.
The 63 added structured questions cover the 21 races outside Singapore, Monaco, and
Silverstone, which the initial questions already cover. Their source rows were compared
with the top-five results embedded in F1's public race reports; numerical keys are calculated
from those matched rows. Comments distinguish these calculations from reported values.
The 27 added unstructured questions use glossary scenarios; their public definitions are
also the ingested sources, rather than independent corroboration.
Race reporting and strategy analysis provide additional human context where available.

The suite covers all 24 completed 2025 races, but remains a custom sample rather than a
comprehensive test of all F1 questions. Several questions share a race or source document. Ten options have a 10% uniform-random baseline; choices can provide clues, and
known results may be answered from memory. Scores do not establish tool use or citation quality.
Review failed responses before editing the agent. Keep the dataset and seed fixed when comparing
runs, and refresh the published agent after any intended catalog changes before evaluating them.
