#!/bin/sh
# Creates and enables two systemd services for Wake-on-Wireless-LAN (WoWLAN):
#   - wowlan.service: enables magic packet wakeup on boot
#   - wowlan-resume.service: re-enables it after resume from suspend
# Logs output to systemd journal (journalctl -u wowlan.service)

echo "Creating WoWLAN systemd services..."

sudo tee /etc/systemd/system/wowlan.service <<'EOF'
[Unit]
Description=Enable WoWLAN magic packet
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/iw phy0 wowlan enable magic-packet
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
echo "Created wowlan.service"

sudo tee /etc/systemd/system/wowlan-resume.service <<'EOF'
[Unit]
Description=Re-enable WoWLAN magic packet after suspend
After=suspend.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/iw phy0 wowlan enable magic-packet
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=suspend.target
EOF
echo "Created wowlan-resume.service"

sudo systemctl daemon-reload
sudo systemctl enable --now wowlan.service
echo "wowlan.service enabled and started"
sudo systemctl enable wowlan-resume.service
echo "wowlan-resume.service enabled"

echo "Done! Verify with: iw phy0 wowlan show"
