#!/bin/sh
# Verify the L681H L91 stock files against the supplied SHA256 manifest.
# On failure print the diagnostic consumed by device.mk; success produces no text.
# The M681 M91 modem and sensor inputs are incompatible with this board.
set -u
DIR=$1
LIST=$2

[ -d "$DIR" ] || {
    echo "КАТАЛОГ СТОКА l681 НЕ НАЙДЕН: $DIR" >&2
    echo "Задайте L681_STOCK_DIR=<.../system стока L681H с L91-патчем> (см. README.md)." >&2
    echo "l681-stock: каталога стока нет, см. подробности выше"; exit 0; }
[ -f "$LIST" ] || { echo "НЕТ СПИСКА: $LIST" >&2; echo "l681-stock: нет списка sha256, см. подробности выше"; exit 0; }

bad=0
tmp=$(mktemp) || { echo "l681-stock: mktemp не сработал — гейт не может проверить сток"; exit 0; }
grep -v '^#' "$LIST" | grep -v '^[[:space:]]*$' > "$tmp"
while read -r want rel; do
    f="$DIR/$rel"
    if [ ! -f "$f" ]; then
        echo "  НЕТ ФАЙЛА: $rel" >&2; bad=$((bad+1)); continue
    fi
    have=$(sha256sum "$f" | cut -d' ' -f1)
    if [ "$have" != "$want" ]; then
        echo "  ДРУГОЙ ФАЙЛ: $rel" >&2
        echo "    ожидаем $want" >&2
        echo "    найдено $have" >&2
        bad=$((bad+1))
    fi
done < "$tmp"
rm -f "$tmp"

[ "$bad" -eq 0 ] && exit 0
cat >&2 <<MSG
СТОКОВЫЕ БЛОБЫ l681 НЕ СОВПАЛИ СО СПИСКОМ ($bad шт.).
  каталог: $DIR
  список:  $LIST
Правильный источник — система L681H с L91-патчем
(L681_STOCK_DIR), а не непатченная система Flyme6G.
Новые файлы требуют проверки происхождения и обновления SHA256 manifest.
MSG
echo "l681-stock: $bad файл(ов) не совпало, см. подробности выше"
