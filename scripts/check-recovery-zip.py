#!/usr/bin/env python3
"""Inspect a Project Crystal CM10.2 recovery package on the host."""
import argparse
import gzip
import hashlib
from pathlib import Path
import re
import struct
from zipfile import BadZipFile, ZipFile

MODELS = {"kltetmo": "SM-G900T", "kltevzw": "SM-G900V"}
RECOVERY = "META-INF/com/google/android/"


def require(condition, message):
    if not condition:
        raise ValueError(message)


def check_boot(image):
    require(48 <= len(image) <= 13631488, "Boot image exceeds the S5 size limit")
    magic, kernel, _, ramdisk, address, second, _, tags, page, dt, _ = (
        struct.unpack_from("<8s10I", image)
    )
    require(magic == b"ANDROID!" and page == 2048, "Unexpected boot header")
    require((address, tags) == (0x02000000, 0x01E00000), "Unexpected ramdisk or tags address")
    require(kernel and ramdisk and dt >= 12 and not second, "Missing kernel, ramdisk or DT table")
    require(image[page + 0x24 : page + 0x28] == b"\x18\x28\x6f\x01", "ARM zImage magic missing")
    ramdisk_offset = page + ((kernel + page - 1) // page) * page
    dt_offset = ramdisk_offset + ((ramdisk + page - 1) // page) * page
    require(dt_offset + dt <= len(image), "Truncated device tree image")
    qcdt = struct.unpack_from("<4sII", image, dt_offset)
    require(qcdt == (b"QCDT", 1, 7), "Unexpected Qualcomm device tree table")
    ramdisk_data = gzip.decompress(image[ramdisk_offset : ramdisk_offset + ramdisk])
    for name in (b"init", b"init.qcom.rc", b"fstab.qcom", b"ueventd.qcom.rc", b"sepolicy"):
        require(name + b"\0" in ramdisk_data, f"Missing ramdisk entry {name.decode()}")


def check_archive(path, variant):
    with ZipFile(path) as archive:
        require(archive.testzip() is None, "Invalid ZIP entry checksum")
        names = set(archive.namelist())
        script = archive.read(RECOVERY + "updater-script").decode()
        device_assert = re.findall(r'getprop\("ro\.(?:product\.device|build\.product)"\)\s*==\s*"([^"]+)"', script)
        if variant == "kltetmo":
            require(set(device_assert) in ({"kltetmo"}, {"kltetmo", "klte"}),
                    "Updater device assertion disagrees with the variant")
            if "klte" in device_assert:
                guard = ('assert(getprop("ro.product.device") == "kltetmo" || '
                         'getprop("ro.build.product") == "kltetmo" || '
                         'is_substring("G900TUV", getprop("ro.bootloader")));')
                first_write = script.index('mount(')
                require(guard in script[:first_write], "Missing G900T guard before partition access")
        else:
            require(set(device_assert) == {variant}, "Updater device assertion disagrees with the variant")
        block_paths = re.findall(r'["\'](/dev/block/[^"\']+)["\']', script)
        expected = {f"/dev/block/platform/msm_sdcc.1/by-name/{p}" for p in ("boot", "system")}
        require(set(block_paths) == expected, "Unexpected updater partition references")
        image_payloads = {name for name in names if "/" not in name and name.endswith(".img")}
        require(image_payloads == {"boot.img"}, "Unexpected top-level image payload")

        props = dict(
            line.split("=", 1)
            for line in archive.read("system/build.prop").decode().splitlines()
            if "=" in line and not line.startswith("#")
        )
        expected_props = {
            "ro.build.version.sdk": "18",
            "ro.build.version.release": "4.3.1",
            "ro.product.device": variant,
            "ro.product.model": MODELS[variant],
        }
        require(all(props.get(k) == v for k, v in expected_props.items()), "Wrong Android version or device")
        require(props.get("ro.cm.version", "").startswith("10.2"), "Wrong CyanogenMod version")
        for path in (
            RECOVERY + "update-binary",
            "system/app/Phone.apk",
            "system/app/Contacts.apk",
            "system/app/ContactsProvider.apk",
            "system/app/TelephonyProvider.apk",
            "system/bin/dalvikvm",
            "system/bin/rild",
            "system/lib/libc.so",
            "system/lib/libdvm.so",
            "system/etc/apns-conf.xml",
        ):
            require(path in names, f"Missing {path}")
        voice_apps = {"system/app/Dialer.apk", "system/app/Mms.apk"}
        if variant == "kltetmo":
            require("system/app/BasicSmsReceiver.apk" in names, "Missing BasicSmsReceiver")
            require(not voice_apps.intersection(names), "Unexpected Dialer or Mms")
        else:
            require(voice_apps.issubset(names), "Missing Verizon Dialer or Mms")
            require("system/app/BasicSmsReceiver.apk" not in names, "Unexpected Verizon receiver package")
        check_boot(archive.read("boot.img"))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("variant", choices=tuple(MODELS))
    parser.add_argument("archive", type=Path)
    args = parser.parse_args()
    try:
        check_archive(args.archive, args.variant)
    except (BadZipFile, ValueError, KeyError, OSError) as error:
        parser.exit(1, f"{args.archive}: {error}\n")
    with args.archive.open("rb") as stream:
        digest = hashlib.file_digest(stream, "sha256").hexdigest()
    print(f"{digest}  {args.archive}")


if __name__ == "__main__":
    main()
