LOCAL_PATH:= $(call my-dir)

ifneq ($(filter l681, $(TARGET_DEVICE)),)

# l681 reuses three makefile sets that are gated on the DEVICE NAME and name
# m681 but not l681.  Without the includes below every module they define is
# silently absent for lineage_l681, and ckati stops on the first consumer
# (e.g. "libreference-ril missing libril", "wpa_supplicant missing
# lib_driver_cmd_mt66xx", "PRODUCT_PACKAGES mtk-ril: no such module").
# Nothing outside this tree is edited; each include reproduces exactly what the
# m681 product gets.  If one of those repos later adds l681 to its own filter,
# the duplicate definition fails the parse loudly -- then delete the matching
# include here.

# 1. This tree's own subdirectory makefiles: nvram/ (m681_nvram_wifi_repair).
#    Keep first, while LOCAL_PATH is still ours (m681 donor note: without it the
#    module finder stops at this Android.mk and nvram/ silently vanishes).
include $(call first-makefiles-under,$(LOCAL_PATH))

# 2. vendor/mediatek -- a copy of the m681 branch of vendor/mediatek/Android.mk
#    (revision 6dd7c54b "lane-telephony-head", the gunwest m6rom16 state, lines
#    19-47): the GUI-only symbol shims (libmtkshim_gui/ui/sensor/icu), the
#    generic wmt_loader, libwifi-hal-mt66xx.  Plus ril/, which the m681 device
#    Android.mk includes itself (libril + rild of the MTK Oreo HIDL RIL, gated
#    inside on BOARD_PROVIDES_LIBRIL / ENABLE_VENDOR_RIL_SERVICE).
MTK_SYMBOLS_GUI_ONLY := true
include vendor/mediatek/symbols/Android.mk
MTK_SYMBOLS_GUI_ONLY :=
include vendor/mediatek/combo_loader/Android.mk
include vendor/mediatek/wlan/wifi_hal/Android.mk
include vendor/mediatek/ril/Android.mk

# 3. device/meizu/m3_meizu_m6-common -- its Android.mk:3 admits only
#    "meizu_m6 m2note m681 M6T".  FACT: m681 takes lib_driver_cmd_mt66xx
#    (wpa_supplicant/), libbt-vendor (libbt-vendor-mtk/), libxlog and flyme-res
#    from there; its own device/meizu/m681/wpa_supplicant_8_lib is dead (never
#    defines the module) and is not carried into this tree.  The inner
#    makefiles guard only against m2note, so they parse for l681.
#    The mkdir mirrors that Android.mk too (prebuilt-kernel header path).
include $(call first-makefiles-under,device/meizu/m3_meizu_m6-common)
$(shell mkdir -p $(PRODUCT_OUT)/obj/KERNEL_OBJ/usr)

# 4. vendor/meizu/m681 -- the vendor of this device (TREBLE_M681_L681 §3.2).
#    Its Android.mk wraps every module in ifeq ($(TARGET_DEVICE),m681):
#    m681_vendor_hal_symlinks, mediatek-res, CustomPropInterface, ImsService,
#    WfoService, CDS_INFO, and the librilmtk / mtk-ril prebuilts that
#    vendor/mediatek/ril/libril links BY MODULE NAME.  It is included here with
#    TARGET_DEVICE held at m681 for the duration of the include only.
#    FACT this is safe: TARGET_DEVICE is not read-only in this build
#    (build/make/core/product_config.mk:156 locks TARGET_PRODUCT, not
#    TARGET_DEVICE); PRODUCT_OUT and TARGET_OUT_VENDOR* are simple (:=)
#    assignments made long before (envsetup.mk:431, 623), so install paths stay
#    those of l681; base_rules.mk / prebuilt*.mk / binary.mk / clear_vars.mk do
#    not read TARGET_DEVICE; the included file reads it only in its guard.
l681_saved_target_device := $(TARGET_DEVICE)
TARGET_DEVICE := m681
include vendor/meizu/m681/Android.mk
TARGET_DEVICE := $(l681_saved_target_device)
l681_saved_target_device :=
ifeq ($(ALL_MODULES.mtk-ril.PATH),)
$(error l681: vendor/meizu/m681/Android.mk defined no mtk-ril module -- its TARGET_DEVICE guard changed; see device/meizu/l681/Android.mk step 4)
endif

endif
