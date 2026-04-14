#!/bin/bash
# fsociety — Installation Sequence

set -e

cat << 'EOF'
==================================================
  __               _      _       
 / _|___  ___  ___(_)___ | |_ _  _ 
|  _(_-< / _ \/ __| / -_)|  _| || |
|_| /__/ \___/\___|_\___| \__|\_, |
                              |__/ 
==================================================
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
   $ fsociety <command>

Example:
   $ fsociety Telegram
   $ fsociety firefox -P VPN

==================================================
Everything is in your hands now. 
Society is a lie. Control is an illusion.
==================================================
EOF
