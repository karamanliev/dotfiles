#!/bin/sh
echo "Adding Keyd config..."

sudo tee /etc/keyd/default.conf <<EOF
[ids]
*

[main]
# Capslock: Esc when tapped, Control when held
capslock = overload(control, esc)

# Only LEFT control uses a custom control layer.
# Right control stays normal.
leftcontrol = layer(lctrl)

[lctrl:C]
# While holding LEFT control:
#   c -> Ctrl+Shift+c
#   v -> Ctrl+Shift+v
c = C-S-c
v = C-S-v

# Hyper keys
o = C-S-A-M-o
p = C-S-A-M-p
r = C-S-A-M-r

# Vim-style arrows with LeftCtrl held
h = left
j = down
k = up
l = right

# Hold LeftCtrl, then press LeftShift -> Hangeul
leftshift = hangeul
EOF

if command -v keyd >/dev/null 2>&1; then
  echo "Reloading using keyd..."
  sudo keyd reload

elif command -v keyd.rvaiya >/dev/null 2>&1; then
  echo "Reloading using keyd.rvaiya..."
  sudo keyd.rvaiya reload

else
  echo "Error: neither 'keyd' nor 'keyd.rvaiya' found in PATH"
  exit 1
fi

echo "Keyd config added!"
