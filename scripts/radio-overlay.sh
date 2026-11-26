#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 apply SERIAL CM_SYSTEM_ROOT | rollback SERIAL" >&2
    echo "CM_SYSTEM_ROOT is target/product/kltetmo/system from the built CM tree." >&2
    exit 2
}

[[ $# -ge 2 ]] || usage
action=$1
serial=$2
adb=(adb -s "$serial")
remote=/data/local/tmp/crystal-radio-overlay
# Bind bin last so the shell used by adb remains available until the end.
mounts=(/system/vendor/lib /system/lib /firmware/image /system/bin)

case "$action" in
    apply)
        [[ $# -eq 3 ]] || usage
        build_system=$(realpath -- "$3")
        [[ -d "$build_system/bin" && -d "$build_system/lib" && -d "$build_system/vendor/lib" ]] || {
            echo "Not a CM system image root: $build_system" >&2
            exit 1
        }
        "${adb[@]}" get-state >/dev/null
        [[ $("${adb[@]}" shell id) == *"uid=0(root)"* ]] || {
            echo "Run 'adb root' first; refusing to stage with an unprivileged shell." >&2
            exit 1
        }
        stage=$(mktemp -d)
        trap 'rm -rf -- "$stage"' EXIT
        mkdir -p "$stage/system/vendor" "$stage/firmware/merged"
        cp -a "$build_system/bin" "$build_system/lib" "$stage/system/"
        cp -a "$build_system/vendor/lib" "$stage/system/vendor/"
        [[ -L "$stage/system/bin/sh" && -x "$stage/system/bin/mksh" ]] || {
            echo "Built system/bin is missing its shell symlink or mksh; refusing to mount it." >&2
            exit 1
        }
        for path in bin/qmuxd bin/rfs_access bin/rmt_storage lib/libsec-ril.so \
            vendor/lib/libqmi.so vendor/lib/libqmiservices.so vendor/lib/libtime_genoff.so; do
            [[ -f "$stage/system/$path" ]] || {
                echo "Built radio file is missing: $stage/system/$path" >&2
                exit 1
            }
        done

        # Android 4.3's ueventd asks for PIL firmware in /firmware/image.
        # The S5 stores the modem payloads in a separate /firmware-modem
        # partition, so construct a merged symlink view without copying or
        # modifying either read-only firmware partition.
        while IFS= read -r name; do
            name=${name%$'\r'}
            [[ -n "$name" ]] || continue
            ln -s "/data/local/tmp/crystal-radio-overlay/firmware/original/$name" \
                "$stage/firmware/merged/$name"
        done < <("${adb[@]}" shell 'ls /firmware/image' | tr -d '\r')
        while IFS= read -r name; do
            name=${name%$'\r'}
            [[ -n "$name" ]] || continue
            ln -sfn "/firmware-modem/image/$name" "$stage/firmware/merged/$name"
        done < <("${adb[@]}" shell 'ls /firmware-modem/image' | tr -d '\r')
        for path in mba.mdt modem.mdt; do
            [[ -L "$stage/firmware/merged/$path" ]] || {
                echo "Modem firmware is missing from /firmware-modem/image: $path" >&2
                exit 1
            }
        done

        "${adb[@]}" shell "mkdir -p '$remote/firmware/original'"
        "${adb[@]}" push "$stage/system" "$remote/" >/dev/null
        "${adb[@]}" push "$stage/firmware/merged" "$remote/firmware/" >/dev/null
        "${adb[@]}" shell "test -L '$remote/system/bin/sh' && test -x '$remote/system/bin/mksh'"
        "${adb[@]}" shell 'stop ril-daemon; stop qmuxd; stop rfs_access; stop rmt_storage; stop time_daemon'
        "${adb[@]}" shell "mount -o bind /firmware/image '$remote/firmware/original'"
        for mountpoint in "${mounts[@]}"; do
            case "$mountpoint" in
                /system/*) relative=${mountpoint#/system/}; source="$remote/system/$relative" ;;
                /firmware/image) source="$remote/firmware/merged" ;;
            esac
            "${adb[@]}" shell "mount -o bind '$source' '$mountpoint'"
        done
        "${adb[@]}" shell "mount | grep -q '$remote/system/bin on /system/bin'"
        "${adb[@]}" shell 'start rfs_access; start rmt_storage; start time_daemon; start qmuxd; start ril-daemon'
        echo "Radio overlay mounted for this boot. It is temporary: reboot or run '$0 rollback $serial' to remove it."
        ;;
    rollback)
        [[ $# -eq 2 ]] || usage
        "${adb[@]}" shell 'stop ril-daemon; stop qmuxd; stop rfs_access; stop rmt_storage; stop time_daemon'
        for mountpoint in "${mounts[@]}"; do
            "${adb[@]}" shell "umount '$mountpoint' 2>/dev/null || true"
        done
        "${adb[@]}" shell "umount '$remote/firmware/original' 2>/dev/null || true; umount /system/etc/firmware 2>/dev/null || true"
        "${adb[@]}" shell 'start ril-daemon'
        echo "Radio overlay removed. Staged files remain under $remote and are inert; reboot also removes all bind mounts."
        ;;
    *) usage ;;
esac
