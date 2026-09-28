#!/bin/bash

set -ouex pipefail

# 1. Copy repository files from system_files/ to root /
cp -avf "/ctx/system_files"/. /

# 2. Global Git Line-Ending Policy (Universal Unix check-in, as-is checkout)
git config --system core.autocrlf input
git config --system core.eol lf

# 3. Add External Repositories (Microsoft .NET 10 & Tailscale)
rpm --import https://packages.microsoft.com/keys/microsoft.asc
curl -fsSL https://packages.microsoft.com/config/fedora/41/prod.repo -o /etc/yum.repos.d/microsoft-prod.repo
curl -fsSL https://pkgs.tailscale.com/stable/fedora/tailscale.repo -o /etc/yum.repos.d/tailscale.repo

# 4. Install Studio Tooling, Platform Dependencies & Hardware Support
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

# 5. Device Permissions & Udev Group Setup for Android / WearOS Hardware
# Create plugdev group if not present (standard across Android/Debian tooling)
getent group plugdev || groupadd -r plugdev

# 6. Enable System Services
systemctl enable podman.socket
systemctl enable tailscaled.service

# 7. Ensure Flathub is registered system-wide for user desktop apps
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 8. Compile GSettings Schemas so the Shattered Vales wallpaper is activated
glib-compile-schemas /usr/share/glib-2.0/schemas

# 9. Install the workstation bootstrap helper to /usr/bin
cp /ctx/setup-workstation.sh /usr/bin/setup-workstation
chmod +x /usr/bin/setup-workstation

echo "===> Base Layer Build Complete"