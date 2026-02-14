# Installing OpenTabletDriver

- For most use cases drivers like `libwacom` (for wacom) etc work.
  They have the following kernel modules
  - `wacom`
  - `hid_uclogic` (for huion, xp-pen etc.)

  Use `lsmod | grep <name>` to check for kernel modules.

- If OTD is to be installed - Install it from chaotic-aur.

- Enable it in user mode

```sh
systemctl --user enable --now opentabletdriver.service
```

- Manually unload existing module

```sh
sudo rmmod wacom
```

- Blacklist the wacom module. Add the following config file

```sh
# Add the file
sudoedit nvim /etc/modprobe.d/blacklist-tablet.conf
```

  - Add the following lines

  ```text
  blacklist wacom
  blacklist hid_uclogic
  ```
