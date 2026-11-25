def FullOTA_Assertions(info):
    # Unified TWRP reports klte on several S5 models. Check the bootloader
    # when recovery cannot identify the handset as kltetmo directly.
    info.script.AppendExtra(
        'assert(getprop("ro.product.device") == "kltetmo" || '
        'getprop("ro.build.product") == "kltetmo" || '
        'is_substring("G900TUV", getprop("ro.bootloader")));')


IncrementalOTA_Assertions = FullOTA_Assertions
