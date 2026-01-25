#!/bin/bash
# Install dependencies
if [ -f "rasp-bridge/requirements.txt" ]; then
    pip install -r rasp-bridge/requirements.txt
else
    echo "requirements.txt not found in rasp-bridge/"
fi

# Create systemd service for the API
echo "Creating systemd service for Rasp Bridge API..."
SERVICE_FILE="/etc/systemd/system/rasp-bridge.service"

# Get current user and directory
CURRENT_USER=$USER
# We assume the script is run from project root, so we get absolute path
PROJECT_DIR=$(pwd)/rasp-bridge
PYTHON_EXEC=$(which python3)

# Note: running as user with `sudo systemctl` in python script requires this user 
# to have passwordless sudo for systemctl or specific commands.
# For simplicity in this personal project, we will run the service as root 
# OR you should configure /etc/sudoers.d/ for the user.
# If running as root, 'sudo' inside python script is redundant but harmless.
# Let's run as root to avoid permission issues with systemctl calls.

CAT_EOF_CONTENT="[Unit]
Description=Rasp Bridge API
After=network.target

[Service]
User=root
WorkingDirectory=$PROJECT_DIR
ExecStart=$PYTHON_EXEC -m uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target"

echo "$CAT_EOF_CONTENT" | sudo tee "$SERVICE_FILE"

sudo systemctl daemon-reload
sudo systemctl enable rasp-bridge
sudo systemctl start rasp-bridge

echo "✅ Rasp Bridge API started on port 8000!"
echo "Try: http://<raspberry-ip>:8000/vpn/status"
