#!/usr/bin/env bash
set -euo pipefail
blob_root=$(realpath -- "${1:?Usage: audit-blobs.sh PROPRIETARY_DIRECTORY}")
readelf_tool=${READELF:-readelf}
while IFS= read -r -d '' file; do
    if "$readelf_tool" -h "$file" >/dev/null 2>&1; then
        printf '\n%s\n' "${file#"$blob_root"/}"
        "$readelf_tool" --wide -h -d --dyn-syms --version-info "$file"
    fi
done < <(find "$blob_root" -type f -print0 | sort -z)
