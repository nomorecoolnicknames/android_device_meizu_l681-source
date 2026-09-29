#!/bin/sh
# Check static PRODUCT_COPY_FILES sources without building.
# Usage: check_copy_sources.sh ANDROID_TOP L681_STOCK_DIR
# Dynamic foreach/wildcard rules are reported separately, not expanded.
set -u
HERE=$(cd "$(dirname "$0")/.." && pwd)
usage() { echo "usage: check_copy_sources.sh ANDROID_TOP L681_STOCK_DIR"; }
if [ "${1:-}" = "--help" ] && [ "$#" -eq 1 ]; then
    usage
    exit 0
fi
if [ "$#" -ne 2 ] || [ -z "${1:-}" ] || [ -z "${2:-}" ]; then
    usage >&2
    exit 2
fi
LOS=$1
STOCK=$2
if [ ! -d "$LOS" ] || [ ! -d "$STOCK" ]; then
    echo "ANDROID_TOP and L681_STOCK_DIR must name existing directories" >&2
    exit 2
fi
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
