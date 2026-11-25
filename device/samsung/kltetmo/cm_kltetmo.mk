$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)
$(call inherit-product, vendor/cm/config/common_full.mk)
$(call inherit-product, vendor/cm/config/telephony.mk)
DEVICE_PACKAGE_OVERLAYS += device/samsung/kltetmo/overlay
PRODUCT_PACKAGES += BasicSMSReceiver
$(call inherit-product, device/samsung/klte-common/klte.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)
$(call inherit-product-if-exists, vendor/samsung/kltetmo/kltetmo-vendor.mk)

PRODUCT_NAME := cm_kltetmo
PRODUCT_DEVICE := kltetmo
PRODUCT_BRAND := samsung
PRODUCT_MANUFACTURER := samsung
PRODUCT_MODEL := SM-G900T
