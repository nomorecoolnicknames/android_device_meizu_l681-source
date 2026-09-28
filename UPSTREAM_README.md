# device/meizu/l681 — Meizu M3 Note L681H, LineageOS 16.0 (Android 9)

Статус на 2026-09-25: **дерево подготовлено, НЕ собрано, НЕ прошито.**
`m`/`make` не запускались (запрет задания); проверено только статически (§7).
Метки — `/srv/forge/android/CLAUDE.md §2`.

## 1. Происхождение

- Донор: `los16-ct07/device/meizu/m681` @ `439b26e` (FACT: тот же HEAD, что в
  gunwest `/home/gun/m6rom16/rom/device/meizu/m681`). Импорт — `git archive`
  коммита, не рабочей копии.
- Общие слои не копируются, используются из LOS16-дерева как есть:
  `device/meizu/mt6755-common` (`b94e086`), `device/meizu/meizu_mt675x-common`
  (`c4e09d2`), `device/meizu/m3_meizu_m6-common` (`fe03476`), `vendor/meizu/m681`
  (`a6b74a0`, рабочая копия с `proprietary/`),
  `vendor/mediatek` (состояние ганвеста `6dd7c54b`, ветка `lane-telephony-head`).
- Вендор = набор m681 (решение `designs/TREBLE_M681_L681_20260924.md §3.2`):
  стока Android 7 для L-ревизии не существует (4pda 739028), сток L681H —
  Android 5.1. Своё у l681 — только то, что в `l681-stock-files.sha256` (§4).
- История: `git log` (6 коммитов импорт → идентичность → ядро → разделы →
  Android.mk → сток L681H), плюс этот README.

## 2. Что нужно сборке снаружи дерева

| Что | Путь в LOS16-дереве / на диске | Зачем |
|---|---|---|
| общие слои | `device/meizu/{mt6755-common,meizu_mt675x-common,m3_meizu_m6-common}` | BoardConfigCommon, lib_driver_cmd_mt66xx, libbt-vendor, libxlog |
| вендор | `vendor/meizu/m681` **с `proprietary/`** | блобы; модули под гардом m681 (Android.mk шаг 4) |
| MTK-исходники | `vendor/mediatek` @ `6dd7c54b` | symbols, combo_loader, wifi_hal, ril (Android.mk шаг 2) |
| заголовки ядра | `kernel/meizu/meizu_m6/kernel-3.18` | как у донора: `TARGET_KERNEL_SOURCE` для заголовков, ничего не компилируется |
| сток L681H | `L681_STOCK_DIR`, по умолчанию `/home/n8n/_l681_patch_l91_system_20260502_104156/system` | модем, WMT/Wi-Fi, mddb, сенсоры; гейт по sha256 |

`L681_STOCK_DIR` должен быть виден процессу сборки (в namespace-сборке — тот же
путь или переопределение переменной). Если каталога нет или хоть один sha256 не
совпал — `$(error)` на этапе product config.

Три набора makefile'ов пускают модули только по имени устройства (m681 да,
l681 нет). `Android.mk` подключает их явно, чужие репозитории не правятся;
если кто-то впишет l681 в свой фильтр — будет громкий дубль модуля, соответствующий
include отсюда надо убрать. `vendor/meizu/m681/Android.mk` подключается с
`TARGET_DEVICE`, временно равным `m681` (обоснование — в самом `Android.mk`),
после чего проверяется `ALL_MODULES.mtk-ril.PATH`.

## 3. Ядро

- **2026-09-28 (flash-l681), текущее ядро — `3.10.72 #3 a9binder2`.** FACT: `prebuilt-kernel/Image.gz-dtb`
  sha256 `a150f575…9693`, md5 `a91321c8…036e` = страницы ядра `[2048, 2048+8003521)` образа `2d8a86e1…`
  (рамдиск LOS 14.1 из `65cd6433…`); ридбек p22 `2d8a86e1…`, загрузка REDACTED_UNIT до
  `sys.boot_completed=1`, `/dev/binder`, `/dev/hwbinder`, `/dev/vndbinder` созданы. Исходник —
  `l681-310-worktrees/l681-310-a9binder-20260925` (ветка `forge/l681-a9-binder`, `0161375bfa6`):
  meizucustoms cm-14.1 `a582fa6` + binder из 4.9 (через m2note 3.10.108, `b64dc7ada81`) + `forge_ar`
  (`0161375bfa6`). Конфиг — #56 с апстримным списком камер + `ANDROID_BINDER_DEVICES`. Журнал —
  `meizu-fleet/flash-l681-20260928.md`. Записи ниже про #56 — история, не переписаны.
