# Meizu M3 Note Global: LineageOS 16.0

Device configuration, init rules, SELinux policy and compatibility code for Android 9.
Place this tree at `device/meizu/l681` in the matching LineageOS source tree.

The build requires the referenced common and MediaTek platform trees, matching kernel
source/headers and prebuilt image where selected, and this board’s proprietary inputs.
Use `proprietary-files.txt`, dependency manifests and kernel checks provided by this branch.
Prebuilt firmware and complete ROM images are not supplied by this repository.

After providing those inputs, select `lunch lineage_l681-userdebug`.
These sources remain under development; compiling them does not certify all hardware
or establish a tested installable release.

Retain the copyright and license notices in individual files.

Set `L681_STOCK_DIR` to the matching L681H L91 stock system directory.
Its files must pass `l681-stock-files.sha256`; M681 firmware is not interchangeable.
Run `tools/check_copy_sources.sh ANDROID_TOP L681_STOCK_DIR` for static input checks.
