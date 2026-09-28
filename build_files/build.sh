#!/bin/bash

set -ouex pipefail

# 1. Copy repository files from system_files/ to root /
cp -avf "/ctx/system_files"/. /

# 2. Dynamic OS Branding (Keep Fedora version dynamic, brand studio identity)
sed -i 's/^NAME=.*/NAME="Shattered Vales DX"/' /usr/lib/os-release
sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="Shattered Vales DX Workstation"/' /usr/lib/os-release
sed -i 's/^DEFAULT_HOSTNAME=.*/DEFAULT_HOSTNAME="shatteredvales-dx"/' /usr/lib/os-release
echo "LOGO=system-logo-sv" >> /usr/lib/os-release

# 3. Global Git Line-Ending Policy (Universal Unix check-in, as-is checkout)
git config --system core.autocrlf input
git config --system core.eol lf

# 4. Install Studio Tooling (Only packages not already bundled in bluefin-dx)
dnf5 install -y \
    dotnet-sdk-10.0 \
    nuget \
    java-openjdk-devel \
    ripgrep \
    cmake

# 5. Device Permissions & Udev Group Setup for Android / WearOS
getent group plugdev || groupadd -r plugdev

# 6. Enable Services
systemctl enable podman.socket
systemctl enable tailscaled.service

# 7. Ensure Flathub is registered
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 8. Compile Branding Schemas
glib-compile-schemas /usr/share/glib-2.0/schemas

# 9. Copy Workstation Setup Helper to /usr/bin
cp /ctx/setup-workstation.sh /usr/bin/setup-workstation
chmod +x /usr/bin/setup-workstation

echo "===> Base Layer Build Complete"