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

The prebuilt step recovers the 2013 Terminal Emulator matching the library name required by `vendor/cm/config/common.mk`. It checks the APK digest before staging the file and its ARM native library. The upstream download command used a retired URL.

## Isolated legacy build environment

The verified environment uses Ubuntu 14.04 amd64 with GNU Make 3.81, GCC 4.8 host tools, Python 2.7.6 and OpenJDK 7 (`javac 1.7.0_201`). The target source pins the AOSP Android 4.3.1 ARM toolchains, including ARM EABI GCC 4.7 for the kernel. CM10.2 emits a warning about OpenJDK but accepts its Java 7 compiler. The modern host lacks Python 2 and its Java 21 compiler fails CM's version requirement.

The [Ubuntu Trusty core amd64 image](https://partner-images.canonical.com/core/trusty/current/) used here has SHA-256 `e09b2c56f2239f08d97c085da8b81b47361cecf73e22063af20bf5cfbb967bc8`. Extract into a dedicated root filesystem. Configure its archive package lists for `trusty`, `trusty-updates` and `trusty-security` from `http://archive.ubuntu.com/ubuntu` with `main universe`, and provide DNS and usable `/dev` and `/proc` within the isolated environment for setup.

```bash
apt-get -o Acquire::Check-Valid-Until=false update
apt-get install --no-install-recommends \
  build-essential gcc-multilib g++-multilib openjdk-7-jdk python git zip unzip \
  bison flex gperf libncurses5-dev lib32ncurses5-dev lib32z1-dev libx11-dev \
  libgl1-mesa-dev libxml2-utils xsltproc lzop bc curl ccache pngcrush schedtool libssl-dev
```

The chroot runner uses a private mount namespace and the caller's UID/GID. It sets `JAVA_HOME` and the build locale. Repository operations stay on the modern host. Keep the chroot's `/src` mount and an **absolute** `OUT_DIR` for integrated kernel recipes, which invoke `make -C kernel/samsung/klte O=...`. A relative output path fails inside the kernel directory.

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
    make -j12 bootimage systemimage
' bash kltetmo
```

Before runtime images, review [blob compatibility](BLOB-COMPATIBILITY.md) and stage ABI-checked target inputs. There is no public flashable build at this checkpoint. The integrated command is for source-level bring-up and may produce incomplete images without proprietary dependencies.

## Failure classification

- Source acquisition. The original published root manifest points to unmaintained refs and aux projects. The checked-in manifest syncs from verified, pinned historical Git refs.
- Missing CM prebuilt. `Term.apk` is an out-of-tree input separate from device blobs. Recover it using the script above.
- Host configuration. Missing Python 2 and relative Kbuild output paths were resolved using Trusty and absolute paths. The CM build treats Java 7 differently from the modern host Java.
- Target interfaces. Hardware components need ABI checks and runtime gates, independently of successful host tooling or kernel compilation. See the [hardware matrix](HARDWARE-COMPATIBILITY.md).
