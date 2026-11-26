# CM9 feasibility: Galaxy S5 (`klte`)

## Assessment

**A genuine CM9.1 / Android 4.0.4 port is technically feasible, but a complete hardware-enabled port is a high-risk reverse port.** The S5's Linux 3.4 kernel, boot chain, partition map, and board support are reusable foundations. The framework can remain native ICS, including Dalvik, Bionic, and Holo. The hard part is making a 2014 MSM8974AC/Adreno 330 device work with an ICS userspace whose Qualcomm display and audio code predates MSM8974, while the available S5 proprietary stack was built for KitKat.

There is no verified official CM9 device tree or kernel branch for `klte`. The checked CyanogenMod S5 device and kernel repositories expose CM11-era refs. CM9 Qualcomm source does exist for older Samsung devices, but it is not a drop-in hardware platform for the S5. The CM10.2 Galaxy S5 work should remain the hardware reference; donor CM9 code is useful for ICS interfaces and product patterns only.

## What is recoverable

- **Native ICS base:** CyanogenMod's `cm-9.1.0` manifest and framework refs are still available. CM9.1 is the practical baseline for an Android 4.0.4 implementation.
- **S5 board and kernel:** The existing CM11 S5 device tree and Linux 3.4 kernel provide real target board support. Reuse their boot image format, partition definitions, device nodes, firmware loading, and board-specific kernel configuration, then adapt the ramdisk and userspace services to ICS.
- **Samsung Qualcomm ICS reference:** CM9-era `hercules` and `skyrocket` trees demonstrate Samsung/Qualcomm ICS integration. They use MSM8660 and Adreno 220, so their init, partition, and Samsung conventions are useful; their kernel, graphics, audio, and blobs are not S5 substitutes.
- **Krait ICS reference:** HTC's `evita` and `msm8960-common` ICS trees provide an independent Krait Qualcomm integration example. MSM8960/Adreno 225 is a generation behind the S5's MSM8974AC/Adreno 330.
- **Current proof from Crystal:** The project has already brought up the S5 with real CM10.2 userspace and adapted the target CM11 RIL to API 18. This supports the feasibility of a native Jelly Bean port, but does not prove that those API adaptations or vendor interfaces can be moved back another two Android API levels to ICS/API 15.

## Main compatibility risks

| Area | Finding | Risk |
| --- | --- | --- |
| Boot and kernel | The target Linux 3.4 kernel and S5 boot packaging are reusable. The kernel does not require replacing ICS Bionic or framework code. Ramdisk service names, permissions, and init behavior still need an ICS adaptation. | Moderate |
| Framework and product | A pinned CM9.1 source base provides real ICS framework, Dalvik, Bionic, and Holo. The data-centric T-Mobile product can be expressed with API-15 framework overlays and product package selection. | Low to moderate |
| Graphics | CM9.1's Qualcomm display repository has generic gralloc/HWC components and optional ION allocation, but no explicit MSM8974 target selection. Its hardware composer and graphics contracts predate the S5's KitKat vendor stack. The S5's Adreno 330 libraries must be checked against ICS Bionic, `libui`, `libhardware`, SurfaceFlinger, buffer handles, and the S5 kernel's KGSL/MDSS interfaces. A software-rendered first boot is realistic; hardware acceleration is the largest blocker. | Very high |
| Audio | The CM9.1 Qualcomm media tree's audio makefile selects legacy `msm8660`, `msm7x30`, `msm7x27a`, and `qsd8k` implementations; it has no MSM8974 audio target. Project Crystal's working CM10.2 audio changes are a better S5 reference, but must be ported to ICS audio HAL and policy interfaces. The S5 codec/UCM and sound-card readiness behavior remain device-specific. | High |
| Radio and SMS | Keep the S5 NCH modem/RIL binaries and port the proven `KlteRIL` parsing, APN schema columns, and null-MVNO handling to API 15. CM9.1 has an older telephony/RIL framework surface, so compilation and request/response compatibility need explicit proof. LTE data and incoming SMS are plausible targets; APN profile selection remains SIM/plan dependent. | High |
| Wi-Fi and Bluetooth | The S5 kernel drivers, firmware, NVRAM, and target vendor files are the relevant inputs. Init, supplicant control sockets, framework service behavior, and Bluedroid APIs differ across ICS and Jelly Bean; copy the known S5 setup selectively and revalidate. | Moderate to high |
| Camera and sensors | No S5 ICS vendor stack is available in the checked source set. KitKat libraries may depend on newer framework symbols and metadata contracts. Camera is likely to require significant ABI work; sensors are narrower but still need API and kernel-node checks. | Very high for camera; high for sensors |
| Verizon | No S5 CM9 `kltevzw` tree was found. Preserve a separate product and RIL path. CDMA 1x/EVDO needs a matching ICS-era CDMA donor and independent modem validation; the T-Mobile plan is not sufficient evidence. | Very high / unproven |
| Build system | The CM9.1 source line is available, but the current Trusty/JDK 7 build container was prepared for CM10.2. CM9's host-tool requirements have not been established here. | Moderate, host-side |

The Qualcomm source comparison is concrete: the CM9.1 audio makefile enumerates only older platform implementations, while CM10.2's MSM8974 code is a later donor. The CM9.1 display code has an ION path, which is encouraging for memory allocation, but that alone does not establish S5 MDSS, HWC, or Adreno compatibility.

## Recommended next engineering step

Do not fork the CM10.2 tree or replace its current milestone. Start an isolated CM9.1 checkout pinned to the manifest below and use it for a source-only compatibility spike:

