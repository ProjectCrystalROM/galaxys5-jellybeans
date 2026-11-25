LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),kltetmo)
include $(CLEAR_VARS)
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := $(call all-java-files-under, src)
LOCAL_PACKAGE_NAME := BasicSMSReceiver
LOCAL_SDK_VERSION := 18
LOCAL_OVERRIDES_PACKAGES := Dialer Mms VoiceDialer VoicePlus
include $(BUILD_PACKAGE)
endif
