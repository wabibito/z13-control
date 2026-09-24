#!/bin/sh
# Z13 Control installer.
#   curl -fsSL https://raw.githubusercontent.com/wabibito/z13-control/main/install.sh | sh
# Downloads the latest release package for your distribution and installs it.
set -eu

REPO=wabibito/z13-control
API=https://api.github.com/repos/$REPO/releases/latest

say() { printf '\033[1m%s\033[0m\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

[ "$(uname -m)" = x86_64 ] || die "this package is for x86_64 machines"
command -v curl >/dev/null || die "curl is required"

if command -v apt-get >/dev/null; then
    EXT=deb
elif command -v dnf >/dev/null; then
    EXT=rpm
elif command -v pacman >/dev/null; then
    EXT=pkg.tar.zst          # Arch, CachyOS, EndeavourOS, Manjaro
else
    die "no supported package manager found (apt, dnf or pacman)"
fi

# An existing install is upgraded in place; settings and saved profiles are kept.
CURRENT=""
case "$EXT" in
    deb) CURRENT=$(dpkg-query -W -f='${Version}' z13-control 2>/dev/null || true) ;;
    rpm) CURRENT=$(rpm -q --qf '%{VERSION}' z13-control 2>/dev/null || true) ;;
    *)   CURRENT=$(pacman -Q z13-control 2>/dev/null | awk '{sub(/-[0-9]+$/, "", $2); print $2}') ;;
esac

say "Finding the latest release…"
RELEASE=$(curl -fsSL "$API")
# Match this package by name, not just by extension: the release also carries
# the optional Rust service package, whose name ends in .deb too.
URL=$(printf '%s' "$RELEASE" \
    | grep -o "https://[^\"]*/z13-control[-_][0-9][^\"]*\.$EXT\"" | tr -d '"' | head -1)
LATEST=$(printf '%s' "$RELEASE" | sed -n 's/.*"tag_name": *"v\{0,1\}\([^"]*\)".*/\1/p' | head -1)
[ -n "$URL" ] || die "no .$EXT package in the latest release"
if [ -n "$CURRENT" ]; then
    [ "$CURRENT" = "$LATEST" ] && say "Version $CURRENT is already installed; reinstalling it." \
                               || say "Updating $CURRENT to $LATEST."
else
    say "Installing version $LATEST."
fi
FILE=$(mktemp -d)/$(basename "$URL")
say "Downloading $(basename "$URL")…"
curl -fsSL -o "$FILE" "$URL"

# pkexec shows a desktop password dialog; sudo is the fallback in a plain terminal.
if [ "$(id -u)" = 0 ]; then
    RUN=""
elif [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ] && command -v pkexec >/dev/null; then
    RUN="pkexec"
else
    RUN="sudo"
fi

say "Installing (you may be asked for your password)…"
# Upgrade, reinstall or downgrade, whichever this file turns out to be.
case "$EXT" in
    deb) $RUN apt-get install -y --reinstall --allow-downgrades "$FILE" ;;
    rpm) $RUN dnf install -y --allowerasing "$FILE" || $RUN dnf reinstall -y "$FILE" ;;
    *)   $RUN pacman -U --noconfirm "$FILE" ;;
esac

say "Done. Open “Z13 Control” from your apps, or run: z13 status"
say "Later updates: System → Updates in the app, or: z13 update"
say "Log out and back in once to get the top-bar menu."
