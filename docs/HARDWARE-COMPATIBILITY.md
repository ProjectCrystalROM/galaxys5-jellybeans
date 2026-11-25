# Hardware compatibility

There is no physical validation for either target. “Configured” means a source configuration or integration entry exists. “Pending” means a required implementation or compatibility check is still open.

| Subsystem | Checkout status | Physical evidence still needed |
| --- | --- | --- |
| Kernel and board DT | Both S5 kernels and QCDT images compiled | Bootloader accepts image, kernel initializes board |
| Init, partitions, early ADB | S5 ramdisk and SELinux policy assembled in the G900T boot image | Init logs, partition mounts, ADB and last_kmsg |
| Launcher and Settings | G900T system image and recovery ZIP verified statically | SurfaceFlinger, Zygote, System Server, UI and handset settings |
| Display/touch/buttons | S5 kernel and target keymaps included | Panel, touchscreen, physical buttons and capacitive keys |
| Accelerated graphics and media | JB MDSS/V4L2 candidates selected | ION/HWC/codec ABI, rendering and hardware decode |
| Internal, microSD, USB, MTP | Jelly Bean FUSE syntax and vold records configured | Storage access, USB functions and MTP transfer |
| Wi-Fi and Bluetooth | Target configuration and candidate firmware inventories | Scan, connection, transfer, suspend/resume |
| Audio | JB CAF and S5 routing selected | Speaker/headset playback, microphone recording and internet voice |
| GPS, sensor, camera | Candidate inventories available, integration pending | GNSS fix, sensor event delivery, photo/video capture |
| Charge, thermal, power | S5 kernel protections and target thermal configuration included | Charging/temperature readings, daemon compatibility, charge limits, suspend and power behavior |
| G900T LTE | Variant properties and APN configuration present, RIL ABI pending | SIM read, attach, APN, routed traffic, reconnect and airplane mode |
| G900T incoming SMS | BasicSmsReceiver packaged with classes.dex and SDK 18. Voice disabled and SMS enabled in compiled resources | Real incoming single/multipart messages and post-reboot delivery, independent of LTE traffic |
| G900V CDMA/EVDO/LTE | Variant properties present, RIL ABI pending | CrystalBTS registration, voice, SMS, EVDO and separate LTE test |
| Fingerprint, heart rate, Samsung apps | Outside initial scope | — |

When an approved image is available, first establish kernel → init → mounts → ADB → native services → SurfaceFlinger → Zygote → System Server → boot animation → launcher and Settings. Capture failures at each boundary. Follow with charging and thermal checks before sustained graphics or radio tests.
