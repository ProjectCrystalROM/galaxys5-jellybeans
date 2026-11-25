#!/usr/bin/env bash
set -euo pipefail
tree=$(realpath -- "${1:?Usage: fetch-cm-prebuilts.sh ANDROID_SOURCE_ROOT}")
test -f "$tree/vendor/cm/config/common.mk"
destination=$tree/vendor/cm/proprietary
revision=334695ec98ded96cdcf66a92af3b7469a18072a7
checksum=f958d347a84eda4603ad4f6cb9c9b5cf06dfb168e64787a02edd0a3060044405
download=$(mktemp)
trap 'rm -- "$download"' EXIT
curl -fsSL "https://raw.githubusercontent.com/jackpal/Android-Terminal-Emulator/$revision/downloads/Term.apk" -o "$download"
printf '%s  %s\n' "$checksum" "$download" | sha256sum -c
mkdir -p -- "$destination"
unzip -qo "$download" 'lib/armeabi/libjackpal-androidterm4.so' -d "$destination"
install -m 0644 "$download" "$destination/Term.apk"
