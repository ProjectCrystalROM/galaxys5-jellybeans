LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE := klte_macloader
LOCAL_MODULE_STEM := macloader
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := macloader.c
LOCAL_SHARED_LIBRARIES := liblog
include $(BUILD_EXECUTABLE)
