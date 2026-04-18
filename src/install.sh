#!/bin/bash
# fsociety — Installation Sequence

set -e

cat << 'EOF'
===================================================================
d88888b .d8888.  .d88b.   .o88b. d888888b d88888b d888888b db    db
88'     88'  YP .8P  Y8. d8P  Y8   `88'   88         88    `8b  d8'
88ooo   `8bo.   88    88 8P         88    88oooooo   88     `8bd8'
88        `Y8b. 88    88 8b         88    88         88       88
88      db   8D `8b  d8' Y8b  d8   .88.   88.        88       88
YP      `8888Y'  `Y88P'   `Y88P' Y888888P Y88888P    YP       YP
===================================================================
EOF

echo "[*] Initializing installation sequence..."

if [ "$EUID" -ne 0 ]; then
    echo "[-] Control is an illusion. But root privileges are required."
    echo "[-] Please run as root: sudo ./install.sh"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR" || { echo "[-] Failed to access installation directory"; exit 1; }

echo "[*] Preparing secure configuration directory..."
mkdir -p /etc/amnezia/amneziawg/
chmod 700 /etc/amnezia/amneziawg/

echo "[*] Copying core binaries to /usr/local/bin/..."
cp fsociety-core /usr/local/bin/
cp fsociety /usr/local/bin/

echo "[*] Setting execution permissions..."
chmod +x /usr/local/bin/fsociety-core
chmod +x /usr/local/bin/fsociety

echo "[*] Installing systemd daemon..."
cp fsociety.service /etc/systemd/system/
systemctl daemon-reload

echo "[*] Configuring passwordless access for fsociety..."
echo "ALL ALL=(ALL) NOPASSWD: /usr/bin/ip netns exec fsociety_mask *" > /etc/sudoers.d/fsociety
chmod 440 /etc/sudoers.d/fsociety

echo "[+] Installation complete."

cat << 'EOF'

[ PHASE 1: PREPARATION ]
1. Ensure 'amneziawg-dkms' and 'amneziawg-tools' are installed.
2. Place your server config at: /etc/amnezia/amneziawg/fsociety.conf

[ PHASE 2: DEPLOYMENT ]
3. Enable the encryption engine:
   $ sudo systemctl enable --now fsociety.service

[ PHASE 3: OPERATION ]
4. To run any application through the secure tunnel:
   $ fsociety [OPTIONS] <command> [args...]

Examples:
   $ fsociety Telegram                  # Runs Telegram through the secure tunnel
   $ fsociety curl ifconfig.me          # Checks the IP address of the VPN tunnel
   $ fsociety --isolate firefox         # Runs Firefox in isolated session
EOF
