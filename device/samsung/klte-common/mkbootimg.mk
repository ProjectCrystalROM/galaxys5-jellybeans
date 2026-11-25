# The bootloader uses a separate Qualcomm DT table. Build the DTBs with the
# same Kconfig and preprocessor as the kernel, including carrier symbols.
crystal_dtbtool := $(HOST_OUT_EXECUTABLES)/dtbToolCM$(HOST_EXECUTABLE_SUFFIX)
crystal_dtimage := $(PRODUCT_OUT)/dt.img

$(crystal_dtimage): $(crystal_dtbtool) $(INSTALLED_KERNEL_TARGET)
	$(MAKE) -C $(TARGET_KERNEL_SOURCE) O=$(abspath $(KERNEL_OUT)) ARCH=arm $(ARM_CROSS_COMPILE) dtbs
	$(hide) mkdir -p $(PRODUCT_OUT)/klte-dtbs
	$(hide) cp $(KERNEL_OUT)/arch/arm/boot/msm8974pro-ac-sec-k-r*.dtb $(PRODUCT_OUT)/klte-dtbs/
	$(hide) $(crystal_dtbtool) -o $@ -s $(BOARD_KERNEL_PAGESIZE) -p $(KERNEL_OUT)/scripts/dtc/ $(PRODUCT_OUT)/klte-dtbs/

$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES) $(crystal_dtimage)
	$(hide) $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --dt $(crystal_dtimage) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE),raw)

$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(crystal_dtimage) $(recovery_ramdisk) $(recovery_kernel)
	$(hide) $(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --dt $(crystal_dtimage) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)
