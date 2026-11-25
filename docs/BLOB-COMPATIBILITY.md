# Galaxy S5 proprietary component compatibility

The source tree carries file inventories and tooling. The ELF audit used locally downloaded historical samples from the pinned CM11 vendor archive at `80299199ecef3dfc99adbae45660de2b0b1ed21a`. The archive records unified GSM `klte`, shared `klte-common` and Verizon `kltevzw` separately. It gives source provenance for these ELF fingerprints. It does not establish the stock firmware build of every file or prove that each unified GSM file originated on a G900T. [Historical vendor source](https://github.com/TheMuppets/proprietary_vendor_samsung/tree/80299199ecef3dfc99adbae45660de2b0b1ed21a)

[ELF inventory](BLOB-ELF-INVENTORY.tsv) enumerates each examined binary's exact path, digest, architecture, direct dependencies and symbol counts. There are 282 ELF files across the three samples. Use `scripts/audit-blobs.sh` to reproduce full imported/exported symbol and version listings. Firmware payloads and APK resources require separate inspection. All extracted binaries are kept outside this Git repository.

| Component | Observed source / ABI | Variant and validation |
| --- | --- | --- |
| `vendor/lib/egl/libEGL_adreno.so` and associated Adreno stack | Shared CM11 archive. ARM ELF32. EGL needs `libgsl`, `libadreno_utils`, hardware and C libraries. Check KGSL firmware, ioctl sizes, native buffer handles and gralloc layout as a set. JB MDSS uses HWC 1.1. CM11 headers include HWC 1.3 fields. | Shared candidate. Static ELF inspection is complete. Device ABI checks inform the EGL choice. |
| `lib/libsec-ril.so`, `lib/libril.so`, `bin/rild` | The GSM and Verizon `libsec-ril.so` have different digests. They both require RIL utils, time service, QMI, Samsung native features and core libraries. CM10.2 RIL headers declare version 8 and CM11 declares 9. Disassembly of each archived `RIL_Init` resolves the returned callback tables to version 8. The tables are at virtual addresses `0x279010` (GSM) and `0x277010` (Verizon) in the exact archived binaries. JB exports `ril_nano_time` in `librilutils`. The CM11 GSM Java adapter consumes four extra retry counters per SIM application in card status. | Keep native JB `rild` and `libril` for initial source builds. Evaluate vendor RIL callbacks and parcel format before integrating a provider. No carrier or SMS success inferred from exports. |
| `vendor/lib/libacdbloader.so`, `libcsd-client.so`, calibration, audience | Shared archive. ACDB loader depends on `libaudcal`, `libacdbrtac`, `libadiertac`, and Android C/C++ libraries. The CM10.2 CAF ALSA path and CM11 S5 mixer paths require routing translation and card/ACDB verification. | Shared candidate. Playback and capture pending. |
| `lib/hw/camera.vendor.msm8974.so`, `libmmcamera_interface.so`, `mm-qcamera-daemon` | Shared CM11 camera stack. The camera HAL depends on `libcamera_client`, `libmmcamera_interface`, `libmmjpeg_interface`, `libvdis`, `libliveframework` and other libraries. Compare the S5 CM11 wrapper and Jelly Bean camera HAL structs before loading the vendor HAL. Keep camera EEPROM/sensor selection target-specific. | Shared candidate. No HAL wrapper port or runtime validation. |
| `lib/hw/sensors.msm8974.so`, GPS, FLP | Sensor HAL imports C logging/cutils/dynamic loading interfaces. GPS FLP requires a separate ABI audit. The GSM Qualcomm location APK declares minimum API 19, which prevents installation on API 18. | Sensor is a shared candidate. Location entries exist in both variant inventories. No runtime validation. |
| `bin/thermal-engine`, `libthermalioctl.so` | Shared CM11 archive. The daemon needs thermalioctl, `libqmi_cci`, `libqmi_common_so`, libcutils and libc. It imports `__strlen_chk`, which has a CM10.2 Bionic implementation. | Shared candidate. Compare transitive dependencies, board sensor configuration and observed safe behavior before sustained hardware work. |
| BCM firmware and NFC | GSM and Verizon inventories name different BCM4354 firmware revisions. Verizon includes a renamed prebuilt NFC HAL. | Variant candidates. Driver and service validation pending. |

The shared and per-variant CM11 inventories have a corresponding file for every listed destination in the vendor archive, including the records with an explicit source-to-destination rename. The files are only the starting inventory. For example, `init.qcom.rc` declares a `netmgrd` service, but the archived S5 inventories do not contain that executable. Compare the target firmware and historical source for that service. D801 and VS980 explicitly list it in their own `proprietary-blobs.txt`.

No compatibility shims have been verified. A resolved dynamic symbol alone cannot justify a shim or prove the layout of a struct crossing the ABI. Compare C/C++ exports, each library's transitive dependency closure, linker namespaces relevant to JB, and the kernel device-node and ioctl contracts before assigning a library to the boot image.

## Static link checks against compiled Jelly Bean libraries

A transitive `DT_NEEDED` and strong dynamic-symbol check used the SM-G900T engineering build's Bionic, ICU and framework libraries together with the archived shared and variant vendor samples.

- All tested names resolved for `thermal-engine`, `libEGL_adreno.so`, `libGLESv2_adreno.so`, `sensors.msm8974.so` and both variants' `libsec-ril.so`, `qmuxd` and `rmt_storage`. The scan used the compiled Jelly Bean provider when the archive contained an identically named core library. Relocation and loader-order checks, HAL layout, kernel ABI and device behavior remain separate validation steps.
- The camera closure had 16 unresolved strong symbols. Twelve are Samsung `CameraParameters` constants for dynamic range control, phase AF and real-time HDR. The four remaining functions are `u_digit_51`, `u_errorName_51`, `utext_close_51`, and `utext_openUChars_51`. The CM10.2 system builds ICU 50.1.1. Its existing older ICU aliases give a compatibility pattern to investigate after comparing the ICU 50/51 `UText` types. The CM11 source supplies the exact strings for the camera constants. [CM11 CameraParameters](https://github.com/CyanogenMod/android_frameworks_av/blob/afc7d8c516a4cff4d7080a444033c06802a60de8/camera/CameraParameters.cpp)

## Offline extraction

Use Python 3.11 or newer and supply the model's own unpacked system directory, with entries such as `lib`, `vendor` and `etc` directly beneath it. Record the exact firmware build in the command. The shared inventory can be populated by the G900T input. Confirm reuse on G900V file-by-file.

```bash
scripts/extract-blobs.py kltetmo /path/to/g900t/system /path/to/cm102 \
  --firmware G900TUVU1BNH5 --common
scripts/extract-blobs.py kltevzw /path/to/g900v/system /path/to/cm102 \
  --firmware G900VVRU1ANE9
scripts/audit-blobs.sh /path/to/cm102/vendor/samsung/kltetmo/proprietary > g900t-elf.txt
```

For a smaller boot and display trial, pass `--profile graphics-thermal` when extracting. This profile includes the shared Adreno EGL components, the A330 firmware, the thermal daemon, and the matching variant's transitive QMI dependencies. The profile has no radio executable or camera HAL. Prepare the shared entries once using `--common`. The variant entries remain separate.

The example build identifiers are drawn from the CM11 device configuration. Use the identifier of the actual input image. An incomplete or mismatched system dump can fail strict extraction. The script reports missing files, preserves CM device-tree filename mappings, and writes hashes and makefiles for review. The generated makefiles initially reflect the candidate inventory. Resolve overlapping package providers such as `rild` and `libril.so`, verify APK API requirements, and review ELF dependencies before attempting a runtime image with them.
