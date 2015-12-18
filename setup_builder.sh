#!/bin/bash

set -eu

# ArchLinux System initialization
pacman --noconfirm -Syu
pacman -S --noconfirm git base-devel arch-install-scripts haveged
useradd -m builder

echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
mkdir /home/builder/.ssh
cp /root/.ssh/authorized_keys /home/builder/.ssh/
git config --global user.email "builder@junest.org"
git config --global user.name "builder"


sudo -u builder bash << EOF
JUNEST_BUILDER=/tmp/builder

# Cleanup and initialization
[ -e "\${JUNEST_BUILDER}" ] && sudo rm -rf \${JUNEST_BUILDER}
mkdir -p \${JUNEST_BUILDER}/tmp

mkdir -p \${JUNEST_BUILDER}/tmp/package-query
cd \${JUNEST_BUILDER}/tmp/package-query
curl -L -J -O -k "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=package-query"
makepkg --noconfirm -sfc
sudo pacman --noconfirm -U package-query*.pkg.tar.xz
mkdir -p \${JUNEST_BUILDER}/tmp/yaourt
cd \${JUNEST_BUILDER}/tmp/yaourt
curl -L -J -O -k "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yaourt"
makepkg --noconfirm -sfc
sudo pacman --noconfirm -U yaourt*.pkg.tar.xz
yaourt -S --noconfirm droxi junest-git
droxi
EOF
