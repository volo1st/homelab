#!/usr/bin/env python3
"""Create a local encrypted network recovery archive. Does not change network settings."""
import argparse
import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import re
import secrets
import shutil
import subprocess
import tarfile
import tempfile


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def crypt(gpg_home, key, source, dest, decrypt=False):
    args = ['gpg', '--homedir', str(gpg_home), '--no-options', '--batch',
            '--pinentry-mode', 'loopback', '--passphrase-fd', '0',
            '--no-symkey-cache', '--output', str(dest)]
    args += ['--decrypt'] if decrypt else ['--symmetric', '--cipher-algo', 'AES256']
    result = subprocess.run(args + [str(source)], input=key.encode() + b'\n',
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=120)
    cleanup = subprocess.run(['gpgconf', '--homedir', str(gpg_home), '--kill', 'gpg-agent'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=15)
    if cleanup.returncode:
        raise RuntimeError('Temporary GPG agent cleanup failed')
    if result.returncode:
        raise RuntimeError('GPG operation failed; no plaintext or passphrase is printed.')


def verify_sources(source):
    for host in ['axt1800', 'wax202', 'mt6000', 'mt1300', 'mikrotik']:
        device = source / host
        for line in (device / 'SHA256SUMS').read_text().splitlines():
            expected, name = line.split(maxsplit=1)
            name = name.lstrip('* ')
            candidate = device / name
            if candidate.resolve().parent != device.resolve():
                raise RuntimeError('Unexpected checksum path')
            if digest(candidate) != expected:
                raise RuntimeError('Source checksum mismatch')
        if host != 'mikrotik':
            with tarfile.open(device / 'config.tar.gz') as archive:
                members = {m.name.lstrip('/') for m in archive.getmembers()}
                if not all(n.lstrip('/') in members for n in (device / 'backup-files.txt').read_text().splitlines()):
                    raise RuntimeError('Backup archive is missing a listed file')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run', action='store_true', help='Create one encrypted router backup, retrieve it, and create local recovery files')
    parser.add_argument('--resume', help='Resume an existing timestamp without creating another router backup')
    parser.add_argument('--output', type=Path, default=Path('/sandbox/vincent/home_network_backup'))
    parser.add_argument('--source', type=Path, help='Reviewed current configuration capture directory; required with --run')
    parser.add_argument('--runtime', type=Path, help='Matching read-only runtime capture directory')
    parser.add_argument('--supplement', type=Path, help='Verified custom files, firmware, packages, and recovery notes')
    args = parser.parse_args()
    if not args.run:
        parser.print_help()
        return
    root = Path(__file__).resolve().parents[1]
    if args.source is None:
        parser.error('--source is required with --run; historical captures are never selected implicitly')
    source = args.source.resolve()
    runtime = args.runtime.resolve() if args.runtime else None
    supplement = args.supplement.resolve() if args.supplement else None
    verify_sources(source)
    capture_manifest = (source / 'manifest.txt').read_text()
    if 'completed_utc=' not in capture_manifest or 'collection_exit=0' not in capture_manifest:
        raise RuntimeError('Configuration capture did not complete')
    if runtime is not None:
        manifest = json.loads((runtime / 'manifest.json').read_text())
        if not manifest.get('all_transports_passed'):
            raise RuntimeError('Runtime capture has an incomplete transport')
    if supplement is not None:
        expected_files = json.loads((supplement / 'SHA256SUMS.json').read_text())
        for name, expected in expected_files.items():
            candidate = supplement / name
            if not candidate.resolve().is_relative_to(supplement) or not candidate.is_file():
                raise RuntimeError('Invalid supplemental recovery path')
            if digest(candidate) != expected:
                raise RuntimeError('Supplemental recovery checksum mismatch')
    for tool in ['gpg', 'gpgconf', 'ssh', 'sftp']:
        if not shutil.which(tool):
            raise RuntimeError('Required installed tool is absent: ' + tool)
    subprocess.run(['git', '-C', str(root), 'check-ignore', '-q', 'secrets/local/network-recovery-keys/protection-check'], check=True)
    output_root = args.output.resolve()
    if output_root == root.resolve() or root.resolve() in output_root.parents:
        raise RuntimeError('Recovery output must be outside the repository')
    os.umask(0o077)
    stamp = args.resume or dt.datetime.now(dt.timezone.utc).strftime('%Y%m%dT%H%M%SZ')
    if not re.fullmatch(r'\d{8}T\d{6}Z', stamp):
        raise RuntimeError('Invalid timestamp')
    output_root.mkdir(parents=True, exist_ok=True)
    output = output_root / stamp
    output.mkdir(mode=0o700, exist_ok=bool(args.resume))
    input_record = {'source': str(source), 'runtime': str(runtime) if runtime else None,
                    'supplement': str(supplement) if supplement else None}
    inputs_path = output / 'inputs.json'
    if args.resume:
        if json.loads(inputs_path.read_text()) != input_record:
            raise RuntimeError('Resume inputs differ from the original recovery run')
    else:
        inputs_path.write_text(json.dumps(input_record, indent=2) + chr(10))
    key_dir = root / 'secrets/local/network-recovery-keys'
    key_dir.mkdir(parents=True, exist_ok=True, mode=0o700)
    key_path = key_dir / (stamp + '.passphrase')
    if not args.resume:
        with key_path.open('x') as handle:
            handle.write(secrets.token_urlsafe(48) + '\n')
    key = key_path.read_text().strip()
    ssh_options = ['-T', '-o', 'BatchMode=yes', '-o', 'StrictHostKeyChecking=yes', '-o', 'ConnectTimeout=8', '-o', 'ConnectionAttempts=1']
    backup_base = 'network-stage0-' + stamp
    # The remote command has no literal secret. RouterOS generates it privately.
    command = (
        ':if ([/system resource get free-hdd-space] < 1000000) do={:error "Insufficient backup space"}; '
        ':local base "' + backup_base + '"; '
        ':if ([:len [/file find where name=($base . ".backup")]] != 0) do={:error "Backup already exists"}; '
        ':local recoveryKey [:rndstr length=48]; '
        ':put ("BACKUP_PASSWORD=" . $recoveryKey); '  # secret-scan: allow -- generated RouterOS variable, not a literal credential
        '/system backup save name=$base encryption=aes-sha256 password=$recoveryKey dont-encrypt=no; '  # secret-scan: allow -- generated RouterOS variable, not a literal credential
        ':local backupId [/file find where name=($base . ".backup")]; '
        ':if ([:len $backupId] != 1) do={:error "Backup file missing"}; '
        ':put ("BACKUP_SIZE=" . [/file get $backupId size]); :put "BACKUP_SAVED"'
    )
    # Raw output includes a generated secret. Keep it in the ignored key directory.
    raw = key_dir / (stamp + '.router-output')
    err = key_dir / (stamp + '.router-stderr')
    if not args.resume:
        with raw.open('xb') as out, err.open('xb') as stderr:
            result = subprocess.run(['ssh'] + ssh_options + ['mikrotik', command], stdout=out, stderr=stderr, timeout=60)
    text = raw.read_text()
    match = re.search(r'^BACKUP_PASSWORD=([A-Za-z0-9]{48})\s*$', text, re.M)  # secret-scan: allow -- format matcher, not a credential
    size = re.search(r'^BACKUP_SIZE=(\d+)\s*$', text, re.M)
    if (not args.resume and result.returncode) or not match or not size or 'BACKUP_SAVED' not in text:
        raise RuntimeError('Router backup creation did not verify; private partial files are retained')
    remote_password = key_dir / (stamp + '.mikrotik-passphrase')  # secret-scan: allow -- private file path, not a credential
    remote_password.write_text(match.group(1) + '\n')
    stage_parent = root / 'secrets/local/network-recovery-work'
    stage_parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    with tempfile.TemporaryDirectory(prefix='recovery-work-', dir=stage_parent) as temporary:
        work = Path(temporary)
        local_backup = output / (backup_base + '.backup')
        second = work / 'second-download.backup'
        for destination in [local_backup, second]:
            batch = 'get ' + backup_base + '.backup "' + str(destination) + '"\n'
            with (key_dir / (stamp + '.sftp-log')).open('ab') as log:
                result = subprocess.run(['sftp', '-b', '-', '-o', 'BatchMode=yes', '-o', 'StrictHostKeyChecking=yes', '-o', 'ConnectTimeout=8', 'mikrotik'], input=batch.encode(), stdout=log, stderr=log, timeout=60)
            if result.returncode:
                raise RuntimeError('Encrypted backup retrieval failed; remote backup is retained')
        if local_backup.stat().st_size != int(size.group(1)) or not local_backup.stat().st_size or digest(local_backup) != digest(second):
            raise RuntimeError('Backup size or repeated-download hash check failed')
        bundle = work / 'recovery.tar.gz'
        with tarfile.open(bundle, 'w:gz') as archive:
            archive.add(source, arcname='configuration/' + source.name)
            if runtime is not None:
                archive.add(runtime, arcname='runtime/' + runtime.name)
            if supplement is not None:
                archive.add(supplement, arcname='supplement')
            archive.add(inputs_path, arcname='inputs.json')
            archive.add(local_backup, arcname='mikrotik/' + local_backup.name)
            archive.add(remote_password, arcname='mikrotik/backup-passphrase.txt')
        # A short path avoids the Unix-domain socket path limit in gpg-agent.
        with tempfile.TemporaryDirectory(prefix='network-gpg-') as short_home:
            home = Path(short_home)
            encrypted = output / 'network-recovery.tar.gz.gpg'
            if encrypted.exists():
                encrypted.replace(output / 'failed-encryption.gpg')
            crypt(home, key, bundle, encrypted)
            checked = work / 'decrypted-check.tar.gz'
            crypt(home, key, encrypted, checked, decrypt=True)
        if digest(bundle) != digest(checked):
            raise RuntimeError('Recovery archive decrypt verification failed')
        with tarfile.open(checked) as archive:
            count = len(archive.getmembers())
        manifest = {
            'utc': stamp, 'storage_scope': 'NAS-local; user accepts loss with NAS',
            'encrypted_archive_sha256': digest(encrypted), 'archive_members': count,
            'decrypt_and_plaintext_hash_check': 'passed',
            'mikrotik_backup_size': local_backup.stat().st_size,
            'mikrotik_backup_sha256': digest(local_backup),
            'mikrotik_repeated_download_hash_check': 'passed',
            'mikrotik_encryption': 'aes-sha256; explicit random password',
            'mikrotik_restore_test': 'not run', 'remote_file_retained': backup_base + '.backup',
            'outer_passphrase_file': str(key_path),
            'inputs': input_record,
        }
        (output / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print('Local encrypted recovery directory:', output)
    print('Private passphrase file:', key_path)
    print('Decrypt verification and repeated encrypted-backup retrieval passed. Router restore was not tested.')


if __name__ == '__main__':
    main()