- **FACT (2026-09-28): LK берёт из заголовка boot только первые 99 байт cmdline** — поэтому
  `BOARD_KERNEL_CMDLINE` сокращён до `bootopt`, `androidboot.selinux=permissive`, `enforcing=0`,
  а `L681_KERNEL_CMDLINE_EXTRA` ставится первым (`BoardConfig.mk`, комментарий у cmdline).
- **Регресс против #56 (FACT, LOS 14.1 на a9binder2):** ядро видит `CAM[1]:ov13853mipiraw_sy_al1518;
  CAM[2]:ov5670mipiraw`, HAL камеры 14.1 (под имена сенсоров #56) падает `stack corruption detected`.
  Исходник камерных коммитов #56 утерян. Для A9 HAL камеры — из набора m681 (H-L681-CAM ниже).

- **FACT:** `prebuilt-kernel/Image.gz-dtb` = `Linux version 3.10.72+ … #56 SMP
  PREEMPT Sat Jun 6 10:37:40 CDT 2026`, sha256 `ec954389…113f`, md5
  `9bb269be…4f33` — страницы ядра `[2048, 2048+7964588)` образа
  `l681-run-reports/ov13853-stockgeom-build-20260606T153740Z/boot-l681-ov13853-stockgeom-8a1a51b-bd90header.img`
  (sha256 `65cd6433…`). Этот образ — ридбек p22 после прошивки, `sys.boot_completed=1`
  (`restore-boot65cd-20260606T165057Z-REDACTED_UNIT/`). Единственное ядро, когда-либо
  загружавшее l681. Гейт: `tools/check_prebuilt_kernel.sh` + `EXPECTED.txt`.
- **FACT:** почему не линия m681: в 4.4 m681 нет ни одного драйвера панелей l681
  (`hx8399/ili9885/nt35596 *_al1518`), плата другая (Huaqin `hq6755_66_b1a_l`
  против Wingtech `wt6755_66_sz_l`).
- **FACT:** Mali: блоб `libGLES_mali.so` m681 = `r5p0-06rel0`, драйвер в #56 =
  `MALI_RELEASE_NAME r5p0-06rel0` (`l681-out/…/KERNEL_OBJ/…/mali-EAC`).
- **FACT:** SELinux: в распакованном #56 есть таблица `policydb_compat` с
  версиями 15..30 → политика версии 30 (xperms) грузится; `POLICYVERS` не задан.
  Запись донора «3.10.72 держит только 29» — про стоковое ядро m681, для #56
  **REJECTED**.
- Геометрия (FACT, заголовок того же образа): base `0x40078000`, kernel
  `0x40080000`, ramdisk `0x45000000`, second `0x40f00000`, tags `0x44000000`,
  page 2048, **`--board` пустой** (у донора `1480869018` — не переносится).
- cmdline = заголовок загрузившегося образа + `androidboot.hardware=mt6755`
  (LK его и так передаёт, dmesg:84; весь rc/fstab-набор завязан на mt6755).

## 4. Чем l681 отличается от донора m681

| Что | l681 | Основание |
|---|---|---|
| идентичность | `lineage_l681`, `TARGET_OTA_ASSERT_DEVICE := l681,l681h,l91` | FACT: OrangeFox `ro.product.device=l681`; `m3note` — строка m681 |
| `TARGET_MEIZU_MT675X_DEVICE` | `l681` | FACT: единственный потребитель — `meizu_mt675x-common/BoardConfigCommon.mk:10-13` (sepolicy-слот; `sepolicy/l681/` есть) |
| fstab | только by-name `/dev/block/platform/mtk-msdc.0/11230000.msdc0/by-name/*` | FACT: этими путями монтировал рамдиск загрузившегося образа; имена — scatter l681 |
| recovery | 16 MiB | FACT: scatter `0x8000..0x1008000`; mt6755-common пишет 32 MiB |
| userdata | 27308982272 | INFERENCE (начало `0xeb000000` из scatter, конец — ёмкость eMMC того же класса) |
| `/vendor` | `custom`, 512 MiB | FACT размер (scatter), LOS 14.1 монтировал `/custom`; номер p3 и содержимое — INFERENCE |
| hwrotation | 180 (и в `rootdir/default.prop`) | FACT: `ROTATION "180"` без `_HW`; postboot-getprop 14.1 `ro.sf.hwrotation=180` |
| модем | L681H: `MOLY.LR11.W1539.MD.MP.V9.P20`, плата HQ6755_66_B1A_L | FACT: sha256 в `l681-stock-files.sha256`; ставил LOS 14.1 (`l681h-vendor.mk:193-198`) |
| WMT/Wi-Fi прошивки | ROMv2_lm_patch_1_{0,1}, WIFI_RAM_CODE_6755 из стока L681H | FACT: у m681 другие хеши; с этими работал 14.1 на этом ядре. WMT_SOC.cfg и pcm_*.bin одинаковы — от m681 |
| сенсоры | стоковый hwmsen HAL L681H (обе ABI) + msensord + akmd09911 + `rootdir/l681-sensors.rc` | FACT: HAL m681 — InvenSense MPL (NEEDED libinvensense_hal, строки st480); чипы l681 LSM6DS3/PA122/AKM09911/BMP280; в 14.1 `init.svc.akmd09911=running` |
| C2K `boot_3_3g_n.rom` | не ставится | FACT: нет в стоке L681H и в наборе 14.1; `ro.mtk_c2k_support=0` |
| RIL | блобы m681 без изменений | FACT: LOS 14.1 l681 брал ровно эти mtkrild/gsm0710muxd/mtkmal/mtk-ril/librilmtk (md5 совпадают) и дошёл до `gsm.sim.state=READY,READY` |

Не переименовано сознательно: `vendor/meizu/m681/...`, `persist.m681.*`,
`debug.m681.*`, имена `m681_*`-скриптов и модуля `m681_nvram_wifi_repair` —
их читают rc, скрипты и патчи платформы вне дерева.

Не перенесено из донора (FACT по ссылкам в makefile'ах, подробно — коммит
`b00eac9`): ядро 4.4, SFOS-ветка, `sfleaktrack/` (дубль имени Soong),
`shims/` (не собирается), `wpa_supplicant_8_lib/` (мёртвый гард), `lineage.mk`,
неотгружаемые rc (`init.rc`, `init.usb.rc`, …), `init.m681_sensors.rc` /
`init.m681_cameraserver.rc` (их импортирует только неотгружаемый `init.rc`).

## 5. Противоречия (обе стороны названы)

1. **Версия модема.** На аппарате под 14.1: `gsm.version.baseband =
   MOLY.LR11.W1539.MD.MP.V9.P19` (postboot-getprop restore-boot65cd). Файл, который
   ставил 14.1 и ставит это дерево: V9.P20. INFERENCE: модем в этой связке грузится
   не из `/vendor/firmware`, а из раздела `md1img`. Проверка — HYPOTHESIS H-L681-MD.
2. **policyvers.** Донор: «3.10.72 держит 29». FACT по бинарю #56: 30 есть. Верим бинарю.
3. **recovery.** mt6755-common: 32 MiB; scatter l681: 16 MiB. Верим scatter.
4. **«Сток l681» на диске.** `/home/n8n/Flyme6G/system` — слой m91/Wingtech
   (модем V9.P60), не L681H. Сток L681H — `_l681_patch_l91_system_20260502_104156`.
   Гейт `check_l681_stock.sh` отличает их (на Flyme6G — 17/17 несовпадений).

## 5a. БЛОКЕР ЯДРА (ревью 2026-09-25, FACT)

**СНЯТ 2026-09-28 (FACT, §3):** ядро a9binder2 создаёт `/dev/hwbinder` и `/dev/vndbinder`
(`ls -l /dev/*binder*` на LOS 14.1: `10,43 binder`, `10,42 hwbinder`, `10,41 vndbinder`). Текст ниже — история.

**Android 9 на 3.10.72 #56 не стартует: в ядре нет `/dev/hwbinder` и `/dev/vndbinder`.**
- FACT: в распакованном `prebuilt-kernel/Image.gz-dtb` строк `hwbinder` и `vndbinder` — 0 (у 3.18.19 m2note и
  4.9 m5s есть `binder,hwbinder,vndbinder`, у 4.4.15 m681 — `hwbinder`, `vndbinder`). У собранного, но не
  прошитого 3.18.35 l681 (`l681-run-reports/318-l681-boardtruth-build-20260608T145331Z/Image.gz-dtb`,
  sha256 `eecefe80…`) — тоже 0, в его `.config` только `CONFIG_ANDROID_BINDER_IPC=y`.
- FACT (цепочка, коммиты ганвеста): libhwbinder `ProcessState.cpp:362` открывает только `/dev/hwbinder`;
  `hwservicemanager` (`critical`) без него выходит; init после 4 выходов за 4 мин — `LOG(FATAL)` → бутлуп.
- **Следствие:** дерево l681 готово как userspace, но **A9 на l681 требует ядра с несколькими binder-устройствами**
  (бэкпорт multi-device binder + `CONFIG_ANDROID_BINDER_DEVICES="binder,hwbinder,vndbinder"` в 3.10/3.18 l681,
  либо ядро линии m681 с DTS/LCM l681). Исходник #56 (`/home/n8n/l681_clean_build/kernel_src/meizucustoms-l681`)
  на диске не найден. Это работа ядерного лейна, не этого дерева.
- Опровержение: на живом l681 с LOS 14.1 / #56 — `adb shell ls -l /dev/*binder*`; если `hwbinder` есть,
  находка снимается.

## 6. Не проверено — HYPOTHESIS с тестом опровержения

| # | Гипотеза | Опровержение на первом буте |
|---|---|---|
| H-L681-HWC | `hwcomposer.mt6755` m681 (md5 `8499d74e…`) работает с дисплейным драйвером 3.10 | нет `Boot is finished` в `logcat -b all`, падения/таймауты `hwcomposer`/`SurfaceFlinger`. Запасной путь (не подключён): HWC/gralloc стока L681H, md5 `29340e94…`/`dbdbc244…` — их ставил 14.1 |
| H-L681-SENS | стоковый hwmsen-HAL L681H работает под Pie через `sensors@1.0-impl.mtk` | `dumpsys sensorservice` без LSM6DS3/AKM09911/PA122 или без событий |
| H-L681-MD | модем поднимается с этим набором | `getprop gsm.version.baseband` (P19 → модем из md1img, P20 → из /vendor/firmware), `gsm.sim.state` |
| H-L681-CCCI | Nougat-демоны m681 (ccci_mdinit, nvram_daemon, wmt_loader) совместимы с ioctl ядра 3.10 | `logcat -s ccci_mdinit NVRAM wmt_loader`; `ls /dev/ccci*`; wlan0 не появляется |
| H-L681-NVRAM | nvram_daemon m681 не переформатирует NVRAM L-ревизии; `rootdir/bin/m681_mdtype_fix.sh` на каждом буте пишет `MD_Type=0x0c` (ulwctg) в `/nvdata` и `/data/nvram` (вызовы `init.nvdata.rc:30,57`, `init.modem.rc:276`; INFERENCE: для образов `*_ulwctg_n` L681H значение верное) | IMEI после бута (`service call iphonesubinfo`) ≠ до прошивки. **Бэкап nvram/nvdata/proinfo — обязателен до прошивки** |
| H-L681-CAM | камеры: `libcameracustom` m681 знает ov5670/ov13853 (FACT: строки есть), но HAL N против ISP-драйвера 3.10 | `dumpsys media.camera` — число устройств (в 14.1 было 2); фронт ov5670 без тюнинга m681 |
| H-L681-FP | отпечаток GF516M через Trustonic TA m681 | на одной загрузке 3.10 чип не ответил по SPI (`9p chip version not detect`) — `lshal`, `logcat -s goodixfpd` |
| H-L681-ROT | `ro.sf.hwrotation=180` верно и с HWC m681 | бутанимация/экран блокировки вверх ногами |
| H-L681-REC | `recovery.img` (ядро 7,96 МБ + рамдиск) влезает в 16 MiB. ВАЖНО: превышение роняет **весь** `m` (droidcore зависит от recoveryimage, `assert-max-image-size`), не только recovery; на рамдиск остаётся 8 810 496 Б. Ориентир (FACT): `recovery.img` m5c LOS16 на ганвесте — 13,8 МБ | `m recoveryimage` первым; если не влез — `LZMA_RAMDISK_TARGETS := recovery` или `TARGET_NO_RECOVERY := true` (в p1 OrangeFox) |
| H-L681-FSM | by-name-симлинки Pie ueventd на 3.10 такие же, как у N | ранний бут: `mount_all` не находит `/system` (pstore / expdb) |
| H-L681-LK99 | cmdline заголовка ≤ 99 байт доходит до ядра целиком (FACT на LOS 14.1: обрезка ровно на 99) | `cat /proc/cmdline` на первом буте A9: `forge_ar=`/`bootopt=`/`androidboot.selinux=permissive` на месте |

## 7. Статическая проверка (без сборки)

```
$ tools/check_copy_sources.sh          # LOS16 = los16-ct07, сток = L91
sources found: 998, missing: 0, unresolved-variable: 0
DYNAMIC  device.mk:142: M681_AUDIO_PARAM_SRC := $(wildcard …/audio_param/*)   (63 файла в каталоге)
DYNAMIC  device.mk:144: $(foreach …)
$ tools/check_prebuilt_kernel.sh prebuilt-kernel/Image.gz-dtb prebuilt-kernel/EXPECTED.txt   # пусто = ок
$ tools/check_l681_stock.sh <L681_STOCK_DIR> l681-stock-files.sha256                           # пусто = ок
```
Негативные контроли: подменённое ядро → маркер + подсказка; `L681_STOCK_DIR=/home/n8n/Flyme6G/system`
→ «17 файл(ов) не совпало»; тот же каталог в `check_copy_sources.sh` → 4 отсутствующих mddb.

## 8. Перед прошивкой (решение владельца; сам ничего не шьёт)

Из OrangeFox (p1 — единственный рабочий recovery l681, его НЕ затирать `recovery.img` из этой сборки без отдельного решения):
```
ls -l /dev/block/platform/mtk-msdc.0/11230000.msdc0/by-name/   # custom -> p3? system -> p29? cache -> p30?
cat /proc/partitions                                            # размер p3 = 524288 КиБ?
sgdisk --backup=/sdcard/l681-gpt.bin /dev/block/mmcblk0
for p in nvram nvdata proinfo boot custom; do dd if=/dev/block/platform/mtk-msdc.0/11230000.msdc0/by-name/$p of=/sdcard/l681-$p.img bs=1048576; done
sha256sum /sdcard/l681-*.img
```

## 9. Проверки первого бута (стиль AGENTS.md §6)

```
adb shell 'uname -a; cat /proc/uptime'                      # 3.10.72+ #56, малый uptime (свежесть)
adb shell 'getprop ro.build.display.id; getprop ro.build.version.release; getprop ro.product.device'   # lineage_l681, 9, l681
adb shell 'getprop sys.boot_completed; getprop sys.system_server.start_count; getenforce'
adb logcat -b crash -d | head -50
adb shell 'lshal | wc -l; getprop | grep init.svc | grep -v running'
adb logcat -d | grep -E "cannot locate symbol|library .* not found" | sort | uniq -c | sort -rn | head
adb shell 'getprop gsm.version.baseband; getprop gsm.sim.state; getprop gsm.operator.numeric'
adb shell 'dumpsys sensorservice | head -40; dumpsys media.camera | grep -m2 "Number of camera"'
adb shell 'getprop ro.sf.hwrotation; getprop ro.sf.lcd_density'   # 180, 480
# посмертно: из OrangeFox — /sys/fs/pstore/*, expdb по имени (skill mtklogs)
```

## 10. Оставлено как у донора (ревью 2026-09-25, не блокеры)

- `init.mt6755.rc:38-45`, `ueventd.mt6755.rc:6-21` ссылаются на `11240000.msdc1` (SD), а eMMC — `msdc0`: симлинки
  nvram/proinfo висят, права не ставятся. Донор m681 живёт так же.
- `sepolicy/file_contexts:1-4` размечает номера разделов m681 (p3/p7/p11/p12) — для l681 INFERENCE; в permissive безвредно.
- `device.mk` просит `android.hardware.biometrics.fingerprint@2.0-service` — такого модуля нет (есть `@2.1-service`);
  Pie не проверяет PRODUCT_PACKAGES, модуль молча не ставится (как у донора).
- Комментарии про «/vendor = симлинк /system/vendor» в `lineage_l681.mk`/`device.mk` устарели: vendor — настоящий раздел.
- Флаг `resize` в fstab fs_mgr Pie не знает — только предупреждение.
- `L681_STOCK_DIR` по умолчанию указывает на путь этой машины; при сборке на ганвесте его надо передать.
