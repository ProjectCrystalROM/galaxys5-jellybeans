# Building Project Crystal

The ROM source is CyanogenMod 10.2.0, Android 4.3.1/API 18 (JLS36I), with the associated Bionic, Dalvik, framework and Holo resources. Build and source-sync environments are separate. The stock Galaxy S5 system partition is an input for HAL/firmware analysis.

## Sync from a modern host

Use Git, Python 3, curl, unzip and the Google repo launcher. The workspace Git repository is the manifest repository. Select a branch containing the intended Project Crystal commit and check out that same commit before staging its device files. Use an absolute path with no spaces and a case-sensitive filesystem. The verified source sync used repo v2.71.

```bash
project=/path/to/galaxys5-jellybeans
android_tree=/path/to/cm102
mkdir -p "$android_tree"
cd "$android_tree"
repo init -u "$project" -b "$(git -C "$project" branch --show-current)" \
  --depth=1 --no-clone-bundle --repo-rev=v2.71 --config-name
repo sync -c -j12
"$project/scripts/stage-device-tree.sh" "$android_tree"
"$project/scripts/fetch-cm-prebuilts.sh" "$android_tree"
```

The staging script applies the pinned local kernel, init, audio, notification, APN, and telephony patches idempotently, then adds the Crystal APN entry. A clean tree staged with this script reproduces the source modifications recorded for the current milestone.

