# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
# BoardConfig.mk - Meizu M3 Note Intl (l681 / L681H / L91), MediaTek MT6755

DEVICE_PATH := device/meizu/l681

# MT6755 uses Cortex-A53 / ARMv8.0-A. Do not enable ARMv8.1 LSE instructions.
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := cortex-a53

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a53

TARGET_USES_64_BIT_BINDER := true

# ---------------------------------------------------------------------------
# Board / platform identity
#
# FACT: [ro.product.board]: [mt6755] and [ro.hardware]: [mt6755] on the live
#   unit (recovery-getprop.txt and postboot-getprop.txt, cited above).
# FACT: the LOS 14.1 tree ships rootdir/init.mt6755.rc and ueventd.mt6755.rc
#   (l681/lineage14.1-m3note/device/meizu/l681h/rootdir/), i.e. ro.hardware
#   must resolve to mt6755 or none of them are read.
# FACT: [ro.meizu.hardware.fp]: [Goodix] on the live unit - the fingerprint
#   sensor is Goodix, as on m681 (GF516M) and M6 (GF3208).
# ---------------------------------------------------------------------------
TARGET_BOARD_PLATFORM := mt6755
TARGET_BOOTLOADER_BOARD_NAME := mt6755
TARGET_BOARD_PLATFORM_GPU := mali-t860mp2

TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true

BOARD_NAME := l681
# FACT: the LOS 14.1 tree asserts l681,l681h,l91,m3note
# (device/meizu/l681h/BoardConfig.mk:9). Kept, minus m3note: that is m681's
# assert string and mixing the two is exactly the "never use l681 artifacts as
# m681 truth" trap (meizu-fleet/factbase/mt6755_family.md:303-304).
TARGET_OTA_ASSERT_DEVICE := l681,l681h,l91

# ---------------------------------------------------------------------------
# Screen
#
# FACT: 1080x1920 - the LOS 14.1 BoardConfig
#   (device/meizu/l681h/BoardConfig.mk:14-15) and the kernel config agree:
#   CONFIG_LCM_WIDTH="1080", CONFIG_LCM_HEIGHT="1920"
#   (l681-run-reports/318-l681-boardtruth-build-20260608T145331Z/l681_318.config).
# FACT: [ro.sf.lcd_density]: [480] on the live booted unit => xxhdpi.
#
# PANEL - and a correction to the campaign factbase, stated explicitly.
#   FACT: the l681 defconfigs register SIX LCM drivers plus the bias chip:
#     CONFIG_CUSTOM_KERNEL_LCM="ili9885_fhd_dsi_vdo_txd_asi_al1518
#       ili9885_fhd_dsi_vdo_dj_asi_al1518 hx8399_fhd_dsi_vdo_txd_boe_al1518
#       hx8399_fhd_dsi_vdo_txd_auo_al1518 nt35596_fhd_dsi_vdo_dj_boe_al1518
#       nt35596_fhd_dsi_vdo_dj_auo_al1518 tps65132"
#     (identical string in meizuosc-l681-hqdebug-20260501/arch/arm64/configs/
#      l681_defconfig, meizuosc-l681-m681-revive/.../l681_m681_revive_defconfig
#      and in the built config l681_318.config).
#   FACT: the boot image that last booted this unit carries
#     `lcm=1-hx8399_fhd_dsi_vdo_txd_auo_al1518` on its kernel command line
#     (header parse of l681-run-reports/ov13853-stockgeom-build-20260606T153740Z/
#      boot-l681-ov13853-stockgeom-8a1a51b-bd90header.img).
#   REJECTED: "l681's panel is nt35695" (meizu-fleet/factbase/mt6755_family.md:304,
#     quoting docs/MT6755_FAMILY_4.9_PORT.md §1). The string `nt35695` does not
#     occur in ANY l681 kernel config on this disk; the closest names are
#     `nt35596_*`, which are two of the six compiled drivers and are NOT the one
#     the booting image selects. The useful half of that factbase line - "never
#     use l681 artifacts as m681 truth" - stands unchanged.
#   Selection is by NAME from LK (strcmp in disp_lcm_probe), same mechanism as
#   the M6 family (M6T_ROADMAP.md §2.1), so the cmdline above is load-bearing.
# ---------------------------------------------------------------------------
TARGET_SCREEN_WIDTH := 1080
TARGET_SCREEN_HEIGHT := 1920
TARGET_RECOVERY_PIXEL_FORMAT := BGRA_8888

# A-only stock partition geometry. No dynamic partitions or super partition.
BOARD_FLASH_BLOCK_SIZE := 131072

