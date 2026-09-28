#!/bin/sh
# check_copy_sources.sh — статическая проверка дерева l681 БЕЗ сборки:
# каждый источник PRODUCT_COPY_FILES, который продукт lineage_l681 соберёт,
# существует на диске.
#
# Что читается: device.mk, lineage_l681.mk, BoardConfig.mk этого дерева и
# vendor/meizu/m681/m681-vendor.mk (наследуется device.mk).  Переменные
# подставляются так, как их увидит сборка:
#   $(LOCAL_PATH), $(DEVICE_PATH)  -> device/meizu/l681 (это дерево)
#   $(L681_STOCK_DIR)              -> $2 (сток L681H)
#   $(TARGET_COPY_OUT_VENDOR)      -> vendor
# Всё остальное (vendor/meizu/m681/..., frameworks/..., hardware/...) ищется
# в LOS16 repo-дереве $1.
#
# Граница: это проверка существования файлов, а не разбор make.  Правила,
# построенные через $(foreach)/$(wildcard) (audio_param донора), не
# раскрываются и перечисляются отдельно; фильтры с % пропускаются.
#
#   $1 — корень LOS16 repo-дерева (по умолчанию /srv/forge/android/los16-ct07)
#   $2 — L681_STOCK_DIR (по умолчанию /home/n8n/_l681_patch_l91_system_20260502_104156/system)
set -u
HERE=$(cd "$(dirname "$0")/.." && pwd)
LOS=${1:-/srv/forge/android/los16-ct07}
STOCK=${2:-/home/n8n/_l681_patch_l91_system_20260502_104156/system}
exec python3 - "$HERE" "$LOS" "$STOCK" <<'PY'
import os, re, sys
here, los, stock = sys.argv[1:4]
files = [os.path.join(here, f) for f in ('device.mk', 'lineage_l681.mk', 'BoardConfig.mk')]
files.append(os.path.join(los, 'vendor/meizu/m681/m681-vendor.mk'))
subst = {
    '$(LOCAL_PATH)': 'device/meizu/l681',
    '$(DEVICE_PATH)': 'device/meizu/l681',
    '$(L681_STOCK_DIR)': stock,
    '$(TARGET_COPY_OUT_VENDOR)': 'vendor',
}
tok = re.compile(r'(\S+):(\S+)')
ok = missing = skipped = 0
miss = []
dynamic = []
for fn in files:
    for ln, line in enumerate(open(fn, encoding='utf-8', errors='replace'), 1):
        s = line.split('#', 1)[0].strip().rstrip('\\').strip()
        if not s or '%' in s:
            continue
        if '$(foreach' in s or '$(wildcard' in s:
            dynamic.append('%s:%d: %s' % (os.path.relpath(fn, here) if fn.startswith(here) else fn, ln, s))
            continue
        for m in tok.finditer(s):
            src, dst = m.group(1), m.group(2)
            if '/' not in src or src.startswith('$(shell'):
                continue
            for k, v in subst.items():
                src = src.replace(k, v)
            if '$(' in src:
                skipped += 1
                continue
            if src.startswith('/'):
                path = src
            elif src.startswith('device/meizu/l681/'):
                path = os.path.join(here, src[len('device/meizu/l681/'):])
            else:
                path = os.path.join(los, src)
            if os.path.exists(path):
                ok += 1
            else:
                missing += 1
                miss.append('%s:%d: %s' % (os.path.basename(fn), ln, src))
print('LOS16 tree:   %s' % los)
print('stock dir:    %s' % stock)
print('sources found: %d, missing: %d, unresolved-variable: %d' % (ok, missing, skipped))
for m in miss:
    print('MISSING  ' + m)
for d in dynamic:
    print('DYNAMIC  ' + d)
sys.exit(1 if missing else 0)
PY
