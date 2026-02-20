#!/usr/bin/env sh

INSTALL_DIR="$HOME/.mozilla/native-messaging-hosts"
BINARY="$INSTALL_DIR/native_main"
MANIFEST="$INSTALL_DIR/tridactyl.json"

usage() {
  echo "Usage: $(basename "$0") [--install | --remove]"
  echo ""
  echo "  --install   Download and install Tridactyl native messenger to:"
  echo "              $INSTALL_DIR"
  echo ""
  echo "  --remove    Remove the native messenger and manifest from:"
  echo "              $INSTALL_DIR"
}

install() {
  VERSION=$(curl -sSL https://api.github.com/repos/tridactyl/native_messenger/releases/latest |
    grep "tag_name" | cut -d':' -f2- | sed 's|[^0-9\.]||g')

  echo "Installing Tridactyl native messenger v$VERSION..."
  mkdir -p "$INSTALL_DIR"

  curl -sSL -o "$BINARY" \
    "https://github.com/tridactyl/native_messenger/releases/download/$VERSION/native_main-Linux"
  chmod +x "$BINARY"

  curl -sSL "https://raw.githubusercontent.com/tridactyl/native_messenger/$VERSION/tridactyl.json" |
    sed "s|REPLACE_ME_WITH_SED|$BINARY|" \
      >"$MANIFEST"

  echo "Done. Run ':native' in Firefox to verify."
}

remove() {
  echo "Removing Tridactyl native messenger..."
  rm -f "$BINARY" "$MANIFEST"
  rmdir --ignore-fail-on-non-empty "$INSTALL_DIR"
  echo "Done."
}

case "$1" in
--install) install ;;
--remove) remove ;;
*) usage ;;
esac