BOARD_BOOTIMAGE_PARTITION_SIZE := 16777216
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 16777216
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 2684354560
BOARD_CACHEIMAGE_PARTITION_SIZE := 452984832
BOARD_USERDATAIMAGE_PARTITION_SIZE := 27879521280

TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := ext4

# A-only. No A/B, no virtual A/B, no dynamic partitions, no super image.
# NOTE: PRODUCT_USE_DYNAMIC_PARTITIONS must NOT be assigned here - it is a
# product variable marked .KATI_READONLY before BoardConfig.mk is read.
AB_OTA_UPDATER := false
BOARD_USES_RECOVERY_AS_BOOT := false
BOARD_BUILD_SYSTEM_ROOT_IMAGE := false

# Treble uses the stock custom partition for /vendor.
# The shipping API remains that of the stock vendor ABI; VNDK is selected explicitly.
TARGET_COPY_OUT_VENDOR := vendor
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_PARTITION_SIZE := 536870912
BOARD_VNDK_VERSION := current

BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED := true
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# The N-era blobs are PRODUCT_COPY_FILES (vendor/meizu/m681), exactly as on m95
# and m681.  TECHNICAL DEBT: nothing validates their DT_NEEDED at build time;
# the closure is checked with meizu-fleet/tools/treble-closure.py instead.
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

# Boot header addresses and page size must match this board.
# Keep the base and offsets together when changing kernel packaging.
BOARD_KERNEL_BASE := 0x40078000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x04f88000
BOARD_SECOND_OFFSET := 0x00e88000
BOARD_TAGS_OFFSET := 0x03f88000
BOARD_MKBOOTIMG_ARGS := --ramdisk_offset $(BOARD_RAMDISK_OFFSET) --second_offset $(BOARD_SECOND_OFFSET) --tags_offset $(BOARD_TAGS_OFFSET)

# Legacy MTK boot header: no header_version, no dtb in bootimg, no dtbo.
BOARD_BOOT_HEADER_VERSION := 0
BOARD_INCLUDE_DTB_IN_BOOTIMG :=
BOARD_INCLUDE_RECOVERY_DTBO :=

# Keep hardware identity and binder devices in the kernel command line.
# LCM selection remains with the bootloader and board kernel.
BOARD_KERNEL_CMDLINE := $(strip $(L681_KERNEL_CMDLINE_EXTRA) bootopt=64S3,32N2,64N2 androidboot.selinux=permissive enforcing=0)

# First-stage mount: /system and /vendor are by-name paths in rootdir/etc/
# fstab.mt6755 (fleet decision 2026-09-25).  androidboot.partition_map is NOT on
# the cmdline: with by-name paths it is inert (the platform by-name link needs a
# PARTNAME anyway, init/devices.cpp:405-413); the no-PARTNAME fallback is raw
# nodes + a self-mapping partition_map together.  Full reasoning:
# device/meizu/m681/BoardConfig.mk.

# ---------------------------------------------------------------------------
# Kernel - PREBUILT. This tree never compiles a kernel.
#
# FACT: prebuilt/Image.gz-dtb is 7 964 588 B,
#   sha256 ec95438926f6aff2b78341de30e18e30701aa29becb512161dd96e192d78113f.
#   It was extracted from pages [2048, 2048+7964588) of
#   l681-run-reports/ov13853-stockgeom-build-20260606T153740Z/
#   boot-l681-ov13853-stockgeom-8a1a51b-bd90header.img on 2026-09-16.
# FACT: its gzip payload carries the banner
#   "Linux version 3.10.72+ (nomore@coolnicknames) (gcc version 4.9 20150123
#    (prerelease) (GCC)) #56 SMP PREEMPT Sat Jun 6 10:37:40 CDT 2026"
#   - identical to /proc/version read back from the running device after that
#   flash (restore-boot65cd-.../postboot-proc-version.txt).
#
# WHY THIS ONE AND NOT THE NEWER 3.18:
#   FACT: the newest l681 kernel artifact on disk is 3.18.35,
#     l681-run-reports/318-l681-boardtruth-build-20260608T145331Z/Image.gz-dtb,
#     7 635 989 B, sha256
#     eecefe80150672c8d1bff83b1a33652d98b77b12591b7ff70f6d6071f13e5175
#     (artifact-sha256.txt in that directory). It has NEVER been flashed - the
#     directory contains only build logs, and seven of its eight build steps
#     ended `status=2` on a missing /mnt/d toolchain.
#   The rule for this fleet is "port from the tree that last actually booted the
#   device" (meizu-fleet/TREES.md §3.2), so the boot-confirmed 3.10.72 wins.
#
# 2026-09-28: #56 replaced by board-specific 3.10.72 #3 a9binder2.
# FACT: full boot SHA 2d8a86e1...d42 matched raw p22 readback and reached
# LOS14.1 boot_completed=1 with binder/hwbinder/vndbinder nodes. This does NOT
# establish Android 11/13 runtime or HIDL scatter/gather acceptance.
# The kernel still lacks a complete A13 eBPF network contract. Do not claim
# that multi-device binder alone makes it an Android 13 kernel.
#
# Headers-only source remains the isolated m681 4.9 headers worktree for
# libtinycompress (generated_kernel_includes). It is NOT the boot kernel or
# an interchangeable l681 board port. Runtime ALSA UAPI equivalence remains
# unverified; resolve that independently of the image identity gate below.
TARGET_NO_KERNEL := false
TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64
TARGET_KERNEL_SOURCE := kernel/meizu/m681
TARGET_KERNEL_CONFIG := m681_49_defconfig
TARGET_FORCE_PREBUILT_KERNEL := true
TARGET_KERNEL_VERSION := 3.10
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image.gz-dtb
BOARD_KERNEL_IMAGE_NAME := kernel

