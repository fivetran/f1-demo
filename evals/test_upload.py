"""Offline checks for durable failed-answer uploads and retry behavior."""

import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import Mock

from google.api_core.exceptions import Conflict

from upload import upload


class UploadTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.report = Path(self.directory.name) / 'results.jsonl'
        self.report.write_text(json.dumps(dict(
            id='example', status='fail', started_at='2026-10-20T00:00:00+00:00',
            messages=[{'systemMessage': {'text': {'parts': ['ANSWER: B']}}}],
        )) + '\n')
        self.client = Mock()

    def test_failed_answer_and_incomplete_counts_are_preserved(self):
        rows = upload(self.client, self.report, 'run_1', 'sha', 'https://ci', 100)
        self.assertEqual(rows[0]['status'], 'fail')
        self.assertEqual((rows[0]['completed_count'], rows[0]['expected_count']), (1, 100))
        self.assertEqual(rows[0]['messages'][0]['systemMessage']['text']['parts'],
                         ['ANSWER: B'])
        self.client.load_table_from_json.return_value.result.assert_called_once()
        self.assertEqual(self.client.load_table_from_json.call_args.kwargs['job_id'],
                         'f1_evals_run_1')

    def test_retry_waits_for_existing_job_without_another_append(self):
        self.client.load_table_from_json.side_effect = Conflict('already submitted')
        upload(self.client, self.report, 'run_1', 'sha', '', 1)
        self.client.get_job.assert_called_once_with('f1_evals_run_1', location='US')
        self.client.get_job.return_value.result.assert_called_once()

    def test_load_failure_is_not_reported_as_success(self):
        self.client.load_table_from_json.return_value.result.side_effect = RuntimeError('failed')
        with self.assertRaises(RuntimeError):
            upload(self.client, self.report, 'run_1', 'sha', '', 1)


if __name__ == '__main__':
    unittest.main()
