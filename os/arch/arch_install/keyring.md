# Arch Hyprland VS Code Keyring Setup

## Install Packages

- `gnome-keyring`
- `seahorse`

## PAM Config (`/etc/pam.d/login`)

- Note this is for TTY login only.
- Add these lines:

```
auth       optional     pam_gnome_keyring.so               # Unlocks keyring on login
session    optional     pam_gnome_keyring.so auto_start    # Starts daemon
password   optional     pam_gnome_keyring.so               # Updates keyring password if system password changes
```

- Check auth and session stack order (after system-local-login).

So final file will look like -

```
#%PAM-1.0

auth       requisite    pam_nologin.so
auth       include      system-local-login
auth	   optional     pam_gnome_keyring.so            # Added
account    include      system-local-login
session    include      system-local-login
session    optional     pam_gnome_keyring.so auto_start # Added
password   include      system-local-login
password   optional     pam_gnome_keyring.so            # Added
```

## Hyprland Config (`hyprland.conf`)

```conf
exec-once = /usr/bin/gnome-keyring-daemon --start --components=secrets # Starts daemon
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP # Fixes env visibility
```

## Shell Config

```bash
if [ -n "$DESKTOP_SESSION" ]; then
    eval $(gnome-keyring-daemon --start)
    export SSH_AUTH_SOCK
fi
```

## VS Code Config (`~/.vscode/argv.json`)

- Force VS Code to use the backend:

```json
{ "password-store": "gnome-libsecret" }
```
