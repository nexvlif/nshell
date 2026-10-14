#!/usr/bin/env bash
# nshell smoke test.
#   ./scripts/smoke.sh          static only (qmllint + python suite, CI-safe)
#   ./scripts/smoke.sh nested   + nested-compositor runtime (needs cage)
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== qmllint =="
# Prefer real Qt qmllint (CI installs Qt; some distros ship a stub as qmllint).
LINT="${QMLLINT:-}"
[ -z "$LINT" ] && [ -x /usr/lib/qt6/bin/qmllint ] && LINT=/usr/lib/qt6/bin/qmllint
[ -z "$LINT" ] && LINT=qmllint
fail=0
while IFS= read -r f; do
  out=$($LINT -I . "$f" 2>&1) || { echo "FAIL $f"; echo "$out"; fail=1; }
done < <(find . -path ./venv -prune -o -name '*.qml' -print)
[ "$fail" -eq 0 ] && echo "qmllint clean" || exit "$fail"

echo "== static suite =="
python3 tests/test_static.py

if [ "${1:-}" = "nested" ]; then
  echo "== nested runtime =="
  command -v cage >/dev/null || { echo "need 'cage' for nested run"; exit 2; }
  log="$(mktemp /tmp/nshell-smoke.XXXXXX.log)"
  echo "log: $log"
  timeout 18 cage -- qs --path "$PWD/shell.qml" >"$log" 2>&1 || code=$?
  code=${code:-0}
  # timeout kills cage after 18s -> exit 124 is the SUCCESS path (shell stayed up)
  if [ "$code" -ne 124 ]; then
    echo "nested run exited early (code $code), tail:"; tail -n 40 "$log"; exit 1
  fi
  if grep -Ei "TypeError|ReferenceError|failed to load|Component\.onCompleted.*fail" "$log"; then
    echo "QML errors above"; exit 1
  fi
  echo "nested smoke OK (no QML errors in 18s)"
fi