1. Reuse the S5 kernel, boot packaging, partition map, and device-specific init data; change only what ICS init and services require.
2. Build a native CM9.1 system and reach ADB/init first. Use software rendering to separate framework boot from graphics bring-up.
3. Audit each S5 KitKat blob against API-15 libraries and HAL structs. Start with gralloc/HWC and audio, which decide whether an interactive system is practical.
4. Port the S5 `KlteRIL` and the provider/APN fixes against CM9 telephony. Validate SIM, LTE packet data, and incoming SMS independently.
5. Keep `kltetmo` data-centric overlays separate from `kltevzw`; assess CDMA only after identifying a compatible ICS-era CDMA reference.

**Go/no-go gate:** proceed beyond a bootable software-rendered prototype only if the S5 graphics path can be made to initialize without replacing the ICS framework or Bionic wholesale. If that requires importing a KitKat framework/runtime stack, it would no longer meet the native CM9 objective.

## Verified historical source refs

Refs below were checked with `git ls-remote` and shallow-cloned on 2026-11-26. The named branch hashes are the exact commits to use for comparison; do not substitute current default branches.

| Repository | Ref and commit | Use |
| --- | --- | --- |
| [CyanogenMod/android](https://github.com/CyanogenMod/android/tree/fd173ae94bb896d1d0793a4284a205c12c86dd30) | `cm-9.1.0` — `fd173ae94bb896d1d0793a4284a205c12c86dd30` | CM9.1 manifest baseline |
| [CyanogenMod/android_frameworks_base](https://github.com/CyanogenMod/android_frameworks_base/tree/10bab68dadba43f5f33c8666c30ae272c35a178e) | `cm-9.1.0` — `10bab68dadba43f5f33c8666c30ae272c35a178e` | ICS framework and HWC consumers |
| [CyanogenMod/android_hardware_qcom_display](https://github.com/CyanogenMod/android_hardware_qcom_display/tree/d1b89cee24c0b4e72dff6fcc6e7406076c2d02ff) | `cm-9.1.0` — `d1b89cee24c0b4e72dff6fcc6e7406076c2d02ff` | ICS gralloc/HWC/ION starting point |
| [CyanogenMod/android_hardware_qcom_media](https://github.com/CyanogenMod/android_hardware_qcom_media/tree/cb2e5b898d2ace7485d5c518efbf5898ccbd3cd4) | `cm-9.1.0` — `cb2e5b898d2ace7485d5c518efbf5898ccbd3cd4` | Legacy Qualcomm audio/media implementation inventory |
| [CyanogenMod/android_hardware_qcom_gps](https://github.com/CyanogenMod/android_hardware_qcom_gps/tree/9f8ad0824da8c1e4a2095af88e8242313e13caaa) | `cm-9.1.0` — `9f8ad0824da8c1e4a2095af88e8242313e13caaa` | ICS Qualcomm GPS starting point |
| [CyanogenMod/android_device_samsung_hercules](https://github.com/CyanogenMod/android_device_samsung_hercules/tree/d035f596f996d394243d9280ac9ecdd01d39d6af) | `ics` — `d035f596f996d394243d9280ac9ecdd01d39d6af` | Samsung Qualcomm ICS device conventions |
| [CyanogenMod/android_device_samsung_skyrocket](https://github.com/CyanogenMod/android_device_samsung_skyrocket/tree/6e92b76e976400850211013a27507a4c76c07e54) | `ics` — `6e92b76e976400850211013a27507a4c76c07e54` | Samsung Qualcomm ICS device conventions |
| [CyanogenMod/android_kernel_samsung_msm8660-common](https://github.com/CyanogenMod/android_kernel_samsung_msm8660-common/tree/7825fc673da5c780daa52f00eac5f593837eb684) | `ics` — `7825fc673da5c780daa52f00eac5f593837eb684` | Samsung ICS kernel comparison only; not S5 kernel candidate |
| [CyanogenMod/android_device_htc_evita](https://github.com/CyanogenMod/android_device_htc_evita/tree/d65ebc1e69d267317786506123015e52b7c95e31) | `ics` — `d65ebc1e69d267317786506123015e52b7c95e31` | Krait/MSM8960 ICS comparison |
| [CyanogenMod/android_device_htc_msm8960-common](https://github.com/CyanogenMod/android_device_htc_msm8960-common/tree/349321a13153fb5367f5412d26d5c46746c8568b) | `ics` — `349321a13153fb5367f5412d26d5c46746c8568b` | Krait/MSM8960 board configuration |
| [CyanogenMod/android_device_samsung_klte](https://github.com/CyanogenMod/android_device_samsung_klte/tree/c5a0e62e32081e7029e32e244ce1ccf30e4f37a8) | `cm-11.0` — `c5a0e62e32081e7029e32e244ce1ccf30e4f37a8` | Actual S5 target hardware; no CM9 branch exposed |
| [CyanogenMod/android_kernel_samsung_klte](https://github.com/CyanogenMod/android_kernel_samsung_klte/tree/ddd87888415168bb105e531dd1813c0f9b4655db) | `cm-11.0` — `ddd87888415168bb105e531dd1813c0f9b4655db` | Actual S5 Linux 3.4 kernel; no CM9 branch exposed |
| [CyanogenMod/android_device_lge_d801](https://github.com/CyanogenMod/android_device_lge_d801/tree/c020cf9eee95409c242aefba9522423c5db5f9b4) | `cm-10.2` — `c020cf9eee95409c242aefba9522423c5db5f9b4` | MSM8974-era Jelly Bean comparison, not an ICS donor |

No CM9 branch was returned for the S5 device/kernel or CM9.1 audio repository. The CM9.1 references above were verified; historical buildability, vendor binary compatibility, and physical S5 behavior remain untested.
