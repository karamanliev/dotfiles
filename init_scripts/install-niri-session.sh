#!/bin/sh
echo "Installing Niri session to /usr/share/wayland-sessions/niri.desktop."

# Check if Niri is already installed, otherwise quit
if ! command -v niri-session >/dev/null 2>&1; then
  echo "Niri is not installed, quitting..."
  exit 1
fi

sudo tee /usr/share/wayland-sessions/niri.desktop >/dev/null <<EOF
[Desktop Entry]
Name=Niri
Comment=A scrollable-tiling Wayland compositor
Exec=$HOME/.nix-profile/bin/niri-session
Type=Application
DesktopNames=niri
EOF

echo "Niri session installed!"
