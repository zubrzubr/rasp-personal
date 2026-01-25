#!/bin/bash

# Define the aliases content
ALIASES_CONTENT='
# VPN Aliases
alias vpn-start="sudo systemctl start openvpn-client@clearvpn"
alias vpn-stop="sudo systemctl stop openvpn-client@clearvpn"

vpn-status() {
    if systemctl is-active --quiet openvpn-client@clearvpn; then
        echo "✅ VPN is CONNECTED"
        echo "🌍 IP info:"
        ip -4 addr show tun0 | grep inet | awk '\''{print $2}'\''
    else
        echo "❌ VPN is DISCONNECTED"
    fi
}
'

# File to modify
BASHRC="$HOME/.bashrc"

# Check if aliases already exist
if grep -q "alias vpn-start" "$BASHRC"; then
    echo "⚠️  VPN aliases already exist in $BASHRC"
else
    echo "✍️  Adding VPN aliases to $BASHRC..."
    echo "$ALIASES_CONTENT" >> "$BASHRC"
    echo "✅ Aliases added!"
    echo "ℹ️  Run '\''source ~/.bashrc'\'' or restart your terminal to use them."
fi
