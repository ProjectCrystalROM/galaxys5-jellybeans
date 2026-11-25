# Jelly Bean build settings for the Samsung Galaxy S5 Qualcomm platform.
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_VARIANT := krait
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_SMP := true
ARCH_ARM_HAVE_TLS_REGISTER := true

TARGET_BOARD_PLATFORM := msm8974
TARGET_BOOTLOADER_BOARD_NAME := MSM8974
TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true
TARGET_KERNEL_SOURCE := kernel/samsung/klte
TARGET_KERNEL_CONFIG := msm8974_sec_defconfig
TARGET_KERNEL_SELINUX_CONFIG := selinux_defconfig
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_CMDLINE := console=null androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x37 ehci-hcd.park=3
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_SEPARATED_DT := true
BOARD_MKBOOTIMG_ARGS := --ramdisk_offset 0x02000000 --tags_offset 0x01e00000
BOARD_CUSTOM_BOOTIMG_MK := device/samsung/klte-common/mkbootimg.mk

BOARD_BOOTIMAGE_PARTITION_SIZE := 13631488
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 15728640
BOARD_FLASH_BLOCK_SIZE := 131072
TARGET_USERIMAGES_USE_EXT4 := true
RECOVERY_FSTAB_VERSION := 2
TARGET_RECOVERY_FSTAB := device/samsung/klte-common/rootdir/fstab.qcom
BOARD_HAS_NO_MISC_PARTITION := true
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"
BOARD_USE_CUSTOM_RECOVERY_FONT := \"roboto_23x41.h\"
BOARD_CUSTOM_RECOVERY_KEYMAPPING := ../../device/samsung/klte-common/recovery/recovery_keys.c

BOARD_USES_QCOM_HARDWARE := true
TARGET_USES_QCOM_BSP := true
COMMON_GLOBAL_CFLAGS += -DQCOM_HARDWARE -DQCOM_BSP
TARGET_USES_ION := true
TARGET_USES_OVERLAY := true
TARGET_USES_C2D_COMPOSITION := true
USE_OPENGL_RENDERER := true
BOARD_EGL_CFG := device/samsung/klte-common/configs/egl.cfg
TARGET_QCOM_DISPLAY_VARIANT := mdss
TARGET_QCOM_MEDIA_VARIANT := v4l2
TARGET_QCOM_AUDIO_VARIANT := caf
BOARD_USES_ALSA_AUDIO := true
BOARD_HAVE_NEW_QCOM_CSDCLIENT := true
TARGET_PROVIDES_LIBLIGHT := true

BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_BCM := true
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/samsung/klte-common/bluetooth
BOARD_BLUEDROID_VENDOR_CONF := device/samsung/klte-common/bluetooth/vnd_klte.txt
BOARD_WLAN_DEVICE := bcmdhd
WIFI_DRIVER_FW_PATH_PARAM := /sys/module/dhd/parameters/firmware_path
WIFI_DRIVER_FW_PATH_STA := /system/etc/wifi/bcmdhd_sta.bin
WIFI_DRIVER_FW_PATH_AP := /system/etc/wifi/bcmdhd_apsta.bin
WIFI_DRIVER_FW_PATH_P2P := /system/etc/wifi/bcmdhd_apsta.bin
WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_bcmdhd
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_bcmdhd

BOARD_SEPOLICY_DIRS += device/samsung/klte-common/sepolicy
BOARD_SEPOLICY_UNION += firmware.te
