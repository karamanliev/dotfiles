#!/bin/sh
echo "Creating pacman hook for creating pkglist.txt in dotfiles/arch"

sudo tee /etc/pacman.d/hooks/pkglist.hook <<EOF
[Trigger]
Operation = Install
Operation = Remove
Type = Package
Target = *

[Action]
When = PostTransaction
Exec = /bin/sh -c "/usr/bin/pacman -Qqe > $HOME/dotfiles/arch/pkglist.txt"
EOF

echo "Pacman hook created!"
