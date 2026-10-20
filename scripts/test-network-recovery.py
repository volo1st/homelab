#!/usr/bin/env python3
"""Check recovery input guards without a router connection or real credential."""
import contextlib
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import subprocess
import sys
import tarfile
import tempfile
import unittest
from unittest.mock import patch


class RecoveryGuards(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.work = Path(self.temporary.name)
        source_file = Path(__file__).with_name('prepare-network-recovery.py')
        spec = importlib.util.spec_from_file_location('recovery_under_test', source_file)
        self.module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(self.module)
        self.module.__file__ = str(self.work / 'repo/scripts/prepare-network-recovery.py')
        self.source = self.work / 'source'
        for host in ['axt1800', 'wax202', 'mt6000', 'mt1300', 'mikrotik']:
            folder = self.source / host
            folder.mkdir(parents=True)
            if host != 'mikrotik':
                raw = b'config interface loopback\n'
                with tarfile.open(folder / 'config.tar.gz', 'w:gz') as archive:
                    member = tarfile.TarInfo('etc/config/network')
                    member.size = len(raw)
                    archive.addfile(member, io.BytesIO(raw))
                (folder / 'backup-files.txt').write_text('/etc/config/network\n')
            else:
                (folder / 'config.rsc').write_text('/system identity\n')
            hashes = ''.join(hashlib.sha256(p.read_bytes()).hexdigest() + '  ' + p.name + '\n'
                             for p in sorted(folder.iterdir()))
            (folder / 'SHA256SUMS').write_text(hashes)
        (self.source / 'manifest.txt').write_text('completed_utc=test\ncollection_exit=0\n')
        self.args = ['recovery', '--run', '--source', str(self.source),
                     '--output', str(self.work / 'out')]
        self.calls = []

    def run_cli(self, args=None):
        def fake_run(command, **kwargs):
            self.calls.append(command[0])
            if command[0] == 'git':
                return subprocess.CompletedProcess(command, 0)
            raise RuntimeError('TEST_STOP_BEFORE_SSH')
        with patch.object(sys, 'argv', args or self.args), \
             patch.object(self.module.subprocess, 'run', side_effect=fake_run), \
             patch.object(self.module.shutil, 'which', return_value='/test/tool'), \
             contextlib.redirect_stderr(io.StringIO()):
            return self.module.main()

    def test_explicit_source_required_before_any_connection(self):
        with self.assertRaises(SystemExit) as result:
            self.run_cli(['recovery', '--run'])
        self.assertEqual(result.exception.code, 2)
        self.assertEqual(self.calls, [])

    def test_changed_source_refused_before_any_connection(self):
        (self.source / 'mikrotik/config.rsc').write_text('changed\n')
        with self.assertRaisesRegex(RuntimeError, 'Source checksum mismatch'):
            self.run_cli()
        self.assertEqual(self.calls, [])

    def test_changed_supplement_refused_before_any_connection(self):
        folder = self.work / 'assets'
        folder.mkdir()
        (folder / 'file').write_text('changed')
        (folder / 'SHA256SUMS.json').write_text(json.dumps({'file': '0' * 64}))
        with self.assertRaisesRegex(RuntimeError, 'Supplemental recovery checksum mismatch'):
            self.run_cli(self.args + ['--supplement', str(folder)])
        self.assertEqual(self.calls, [])

    def test_resume_different_source_refused_before_ssh(self):
        folder = self.work / 'out/20261020T000000Z'
        folder.mkdir(parents=True)
        (folder / 'inputs.json').write_text(json.dumps({'source': 'old'}))
        with self.assertRaisesRegex(RuntimeError, 'Resume inputs differ'):
            self.run_cli(self.args + ['--resume', folder.name])
        self.assertEqual(self.calls, ['git'])

    def test_inputs_are_valid_json_before_ssh(self):
        with self.assertRaisesRegex(RuntimeError, 'TEST_STOP_BEFORE_SSH'):
            self.run_cli()
        records = list((self.work / 'out').glob('*/inputs.json'))
        self.assertEqual(len(records), 1)
        self.assertEqual(json.loads(records[0].read_text())['source'], str(self.source))
        self.assertEqual(self.calls, ['git', 'ssh'])


if __name__ == '__main__':
    unittest.main()
