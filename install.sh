#!/bin/sh
# Per-user install of matrix-saver (no root needed).
#
#   ./install.sh               install to ~/.local/bin and add to xscreensaver
#   ./install.sh --activate    ...and make it the only screensaver in use
#   ./install.sh --uninstall   remove it again
#
# For a system-wide install (or packaging) use `make install` instead.
#
# SPDX-License-Identifier: MIT
set -eu

HERE=$(dirname "$(readlink -f "$0")")
BIN_DIR=${XDG_BIN_HOME:-$HOME/.local/bin}
CONF_DIR=${XDG_CONFIG_HOME:-$HOME/.config}/matrix-saver
XSS=$HOME/.xscreensaver
# Literal $HOME on purpose: xscreensaver runs this line through /bin/sh.
# shellcheck disable=SC2016
ENTRY='"Matrix (cmatrix)"  $HOME/.local/bin/matrix-saver'
[ "$BIN_DIR" = "$HOME/.local/bin" ] || ENTRY="\"Matrix (cmatrix)\"  $BIN_DIR/matrix-saver"

say() { printf '%s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }

backup_xss() {
  cp -p "$XSS" "$XSS.bak-$(date +%Y%m%d-%H%M%S)"
}

uninstall() {
  rm -f "$BIN_DIR/matrix-saver"
  say "Removed $BIN_DIR/matrix-saver"
  if [ -f "$XSS" ] && grep -q 'matrix-saver' "$XSS"; then
    backup_xss
    sed -i '/matrix-saver/d' "$XSS"
    say "Removed it from $XSS (backup saved next to it)"
  fi
  [ -d "$CONF_DIR" ] && say "Your settings in $CONF_DIR were left alone."
  exit 0
}

activate=no
case ${1-} in
  --uninstall) uninstall ;;
  --activate) activate=yes ;;
  "") ;;
  *) sed -n '2,8s/^# \{0,1\}//p' "$0" >&2; exit 2 ;;
esac

# --- dependencies ------------------------------------------------------------
missing=
for c in cmatrix xterm xwininfo xscreensaver; do
  command -v "$c" >/dev/null 2>&1 || missing="$missing $c"
done
if [ -n "$missing" ]; then
  warn "missing:$missing"
  if command -v apt-get >/dev/null 2>&1; then
    say "  sudo apt install cmatrix xterm x11-utils xscreensaver fonts-noto-cjk"
  elif command -v dnf >/dev/null 2>&1; then
    say "  sudo dnf install cmatrix xterm xwininfo xscreensaver google-noto-sans-cjk-fonts"
  elif command -v pacman >/dev/null 2>&1; then
    say "  sudo pacman -S cmatrix xterm xorg-xwininfo xscreensaver noto-fonts-cjk"
  elif command -v zypper >/dev/null 2>&1; then
    say "  sudo zypper install cmatrix xterm xwininfo xscreensaver noto-sans-cjk-fonts"
  fi
  say "Install those, then run this again."
  exit 1
fi

if [ "${XDG_SESSION_TYPE-}" = wayland ]; then
  warn "you are on a Wayland session; xscreensaver (and so matrix-saver)"
  warn "only works on X11.  Pick an Xorg session at the login screen."
fi

# --- files ---------------------------------------------------------------------
mkdir -p "$BIN_DIR"
install -m 755 "$HERE/matrix-saver" "$BIN_DIR/matrix-saver"
say "Installed $BIN_DIR/matrix-saver"

if [ ! -e "$CONF_DIR/config" ]; then
  mkdir -p "$CONF_DIR"
  install -m 644 "$HERE/matrix-saver.conf.example" "$CONF_DIR/config"
  say "Wrote default settings to $CONF_DIR/config"
fi

# --- register with xscreensaver ---------------------------------------------
if [ ! -f "$XSS" ]; then
  say ""
  say "No $XSS yet.  Open xscreensaver-settings once, change any"
  say "setting so it saves the file, then run ./install.sh again."
  exit 0
fi

backup_xss
if grep -q 'matrix-saver' "$XSS"; then
  say "Already listed in $XSS"
else
  # Put it first in the programs list.
  sed -i "/^programs:/a\\
		  $ENTRY		    \\\\n\\\\" "$XSS"
  say "Added \"Matrix (cmatrix)\" to $XSS"
fi

if [ "$activate" = yes ]; then
  # "selected" is an index into the full programs list, disabled ones too.
  idx=$(awk '
    /^programs:/ { p = 1; next }
    p && /matrix-saver/ { print n + 0; exit }
    p && /\\n\\/ { n++ }' "$XSS")
  sed -i -e 's/^mode:.*/mode:\t\tone/' -e "s/^selected:.*/selected:\t$idx/" "$XSS"
  say "Set it as the active screensaver"
fi

say ""
say "Done.  xscreensaver picks up the change by itself; preview with:"
say "  xscreensaver-settings      (or: matrix-saver -window)"
