#!/usr/bin/env bash
set -euo pipefail
out=${1:?Usage: collect-boot-logs.sh NEW_LOG_DIRECTORY}
mkdir -- "$out"
adb get-state >"$out/adb-state.txt" 2>&1
capture() {
    local output=$1
    shift
    adb "$@" >"$out/$output" 2>"$out/$output.stderr" || true
}
capture properties.txt shell getprop
capture mounts.txt shell cat /proc/mounts
capture dmesg.txt shell dmesg
capture last-kmsg.txt shell cat /proc/last_kmsg
capture logcat-main.txt logcat -d -v threadtime -b main -b system -b events
capture logcat-radio.txt logcat -d -v threadtime -b radio
