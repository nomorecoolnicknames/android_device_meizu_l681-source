# Meizu M3 Note (L681)

**LineageOS 16.0 · Android 9 · ARM64**

Device configuration and compatibility code maintained by [ReMeizu](https://github.com/nomorecoolnicknames/remeizu).

| Target | Configuration |
| --- | --- |
| Product | `lineage_l681-userdebug` |
| Device path | `device/meizu/l681` |
| Platform | MT6755 / Helio P10 |
| Display | 1080 × 1920 |
| Kernel route | Pinned L681 prebuilt; external kernel headers |

## Status

The LOS16 product and L681-specific stock-input checks are present. A complete build and first hardware boot remain to be verified.

**Source available** means the listed implementation or configuration is in this repository. **External** means it also needs the matching platform, kernel or vendor inputs. **Untested** means there is no functional test for this branch.

## Components

| Subsystem | Implementation / source | Availability | Working status |
| --- | --- | --- | --- |
| Boot / storage | [BoardConfig.mk](BoardConfig.mk) · [rootdir/fstab.mt6755](rootdir/fstab.mt6755) | Config; kernel image external | Current kernel route untested |
| Display / touch | [overlay](overlay) · [device.mk](device.mk) · external MTK HWC/Mali stack | Config; kernel drivers external | Untested with this kernel/ROM configuration |
| Wi-Fi | [wifi](wifi) · [nvram](nvram) | Configuration/NVRAM repair source; HAL/firmware external | Untested |
| Bluetooth | [device.mk](device.mk) · stock MTK transport | Config; controller firmware/vendor transport external | Untested |
| SIM / LTE / calls | [rild-mtk-hidl.rc](rild-mtk-hidl.rc) | RIL service configuration; modem and MTK vendor ABI external | Untested; board-specific modem inputs required |
| Camera | [device.mk](device.mk) · [l681-stock-files.sha256](l681-stock-files.sha256) | Provider configuration; camera HAL and calibration external | Untested; calibration and vendor ABI remain board-specific |
| Audio | [device.mk](device.mk) · [media](media) | MTK audio service/configuration; primary HAL external | Untested on this branch |
| Sensors | [rootdir/l681-sensors.rc](rootdir/l681-sensors.rc) | Init/HAL configuration; board sensor drivers external | Untested |
| Fingerprint | [device.mk](device.mk) · [l681-stock-files.sha256](l681-stock-files.sha256) | Service/TEE configuration; fingerprint HAL external | Untested |
| GPS | [gps/gps.conf](gps/gps.conf) | Configuration/vendor inputs; GNSS stack external | Location fix unverified |
| Power / USB / SELinux | [BoardConfig.mk](BoardConfig.mk) · [sepolicy](sepolicy) | Kernel/HAL configuration and policy | Functional testing and enforcing policy pending |

## Build

Use a matching LineageOS 16.0 source tree and place this checkout at `device/meizu/l681`. LOS16 uses JDK 8. Provide these inputs before running lunch:

| Input | Location / requirement |
| --- | --- |
| Common device tree | `device/meizu/mt6755-common` |
| MTK RIL/HAL integration | Matching `vendor/mediatek` sources, including MTK telephony headers |
| Vendor inputs | Prepared `vendor/meizu/m681` tree plus the L681H L91 stock layer |
| Kernel source / headers | `kernel/meizu/meizu_m6/kernel-3.18` |
| Kernel image | `device/meizu/l681/prebuilt-kernel/Image.gz-dtb`; use the matching board kernel and DTB |

Use the L681H L91 stock system, not the M681 M91/Wingtech firmware. The exact files are checked by [l681-stock-files.sha256](l681-stock-files.sha256).

```sh
export L681_STOCK_DIR=/absolute/path/to/l681-l91/system
source build/envsetup.sh
lunch lineage_l681-userdebug
m -j4 bacon
```

Before building, `device/meizu/l681/tools/check_copy_sources.sh "$ANDROID_BUILD_TOP" "$L681_STOCK_DIR"` checks static copy-file inputs. Dynamic Make rules are reported separately.

## Next steps

- Validate the L681 board kernel independently of the M681 donor.
- Complete the ROM build with the pinned L91/vendor inputs, then test boot and peripherals.

The [ReMeizu overview](https://github.com/nomorecoolnicknames/remeizu/blob/main/PROJECT_STATUS.md) tracks the broader project; the [source index](https://github.com/nomorecoolnicknames/remeizu/blob/main/SOURCE_INDEX.md) links device, common and kernel trees.

## Credits

LineageOS and CyanogenMod contributors, the original device-tree authors, and ReMeizu contributors. Copyright and license notices remain with their source files.
