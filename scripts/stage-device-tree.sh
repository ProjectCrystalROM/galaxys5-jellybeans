#!/usr/bin/env bash
set -euo pipefail
project=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
tree=$(realpath -- "${1:?Usage: stage-device-tree.sh ANDROID_SOURCE_ROOT}")
[[ -f "$tree/build/envsetup.sh" && "$tree" != "$project" ]]
for path in device/samsung/klte-common device/samsung/kltetmo device/samsung/kltevzw packages/apps/BasicSmsReceiver; do
    destination=$tree/$path
    if [[ -e "$destination" || -L "$destination" ]]; then
        if [[ -L "$destination" ]] || ! diff -qr -- "$project/$path" "$destination"; then
            printf 'Existing checkout or files at %s\n' "$destination" >&2
            exit 1
        fi
        continue
    fi
    mkdir -p -- "$(dirname -- "$destination")"
    cp -a -- "$project/$path" "$destination"
done
