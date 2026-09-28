#
# device.mk - Meizu M3 Note Intl (l681), MT6755, LineageOS 20 (Android 13)
#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/meizu/l681

# ---------------------------------------------------------------------------
# Soong namespaces (device-tree isolation)
#
# FACT (measured 2026-09-16): Soong parses every Android.bp in the workspace
# for every product and has no TARGET_DEVICE guard, so a bp module declared in
# one device tree lands in installs-<product>.mk of ALL products — a plain
# `m nothing` for lineage_m5s carried 51 install-rule lines from
# device/meizu/m95 (27 modules), two of them colliding with real m5s blobs
# (vendor/lib{,64}/libperfservicenative.so, via the `stem:` of
# libm95shim_perfservice).  Modules of a namespace reach Make only for the
# products that list that namespace here
# (build/soong/cmd/soong_build/main.go:99-112 -> android/namespace.go:204 ->
# android/androidmk.go:919).  Each tree carries a root Android.bp with
# `soong_namespace {}`; this line is the other half of the pair.
# ---------------------------------------------------------------------------
PRODUCT_SOONG_NAMESPACES += \
    device/meizu/l681 \
    vendor/meizu/m681

# ---------------------------------------------------------------------------
# Screen density
#
# FACT: [ro.sf.lcd_density]: [480] read off the live unit REDACTED_UNIT while
#   booted into LineageOS 14.1 (l681-run-reports/
#   restore-boot65cd-20260606T165057Z-REDACTED_UNIT/postboot-getprop.txt),
#   consistent with the 1080x1920 5.5" panel => xxhdpi.
# ---------------------------------------------------------------------------
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xxhdpi

# Device-specific framework overlays.
DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

# ---------------------------------------------------------------------------
# Ramdisk / fstab
#
# A13 first-stage init mounts every fstab entry carrying `first_stage_mount`
# and, if there is a /system entry, calls SwitchRoot("/system")
# (system/core/init/first_stage_mount.cpp:505-525). So the fstab must live in
# the BOOT ramdisk, not only in /vendor/etc.
# ---------------------------------------------------------------------------
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6755:$(TARGET_COPY_OUT_RAMDISK)/fstab.mt6755 \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6755:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.mt6755

# ---------------------------------------------------------------------------
# VINTF
#
# Enforced now: PRODUCT_ENFORCE_VINTF_MANIFEST follows PRODUCT_FULL_TREBLE
# (build/make/core/config.mk:683-695), which lineage_l681.mk switches on.
# manifest.xml is m681's (same vendor set, same HAL list), target-level 3.
# ---------------------------------------------------------------------------
DEVICE_MANIFEST_FILE := $(LOCAL_PATH)/manifest.xml

# ---------------------------------------------------------------------------
# Wi-Fi / supplicant
# ---------------------------------------------------------------------------
# NOTE: `wpa_supplicant.conf` is NOT a module in Android 13 - putting it in
# PRODUCT_PACKAGES fails main.mk:1312 "includes non-existent modules". The
# device tree must ship the file itself.
PRODUCT_PACKAGES += \
    libwpa_client \
    wpa_supplicant \
    hostapd

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/wifi/wpa_supplicant.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant.conf \
    $(LOCAL_PATH)/wifi/p2p_supplicant.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant.conf

# wpa_supplicant service with the AIDL interface name the A13 framework asks
# for (m95 lesson 161682f; nothing else in this image defines the service —
# see the header of that rc).
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/init/init.l681.wifi.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.l681.wifi.rc

