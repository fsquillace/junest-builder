#!/bin/bash

set -eu

JUNEST_BUILDER=/home/builder/junest-builder

# Cleanup and initialization
[ -d ${JUNEST_BUILDER} ] && sudo rm -rf ${JUNEST_BUILDER}
mkdir -p ${JUNEST_BUILDER}/tmp
mkdir -p ${JUNEST_BUILDER}/junest

# ArchLinux System initialization
sudo pacman -Syyu --noconfirm
sudo pacman -S --noconfirm git base-devel arch-install-scripts haveged

# Fix for ARM architectures
# http://bit.ly/1ZIkVqh
if [[ $(uname -m) =~ .*(arm).* ]]
then
    sudo sed -i -e 's/unshare --fork --pid//' /usr/bin/arch-chroot
fi

sudo systemctl start haveged
mkdir -p ${JUNEST_BUILDER}/tmp/package-query
cd ${JUNEST_BUILDER}/tmp/package-query
curl -L -J -O -k "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=package-query"
makepkg --noconfirm -sfc
sudo pacman --noconfirm -U package-query*.pkg.tar.xz
mkdir -p ${JUNEST_BUILDER}/tmp/yaourt
cd ${JUNEST_BUILDER}/tmp/yaourt
curl -L -J -O -k "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yaourt"
makepkg --noconfirm -sfc
sudo pacman --noconfirm -U yaourt*.pkg.tar.xz
yaourt -S --noconfirm droxi

# Building JuNest image
mkdir -p ${JUNEST_BUILDER}/junest
cd ${JUNEST_BUILDER}
git clone https://github.com/fsquillace/junest ${JUNEST_BUILDER}/junest
JUNEST_TEMPDIR=${JUNEST_BUILDER}/tmp ${JUNEST_BUILDER}/junest/bin/junest -b

# Upload image
for img in $(ls junest-*.tar.gz);
do
    droxi put -f -O /Public/junest ${img}
done

DATE=$(date +'%Y-%m-%d-%H-%M-%S')

for img in $(ls junest-*.tar.gz);
do
    mv ${img} "${img}.${DATE}"
    droxi put -E -f -O /Public/junest "${img}.${DATE}"
done

# Cleanup
ARCH=x86_64
droxi ls /Public/junest/junest-${ARCH}.tar.gz.* | sed 's/ .*$//' | head -n -3 | xargs -I {} droxi rm "{}"
rm -rf ${JUNEST_BUILDER}
