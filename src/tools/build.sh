#!/bin/sh
set -eu

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

OUT_DIR="${1:-}"
if [ -z "$OUT_DIR" ]; then
  if [ -d /sdcard/Download ]; then
    OUT_DIR=/sdcard/Download
  else
    OUT_DIR="$ROOT/build"
  fi
fi
OUT="$OUT_DIR/musicvaporcode.love"

echo "1/3 Verificando sintaxis..."
find . -name '*.lua' -print0 | xargs -0 -n1 luac -p
echo "Sintaxis OK"

echo "2/3 Empaquetando .love..."
mkdir -p "$OUT_DIR"
rm -f "$OUT"
zip -r -D "$OUT" conf.lua main.lua src -x 'src/tools/*'

echo "3/3 Verificando paquete..."
unzip -t "$OUT"

echo "Paquete listo: $OUT"
echo "Abrelo con LÖVE Loader / LÖVE for Android 11.5 (no con am start)."
