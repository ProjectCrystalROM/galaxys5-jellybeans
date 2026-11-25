# Galaxy S5 variant compatibility

| Area | SM-G900T `kltetmo` | SM-G900V `kltevzw` |
| --- | --- | --- |
| Shared source | CM10.2.0, S5 common Linux 3.4, S5 ramdisk and board data, JB Qualcomm display/audio/media | Same |
| Kernel configuration | `msm8974_sec_defconfig` + `msm8974pro_sec_klte_eur_defconfig` + `selinux_defconfig` | Same base, `msm8974pro_sec_klte_vzw_defconfig` variant |
| System and data partition sizes from CM11 | 2,621,440,000 and 12,669,926,400 bytes | 2,831,155,200 and 12,187,581,440 bytes |
| Build status | Kernel, boot, system, recovery and two engineering ZIPs compiled | Kernel, boot, system, recovery and a separate engineering ZIP compiled |
| Installer target | Accepts `kltetmo` or `klte` with a G900TUV bootloader | Separate `kltevzw` assertion |
| Product capability | Voice off, SMS on, handset UI, BasicSmsReceiver | Standard voice and SMS resources, Dialer and Mms |
| Telephony product | GSM/LTE preference, mode 9, CM APNs and retained Phone/TelephonyProvider/Stk | CDMA/LTE preference, mode 10, NV/RUIM settings |
| RIL differences | CM11 reference used `KlteRIL` and a GSM `libsec-ril.so` | CM11 reference used `SamsungQualcommRIL` and a separate target `libsec-ril.so` |
| Vendor inputs | Shared candidate inventory plus GSM radio/Bluetooth inventory | Shared candidate inventory plus separate radio, NFC and Bluetooth firmware |
| Hardware validation | Pending SM-G900T and compatible test recovery | Pending SM-G900V and CrystalBTS test access |

The initial installer identity is variant-specific. Recovery partition mappings and device assertions require comparison with each model's actual recovery environment. Modem firmware, bootloaders, EFS images and partition tables are outside the installer payload.

Native public-carrier voice, native emergency calls and an outgoing SMS UI are intentionally excluded from the T-Mobile product. It is unsuitable as a primary emergency-capable phone. IMS and VoLTE are outside scope for both variants. CDMA voice and EVDO on CrystalBTS remain in scope for Verizon.
