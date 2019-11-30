#!/bin/bash

encryption_passphrase=""
root_password=""
user_password=""
hostname=""
user_name=""
continent_city=""
swap_size="8"

echo "Updating system clock"
timedatectl set-ntp true

echo "Creating partition tables"
printf "n\n1\n4096\n+512M\nef00\nw\ny\n" | gdisk /dev/nvme0n1
printf "n\n2\n\n\n8e00\nw\ny\n" | gdisk /dev/nvme0n1

echo "Zeroing partitions"
cat /dev/zero > /dev/nvme0n1p1
cat /dev/zero > /dev/nvme0n1p2

echo "Building EFI filesystem"
yes | mkfs.fat -F32 /dev/nvme0n1p1

echo "Setting up cryptographic volume"
printf "%s" "$encryption_passphrase" | cryptsetup -c aes-xts-plain64 -h sha512 -s 512 --use-random --type luks2 --label LVMPART luksFormat /dev/nvme0n1p2
printf "%s" "$encryption_passphrase" | cryptsetup luksOpen /dev/nvme0n1p2 cryptoVols

echo "Setting up LVM"
pvcreate /dev/mapper/cryptoVols
vgcreate Arch /dev/mapper/cryptoVols
lvcreate -L +"$swap_size"GB Arch -n swap
lvcreate -l +100%FREE Arch -n root

echo "Building filesystems for root and swap"
yes | mkswap /dev/mapper/Arch-swap
yes | mkfs.ext4 /dev/mapper/Arch-root

echo "Mounting root/boot and enabling swap"
mount /dev/mapper/Arch-root /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
swapon /dev/mapper/Arch-swap

echo "Installing Arch Linux"
yes '' | pacstrap /mnt base base-devel intel-ucode networkmanager wget linux-lts apparmor

echo "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

echo "Configuring new system"
arch-chroot /mnt /bin/bash <<EOF
echo "Setting system clock"
ln -fs /usr/share/zoneinfo/$continent_city /etc/localtime
hwclock --systohc --localtime

echo "Setting locales"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
locale-gen

echo "Setting hostname"
echo $hostname > /etc/hostname

echo "Setting root password"
echo -en "$root_password\n$root_password" | passwd

echo "Creating new user"
useradd -m -G wheel -s /bin/bash $user_name
usermod -a -G video $user_name
echo -en "$user_password\n$user_password" | passwd $user_name

echo "Generating initramfs"
sed -i 's/^HOOKS.*/HOOKS=(base udev keyboard autodetect modconf block keymap encrypt lvm2 resume filesystems fsck)/' /etc/mkinitcpio.conf
sed -i 's/^MODULES.*/MODULES=(ext4 intel_agp i915)/' /etc/mkinitcpio.conf
mkinitcpio -p linux-lts
mkinitcpio -p linux

echo "Setting up systemd-boot"
bootctl --path=/boot install

mkdir -p /boot/loader/
touch /boot/loader/loader.conf
tee -a /boot/loader/loader.conf << END
default arch
timeout 1
editor 0
END

mkdir -p /boot/loader/entries/
touch /boot/loader/entries/arch.conf
tee -a /boot/loader/entries/arch.conf << END
title ArchLinux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options cryptdevice=LABEL=LVMPART:cryptoVols root=/dev/mapper/Arch-root resume=/dev/mapper/Arch-swap apparmor=1 security=apparmor quiet rw
END

touch /boot/loader/entries/archlts.conf
tee -a /boot/loader/entries/archlts.conf << END
title ArchLinux
linux /vmlinuz-linux-lts
initrd /intel-ucode.img
initrd /initramfs-linux-lts.img
options cryptdevice=LABEL=LVMPART:cryptoVols root=/dev/mapper/Arch-root resume=/dev/mapper/Arch-swap apparmor=1 security=apparmor quiet rw
END

echo "Setting up Pacman hook for automatic systemd-boot updates"
mkdir -p /etc/pacman.d/hooks/
touch /etc/pacman.d/hooks/systemd-boot.hook
tee -a /etc/pacman.d/hooks/systemd-boot.hook << END
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot
When = PostTransaction
Exec = /usr/bin/bootctl update
END

echo "Enabling autologin"
mkdir -p  /etc/systemd/system/getty@tty1.service.d/
touch /etc/systemd/system/getty@tty1.service.d/override.conf
tee -a /etc/systemd/system/getty@tty1.service.d/override.conf << END
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $user_name --noclear %I $TERM
END

echo "Enabling periodic TRIM"
systemctl enable fstrim.timer

echo "Enabling NetworkManager"
systemctl enable NetworkManager

echo "Enabling suspend and hibernate"
sed -i 's/#HandlePowerKey=poweroff/HandlePowerKey=hibernate/g' /etc/systemd/logind.conf
sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=suspend/g' /etc/systemd/logind.conf

echo "Enabling AppArmor"
systemctl enable apparmor.service

echo "Adding user as a sudoer"
echo '%wheel ALL=(ALL) ALL' | EDITOR='tee -a' visudo
EOF

umount -R /mnt
swapoff -a

echo "ArchLinux is ready. You can reboot now!"
