#!/bin/sh
# Start matrix-saver the way xscreensaver would, inside a throwaway X
# server, and check that cmatrix runs and the xterm covers the window.
set -eu
cd "$(dirname "$0")/.."

W=1280 H=720
if [ -z "${DISPLAY-}" ] || [ "${SMOKE_OWN_X-1}" = 1 ]; then
  Xvfb :99 -screen 0 ${W}x${H}x24 >/dev/null 2>&1 &
  xpid=$!
  trap 'kill $xpid 2>/dev/null' EXIT
  export DISPLAY=:99
  sleep 1
fi

root=$(xwininfo -root | awk '/Window id:/{print $4}')
XSCREENSAVER_WINDOW=$root timeout 5 ./matrix-saver &
sleep 3

pgrep -x cmatrix >/dev/null || { echo "FAIL: cmatrix is not running"; exit 1; }
size=$(xwininfo -root -tree | awk '/"matrix-saver"/ { split($5, g, "+"); print g[1]; exit }')
echo "xterm window: $size (screen ${W}x${H})"
[ "$size" = "${W}x${H}" ] || { echo "FAIL: xterm does not cover the window"; exit 1; }
wait || true
echo PASS