# ---------------------------------------------------------------------------
# Vendor HALs (full Treble) and the libraries the N-era blobs need in the
# vendor namespace.  Identical to device/meizu/m681/device.mk, because the
# vendor set is the same (vendor/meizu/m681); the reasoning for every line -
# m95's HAL map, why no bluetooth/fingerprint/radio yet, lessons 5-8 - is
# written there once and not duplicated here.
# ---------------------------------------------------------------------------
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.allocator@2.0-service \
    android.hardware.graphics.composer@2.1-service \
    android.hardware.graphics.mapper@2.0-impl-2.1 \
    android.hardware.memtrack@1.0-impl \
    android.hardware.memtrack@1.0-service \
    android.hardware.renderscript@1.0-impl \
    android.hardware.power@1.0-impl \
    android.hardware.power@1.0-service \
    android.hardware.light@2.0-impl \
    android.hardware.light@2.0-service \
    android.hardware.vibrator@1.0-impl \
    android.hardware.vibrator@1.0-service \
    android.hardware.audio@2.0-impl \
    android.hardware.audio@2.0-service \
    android.hardware.audio.effect@2.0-impl \
    android.hardware.audio@6.0-impl \
    android.hardware.audio.effect@6.0-impl \
    android.hardware.keymaster@3.0-impl \
    android.hardware.keymaster@3.0-service \
    android.hardware.gatekeeper@1.0-service.software \
    android.hardware.drm@1.0-impl \
    android.hardware.drm@1.0-service \
    android.hardware.drm@1.3-service.clearkey \
    android.hardware.gnss@1.0-impl \
    android.hardware.gnss@1.0-service \
    android.hardware.camera.provider@2.4-impl \
    android.hardware.camera.provider@2.4-service \
    android.hardware.sensors@1.0-impl \
    android.hardware.sensors@1.0-service \
    android.hardware.wifi@1.0-service \
    libwifi-hal-mt66xx \
    wificond

PRODUCT_PACKAGES += \
    libgui_mt6755fwd \
    libcamera_client_vendor \
    libstdc++.vendor \
    libtinyxml \
    libalsautils

# libtinycompress: audio.primary.mt6755.so (lib and lib64) NEEDs it.  It needs
# the kernel headers genrule, hence kernel/meizu/m681 (headers only) +
# TARGET_FORCE_PREBUILT_KERNEL in BoardConfig.mk (2026-09-25; it had been
# dropped for two commits, 6dac745; same as device/meizu/m681 7872f89).
PRODUCT_PACKAGES += \
    libtinycompress

# ---------------------------------------------------------------------------
# Feature declarations. Only what is backed by hardware FACT-verified working on
# THIS unit in its last boot-confirmed run (2026-06-06, LineageOS 14.1,
# sys.boot_completed=1):
#   display+touch    - the device was screenshotted and driven through the
#                      camera app during that session;
#   fingerprint      - [ro.meizu.hardware.fp]: [Goodix] present;
#   wifi             - [debug.l681.wifi.kick]: [wlan0_present],
#                      [debug.l681.wifi.nvram_ready]: [1];
#   telephony gsm    - the RIL lane (ril-* run-reports, 2026-06-05) got SIM1/SIM2
#                      registered and data connected on this unit;
#   gps              - [init.svc.wifi2agps]: [running].
#
# Deliberately NOT declared:
#   android.hardware.camera*  - both l681 cameras (ov13853 rear + ov5670 front)
#                      were the open lane when work stopped on 2026-06-08; the
#                      front-camera QH route is explicitly REJECTED as not
#                      boot-safe (mt6755_family.md:300).
#   sensor.*         - no sensor capture from this unit exists in the
#                      run-reports; m681's list must not be assumed to apply.
#   bluetooth        - never exercised on this unit in any captured run.
# ---------------------------------------------------------------------------
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.fingerprint.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/handheld_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/handheld_core_hardware.xml

# ---------------------------------------------------------------------------
# Vendor blobs - the real /vendor image on `custom` (p3).
#
# 2026-09-25: the tree now ships the m681 Nougat set (vendor/meizu/m681, branch
# lineage-20-treble; 839 files of the LOS16 m681 daily driver).  Why not l681's
# own blobs: l681's stock is Flyme 6.3.0.0G = Android 5.1 / SDK 22
# (/home/n8n/Flyme6G) and the L revision never got Android 7 - the full
# argument is in BoardConfig.mk, block "Treble - FULL".
# REJECTED (old note of this block): "THE BLOBS THEMSELVES ARE NOT ON THIS
# DISK" - l681's own are at /home/n8n/Flyme6G (+ patch_l91); they are simply
# the wrong generation for an Android 13 vendor.
# proprietary-files.txt of this directory stays as the LOS 14.1 inventory.
# ---------------------------------------------------------------------------
$(call inherit-product, vendor/meizu/m681/m681-vendor-blobs.mk)

# N-ABI shims of the same blob set (libm681shim_base, libmtkshim_ui,
# libm681shim_perfservice); their linker wiring is vendor/meizu/m681/
# BoardConfigVendor.mk, included from BoardConfig.mk.
$(call inherit-product, vendor/meizu/m681/m681-vendor-shims.mk)

PRODUCT_PACKAGES += \
    m681_vendor_symlinks
