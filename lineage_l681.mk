# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
# lineage_l681.mk - Meizu M3 Note Intl (l681 / L681H / L91), MT6755

# arm64 with a 32-bit second ABI. core_64_bit must come before the phone stack
# so core_minimal does not pin ro.zygote=zygote32.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Device configuration.
$(call inherit-product, device/meizu/l681/device.mk)

# LineageOS common phone stack.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Preserve the L681 product identity and OTA assertions.
PRODUCT_DEVICE := l681
PRODUCT_NAME := lineage_l681
PRODUCT_BRAND := Meizu
PRODUCT_MODEL := M3 Note
PRODUCT_MANUFACTURER := Meizu

PRODUCT_GMS_CLIENTID_BASE := android-meizu

# The stock vendor baseline is Android 5.1 (API 22).
# Treble and VNDK settings are explicit rather than inferred from a newer shipping API.
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

# This private product belongs to the API 30 platform; reject accidental A13 overlays.
ifneq ($(PLATFORM_SDK_VERSION),30)
$(error l681 lineage-18.1 requires PLATFORM_SDK_VERSION=30)
endif
