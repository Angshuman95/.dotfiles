# Fixing electron Apps in Wayland

- Some electron apps (like bruno) looks rubbish in wayland. This is probably
  because it doesn't support wayland by default.

- Check that
  - Launch the app
  - Run `hyprctl clients | less` and check the apps. The app in question
    should have `xwayland: 1` which means it's not working as expected.
  - Run the following command and check if issue is fixed -

```bash
bruno --ozone-platform=wayland
```

- If this fixes the issue we need to make it permanent.

- For desktop launching

```bash
# Copy the application shortcut in home
cp /usr/share/applications/bruno.desktop ~/.local/share/applications/
```

- Open the local shortcut and add the following - Add the option before %U

```toml
[Desktop Entry]
Name=Bruno
Exec=/opt/Bruno/bruno --ozone-platform=wayland %U
Terminal=false
Type=Application
Icon=bruno
StartupWMClass=Bruno
MimeType=x-scheme-handler/bruno;
Comment=Opensource API Client for Exploring and Testing APIs
Categories=Development;
```

- If launching from shell, add this as an alias.
