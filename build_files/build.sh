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

# 4. Tailscale Official Repository (Dynamic release)
curl -fsSL https://pkgs.tailscale.com/stable/fedora/tailscale.repo -o /etc/yum.repos.d/tailscale.repo

# 5. Install Studio Tooling & Platform Dependencies (Fedora Native Repositories)
dnf5 install -y \
    dotnet-sdk-10.0 \
    nuget \
    tailscale \
    rclone \
    cmake \
    nano \
    wget \
    ripgrep \
    android-tools \
    android-udev-rules \
    java-21-openjdk-devel \
    gcc \
    gcc-c++ \
    make \
    python3-pip \
    python3-devel \
    mesa-libGLU \
    nss \
    libnotify \
    alsa-lib

# 6. Udev group setup for physical watch / mobile debugging
getent group plugdev || groupadd -r plugdev

# 7. Enable Services
systemctl enable podman.socket
systemctl enable tailscaled.service

# 8. Ensure Flathub is registered
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 9. Compile Branding Schemas
glib-compile-schemas /usr/share/glib-2.0/schemas

# 10. Copy Workstation Setup Helper to /usr/bin
cp /ctx/setup-workstation.sh /usr/bin/setup-workstation
chmod +x /usr/bin/setup-workstation

echo "===> Base Layer Build Complete"