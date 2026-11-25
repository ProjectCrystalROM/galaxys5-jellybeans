#!/usr/bin/env bash
set -euo pipefail
variant=${1:?Usage: build-kernel.sh kltetmo|kltevzw [JOBS]}
case "$variant" in
    kltetmo) carrier=eur ;;
    kltevzw) carrier=vzw ;;
    *) printf 'Unknown variant %s\n' "$variant" >&2; exit 2 ;;
esac
kernel=kernel/samsung/klte
toolchain=$PWD/prebuilts/gcc/linux-x86/arm/arm-eabi-4.7/bin/arm-eabi-
output=$PWD/out/kernel-$variant
test -x "${toolchain}gcc"
test -f "$kernel/arch/arm/configs/msm8974_sec_defconfig"
mkdir -p -- "$output"
make -C "$kernel" ARCH=arm CROSS_COMPILE="$toolchain" O="$output" \
    VARIANT_DEFCONFIG="msm8974pro_sec_klte_${carrier}_defconfig" \
    SELINUX_DEFCONFIG=selinux_defconfig msm8974_sec_defconfig
make -C "$kernel" ARCH=arm CROSS_COMPILE="$toolchain" O="$output" -j"${2:-8}" zImage dtbs
