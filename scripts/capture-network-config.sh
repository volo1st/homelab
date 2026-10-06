#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
    printf '%s\n' 'Usage: bash scripts/capture-network-config.sh --run'
    printf '%s\n' 'Run on macOS or Linux. Collect private backups through existing SSH aliases.'
    printf '%s\n' 'Output: secrets/local/network/<UTC timestamp>/'
}

if [[ $# -eq 1 && ( "$1" == '-h' || "$1" == '--help' ) ]]; then
    usage
    exit 0
fi
if [[ $# -ne 1 || "$1" != '--run' ]]; then
    usage >&2
    exit 2
fi
collector_platform="$(uname -s)"
case "$collector_platform" in
    Darwin|Linux) ;;
    *) printf 'Unsupported collector platform: %s\n' "$collector_platform" >&2; exit 2 ;;
esac
for command_name in ssh tar shasum git; do
    command -v "$command_name" >/dev/null 2>&1 || {
        printf 'Required command is absent: %s\n' "$command_name" >&2
        exit 2
    }
done
git -C "$repo_root" check-ignore -q secrets/local/network/protection-check || {
    printf '%s\n' 'Private output is not ignored by Git. Collection stopped.' >&2
    exit 2
}

umask 077
timestamp="$(date -u '+%Y%m%dT%H%M%SZ')"
output_dir="${repo_root}/secrets/local/network/${timestamp}"
[[ ! -e "$output_dir" ]] || {
    printf 'Output already exists: %s\n' "$output_dir" >&2
    exit 2
}
mkdir -p "$output_dir"
chmod 700 "$output_dir"
printf 'started_utc=%s\n' "$timestamp" >"${output_dir}/manifest.txt"
printf 'collector_host=%s\ncollector_platform=%s\n' \
    "$(hostname)" "$collector_platform" >>"${output_dir}/manifest.txt"
printf 'Output contains private configuration: %s\n' "$output_dir"

finish() {
    local status=$?
    trap - EXIT
    printf 'collection_exit=%s\n' "$status" >>"${output_dir}/manifest.txt"
    if [[ "$status" -ne 0 ]]; then
        printf 'Capture is incomplete. Private partial files remain at %s\n' "$output_dir" >&2
    fi
    exit "$status"
}
trap finish EXIT

ssh_options=(-T -o BatchMode=yes -o StrictHostKeyChecking=yes -o ConnectTimeout=8 -o ConnectionAttempts=1)
for host in axt1800 wax202 mt6000 mt1300; do
    printf 'Collecting %s\n' "$host"
    device_dir="${output_dir}/${host}"
    mkdir "$device_dir"
    ssh "${ssh_options[@]}" "$host" 'ubus call system board' \
        >"${device_dir}/board.json" 2>"${device_dir}/board.stderr"
    ssh "${ssh_options[@]}" "$host" 'uci export' \
        >"${device_dir}/config.uci" 2>"${device_dir}/config.stderr"
    ssh "${ssh_options[@]}" "$host" 'ip -4 addr show && ip -4 route show' \
        >"${device_dir}/network-state.txt" 2>"${device_dir}/network-state.stderr"
    ssh "${ssh_options[@]}" "$host" 'sysupgrade -l' \
        >"${device_dir}/backup-files.txt" 2>"${device_dir}/backup-list.stderr"
    ssh "${ssh_options[@]}" "$host" \
        'if command -v apk >/dev/null 2>&1; then apk info -v; else opkg list-installed; fi' \
        >"${device_dir}/packages.txt" 2>"${device_dir}/packages.stderr"
    ssh "${ssh_options[@]}" "$host" 'sysupgrade -b -' \
        >"${device_dir}/config.tar.gz" 2>"${device_dir}/backup.stderr"
    [[ -s "${device_dir}/board.json" && -s "${device_dir}/config.uci" && \
        -s "${device_dir}/packages.txt" && -s "${device_dir}/config.tar.gz" ]]
    tar -tzf "${device_dir}/config.tar.gz" >"${device_dir}/archive-files.txt"
    [[ -s "${device_dir}/archive-files.txt" ]]
    (
        cd "$device_dir"
        shasum -a 256 board.json config.uci network-state.txt backup-files.txt packages.txt config.tar.gz archive-files.txt \
            >SHA256SUMS
        shasum -a 256 -c SHA256SUMS >checksum-check.txt
    )
    printf '%s_archive_check=passed\n' "$host" >>"${output_dir}/manifest.txt"
done

printf '%s\n' 'Collecting mikrotik'
device_dir="${output_dir}/mikrotik"
mkdir "$device_dir"
ssh "${ssh_options[@]}" mikrotik '/system resource print; /system routerboard print' \
    >"${device_dir}/identity.txt" 2>"${device_dir}/identity.stderr"
ssh "${ssh_options[@]}" mikrotik '/export' \
    >"${device_dir}/config.rsc" 2>"${device_dir}/export.stderr"
[[ -s "${device_dir}/identity.txt" && -s "${device_dir}/config.rsc" ]]
(
    cd "$device_dir"
    shasum -a 256 identity.txt config.rsc >SHA256SUMS
    shasum -a 256 -c SHA256SUMS >checksum-check.txt
)
printf '%s\n' 'mikrotik_text_export=collected' 'mikrotik_encrypted_binary_backup=pending' \
    >>"${output_dir}/manifest.txt"
printf 'completed_utc=%s\n' "$(date -u '+%Y%m%dT%H%M%SZ')" >>"${output_dir}/manifest.txt"
printf '%s\n' 'Private collection completed. Review exports before creating tracked templates.'
printf '%s\n' 'Complete the MikroTik encrypted backup and separate certificate/key recovery copies.'
