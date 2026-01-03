# Network notes

## Start openssh

```bash
sudo systemctl enable --now sshd
```

- Get IP address using

```bash
ip addr
```

- look for `wlan0` for wifi and find the ip with `192.168 ...` and verify with
  router app.

- Connect to machine using

```bash
ssh <username>@<ipaddress>
```

- Provide password of user when prompted.

## Install firewall

```bash
sudo pacman -S ufw
```

- Enable firewall

```bash
sudo ufw enable
```

- Autostart service now

```bash
sudo systemctl enable --now ufw
```

- Allow ssh

```bash
sudo ufw allow ssh
```

- Service status

```bash
sudo ufw status verbose
```
