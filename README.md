# Meizu M3 Note (L681)

**LineageOS 20.0 · Android 13 · ARM64**

Device configuration and compatibility code maintained by [ReMeizu](https://github.com/nomorecoolnicknames/remeizu).

| Target | Configuration |
| --- | --- |
| Product | `lineage_l681-userdebug` |
| Device path | `device/meizu/l681` |
| Platform | MT6755 / Helio P10 |
| Display | 1080 × 1920 |
| Kernel route | 4.9 donor prebuilt; `m681_49_defconfig` headers |

## Status

The Treble product configuration is present. It currently references an M681 4.9 donor kernel configuration; L681-specific kernel/board validation and a complete ROM build are still required.

**Source available** means the listed implementation or configuration is in this repository. **External** means it also needs the matching platform, kernel or vendor inputs. **Untested** means there is no functional test for this branch.

## Components

| Subsystem | Implementation / source | Availability | Working status |
| --- | --- | --- | --- |
| Boot / storage | [BoardConfig.mk](BoardConfig.mk) · [rootdir/etc/fstab.mt6755](rootdir/etc/fstab.mt6755) | Config; kernel image external | Current kernel route untested |
| Display / touch | [overlay](overlay) · [device.mk](device.mk) · external MTK HWC/Mali stack | Config; kernel drivers external | Untested with this kernel/ROM configuration |
| Wi-Fi | [wifi](wifi) · [device.mk](device.mk) | Configuration; HAL/firmware external | Untested |
| Bluetooth | [device.mk](device.mk) · stock MTK transport | Config; controller firmware/vendor transport external | Untested |
| SIM / LTE / calls | [device.mk](device.mk) · [proprietary-files.txt](proprietary-files.txt) | RIL service configuration; modem and MTK vendor ABI external | Untested; board-specific modem inputs required |
| Camera | [device.mk](device.mk) · [proprietary-files.txt](proprietary-files.txt) | Provider configuration; camera HAL and calibration external | Untested; calibration and vendor ABI remain board-specific |
| Audio | [device.mk](device.mk) · [proprietary-files.txt](proprietary-files.txt) | MTK audio service/configuration; primary HAL external | Untested on this branch |
| Sensors | [device.mk](device.mk) · [proprietary-files.txt](proprietary-files.txt) | Init/HAL configuration; board sensor drivers external | Untested |
| Fingerprint | [device.mk](device.mk) · [proprietary-files.txt](proprietary-files.txt) | Service/TEE configuration; fingerprint HAL external | Untested |
| GPS | [proprietary-files.txt](proprietary-files.txt) | Configuration/vendor inputs; GNSS stack external | Location fix unverified |
| Power / USB / SELinux | [BoardConfig.mk](BoardConfig.mk) · [sepolicy](sepolicy) | Kernel/HAL configuration and policy | Functional testing and enforcing policy pending |

## Build

Use a matching LineageOS 20.0 source tree and place this checkout at `device/meizu/l681`. Provide these inputs before running lunch:

| Input | Location / requirement |
| --- | --- |
| Platform compatibility | Matching legacy MediaTek framework/HAL adaptations; this device tree alone is not the platform |
| Vendor inputs | Prepared `vendor/meizu/m681` tree matching this device and branch |
| L681 board compatibility | The vendor makefiles currently come from M681; L681-specific firmware/HAL validation remains open |
| Kernel source / headers | `kernel/meizu/m681` |
| Kernel image | `device/meizu/l681/prebuilt/Image.gz-dtb`; use the matching board kernel and DTB |

```sh
source build/envsetup.sh
lunch lineage_l681-userdebug
m -j4 bacon
```

## Next steps

- Validate the L681 board kernel independently of the M681 donor.
- Complete the ROM build with the pinned L91/vendor inputs, then test boot and peripherals.

The [ReMeizu overview](https://github.com/nomorecoolnicknames/remeizu/blob/main/PROJECT_STATUS.md) tracks the broader project; the [source index](https://github.com/nomorecoolnicknames/remeizu/blob/main/SOURCE_INDEX.md) links device, common and kernel trees.

## Credits

LineageOS and CyanogenMod contributors, the original device-tree authors, and ReMeizu contributors. Copyright and license notices remain with their source files.
