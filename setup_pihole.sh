#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting Pi-hole setup...${NC}"

# 1. Directories
echo -e "${YELLOW}📂 Creating directories...${NC}"
mkdir -p pihole/etc-pihole
mkdir -p pihole/etc-dnsmasq.d
echo -e "${GREEN}✅ Directories created.${NC}"

# 2. Port 53 check (systemd-resolved)
echo -e "${YELLOW}🔍 Checking port 53 usage...${NC}"
# Check using ss (socket statistics) which is standard on most modern Linux distros
if sudo ss -tulpn | grep ':53 ' | grep -q 'systemd-res'; then
    echo -e "${RED}⚠️  Port 53 is occupied by systemd-resolved!${NC}"
    echo "Pi-hole requires port 53. systemd-resolved prevents Docker from binding to it."
    
    read -p "Do you want to automatically fix this (disable DNSStubListener)? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}🔧 Disabling DNSStubListener in /etc/systemd/resolved.conf...${NC}"
        
        # Backup config
        sudo cp /etc/systemd/resolved.conf /etc/systemd/resolved.conf.bak
        
        # Uncomment and change to no, or just append/replace
        # We try to replace if it exists commented or uncommented
        if grep -q "DNSStubListener=" /etc/systemd/resolved.conf; then
             sudo sed -i 's/^#*DNSStubListener=.*/DNSStubListener=no/' /etc/systemd/resolved.conf
        else
             echo "DNSStubListener=no" | sudo tee -a /etc/systemd/resolved.conf
        fi
        
        # Create symlink for resolv.conf if needed (often necessary when disabling stub listener)
        # sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
        
        echo -e "${YELLOW}🔄 Restarting systemd-resolved...${NC}"
        sudo systemctl restart systemd-resolved
        echo -e "${GREEN}✅ systemd-resolved updated.${NC}"
    else
        echo -e "${YELLOW}ℹ️  Skipping automatic fix. You might encounter 'address already in use' errors.${NC}"
    fi
else
    echo -e "${GREEN}✅ Port 53 seems free or not taken by systemd-resolved.${NC}"
fi

# 3. Environment variables
if [ ! -f .env ]; then
    echo -e "${YELLOW}📝 Creating .env file...${NC}"
    touch .env
fi

if ! grep -q "PIHOLE_PASSWORD" .env; then
    echo -e "${YELLOW}🔐 Setting up PIHOLE_PASSWORD...${NC}"
    read -sp "Enter Pi-hole password (leave empty to generate random): " PASSWORD
    echo
    if [ -z "$PASSWORD" ]; then
        if command -v openssl &> /dev/null; then
            PASSWORD=$(openssl rand -base64 12)
        else
            PASSWORD=$(date +%s | sha256sum | base64 | head -c 12)
        fi
        echo -e "Generated password: ${GREEN}$PASSWORD${NC}"
        echo -e "⚠️  Save this password!"
    fi
    echo "PIHOLE_PASSWORD=$PASSWORD" >> .env
    echo -e "${GREEN}✅ Password saved to .env${NC}"
else
    echo -e "${GREEN}✅ PIHOLE_PASSWORD found in .env${NC}"
fi

# 4. Docker Compose
echo -e "${YELLOW}🐳 Configuring Docker...${NC}"
sudo systemctl enable docker
echo -e "${GREEN}✅ Docker service enabled on boot.${NC}"

echo -e "${YELLOW}🚀 Starting Pi-hole with Docker Compose...${NC}"

# Source .env and export PIHOLE_PASSWORD so docker compose can substitute it
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

if docker compose up -d; then
    echo -e "${GREEN}🎉 Pi-hole Setup & Start Complete!${NC}"
    IP=$(hostname -I | cut -d' ' -f1)
    echo -e "Admin Interface: http://$IP/admin"
else
    echo -e "${RED}❌ Docker Compose failed. Check logs.${NC}"
fi
