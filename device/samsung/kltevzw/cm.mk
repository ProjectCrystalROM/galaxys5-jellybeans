$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, vendor/cm/config/common_full_phone.mk)
PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.telephony.cdma.xml:system/etc/permissions/android.hardware.telephony.cdma.xml
$(call inherit-product, device/samsung/klte-common/klte.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)
$(call inherit-product-if-exists, vendor/samsung/kltevzw/kltevzw-vendor.mk)

PRODUCT_NAME := cm_kltevzw
PRODUCT_DEVICE := kltevzw
PRODUCT_BRAND := samsung
PRODUCT_MANUFACTURER := samsung
PRODUCT_MODEL := SM-G900V

# These Samsung products copy their own RIL stack; omit the generic test RIL pair.
PRODUCT_PACKAGES := $(filter-out libreference-ril libril,$(PRODUCT_PACKAGES))
