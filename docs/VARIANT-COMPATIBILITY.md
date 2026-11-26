# Galaxy S5 variant compatibility

| Area | SM-G900T `kltetmo` | SM-G900V `kltevzw` |
| --- | --- | --- |
| Shared source | CM10.2.0, S5 common Linux 3.4, S5 ramdisk and board data, JB Qualcomm display/audio/media | Same |
| Kernel configuration | `msm8974_sec_defconfig` + `msm8974pro_sec_klte_eur_defconfig` + `selinux_defconfig` | Same base, `msm8974pro_sec_klte_vzw_defconfig` variant |
| System and data partition sizes from CM11 | 2,621,440,000 and 12,669,926,400 bytes | 2,831,155,200 and 12,187,581,440 bytes |
| Build status | Kernel, boot, system, recovery and radio-compatibility OTA compiled | Kernel, boot, system, recovery and a separate engineering ZIP compiled |
| Installer target | Accepts `kltetmo` or `klte` with a G900TUV bootloader | Separate `kltevzw` assertion |
| Product capability | Voice off, SMS on, handset UI, BasicSmsReceiver | Standard voice and SMS resources, Dialer and Mms |
| Telephony product | GSM/LTE preference, mode 9, CM APNs and retained Phone/TelephonyProvider/Stk | CDMA/LTE preference, mode 10, NV/RUIM settings |
| RIL differences | NCH-matched `rild`/`libril`/`libsec-ril`; API 18 includes target-hardware CM11 `KlteRIL`. SIM and modem initialize, LTE registration and incoming SMS are physically confirmed. | Separate target `libsec-ril.so`; CM10.2 integration pending |
| Vendor inputs | Shared candidate inventory plus GSM radio/Bluetooth inventory | Shared candidate inventory plus separate radio, NFC and Bluetooth firmware |
| Hardware validation | Boots to launcher and `sys.boot_completed=1`. Charge LED and capacitive key lighting work. Wi-Fi scan, association and web access, Bluetooth scan/pair, built-in audio playback and notification audio have been observed. LTE registration and incoming SMS work; after factory reset, selecting the APN manually restored packet data to AT&T's captive billing portal. A2DP/PAN packet flow, camera, sensors, GPS, capture, suspend and clean-boot persistence still need validation. | Pending SM-G900V and CrystalBTS test access |

The initial installer identity is variant-specific. Recovery partition mappings and device assertions require comparison with each model's actual recovery environment. Modem firmware, bootloaders, EFS images and partition tables are outside the installer payload.

Native public-carrier voice, native emergency calls and an outgoing SMS UI are intentionally excluded from the T-Mobile product. It is unsuitable as a primary emergency-capable phone. IMS and VoLTE are outside scope for both variants. CDMA voice and EVDO on CrystalBTS remain in scope for Verizon.
