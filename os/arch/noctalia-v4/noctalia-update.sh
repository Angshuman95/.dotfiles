#!/bin/sh

noctalia_path="/home/angshuman/.config/quickshell/noctalia-shell"

if [ -e "$noctalia_path" ]; then
    echo "Noctalia shell present."
    mv $noctalia_path "${noctalia_path}-bak"
    echo "Moved noctalia shell to '${noctalia_path}-bak'."
fi

mkdir -p "$noctalia_path"
echo "Noctalia shell directory created."

curl -sL https://github.com/noctalia-dev/noctalia-shell/releases/latest/download/noctalia-latest.tar.gz \
| tar -xz --strip-components=1 -C "$noctalia_path"
echo "Downloaded Noctalia shell."

read -p "Restart hyprland? (Y/n) : " answer

if [ "$answer" = "Y" ] || [ "$answer" = "y" ]; then
    loginctl terminate-user "$USER"
fi
