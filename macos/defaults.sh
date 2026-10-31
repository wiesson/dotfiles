#!/usr/bin/env bash
# macOS-Einstellungen fürs Terminal. Ohne sudo, wirkt nach dem nächsten Login.
set -euo pipefail
defaults write -g KeyRepeat -int 2                    # schnelle Tastenwiederholung
defaults write -g InitialKeyRepeat -int 15            # kurze Verzögerung vor der Wiederholung
defaults write -g ApplePressAndHoldEnabled -bool false # Wiederholung statt Akzent-Popup
echo "macOS-Defaults gesetzt (wirken nach dem nächsten Login)."
