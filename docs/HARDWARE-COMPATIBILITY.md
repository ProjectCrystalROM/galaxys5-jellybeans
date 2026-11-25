# Hardware compatibility

The SM-G900T now reaches `sys.boot_completed=1` and Setup Wizard. This is an early boot milestone, not a declaration that the hardware is functional. “Configured” means a source configuration or integration entry exists. “Pending” means a required implementation or compatibility check is still open.

| Subsystem | Checkout status | Physical evidence still needed |
| --- | --- | --- |
| Kernel and board DT | Both S5 kernels and QCDT images compiled | Bootloader accepts image, kernel initializes board |
| Recovery | Original image booted in preliminary device testing. Updated font and keys verified at build level | Check readability and physical button handling |
| Init, partitions, ADB | G900T reaches completed Android boot. USB debugging had to be enabled manually; the host then authenticated and ADB works. `adb root` is currently disabled by the device's Root access setting. | Verify ADB behavior on cold boot; enable “Apps and ADB” in Developer options for root diagnostics |
| Launcher and Settings | G900T reaches Setup Wizard; initial services and UI are available | Confirm sustained UI stability and usable Settings |
| Display/touch/buttons | Display reaches Setup Wizard. Charge LED and capacitive-button lighting, including timeout, physically work | Touchscreen, physical buttons, and full UI interaction |
| Accelerated graphics and media | JB MDSS/V4L2 candidates selected | ION/HWC/codec ABI, rendering and hardware decode |
| Internal, microSD, USB, MTP | USB ADB works after manually enabling USB debugging and authorizing the host | Internal and microSD access, cold-boot USB behavior, MTP transfer |
| Wi-Fi | G900T cannot use Wi-Fi yet. Boot log: `softap fwreload wlan0 STA` returns 501, then `wpa_supplicant` cannot unlink the existing `@android:wpa_wlan0` control socket and fails initialization | Inspect firmware/driver state and supplicant socket ownership with root diagnostics; scan and connect |
| Bluetooth | G900T Bluetooth turns on and scans. Pairing and audio path not tested | Pairing, connection, audio, transfer, suspend/resume |
| Audio | JB CAF and S5 routing selected; boot log shows primary ALSA HAL fails sound-card detection | Speaker/headset playback, microphone recording and internet voice |
| GPS, sensor, camera | Candidate inventories available, integration pending | GNSS fix, sensor event delivery, photo/video capture |
| Charge, thermal, power | S5 kernel protections and target thermal configuration included | Charging/temperature readings, daemon compatibility, charge limits, suspend and power behavior |
| G900T LTE | Not working in the source-only image. Log shows repeated `rild` failure because `/system/lib/libsec-ril.so` is absent; SIM state is `NOT_READY`, IMEI and signal are unavailable | Integrate and validate the G900T RIL/vendor inputs, then test SIM, attach, APN, routed traffic, reconnect and airplane mode |
| G900T incoming SMS | BasicSmsReceiver packaged with classes.dex and SDK 18. Voice disabled and SMS enabled in compiled resources | Real incoming single/multipart messages and post-reboot delivery, independent of LTE traffic |
| G900V CDMA/EVDO/LTE | Variant properties present, RIL ABI pending | CrystalBTS registration, voice, SMS, EVDO and separate LTE test |
| Fingerprint, heart rate, Samsung apps | Outside initial scope | — |

When an approved image is available, first establish kernel → init → mounts → ADB → native services → SurfaceFlinger → Zygote → System Server → boot animation → launcher and Settings. Capture failures at each boundary. Follow with charging and thermal checks before sustained graphics or radio tests.
