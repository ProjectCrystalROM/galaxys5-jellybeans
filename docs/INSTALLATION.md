# Installation and recovery status

The separate SM-G900T and SM-G900V engineering recovery ZIPs passed static format, variant and partition checks. The SM-G900T boots into Android 4.3.1 and has been tested with target Samsung RIL binaries, Wi-Fi firmware, and audio routing. The latest tested T-Mobile OTA is `574dc9f24d`; after a factory reset, incoming carrier SMS and LTE packet data after manual APN selection were confirmed. Remaining validation is listed in the hardware matrix.

The built recovery uses a larger 23 × 41 pixel Roboto font. Volume Up and Down move the highlight, Power and Home confirm, and Back returns to the previous menu. Recovery has booted on the G900T; the ROM installer was tested from the built recovery.

The SM-G900T now boots through Setup Wizard and reports `sys.boot_completed=1`. Charge LED and capacitive-button lighting work, including the button timeout. The first boot needed USB debugging enabled manually; ADB then forwarded and authenticated. Although the product requests ADB in its USB configuration, CM10.2's Developer options ADB setting still controls whether the USB function comes up. The authorized host key remains required (`ro.adb.secure=1`). Root access is now enabled for ADB, and `adb root` succeeds; interactive `su` requests are controlled separately.

Earlier boot logs documented the initial missing-vendor failures; those are superseded by later bring-up. Current logs are not checked in because they can contain subscriber and device identifiers. The non-identifying findings and validation state are maintained in `docs/HARDWARE-COMPATIBILITY.md` and `diagnostics/`.

For a future device session, record the model, current firmware build, recovery version, partition names, recovery device identifier and current ability to restore a model-matching backup. Copy the recovery backup and important data off the device. Use separate, validated recovery packages for `kltetmo` and `kltevzw`. The revised SM-G900T installer accepts the generic `klte` recovery label when `ro.bootloader` identifies a G900TUV bootloader. The original SM-G900T ZIP requires `kltetmo`. The Verizon installer requires `kltevzw`. Bootloader unlock is outside the project.

The generated recovery scripts target boot and system. When an approved device session begins, select the model-matching ZIP in the existing recovery and save its recovery log before rebooting. Keep the device's recovery, modem firmware, bootloader, EFS and partition table intact. Verify the package manifest and updater script before installation. During the first device session, verify charge reporting and thermal protections before sustained testing. Stop the session on a thermal or charging fault.

If a test boot fails, return to the device's existing recovery, capture `/proc/last_kmsg` when available, and restore the backed-up boot and system images with that recovery. Preserve unrelated partitions and use the model's backup procedures for data. From a device that exposes ADB, use `scripts/collect-boot-logs.sh NEW_LOG_DIRECTORY` to collect the available read-only diagnostics. Radio and system logs can contain device and subscriber identifiers, so review them before sharing.

The T-Mobile product excludes native carrier and emergency calls and is unsuitable as a primary emergency-capable phone.
