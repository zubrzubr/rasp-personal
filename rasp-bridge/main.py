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
    # Use nsenter to check status on HOST
    # -t 1: Target pid 1 (host init)
    # -m -u -n -i: Enter mount, uts, net, ipc namespaces
    command = f"nsenter -t 1 -m -u -n -i systemctl is-active --quiet {VPN_SERVICE_NAME}"
    
    result = subprocess.run(
        command,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    # 0 = active, 3 = inactive
    is_active = (result.returncode == 0)
    logger.info(f"Status check return code: {result.returncode}")
    return {"active": is_active, "status": "ON" if is_active else "OFF"}

@app.get("/vpn/on")
def vpn_turn_on():
    """Turn VPN on."""
    # Use nsenter to run start command on HOST
    command = f"nsenter -t 1 -m -u -n -i systemctl start {VPN_SERVICE_NAME}"
    success, output = run_command(command)
    if success:
        return {"status": "success", "message": "VPN started"}
    else:
        raise HTTPException(status_code=500, detail=f"Failed to start VPN: {output}")

@app.get("/vpn/off")
def vpn_turn_off():
    """Turn VPN off."""
    # Use nsenter to run stop command on HOST
    command = f"nsenter -t 1 -m -u -n -i systemctl stop {VPN_SERVICE_NAME}"
    success, output = run_command(command)
    if success:
        return {"status": "success", "message": "VPN stopped"}
    else:
        raise HTTPException(status_code=500, detail=f"Failed to stop VPN: {output}")
