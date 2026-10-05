#!/bin/bash
# karryn-steam-fix.sh - add the Steam achievements / overlay fix to an existing
# rpgmaker-linux (bakustarver/rpgmakermlinux-cicpoffs) install.
#
# Install or update the fix:
#   wget -qO- "https://raw.githubusercontent.com/DanielUlises98/rpgmakermlinux-cicpoffs-karryn-steam/steam-greenworks/karryn-steam-fix.sh" | bash
# Undo it (put the original launcher back):
#   wget -qO- "https://raw.githubusercontent.com/DanielUlises98/rpgmakermlinux-cicpoffs-karryn-steam/steam-greenworks/karryn-steam-fix.sh" | bash -s -- --restore
#
# Options: --restore   put back the launcher saved before the fix
#          --force     install even if your rpgmaker-linux is not the version this fix was made for
#
# The fix replaces one file: nwjs/packagefiles/nwjsstart-cicpoffs.sh (the launcher).
# The original is kept next to it as nwjsstart-cicpoffs.sh.bak-before-steam-fix.
# License: GPL-3.0, like the project it modifies.
set -euo pipefail

FIX_REPO="DanielUlises98/rpgmakermlinux-cicpoffs-karryn-steam"
FIX_BRANCH="steam-greenworks"
BASE_VERSION="1.1.9"    # rpgmaker-linux version this fix is based on
NAME="nwjsstart-cicpoffs.sh"
URL="https://raw.githubusercontent.com/$FIX_REPO/$FIX_BRANCH/nwjs/packagefiles/$NAME"

mode="install"; force=""
for arg in "$@"; do
  case "$arg" in
    --restore) mode="restore" ;;
    --force) force=true ;;
    -h|--help) sed -n '2,16p' "$0" 2>/dev/null || true; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

say() { echo "[karryn-steam-fix] $*"; }
die() { echo "[karryn-steam-fix] ERROR: $*" >&2; exit 1; }

# Find the installed launcher (follows the rpgmaker-linux command, then the default places).
launcher=""
if [ -e "$HOME/.local/bin/rpgmaker-linux" ]; then
  launcher="$(readlink -f "$HOME/.local/bin/rpgmaker-linux")"
fi
if [ -z "$launcher" ] || [ ! -f "$launcher" ]; then
  base="$HOME/desktopapps"
  if [ -r "$HOME/.config/defrpgmakerlinuxpath.txt" ]; then
    read -r base < "$HOME/.config/defrpgmakerlinuxpath.txt" || true
    base="${base%/}"
  fi
  launcher="$base/nwjs/nwjs/packagefiles/$NAME"
fi
[ -f "$launcher" ] || die "rpgmaker-linux is not installed (no $NAME found).
Install it first with:
  wget -qO- \"https://raw.githubusercontent.com/bakustarver/rpgmakermlinux-cicpoffs/main/installgithub.sh\" | bash"

dir="$(dirname "$launcher")"
backup="$dir/$NAME.bak-before-steam-fix"
say "Launcher found: $launcher"

if [ "$mode" = "restore" ]; then
  [ -f "$backup" ] || die "no backup found ($backup), nothing to restore."
  cp -p "$backup" "$dir/.$NAME.restore"
  mv -f "$dir/.$NAME.restore" "$launcher"
  say "Original launcher restored. (The backup is still at $backup)"
  exit 0
fi

# Download the fixed launcher.
tmp="$(mktemp)"; trap 'rm -f "$tmp" "$tmp.dl"' EXIT
say "Downloading the fixed launcher ..."
if command -v wget >/dev/null 2>&1; then
  wget -qO "$tmp.dl" "$URL" || die "download failed: $URL"
elif command -v curl >/dev/null 2>&1; then
  curl -fsSL -o "$tmp.dl" "$URL" || die "download failed: $URL"
else
  die "neither wget nor curl is available to download the fix."
fi
sed '/#REMOVEDEBUG/d' "$tmp.dl" > "$tmp"
grep -q 'steamgreenworksfunc' "$tmp" && bash -n "$tmp" \
  || die "the downloaded file doesn't look right, nothing was changed."

if cmp -s "$tmp" "$launcher"; then
  say "The fix is already installed and up to date. Nothing to do."
  exit 0
fi

already_fixed=""
grep -q 'steamgreenworksfunc' "$launcher" && already_fixed=true

if [ -z "$already_fixed" ]; then
  installed_version="$(sed -n "s/^version='\(.*\)'/\1/p" "$launcher" | head -1)"
  if [ "$installed_version" != "$BASE_VERSION" ] && [ -z "$force" ]; then
    die "your rpgmaker-linux is version ${installed_version:-unknown}, but this fix was made for $BASE_VERSION.
Installing it would replace your launcher with an older/different one, so nothing was changed.
If you understand that, run this again with --force."
  fi
  cp -p "$launcher" "$backup"
  say "Original launcher saved as $backup"
else
  say "Updating an earlier version of the fix."
fi

chmod --reference="$launcher" "$tmp"
cp -p "$tmp" "$dir/.$NAME.new"
mv -f "$dir/.$NAME.new" "$launcher"
say "Done! The Steam achievements fix is installed."
say "Note: 'rpgmaker-linux --fullupdate' or reinstalling rpgmaker-linux removes the fix; just run this script again afterwards."
