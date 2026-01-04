#!/bin/bash

# ==============================================================================
# Arch Linux Hyprland + Noctalia Setup Script
# Based on user history
# ==============================================================================

# Exit immediately if a command exits with a non-zero status
set -e

# Colors for logging
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[SETUP]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check if script is run as root (we generally shouldn't, except for specific parts)
if [ "$EUID" -eq 0 ]; then
    warn "Please run this script as a normal user, not root."
    warn "The script will ask for sudo password when necessary."
    exit 1
fi

# ==============================================================================
# 1. Core System & AUR Helper
# ==============================================================================
log "Updating system..."
sudo pacman -Syu --noconfirm

if ! command -v yay &> /dev/null; then
    log "Installing yay (AUR Helper)..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
else
    log "yay is already installed."
fi

# ==============================================================================
# 2. Package Lists
# ==============================================================================

# Official Arch Repo Packages
PACMAN_PKGS=(
    # Desktop Environment / Hyprland Core
    "hyprland"
    "uwsm"
    "cmake"             # hyprpm dependencies
    "cpio"
    "meson"
    "xdg-desktop-portal-hyprland"
    "hyprpolkitagent"
    "polkit-gnome"
    "hypridle"
    "qt6ct"             # Qt theming
    "bluez"             # Bluetooth
    "bluez-utils"
    "brightnessctl"     # Screen brightness
    
    # Terminal & Shell
    "ghostty"
    "zsh"
    "tmux"
    "neovim"
    "wget"
    "unzip"
    "zip"
    "git"
    "tree"
    "inotify-tools"     # Needed for file watching scripts
    "ripgrep"           # Fast search (rg)
    "stow"              # Dotfile management
    "eza"               # ls replacement
    "fzf"               # Fuzzy finder
    "zoxide"            # cd replacement
    "htop"              # Process viewer
    "ncdu"              # Disk usage
    "lazygit"           # Git TUI
    "python"

    # File Management (Thunar + plugins)
    "thunar"
    "gvfs"
    "gvfs-mtp"
    "tumbler"
    "thunar-volman"
    "thunar-archive-plugin"
    "file-roller"
    "ffmpegthumbnailer"

    # Network
    "networkmanager"

    # snapshots
    "snapper"
    "btrfs-assistant"

    # vlc
    "vlc"
    "ffmpeg"
    "vlc-plugin-ffmpeg"

    # keyring
    "gnome-keyring"
    "seahorse"
)

# AUR Packages
AUR_PKGS=(
    # Browser
    "zen-browser-bin"
    
    # Fonts
    "terminus-font"
    "ttf-jetbrains-mono-nerd"
    "ttf-firacode-nerd"
    "noto-fonts"
    
    # Audio
    "pwvucontrol"       # Pipewire Volume Control
    "cava"              # Audio visualizer
    
    # Theming
    "adw-gtk-theme"     # Libadwaita theme for GTK3
    "nwg-look"          # GTK3 settings editor
    "matugen-bin"       # Material You color generator
    
    # Tools
    "walker"            # App launcher
    "wlsunset"          # Night light
    "imv"               # Image viewer
    "vlc"               # Video player
    "cliphist"          # Clipboard manager
    "nvm"               # Node Version Manager
    "rustup"            # Rust toolchain
    
    # Elephant Ecosystem (as per history)
    "elephant-bin"
    "elephant-clipboard-bin"
    "elephant-desktopapplications-bin"
    
    # Noctalia Shell Requirements
    "quickshell"
    "gpu-screen-recorder"
    "ddcutil"

    # Screenshot
    "flameshot"
    "grim"

    # PDF
    "sioyek"

    # VSCode
    "visual-studio-code-bin"
)

# ==============================================================================
# 3. Installation Loop
# ==============================================================================

log "Installing Official Packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

log "Installing AUR Packages..."
yay -S --needed --noconfirm "${AUR_PKGS[@]}"

# ==============================================================================
# 4. Configurations & setup
# ==============================================================================

log "Setting up Rust..."
rustup default stable

log "Setting up Node (via NVM)..."
# Source nvm script provided by the package to use it immediately
source /usr/share/nvm/init-nvm.sh
nvm install --lts
nvm use --lts

log "Cloning Neovim Configuration..."
if [ -d "$HOME/.config/nvim" ]; then
    warn "Neovim config already exists. Backing up to .config/nvim.bak"
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
fi
git clone https://github.com/Angshuman95/nvim-config.git "$HOME/.config/nvim"

log "Setting up Tmux Plugin Manager..."
if [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
fi

log "Install sdkman"
if [ -d "$HOME/.sdkman" ]; then
    warn "Sdkman already exists. Backing up to .sdkman.bak"
    mv "$HOME/.sdkman" "$HOME/.sdkman.bak"
fi
# This prevents the script from pausing to ask questions
export sdkman_auto_answer=true
export sdkman_selfupdate_feature=false

curl -s "https://get.sdkman.io" | bash

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# ==============================================================================
# 5. Shell Setup (Oh My Zsh + P10k)
# ==============================================================================
log "Setting up Zsh..."

# Install Oh My Zsh (Unattended)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Powerlevel10k
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
fi

# Install Zsh Plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"

[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

[ ! -d "$ZSH_CUSTOM/plugins/zsh-vi-mode" ] && \
    git clone https://github.com/jeffreytse/zsh-vi-mode "$ZSH_CUSTOM/plugins/zsh-vi-mode"

# Note: You still need to enable these in your .zshrc manually if you aren't stowing a config

# ==============================================================================
# 6. Noctalia Shell Setup
# ==============================================================================
log "Installing Noctalia Shell..."
mkdir -p "$HOME/.config/quickshell/noctalia-shell"
# Downloads the latest release and strips the first folder component to keep it clean
curl -sL https://github.com/noctalia-dev/noctalia-shell/releases/latest/download/noctalia-latest.tar.gz | tar -xz --strip-components=1 -C "$HOME/.config/quickshell/noctalia-shell"

# ==============================================================================
# 7. Services & Networking Clean up
# ==============================================================================
log "Configuring Services..."

# Bluetooth
sudo systemctl enable --now bluetooth

# Elephant Service (User specific)
# Using systemctl --user as per history, but checking if service file exists first is prudent
if systemctl --user list-unit-files | grep -q elephant.service; then
    systemctl --user enable --now elephant.service
else
    warn "Elephant service unit not found. You might need to log out/in or run 'elephant service enable' manually."
fi

# Networking Resolution
# Based on your history, you moved from iwd/systemd-networkd to NetworkManager
log "Resolving Network Conflicts..."
sudo systemctl disable --now iwd.service 2>/dev/null || true
sudo systemctl disable --now systemd-networkd.service 2>/dev/null || true
sudo systemctl disable --now wpa_supplicant.service 2>/dev/null || true

log "Enabling NetworkManager..."
sudo systemctl enable --now NetworkManager

# ==============================================================================
# 8. Final Cleanup
# ==============================================================================
log "Removing unused dependencies..."
# Use || true to prevent script failure if nothing to remove
sudo pacman -Qdtq | sudo pacman -Rns - || true

success "Installation Complete! Please reboot your system."
log "Don't forget to run 'p10k configure' after you launch zsh."
