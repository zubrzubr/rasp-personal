#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting Docker Setup for Raspberry Pi...${NC}"

# 1. Update and Install Prerequisites
echo -e "${YELLOW}🔄 Updating package index and installing prerequisites...${NC}"
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# 2. Add Docker GPG Key
echo -e "${YELLOW}🔑 Adding Docker GPG key...${NC}"
sudo install -m 0755 -d /etc/apt/keyrings
# Load OS release info (ID, VERSION_CODENAME, etc.)
source /etc/os-release

# Safe removal if it exists to avoid conflicts
if [ -f /etc/apt/keyrings/docker.gpg ]; then
    sudo rm /etc/apt/keyrings/docker.gpg
fi

# Download GPG key using the ID from os-release (likely 'debian' or 'raspbian')
curl -fsSL "https://download.docker.com/linux/$ID/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 3. Set up Repository
echo -e "${YELLOW}📂 Setting up Docker repository...${NC}"
echo \
  "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$ID \
  $VERSION_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4. Install Docker
echo -e "${YELLOW}📦 Installing Docker Engine, CLI, and Compose...${NC}"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5. User Group Configuration
echo -e "${YELLOW}👤 Adding $USER to 'docker' group...${NC}"
sudo usermod -aG docker "$USER"

# 6. Enable Service
echo -e "${YELLOW}🔌 Enabling Docker service...${NC}"
sudo systemctl enable docker
sudo systemctl start docker

echo -e "${GREEN}✅ Docker setup complete!${NC}"
echo -e "${YELLOW}⚠️  You may need to log out and log back in (or reboot) for group changes to take effect.${NC}"
echo -e "ℹ️  Check status with: docker version"
