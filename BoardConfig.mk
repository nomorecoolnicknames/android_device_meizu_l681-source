#
# BoardConfig.mk - Meizu M3 Note Intl (l681 / L681H / L91), MediaTek MT6755
# LineageOS 20 / Android 13 device tree.
#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# ---------------------------------------------------------------------------
# EVIDENCE POLICY (see /srv/forge/android/CLAUDE.md §2)
# FACT       = read off a file / image header / device capture on this disk.
# INFERENCE  = derived from one or more FACTs.
# HYPOTHESIS = untested; carries a falsification step.
#
# Companion report: /srv/forge/android/meizu-fleet/trees/L681_LOS20_TREE.md
#
# THE ONE-LINE TRUTH ABOUT THIS TREE: it is a placeholder, not a ROM. No kernel
# on this disk is runtime-verified for Android 13 on l681. The selected
# 3.10.72 a9binder2 adds multi-device binder and boots LOS14.1, but the A13
# eBPF/cgroup network contract and full userspace runtime remain unresolved. The gap table
# lives in meizu-fleet/trees/M681_LOS20_TREE.md §3.1 and applies verbatim here,
# only worse: 3.10 is two more generations back than m681's 4.4.
# ---------------------------------------------------------------------------

DEVICE_PATH := device/meizu/l681

