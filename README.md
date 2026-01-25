# rasp-personal
Personal scripts for raspberry pi


## VPN Router config

1. sudo nano /etc/openvpn/client/clearvpn.conf
2. Copy config from clearvpn
3. Edit line with auth-user-pass and change it to:
    ```bash
    auth-user-pass /etc/openvpn/client/clearvpn-pass.txt
    ```
4. sudo nano /etc/openvpn/client/clearvpn-pass.txt
5. Add your credentials

## Aliases

Run `make setup-vpn-aliases` to add the following aliases to your `.bashrc`:

- `vpn-start`: Start the VPN connection.
- `vpn-stop`: Stop the VPN connection.
- `vpn-status`: Check the VPN connection status.

