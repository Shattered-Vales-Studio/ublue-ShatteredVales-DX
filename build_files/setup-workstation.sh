#!/usr/bin/env bash
set -euo pipefail

echo "=========================================================="
echo "    Shattered Vales Studio - Workstation Setup            "
echo "=========================================================="

# 1. Ensure current user is in necessary hardware access groups
echo "===> Checking hardware groups for USB/WearOS debugging..."
CURRENT_USER="$USER"
for grp in plugdev dialout; do
    if ! id -nG "$CURRENT_USER" \vert{} grep -qw "$grp"; then
        echo "Adding $CURRENT_USER to$grp group..."
        sudo usermod -aG "$grp" "$CURRENT_USER" || true
    fi
done

# 2. Desktop Flatpaks from Flathub
echo "===> Installing studio desktop applications..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

FLATPAK_APPS=(
    "com.google.AndroidStudio"          # Android & WearOS IDE
    "com.unity.UnityHub"                # Unity Editor Manager
    "com.jetbrains.Toolbox"             # Rider, DataGrip, WebStorm manager
    "io.podman_desktop.PodmanDesktop"   # GUI container management
    "com.usebottles.bottles"            # Sandboxed Wine/Proton runner for Windows tools
    "com.valvesoftware.Steam"           # Testing client / runtime
    "org.videolan.VLC"                  # Media inspection
    "org.libreoffice.LibreOffice"       # Documents & spreadsheets
)

for app in "${FLATPAK_APPS[@]}"; do
    echo "Installing Flatpak: $app..."
    flatpak install -y flathub "$app" || true
done

# 3. Fast Node Manager (fnm) for NodeJS / TypeScript / React / Vite
echo "===> Setting up Fast Node Manager (fnm)..."
if ! command -v fnm &> /dev/null && [ ! -d "$HOME/.local/share/fnm" ]; then
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    
    # Configure bashrc / zshrc shell integration if not present
    FNM_SNIPPET='
# Fast Node Manager (fnm)
export PATH="$HOME/.local/share/fnm:$PATH"
if command -v fnm &>/dev/null; then
  eval "`fnm env --use-on-cd`"
fi'

    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$rc" ] && ! grep -q "fnm env" "$rc"; then
            echo "$FNM_SNIPPET" >> "$rc"
        fi
    done
    echo "fnm installed. Node LTS can now be installed via: fnm install --lts"
else
    echo "fnm is already installed."
fi

# 4. Global Git User Check
if [ -z "$(git config --global user.name || true)" ]; then
    echo ""
    echo "Notice: Global Git user is not configured yet."
    echo "Run: git config --global user.name \"Your Name\""
    echo "     git config --global user.email \"you@shatteredvales.com\""
fi

echo ""
echo "=========================================================="
echo "    Workstation setup complete!                           "
echo "    (If you were added to new groups, log out and back in)"
echo "=========================================================="