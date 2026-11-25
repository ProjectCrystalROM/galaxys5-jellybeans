#!/usr/bin/env bash
set -euo pipefail
rootfs=$(realpath -- "${1:?Usage: in-trusty.sh ROOTFS ANDROID_TREE COMMAND [ARG...]}")
tree=$(realpath -- "${2:?Pass the Android source root}")
shift 2
[[ -f "$rootfs/etc/lsb-release" && -f "$tree/build/envsetup.sh" ]]
if ! grep -qx 'DISTRIB_CODENAME=trusty' "$rootfs/etc/lsb-release"; then
    printf 'Expected an Ubuntu 14.04 root filesystem\n' >&2
    exit 1
fi
sudo unshare --mount --propagation private bash -e -c '
    rootfs=$1
    tree=$2
    uid=$3
    gid=$4
    shift 4
    mkdir -p "$rootfs/src" "$rootfs/tmp/crystal-home"
    chown "$uid:$gid" "$rootfs/tmp/crystal-home"
    mount --bind "$tree" "$rootfs/src"
    mount --bind /dev "$rootfs/dev"
    mount -t proc proc "$rootfs/proc"
    exec chroot --userspec="$uid:$gid" "$rootfs" /usr/bin/env -i HOME=/tmp/crystal-home \
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin LANG=C LC_ALL=C \
        JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64 \
        /bin/bash -c '\''cd /src && exec "$@"'\'' bash "$@"
' bash "$rootfs" "$tree" "$(id -u)" "$(id -g)" "$@"
