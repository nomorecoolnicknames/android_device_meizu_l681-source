# Meizu M3 Note (L681): LineageOS 16.0

Device configuration, init rules, policy and compatibility code.
Place at `device/meizu/l681` in the matching LineageOS source tree.
Provide the referenced common/MediaTek trees, matching kernel source or prebuilt,
and board-specific vendor inputs from `proprietary-files.txt` and dependency manifests.
Keep the included kernel/input checksum checks enabled.
Select `lunch lineage_l681-userdebug`.

Set `L681_STOCK_DIR` to the matching L681H L91 stock system directory.
Its files must pass `l681-stock-files.sha256`; M681 firmware is not interchangeable.
Run `tools/check_copy_sources.sh ANDROID_TOP L681_STOCK_DIR` for static input checks.
