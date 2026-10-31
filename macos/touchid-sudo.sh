#!/usr/bin/env bash
# Touch ID für sudo. /etc/pam.d/sudo_local übersteht macOS-Updates. Braucht sudo.
set -euo pipefail
FILE=/etc/pam.d/sudo_local
if grep -qs '^[^#]*pam_tid.so' "$FILE"; then echo "Touch ID für sudo ist schon aktiv."; exit 0; fi
sudo tee "$FILE" >/dev/null <<'PAM'
# sudo_local: local config file which survives system update and is included for sudo
auth       sufficient     pam_tid.so
PAM
echo "Touch ID für sudo aktiviert."
