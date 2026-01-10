# File history

- Thunar stores its history here -

```bash
~/.local/share/recently-used.xbel
```

- Any other gtk apps should also store it here.

- To force not to store history add the following line in
  `~/.config/gtk-3.0/settings.ini`

```toml
[Settings]
gtk-recent-files-enabled=0
```

- If this is not respected, then make the `recently-used` file readonly -

```bash
sudo chattr +i ~/.local/share/recently-used.xbel
```

- To remove this readonly status

```bash
sudo chattr -i ~/.local/share/recently-used.xbel
```