# Exact kernel identity gate; no claim about Android-version compatibility.
L681_PREBUILT_SHA256 := a150f5756935be8c78bbdafe56425f9502184d9bcc8692126fba0a2928199693
l681_kernel_sha256 := $(word 1,$(shell sha256sum $(TARGET_PREBUILT_KERNEL)))
ifneq ($(l681_kernel_sha256),$(L681_PREBUILT_SHA256))
$(error l681 prebuilt kernel differs from the pinned a9binder2 artifact)
endif

# ---------------------------------------------------------------------------
# Recovery / fstab
# ---------------------------------------------------------------------------
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.mt6755
BOARD_SUPPRESS_SECURE_ERASE := true
BOARD_CHARGER_SHOW_PERCENTAGE := true

# ---------------------------------------------------------------------------
# Wi-Fi - MediaTek WMT / conn_soc combo chip.
#
# CONTRADICTION, resolved. The LOS 14.1 tree declares
#   BOARD_WLAN_DEVICE := bcmdhd  and  BOARD_WPA_SUPPLICANT_PRIVATE_LIB :=
#   lib_driver_cmd_bcmdhd  (device/meizu/l681h/BoardConfig.mk:21-25)
# while in the SAME file setting WIFI_DRIVER_STATE_CTRL_PARAM := /dev/wmtWifi,
# which is a MediaTek WMT node and has nothing to do with Broadcom.
# Ground truth is the running device:
#   FACT: [ro.mediatek.wlan.p2p]: [0], [ro.mediatek.wlan.wsc]: [1],
#     [ro.mtk_dhcpv6c_wifi]: [1], [debug.l681.wifi.kick]: [wlan0_present]
#     (restore-boot65cd-.../postboot-getprop.txt).
# REJECTED: bcmdhd. This is a MediaTek combo part; the driver-command library
# is lib_driver_cmd_mt66xx, exactly as on m681 and M6.
# ---------------------------------------------------------------------------
BOARD_WLAN_DEVICE := MediaTek
WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_mt66xx
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_mt66xx
WIFI_DRIVER_STATE_CTRL_PARAM := /dev/wmtWifi
WIFI_DRIVER_STATE_ON := 1
WIFI_DRIVER_STATE_OFF := 0

# ---------------------------------------------------------------------------
# SELinux
#
# The blob set is Nougat-era MTK; A13 public policy neverallows reject it
# wholesale, exactly as they did on the m681 and M6 lanes. Runtime is permissive
# via the cmdline above (which is also what the booting LOS 14.1 image used:
# `androidboot.selinux=permissive enforcing=0`). Keeping the build-time
# assertion off is honest about that; it must be revisited before any enforcing
# build.
# ---------------------------------------------------------------------------
SELINUX_IGNORE_NEVERALLOWS := true
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor

# ---------------------------------------------------------------------------
# Not-Qualcomm. Leaving these on drags SurfaceFlinger into QTI wrappers.
# (The LOS 14.1 mt6755-common BoardConfig says the same thing in the same words
#  and ties it to a black-screen deadlock it had to debug.)
# ---------------------------------------------------------------------------
BOARD_USES_QCOM_HARDWARE := false
TARGET_USES_QCOM_BSP := false

# ---------------------------------------------------------------------------
# System properties file
# ---------------------------------------------------------------------------
TARGET_SYSTEM_PROP := $(DEVICE_PATH)/system.prop

# ---------------------------------------------------------------------------
# N-ABI shims of the vendor blob set (vendor/meizu/m681, shared with m681):
# TARGET_LD_SHIM_LIBS for Mali EGL, gralloc and libgui_ext (2026-09-25).
# ---------------------------------------------------------------------------
include vendor/meizu/m681/BoardConfigVendor.mk
