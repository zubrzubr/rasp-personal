from fastapi import FastAPI, HTTPException
import subprocess
import logging

app = FastAPI()

# Configuration
VPN_SERVICE_NAME = "openvpn-client@clearvpn"

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("rasp-bridge")

def run_command(command):
    try:
        result = subprocess.run(
            command,
            shell=True,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        return True, result.stdout.strip()
    except subprocess.CalledProcessError as e:
        logger.error(f"Command failed: {e.stderr}")
        return False, e.stderr.strip()


@app.get("/")
def read_root():
    return {"message": "Rasp Bridge API is running"}


@app.get("/vpn/status")
def get_vpn_status():
    """Check if VPN service is active."""
    # systemctl is-active returns 0 if active, non-zero otherwise
    success, _ = run_command(f"systemctl is-active --quiet {VPN_SERVICE_NAME}")
    # Apple Shortcuts often work best with simple text or explicit ON/OFF strings
    return {"active": success, "status": "ON" if success else "OFF"}

@app.get("/vpn/on")
def vpn_turn_on():
    """Turn VPN on."""
    # Running inside container with privileged=true and dbus mounted
    # We don't need sudo as we are root in container
    success, output = run_command(f"systemctl start {VPN_SERVICE_NAME}")
    if success:
        return {"status": "success", "message": "VPN started"}
    else:
        raise HTTPException(status_code=500, detail=f"Failed to start VPN: {output}")

@app.get("/vpn/off")
def vpn_turn_off():
    """Turn VPN off."""
    success, output = run_command(f"systemctl stop {VPN_SERVICE_NAME}")
    if success:
        return {"status": "success", "message": "VPN stopped"}
    else:
        raise HTTPException(status_code=500, detail=f"Failed to stop VPN: {output}")