# ---------------------------------------------------------------------------
# Architecture
#
# FACT: MT6755 (Helio P10) is 8x Cortex-A53, AArch64, ARMv8.0-A. No LSE atomics
#   (FEAT_LSE is ARMv8.1-A). Live confirmation on this very unit:
#   [ro.product.cpu.abi]: [arm64-v8a], [ro.mediatek.platform]: [MT6755]
#   (l681-run-reports/restore-boot65cd-20260606T165057Z-REDACTED_UNIT/postboot-getprop.txt).
#
# FACT: build/soong/cc/config/arm64_device.go:31-33 maps arch variant "armv8-a"
#   to exactly `-march=armv8-a`; arm64_device.go:57-59 maps cpu variant
#   "cortex-a53" to `-mcpu=cortex-a53` (+ -Wl,--fix-cortex-a53-843419).
#   Neither enables +lse. The forbidden values in the same table are "armv8-2a"
#   (-march=armv8.2-a) and "cortex-a55"; NEITHER is used here.
#
# DO NOT change TARGET_ARCH_VARIANT to armv8-2a or TARGET_CPU_VARIANT to
# cortex-a55/kryo*/exynos-m*. That is an instant SIGILL storm on this SoC.
#
# NOTE, carried from the m681 pass (meizu-fleet/BRINGUP_STATE.md §1.2, risk R7):
#   two modules in LOS20 do carry higher-than-v8.0 flags and land in the image -
#   XNNPACK's armv8.2 microkernels inside libtflite.so (runtime-gated by
#   cpuinfo_has_arm_neon_dot()) and /system/bin/crypto (-march=armv8-a+crypto,
#   which is ARMv8.0 plus the optional Crypto Extensions, not ARMv8.1).
#   Re-check after any toolchain bump with the ninja scan in
#   meizu-fleet/trees/M681_LOS20_TREE.md §8.
#
# FACT: the LOS 14.1 tree that produced the last booting l681 build used
#   TARGET_2ND_ARCH_VARIANT := armv7-a-neon
#   (l681/lineage14.1-m3note/device/meizu/mt6755-common/BoardConfigCommon.mk).
#   This tree uses armv8-a for the second arch, exactly like m681, because on
#   A13 the 32-bit ABI is only there for legacy blobs and armv8-a is what the
#   m681 pass validated end to end.
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Partitions - A-only, no slots, no dynamic partitions, no super.
#
# FACT (measured on the live unit REDACTED_UNIT):
#   boot   = /dev/block/mmcblk0p22
#     (l681-run-reports/recovery-after-ril-sim1-fail-20260605T180752Z-REDACTED_UNIT/
#      boot-partition.txt, and .../20260603T213838Z-post-v4-bootblock-recovery-.../
#      bootdev.txt resolves by-name/boot to the same node)
#   system = /dev/block/mmcblk0p29
#     ([orangefox.system.block_device]: [/dev/block/mmcblk0p29], recovery-getprop.txt)
#   cache  = /dev/block/mmcblk0p30
#     (`/dev/block/mmcblk0p30 on /cache type ext4` in the live mount output)
#   [orangefox.super.partition]: [false] - no dynamic partitions.
#   These are the SAME numbers as m681 (meizu-fleet/factbase/mt6755_family.md:67-69).
#
# INFERENCE, not FACT: the remaining block numbers below are taken from the m681
#   map. l681 and m681 are the same M3 Note board with the same MTK partition
#   table; three independent anchor points (boot/system/cache) match exactly, so
#   the rest of the ordering is almost certainly identical. There is NO l681
#   scatter file on this disk (verified: the only Meizu scatters present are
#   m681/Flyme6.2.0.2A/scatter.txt, meizu_m6/stock-flyme-7.1.2.0G/scatter.txt and
#   /srv/forge/m6t-dump/scatter.txt). Get one before trusting a flash script.
#
# FACT (sizes, two independent sources agreeing):
#   (a) the LOS 14.1 common BoardConfig that built the booting image
#       (l681/lineage14.1-m3note/device/meizu/mt6755-common/BoardConfigCommon.mk:41-47)
#       gives boot 16777216, recovery 16777216, cache 452984832,
#       system 2684354560, userdata 27879521280;
#   (b) the m681 stock scatter arithmetic gives boot 0x01000000 = 16777216,
#       system 0xa0000000 = 2684354560, cache 0x1b000000 = 452984832
#       (m681/Flyme6.2.0.2A/scatter.txt).
#   Same numbers from a ROM tree and from a factory scatter of the same board.
#
# INFERENCE: BOARD_USERDATAIMAGE_PARTITION_SIZE 27879521280 has no scatter end
#   offset behind it. It is inert - we do not build userdata.img.
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Treble - FULL, with a real /vendor on the stock `custom` partition (p3).
# Owner directive 2026-09-24: every Meizu fleet tree goes full Treble, the way
# m95 (MX6) is.  Report: meizu-fleet/designs/TREBLE_M681_L681_20260924.md.
#
# WHERE /vendor LIVES:
#   FACT: l681's own stock package is on disk after all -
#     /home/n8n/Flyme6G (Flyme 6.3.0.0G, ro.build.mask.id=
#     5.1-1523466149_intlstable, the L91/intl build; the L91 OTA layer is
#     /home/n8n/Flyme6G/patch_l91).  Its scatter.txt is byte-identical to the
#     m681 one (`diff` = empty, also against patch_l91/scatter.txt):
#       custom 0x1088000 -> expdb 0x21088000  => 0x20000000 = 536870912 B.
#     The older detailed scatter /home/n8n/Flyme5.1.6.0A/MT6755_Android_scatter.txt
#     (lines 84-94) gives the same partition_size: 0x20000000 for `custom`.
#   FACT: `custom` exists on the live unit - the LOS 14.1 fstab that booted it
#     mounts .../by-name/custom on /custom (l681/lineage14.1-m3note/device/
#     meizu/l681h/rootdir/fstab.mt6755:19).  Stock content of that partition
#     is regional preinstalls only (Flyme6G/custom: 3rd-party 45 MB,
#     cip-build.prop, plugin) - nothing a LineageOS system reads.
#   INFERENCE: p3 is `custom` - the scatter order is identical to m681 (where
#     p3 = custom is FACT) and the three measured anchors p22/p29/p30 of this
#     unit match it.  CHECK before any flash: `ls -l
#     /dev/block/platform/mtk-msdc.0/11230000.msdc0/by-name/custom` from
#     recovery must point at mmcblk0p3, and `blockdev --getsize64
#     /dev/block/mmcblk0p3` must print 536870912.
#   Same partition as m681 and m95: no repartitioning.
#
# VNDK: `current`, as on m95 and m681 (the v30 pin is measured-REJECTED on
#   m95; no old vendor image exists here that the v30 APEX would serve).
#
# PRODUCT_FULL_TREBLE_OVERRIDE := true lives in lineage_l681.mk.
#
# VENDOR BLOB SET - the m681 one (vendor/meizu/m681, Nougat, API 24), NOT
#   l681's own stock, and here is why (details in the report):
#   FACT: Flyme6G is Android 5.1, ro.build.version.sdk=22 (system/build.prop),
#     and Meizu never shipped Android 7 for the L revision: the official
#     firmware thread lists "Flyme 6 на базе Android 7 (Только для М681) ...
#     нельзя устанавливать на L версии", and the newest international build
#     "для M681H и L681H" is Flyme 6.3.0.0G (4pda topic 739028, post #1).
#   FACT: in that 5.1 image the MTK libraries sit in /system/lib*, not in
#     /system/vendor (1247 .so in system/, 19 in system/vendor).
#   INFERENCE: the only kernel path to Android 13 for l681 is the m681 4.x
#     line with an l681 DTS (l681_GRAND_PLAN_2026-09-11.md §3, Tier B), so the
#     userspace driver ABI it will expose is m681's; the m681 Nougat set is the
#     one that matches it and the newest one for this board family.
#   l681-specific pieces (front camera ov5670 vs m681's s5k5e8, panel
#     hx8399/nt35596/ili9885) are open items of the camera/display lanes.
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Boot image geometry
#
# FACT - read directly out of the boot image that LAST BOOTED THIS DEVICE,
#   /srv/forge/android/l681-run-reports/ov13853-stockgeom-build-20260606T153740Z/
#   boot-l681-ov13853-stockgeom-8a1a51b-bd90header.img
#   (9 633 792 B, sha256 65cd64335d5f32931567af847835eb127fa4da80a9aa68d76ff56ef4bbfd9e4e).
#   Android boot header v0:
#     kernel_addr  0x40080000  => BOARD_KERNEL_BASE 0x40078000 (addr - 0x8000)
#     ramdisk_addr 0x45000000  => ramdisk_offset 0x04f88000
#     second_addr  0x40f00000  => second_offset  0x00e88000  (second_size = 0)
#     tags_addr    0x44000000  => tags_offset    0x03f88000
#     page_size    2048        name "" (empty)  header_version 0
#
#   That this image booted is not a guess:
#     restore-boot65cd-20260606T165057Z-REDACTED_UNIT/postflash-sha256.txt and
#     postboot-boot-sha256.txt both read back 65cd6433... from p22, and
#     postboot-getprop.txt reads [sys.boot_completed]: [1] with
#     [ro.build.description]: [lineage_l681-userdebug 7.1.2 NJH47F ...].
#
# FACT (independent second source): the same five values are recorded in the
#   campaign factbase for l681 - "геометрия boot: kernel 0x40080000,
#   ramdisk 0x45000000, tags 0x44000000" (mt6755_family.md:301).
#
# FACT (third source, same numbers, different convention): the LOS 14.1
#   BoardConfig writes BOARD_KERNEL_BASE := 0x40080000 with
#   --kernel_offset 0x00000000 --ramdisk_offset 0x04f80000
#   --second_offset 0x00e80000 --tags_offset 0x03f80000
#   (device/meizu/l681h/BoardConfig.mk). Base+offset gives the identical
#   absolute addresses 0x45000000 / 0x40f00000 / 0x44000000. This tree uses the
#   AOSP convention (base = kernel_addr - 0x8000) that the rest of the fleet uses.
#
# --board: DELIBERATELY NOT SET. FACT: the name field of the booting image is
#   EMPTY. The LOS 14.1 tree offers L681_STOCK_KERNEL_BOARD ?= 1523476840 but
#   did not apply it to the image that booted. Setting a board id nobody has
#   verified would be inventing an artifact.
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Kernel command line
#
# FACT: the exact cmdline of the image that booted this unit (header parse):
#   bootopt=64S3,32N2,64N2 androidboot.selinux=permissive enforcing=0
#   lcm=1-hx8399_fhd_dsi_vdo_txd_auo_al1518 fps=5434 vram=29229056
#   buildvariant=userdebug
# `lcm=` is how LK names the panel to disp_lcm_probe (selection is by strcmp on
# the name), so it is kept verbatim, together with fps/vram which come from the
# same LK handoff.
#
# ADDED here and not present there: androidboot.hardware=mt6755. On m681 this is
# load-bearing on LOS16 (it selects init.mt6755.rc). The live l681 already
# reports [ro.boot.hardware]: [mt6755] without it (the MTK kernel supplies it
# from the atags), so this is belt and braces, not a change of behaviour.
# ---------------------------------------------------------------------------
# PROPER-FIX (2026-09-28): this LK keeps only the first 99 header bytes.
# Fresh capture l681-k2-los141-1358/dmesg.txt:84; LK supplies hardware/panel.
# Put optional diagnostic arguments FIRST, then retain the proven boot mode.
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
