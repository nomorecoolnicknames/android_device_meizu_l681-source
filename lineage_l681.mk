#
# lineage_l681.mk - Meizu M3 Note Intl (l681 / L681H / L91), MT6755
# LineageOS 20 (Android 13)
#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Companion report: /srv/forge/android/meizu-fleet/trees/L681_LOS20_TREE.md
#

# arm64 with a 32-bit second ABI. core_64_bit must come before the phone stack
# so core_minimal does not pin ro.zygote=zygote32.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Device configuration.
$(call inherit-product, device/meizu/l681/device.mk)

# LineageOS common phone stack.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# ---------------------------------------------------------------------------
# Identity
#
# FACT: the live unit REDACTED_UNIT reports, in OrangeFox recovery
#   (/srv/forge/android/l681-run-reports/
#    20260603T203105Z-source-3.10-bootlogo-recovery-REDACTED_UNIT/recovery-getprop.txt):
#     [ro.product.device]: [l681]
#     [ro.product.model]:  [M3 Note (L681)]
#     [ro.product.board]:  [mt6755]
#     [ro.orangefox.target.devices]: [l681,M3Note,m681,m3note]
#     [orangefox.super.partition]: [false]   [ro.orangefox.sar]: [0]
#   and, in the booted LineageOS 14.1 system
#   (restore-boot65cd-20260606T165057Z-REDACTED_UNIT/postboot-getprop.txt):
#     [ro.product.device]: [l681]  [ro.product.name]: [lineage_l681]
#     [ro.hardware]: [mt6755]      [ro.sf.lcd_density]: [480]
#
# FACT: the LOS 14.1 tree on disk uses directory name `l681h` but sets
#   PRODUCT_DEVICE := l681 and PRODUCT_NAME := lineage_l681
#   (l681/lineage14.1-m3note/device/meizu/l681h/lineage_l681.mk:13,17).
#   This tree keeps the codename the device itself reports: l681.
# ---------------------------------------------------------------------------
PRODUCT_DEVICE := l681
PRODUCT_NAME := lineage_l681
PRODUCT_BRAND := Meizu
PRODUCT_MODEL := M3 Note
PRODUCT_MANUFACTURER := Meizu

PRODUCT_GMS_CLIENTID_BASE := android-meizu

# ---------------------------------------------------------------------------
# Shipping API level + Treble.
#
# 2026-09-25 correction (append, the reasoning below replaces the old block):
#   REJECTED "there is NO l681 stock Flyme dump on this disk" - there is:
#     /home/n8n/Flyme6G, Flyme 6.3.0.0G intl, and it is Android 5.1,
#     ro.build.version.sdk=22 (system/build.prop).
#   REJECTED "l681's vendor set is the same Nougat generation as m681's" - the
#     L revision never got Android 7 (4pda topic 739028, post #1).
# 24 stays, for a different reason: it is the API of the vendor blob set this
# tree now ships - the m681 Nougat set (vendor/meizu/m681, stock Flyme 6.2.0.2A
# lineage, ro.build.version.sdk=24).  Why that set and not l681's own 5.1 one:
# BoardConfig.mk, block "Treble - FULL".
#
# Full Treble is switched on explicitly (owner directive 2026-09-24).
# build/make/core/config.mk:669-670 reads the override before the shipping
# level; :683-695 derive TREBLE_LINKER_NAMESPACES, SEPOLICY_SPLIT and
# ENFORCE_VINTF_MANIFEST from it.  PRODUCT_USE_VNDK stays false at level 24
# (config.mk:722-729), so BOARD_VNDK_VERSION is set in BoardConfig.mk, as on
# m95 and m681.
# ---------------------------------------------------------------------------
PRODUCT_SHIPPING_API_LEVEL := 24
PRODUCT_FULL_TREBLE_OVERRIDE := true

PRODUCT_CHARACTERISTICS := nosdcard

# FACT: 1080x1920 panel (BoardConfig.mk).
TARGET_BOOT_ANIMATION_RES := 1080

# FACT: the last boot-confirmed LineageOS 14.1 build on this unit reported
#   [ro.build.description]: [lineage_l681-userdebug 7.1.2 NJH47F 7e5506df5d test-keys]
#   (restore-boot65cd-.../postboot-getprop.txt). There is no stock Flyme
#   fingerprint on disk to copy, so - unlike m681 - NO BUILD_FINGERPRINT or
#   PRIVATE_BUILD_DESC override is asserted here. Inventing one would be a lie
#   that later CTS/GMS work would have to unpick.
