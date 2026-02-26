#!/bin/bash

sudo tee /usr/local/bin/ssh-inhibit-sleep.sh >/dev/null <<'EOF'
#!/bin/bash
while true; do
    if who | grep -q "pts/"; then
        systemd-inhibit --what=sleep --who="ssh" --why="SSH session active" \
            sh -c 'while who | grep -q pts/; do sleep 5; done'
    fi
    sleep 5
done
EOF

sudo chmod +x /usr/local/bin/ssh-inhibit-sleep.sh

sudo tee /etc/systemd/system/ssh-inhibit-sleep.service >/dev/null <<'EOF'
[Unit]
Description=Inhibit sleep during active SSH sessions
After=network.target

[Service]
ExecStart=/usr/local/bin/ssh-inhibit-sleep.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable --now ssh-inhibit-sleep.service
