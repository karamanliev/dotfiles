#!/bin/sh
echo "Creating apt hook for creating pkglist.txt in dotfiles/thinkpad"

sudo tee /etc/apt/apt.conf.d/99pkglist <<EOF
DPkg::Post-Invoke {"/usr/bin/apt-mark showmanual | sort > $HOME/dotfiles/thinkpad/pkglist.txt";};
EOF

echo "Apt hook created!"
