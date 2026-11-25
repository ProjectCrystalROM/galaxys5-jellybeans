# Galaxy S5 proprietary component compatibility

The source tree carries file inventories and tooling. The ELF audit used locally downloaded historical samples from the pinned CM11 vendor archive at `80299199ecef3dfc99adbae45660de2b0b1ed21a`. The archive records unified GSM `klte`, shared `klte-common` and Verizon `kltevzw` separately. It gives source provenance for these ELF fingerprints. It does not establish the stock firmware build of every file or prove that each unified GSM file originated on a G900T. [Historical vendor source](https://github.com/TheMuppets/proprietary_vendor_samsung/tree/80299199ecef3dfc99adbae45660de2b0b1ed21a)

[ELF inventory](BLOB-ELF-INVENTORY.tsv) enumerates each examined binary's exact path, digest, architecture, direct dependencies and symbol counts. There are 282 ELF files across the three samples. Use `scripts/audit-blobs.sh` to reproduce full imported/exported symbol and version listings. Firmware payloads and APK resources require separate inspection. All extracted binaries are kept outside this Git repository.

| Component | Observed source / ABI | Variant and validation |
| --- | --- | --- |
| `vendor/lib/egl/libEGL_adreno.so` and associated Adreno stack | Shared CM11 archive. ARM ELF32. EGL needs `libgsl`, `libadreno_utils`, hardware and C libraries. Check KGSL firmware, ioctl sizes, native buffer handles and gralloc layout as a set. JB MDSS uses HWC 1.1; CM11 headers include HWC 1.3 fields. | Shared candidate. Static ELF inspection complete; choose a JB or target EGL set after device ABI checks. |
| `lib/libsec-ril.so`, `lib/libril.so`, `bin/rild` | The GSM and Verizon `libsec-ril.so` have different digests. They both require RIL utils, time service, QMI, Samsung native features and core libraries. CM10.2 RIL headers declare version 8 and CM11 declares 9. JB exports `ril_nano_time` in `librilutils`. The CM11 GSM Java adapter consumes four extra retry counters per SIM application in card status. | Keep native JB `rild` and `libril` for initial source builds. Evaluate vendor RIL callbacks and parcel format before integrating a provider. No carrier or SMS success inferred from exports. |
| `vendor/lib/libacdbloader.so`, `libcsd-client.so`, calibration, audience | Shared archive. ACDB loader depends on `libaudcal`, `libacdbrtac`, `libadiertac`, and Android C/C++ libraries. The CM10.2 CAF ALSA path and CM11 S5 mixer paths require routing translation and card/ACDB verification. | Shared candidate. Playback and capture pending. |
| `lib/hw/camera.vendor.msm8974.so`, `libmmcamera_interface.so`, `mm-qcamera-daemon` | Shared CM11 camera stack. The camera HAL depends on `libcamera_client`, `libmmcamera_interface`, `libmmjpeg_interface`, `libvdis`, `libliveframework` and other libraries. Compare the S5 CM11 wrapper and Jelly Bean camera HAL structs before loading the vendor HAL. Keep camera EEPROM/sensor selection target-specific. | Shared candidate. No HAL wrapper port or runtime validation. |
| `lib/hw/sensors.msm8974.so`, GPS, FLP | Sensor HAL imports C logging/cutils/dynamic loading interfaces. GPS FLP and Qualcomm location APK require a separate API audit. | Sensor is a shared candidate. Location entries exist in both variant inventories. No runtime validation. |
| `bin/thermal-engine`, `libthermalioctl.so` | Shared CM11 archive. The daemon needs thermalioctl, `libqmi_cci`, `libqmi_common_so`, libcutils and libc. It imports `__strlen_chk`, which has a CM10.2 Bionic implementation. | Shared candidate. Compare transitive dependencies, board sensor configuration and observed safe behavior before sustained hardware work. |
| BCM firmware and NFC | GSM and Verizon inventories name different BCM4354 firmware revisions. Verizon includes a renamed prebuilt NFC HAL. | Variant candidates. Driver and service validation pending. |

The shared and per-variant CM11 inventories have a corresponding file for every listed destination in the vendor archive, including the records with an explicit source-to-destination rename. The files are only the starting inventory. For example, `init.qcom.rc` declares a `netmgrd` service, but the archived S5 inventories do not contain that executable. Compare the target firmware and historical source for that service. D801 and VS980 explicitly list it in their own `proprietary-blobs.txt`.

No compatibility shims have been verified. A resolved dynamic symbol alone cannot justify a shim or prove the layout of a struct crossing the ABI. Compare C/C++ exports, each library's transitive dependency closure, linker namespaces relevant to JB, and the kernel device-node and ioctl contracts before assigning a library to the boot image.

## Offline extraction

Supply the model's own unpacked system directory, with entries such as `lib`, `vendor` and `etc` directly beneath it. Record the exact firmware build in the command. The shared inventory can be populated by the G900T input. Confirm reuse on G900V file-by-file.

```bash
scripts/extract-blobs.py kltetmo /path/to/g900t/system /path/to/cm102 \
  --firmware G900TUVU1BNH5 --common
scripts/extract-blobs.py kltevzw /path/to/g900v/system /path/to/cm102 \
  --firmware G900VVRU1ANE9
scripts/audit-blobs.sh /path/to/cm102/vendor/samsung/kltetmo/proprietary > g900t-elf.txt
```

The example build identifiers are drawn from the CM11 device configuration. Use the identifier of the actual input image. An incomplete or mismatched system dump can fail strict extraction. The script reports missing files, preserves CM device-tree filename mappings, and writes hashes and makefiles for review. The generated makefiles initially reflect the candidate inventory. Resolve overlapping package providers such as `rild` and `libril.so`, verify APK API requirements, and review ELF dependencies before attempting a runtime image with them.
