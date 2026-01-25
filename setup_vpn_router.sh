#!/bin/bash

# Settings
VPN_CONFIG_NAME="clearvpn" # Your file name without .conf
LAN_INTERFACE="eth0"       # Your cable interface (if Wi-Fi, change to wlan0)
VPN_INTERFACE="tun0"       # Interface created by OpenVPN

echo "🚀 Starting VPN router setup..."

# 1. Installing packages
echo "📦 Installing OpenVPN and utilities..."
sudo apt update
sudo apt install -y openvpn iptables iptables-persistent netfilter-persistent

# 2. Enabling IP Forwarding (router mode)
echo "twisted 🔀 Enabling IP Forwarding..."
# Uncomment line in sysctl.conf
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
# Apply immediately
sudo sysctl -p
echo "✅ IP Forwarding enabled."

# 3. OpenVPN Setup
echo "🛡️ Configuring OpenVPN..."
# Check if config exists in home folder
if [ -f "/home/$USER/$VPN_CONFIG_NAME.conf" ]; then
    echo "📄 Config found! Copying to /etc/openvpn/client/..."
    sudo cp "/home/$USER/$VPN_CONFIG_NAME.conf" "/etc/openvpn/client/$VPN_CONFIG_NAME.conf"
    
    # Fix permissions (this is important!)
    sudo chmod 600 "/etc/openvpn/client/$VPN_CONFIG_NAME.conf"
    
    # Enable autostart
    sudo systemctl enable openvpn-client@$VPN_CONFIG_NAME
    echo "✅ Service added to autostart."
else
    echo "⚠️ WARNING: File /home/$USER/$VPN_CONFIG_NAME.conf not found!"
    echo "⚠️ Please place the configuration file and run the script again or copy manually."
fi

# 4. IPtables (NAT) Setup
echo "walls 🔥 Configuring Firewall (NAT)..."

# Clear old NAT rules to avoid duplicates
sudo iptables -t nat -F
sudo iptables -t nat -X

# Main rule: masquerade all traffic going out through VPN (tun0)
sudo iptables -t nat -A POSTROUTING -o $VPN_INTERFACE -j MASQUERADE

# Allow traffic between LAN and VPN
sudo iptables -A FORWARD -i $VPN_INTERFACE -o $LAN_INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i $LAN_INTERFACE -o $VPN_INTERFACE -j ACCEPT

# Save rules persistently
sudo netfilter-persistent save

echo "🎉 Setup complete!"
echo "ℹ️ To start VPN manually: sudo systemctl start openvpn-client@$VPN_CONFIG_NAME"
echo "ℹ️ To check status: sudo systemctl status openvpn-client@$VPN_CONFIG_NAME"
