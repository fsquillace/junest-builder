#!/bin/bash

pacman --noconfirm -Syu
pacman --noconfirm -S sudo git
useradd -m builder

echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
mkdir /home/builder/.ssh
cp /root/.ssh/authorized_keys /home/builder/.ssh/
git config --global user.email "builder@junest.org"
git config --global user.name "builder"

