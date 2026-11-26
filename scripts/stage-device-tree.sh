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
kernel_dir=$tree/kernel/samsung/klte
kernel_patch=$project/patches/kernel/klte/0001-enable-bt-pan-dun-protocols.patch
if git -C "$kernel_dir" apply --reverse --check "$kernel_patch" >/dev/null 2>&1; then
    : # The patch is already staged.
else
    git -C "$kernel_dir" apply --check "$kernel_patch"
    git -C "$kernel_dir" apply "$kernel_patch"
fi
init_dir=$tree/system/core
firmware_patch=$project/patches/system/core/0001-ueventd-search-modem-firmware-partition.patch
if git -C "$init_dir" apply --reverse --check "$firmware_patch" >/dev/null 2>&1; then
    : # The patch is already staged.
else
    git -C "$init_dir" apply --check "$firmware_patch"
    git -C "$init_dir" apply "$firmware_patch"
fi
audio_dir=$tree/hardware/qcom/audio-caf
audio_patch=$project/patches/hardware/qcom/audio-caf/0001-wait-for-msm8974-taiko-sound-card.patch
if git -C "$audio_dir" apply --reverse --check "$audio_patch" >/dev/null 2>&1; then
    : # The patch is already staged.
else
    git -C "$audio_dir" apply --check "$audio_patch"
    git -C "$audio_dir" apply "$audio_patch"
fi
telephony_dir=$tree/frameworks/opt/telephony
mvno_patch=$project/patches/frameworks/opt/telephony/0001-handle-empty-MVNO-fields.patch
if git -C "$telephony_dir" apply --reverse --check "$mvno_patch" >/dev/null 2>&1; then
    : # The patch is already staged.
else
    git -C "$telephony_dir" apply --check "$mvno_patch"
    git -C "$telephony_dir" apply "$mvno_patch"
fi
provider_dir=$tree/packages/providers/TelephonyProvider
provider_patch=$project/patches/packages/providers/TelephonyProvider/0001-add-Samsung-APN-columns-and-normalize-MVNO.patch
if git -C "$provider_dir" apply --reverse --check "$provider_patch" >/dev/null 2>&1; then
    : # The patch is already staged.
else
    git -C "$provider_dir" apply --check "$provider_patch"
    git -C "$provider_dir" apply "$provider_patch"
fi
frameworks_dir=$tree/frameworks/base
notification_patch=$project/patches/frameworks/base/packages/SystemUI/0001-resolve-default-notification-sound-uri.patch
if git -C "$frameworks_dir" apply --reverse --check "$notification_patch" >/dev/null 2>&1; then
    : # The patch is already staged.
else
    git -C "$frameworks_dir" apply --check "$notification_patch"
    git -C "$frameworks_dir" apply "$notification_patch"
fi
python3 "$project/scripts/add-att-apn.py" \
    "$tree/vendor/cm/prebuilt/common/etc/apns-conf.xml"
