# Fonts

## TTY fonts

- A nice `terminus` font is installed.

- Add the folliwing to `/etc/vconsole.conf`

```conf
FONT=ter-128n
```

- For a 4k Screen
  - ter-132n (Size 32): The one I found too big.
  - ter-128n (Size 28): ~12% smaller. Usually the sweet spot for 27" 4K.
  - ter-124n (Size 24): ~25% smaller. Might be getting too small to read comfortably.

- Re-build kernel initramfs

```bash
sudo mkinitcpio -P
```