The exact extracted G900T/common vendor snapshot can be cloned from the public [ProjectCrystalROM vendor repository](https://github.com/ProjectCrystalROM/proprietary_vendor_samsung_klte) at `vendor/samsung`. Its `klte-common/` and `kltetmo/` trees include source provenance and SHA-256 manifests. This snapshot has no Verizon-specific vendor tree.

The checked-in GitHub remote allows anonymous cloning. On a machine configured for GitHub SSH, scope a rewrite to the sync command.

```bash
GIT_CONFIG_COUNT=1 \
  GIT_CONFIG_KEY_0=url.ssh://git@github.com/.insteadOf \
  GIT_CONFIG_VALUE_0=https://github.com/ \
  repo sync -c -j12
```

The prebuilt step recovers the 2013 Terminal Emulator matching the library name required by `vendor/cm/config/common.mk`. It checks the APK digest before staging the file and its ARM native library. The upstream download command used a retired URL.

## Isolated legacy build environment

The [installed package lock](../manifest/trusty-build-packages.tsv) records the exact versions used. The verified environment uses Ubuntu 14.04 amd64 with GNU Make 3.81, GCC 4.8.4 host tools, Python 2.7.6 and OpenJDK 7 (`javac 1.7.0_201`). The target source pins the AOSP Android 4.3.1 ARM toolchains, including ARM EABI GCC 4.7 for the kernel. CM10.2 emits a warning about OpenJDK but accepts its Java 7 compiler. The modern host lacks Python 2 and its Java 21 compiler fails CM's version requirement.

The [Ubuntu Trusty core amd64 image](https://partner-images.canonical.com/core/trusty/current/) used here has SHA-256 `e09b2c56f2239f08d97c085da8b81b47361cecf73e22063af20bf5cfbb967bc8`. Extract into a dedicated root filesystem. Configure its archive package lists for `trusty`, `trusty-updates` and `trusty-security` from `http://archive.ubuntu.com/ubuntu` with `main universe`, and provide DNS and usable `/dev` and `/proc` within the isolated environment for setup.

```bash
apt-get -o Acquire::Check-Valid-Until=false update
apt-get install --no-install-recommends \
  build-essential gcc-multilib g++-multilib openjdk-7-jdk python git zip unzip \
  bison flex gperf libncurses5-dev lib32ncurses5-dev lib32z1-dev libx11-dev \
  libgl1-mesa-dev libxml2-utils xsltproc lzop bc curl ccache pngcrush schedtool libssl-dev
```

The chroot runner uses a private mount namespace and the caller's UID/GID. It sets `JAVA_HOME` and the `C.UTF-8` build locale. CM10.2 DroidDoc fails on non-ASCII source and generated resources when the locale is plain `C`. Repository operations stay on the modern host. Keep the chroot's `/src` mount and an **absolute** `OUT_DIR` for integrated kernel recipes, which invoke `make -C kernel/samsung/klte O=...`. A relative output path fails inside the kernel directory. Build variants sequentially within one checkout because the historical BusyBox build probes library availability using a shared temporary filename.

```bash
# Standalone kernel and DTBs. Stage the helper under the mounted source root.
mkdir -p "$android_tree/out"
cp "$project/scripts/build-kernel.sh" "$android_tree/out/"
"$project/scripts/in-trusty.sh" "$trusty_root" "$android_tree" \
  bash out/build-kernel.sh kltetmo 10
"$project/scripts/in-trusty.sh" "$trusty_root" "$android_tree" \
  bash out/build-kernel.sh kltevzw 10

# Integrated build. Use kltevzw for the separate secondary product.
"$project/scripts/in-trusty.sh" "$trusty_root" "$android_tree" bash -c '
  export OUT_DIR="$PWD/out-$1"
  source build/envsetup.sh &&
    lunch "cm_$1-userdebug" &&
    make -j12 bootimage systemimage otapackage
' bash kltetmo
```

The recovery ZIP appears under `out-<variant>/target/product/<variant>/` in the Android checkout. Verify the package on the modern host.

```bash
"$project/scripts/check-recovery-zip.py" kltetmo /path/to/cm_kltetmo-ota-*.zip
```

Before device use, review [blob compatibility](BLOB-COMPATIBILITY.md) and the [installation status](INSTALLATION.md). The product is an engineering build; successful compilation does not imply that every hardware path works. The current T-Mobile state is recorded in the hardware matrix.

## Verified workspace outputs

- SM-G900T source-only build. Kernel, QCDT, boot, system, recovery and OTA compiled under Trusty. The staged archive is `out/engineering/kltetmo/cm_kltetmo-ota-70bd1fc4d2.zip` in this workspace. The verifier checked the archive CRCs, boot format, variant assertion, partition references, native Dalvik and required package contents.
- SM-G900T graphics and thermal trial. Built and verified locally with the optional extraction profile from the pinned historical vendor archive. The ZIP includes 23 input files whose packaged hashes were compared with the extraction records. This output remains in the local Android output directory.
- SM-G900T radio adapter build. The NCH `rild`, `libril.so`, and `libsec-ril.so` remain matched. The product now selects a CM11 `KlteRIL` port through `BOARD_RIL_CLASS` and `ro.telephony.ril_class`, compiled into API 18 `telephony-common`. `mmm frameworks/opt/telephony` and the full `bootimage systemimage otapackage` build succeeded; the recovery ZIP verifier passed. Recovery ZIP: `out/engineering/kltetmo/cm_kltetmo-ota-abb29cbee9.zip`; SHA-256 `c1de6e496a4c77cf2363b4b6303ec5662280c8f2b93bfc61620d0ed390d1c4e1`. The user installed this OTA. With the temporary firmware overlay, baseband `G900TUVU1ANCH` and SIM READY returned. `KlteRIL` completes operator, registration, signal and preferred-network queries. Mode 9 is now selected (the preserved database had been mode 12), but service remains unregistered/searching with invalid signal. The firmware mapping is temporary and cold boot without it is untested.
- SM-G900T Wi-Fi and Bluetooth test build. Wi-Fi scan, 5 GHz WPA2 association, DHCP (`192.168.68.51/22`) and Google page load were physically confirmed after correcting firmware-path and supplicant control-socket setup. The follow-up kernel config enables BNEP, RFCOMM, and asynchronous/synchronous PPP. The combined OTA includes the boot-time Wi-Fi socket-path symlink. Recovery ZIP `out/engineering/kltetmo/cm_kltetmo-ota-9388778f7e.zip` passed verification; SHA-256 `5f8e184870d237201ef2493c5801efe2807ca7796b58b9f2f360e94de448c9da`. Bluetooth packet flow and cold-boot Wi-Fi persistence await isolated retesting.
- SM-G900T audio firmware-path test build. The first attempted fix used init-created links on the read-only VFAT `/firmware` mount; device logs proved those links were absent, so that OTA did not fix audio. The corrected change extends Jelly Bean `ueventd`'s firmware search from three to four locations, adding `/firmware-modem/image` without changing either partition. `system/core/init` compiled and the full G900T build completed. Recovery ZIP `out/engineering/kltetmo/cm_kltetmo-ota-adsp-ueventd-47f390c588.zip` passed the recovery ZIP verifier and ZIP integrity check; SHA-256 `b88fb5d724ee1bff3c24ee931df35d32e68296e0a61a2b8e529bdefbbb18db4d`. This only addresses firmware lookup; it does not include the missing `adsprpcd`/ACDB components or establish that the audio card will register. Physical validation is pending.
- SM-G900T audio and notification path. The baseline CM10.2 G2 UCM did not match the S5 codec: the S5 lacks `SPK DAC Switch` and exposes `SPK DRV Volume` only from 0 to 8. The shared UCM now uses `DAC1 Switch` and valid values. Taiko appears around 8.3 seconds after boot. Both 10- and 30-second HAL retries failed to make cold-boot audio reliable; restarting `media` after card registration restored audio. Source inspection found the ordering bug: `AudioHardwareALSA` created `ALSADevice` before checking for the sound card, while `ALSADevice` immediately calls `mixer_open("/dev/snd/controlC0")`. That early mixer handle remains invalid even if later polling sees the card. The current fix waits for card registration, reopening `/proc/asound/cards` on each poll, and only then constructs `ALSADevice` so its mixer opens against the registered card. This waits on hardware readiness rather than a guessed timeout. The readiness-gated code is built and its OTA verified; physical cold-boot validation is pending. The Jelly Bean SystemUI notification URI fix and CM10.2 codec list remain included. The user previously heard the WAV through raw PCM devices 0 and 15, Stagefright/AudioTrack, and the built-in player, and confirmed a default notification after correcting the UCM/URI setup. ACDB loader dlopen still fails; microphone, headset and recording paths remain untested.
- SM-G900T audio/notification OTA. The previous `14a4f0a469` OTA (30-second retry) was physically tested and did not resolve cold-boot audio. The readiness-gated HAL fix now waits for the Taiko card and `/dev/snd/controlC0` before constructing `ALSADevice`. Full `bootimage systemimage otapackage` build succeeded in Trusty; the recovery ZIP passed the variant verifier and ZIP CRC check. `out/engineering/kltetmo/cm_kltetmo-ota-5a4935f8f8.zip`; SHA-256 `f4dc886d2b11532dd3e7569d75d29b2c9850b5cd8be3af85326808bc9f3d584d`. Built and verified; physical cold-boot validation is pending. Existing kernel Kconfig warnings remain.
- SM-G900T attach-APN schema OTA. Static analysis of the G900T Samsung RIL found its `carriers` query requires `max_conn`, `max_conn_t`, and `wait_time`; CM10.2 lacked them. TelephonyProvider schema version 10 adds all three with zero defaults. OTA `e5d4cc889f` was an intermediate build; the current OTA includes this migration and v11 null-MVNO handling. CM11 standard initial-attach request 111 is rejected by the Samsung vendor interface, so the port preserves Samsung's own attach-APN refresh path.
- SM-G900T null-MVNO recovery OTA. A NULL `mvno_type` in the AT&T APN row crashed `DcTracker` while rebuilding APNs. The API 18 framework now treats missing MVNO metadata safely, and TelephonyProvider schema v11 normalizes old rows and gives new rows empty defaults. The OTA also contains the APN fix. Full Trusty build and variant ZIP verification succeeded; `out/engineering/kltetmo/cm_kltetmo-ota-574dc9f24d.zip`; SHA-256 `03e988f0716b9d9771bcf044e5d3569b8bbd1a6391ebf32520eb34d13d182a8c`. After installation and factory reset, Phone remained alive, incoming carrier SMS arrived, and manual APN selection brought LTE data to AT&T's captive billing portal. Automatic APN preselection did not occur; record the SIM/plan and APN used because AT&T offers multiple SIM/APN profiles.
- SM-G900V source-only build. Kernel, QCDT, boot, system, recovery and OTA compiled under Trusty. The staged archive is `out/engineering/kltevzw/cm_kltevzw-ota-df89e0d8ad.zip`. The verifier accepted the Verizon target, rejected it as a T-Mobile package, and confirmed the presence of Dialer and Mms. The compiled framework resources retain voice and SMS capability.
- Standalone kernels. `out/kernel-kltetmo/` and `out/kernel-kltevzw/` hold verified Linux 3.4 zImages, DTBs, QCDT images and SHA-256 manifests. The two products use separate kernel builds and each DT image has seven board entries.

## Failure classification

- Source acquisition. The original published root manifest points to unmaintained refs and aux projects. The checked-in manifest syncs from verified, pinned historical Git refs.
- Missing CM prebuilt. `Term.apk` is an out-of-tree input separate from device blobs. Recover it using the script above.
- Host configuration. Missing Python 2 and relative Kbuild output paths were resolved using Trusty and absolute paths. The CM build treats Java 7 differently from the modern host Java.
- Kernel modules. Both historical target configurations have `CONFIG_MODULES` disabled. CM10.2 invokes `modules` and `modules_install` regardless and prints ignored errors for these built-in-driver configurations.
- Target interfaces. Hardware components need ABI checks and runtime gates, independently of successful host tooling or kernel compilation. See the [hardware matrix](HARDWARE-COMPATIBILITY.md).
