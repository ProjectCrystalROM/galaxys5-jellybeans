# Project Crystal for Galaxy S5

A native CyanogenMod 10.2 / Android 4.3.1 reverse port for the Qualcomm Galaxy S5. SM-G900T (`kltetmo`) is the primary data-centric product. SM-G900V (`kltevzw`) shares the platform with separate radio and voice-capable product settings.

- [Build and source sync](docs/BUILD.md)
- [Extracted Galaxy S5 vendor snapshot](https://github.com/ProjectCrystalROM/proprietary_vendor_samsung_klte)
- [Historical sources and engineering decisions](docs/PORTING-RESEARCH.md)
- [CM9 feasibility assessment](docs/CM9-FEASIBILITY.md)
- [Proprietary libraries and ABI status](docs/BLOB-COMPATIBILITY.md)
- [Hardware status](docs/HARDWARE-COMPATIBILITY.md) and [variant status](docs/VARIANT-COMPATIBILITY.md)
- [Installation and recovery status](docs/INSTALLATION.md)

The SM-G900T physically boots to Setup Wizard and a usable home screen. After installing OTA `574dc9f24d` and factory resetting, the Phone process stayed up, carrier SMS arrived, and LTE packet data reached AT&T's captive billing portal after manual APN selection. Wi-Fi, Bluetooth discovery/pairing, and audio playback have also been physically observed; see the [hardware matrix](docs/HARDWARE-COMPATIBILITY.md) for what remains untested or broken. Automatic APN preselection is SIM/profile dependent and not assumed. The SM-G900V builds but still needs device validation.
