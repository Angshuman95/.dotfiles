# Enabling Bluetooth at startup

- Bluetooth is generally not enabled during startup. To enable it we need
  Bluetooth module in `initramfs`.

- Connect the Bluetooth device using normal way. Make sure it is **trusted**.

- Install `mkinitcpio-bluetooth` from aur.

- Add the following to the `HOOKS=` in `mkinitcpio.conf`

```conf
HOOKS=(base udev modconf keyboard keymap consolefont block bluetooth encrypt lvm2 resume filesystems fsck)
# Note the bluetooth module's position -----------------------^
```
