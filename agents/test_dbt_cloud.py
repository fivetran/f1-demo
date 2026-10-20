"""Check the downstream deployment gate without calling dbt Cloud."""

import unittest
from unittest.mock import Mock, patch

from run_dbt_cloud import run_job


class DbtCloudTests(unittest.TestCase):
    @patch('run_dbt_cloud.request')
    def test_success_uses_and_verifies_commit(self, request):
        request.side_effect = [{'id': 7}, {'status': 10, 'git_sha': 'abc'}]
        run_job(Mock(), 'https://example/api/v2/accounts/1', 2, 'abc')
        self.assertEqual(request.call_args_list[0].kwargs['json']['git_sha'], 'abc')
        self.assertEqual(request.call_count, 2)

    @patch('run_dbt_cloud.request')
    def test_failure_or_wrong_commit_blocks_deployment(self, request):
        for result in [{'status': 20}, {'status': 30}, {'status': 10, 'git_sha': 'other'}]:
            with self.subTest(result=result):
                request.side_effect = [{'id': 7}, result, {}]
                with self.assertRaises(RuntimeError):
                    run_job(Mock(), 'https://example/api/v2/accounts/1', 2, 'abc')

    @patch('run_dbt_cloud.request')
    def test_timeout_requests_cancellation(self, request):
        request.side_effect = [{'id': 7}, {}]
        with self.assertRaises(TimeoutError):
            run_job(Mock(), 'https://example/api/v2/accounts/1', 2, 'abc', timeout=0)
        self.assertTrue(request.call_args.args[2].endswith('/runs/7/cancel/'))
