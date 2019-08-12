#!/bin/bash

echo "Installing common packages"
yes | sudo pacman -S linux-headers dkms xdg-user-dirs xorg-server-xwayland

echo "Installing and configuring UFW"
yes | sudo pacman -S ufw
sudo systemctl enable ufw
sudo systemctl start ufw
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing

echo "Installing and enabling TLP"
sudo pacman -S tlp tlp-rdw
sudo systemctl enable tlp.service
sudo systemctl enable tlp.service
sudo systemctl start tlp.service
sudo systemctl start tlp.service
sudo systemctl enable NetworkManager-dispatcher.service
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket

echo "Installing common applications"
echo -en "1\nyes" | sudo pacman -S firefox chromium keepassxc git openssh vim links alacritty upower htop powertop p7zip

echo "Installing office applications"
yes | sudo pacman -S tumbler evince gimp inkscape thunderbird

echo "Installing fonts"
yes | sudo pacman -S ttf-droid ttf-opensans ttf-dejavu ttf-liberation ttf-hack ttf-fira-code noto-fonts gsfonts

echo "Installing VS Code, NVM and Node.js LTS"
yes | sudo pacman -S code
git clone https://aur.archlinux.org/nvm.git
cd nvm
yes | makepkg -si
cd ..
rm -rf nvm
source /usr/share/nvm/init-nvm.sh
nvm install --lts=dubnium

echo "Installing VS Code theme and icons"
code --install-extension jolaleye.horizon-theme-vscode
code --install-extension vscode-icons-team.vscode-icons

echo "Installing and setting zsh"
yes | sudo pacman -S zsh zsh-theme-powerlevel9k
chsh -s /bin/zsh
wget -P ~/ https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/zsh/.zshrc
wget -P ~/ https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/zsh/.zprofile
mkdir -p ~/.zshrc.d
wget -P ~/.zshrc.d https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/zsh/.zshrc.d/environ.zsh
wget -P ~/.zshrc.d https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/zsh/.zshrc.d/wayland.zsh

echo "Setting up GTK theme and installing dependencies"
yes | sudo pacman -S gtk-engine-murrine gtk-engines
git clone https://github.com/vinceliuice/Qogir-theme.git
cd Qogir-theme
sudo mkdir -p /usr/share/themes
sudo ./install.sh -d /usr/share/themes
cd ..
rm -rf Qogir-theme

echo "Setting up icon theme"
git clone https://github.com/vinceliuice/Qogir-icon-theme.git
cd Qogir-icon-theme
sudo mkdir -p /usr/share/icons
sudo ./install.sh -d /usr/share/icons
cd ..
rm -rf Qogir-icon-theme

echo "Installing Material Design icons"
sudo mkdir -p /usr/share/fonts/TTF/
sudo wget -P /usr/share/fonts/TTF/ https://raw.githubusercontent.com/Templarian/MaterialDesign-Webfont/master/fonts/materialdesignicons-webfont.ttf

echo "Installing sway and additional packages"
yes | sudo pacman -S sway swaylock swayidle waybar pulseaudio pavucontrol rofi slurp grim thunar mousepad nnn light feh qalculate-gtk
mkdir -p ~/.config/sway
wget -P ~/.config/sway/ https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/sway/config
mkdir -p ~/Pictures/screenshots

echo "Enabling auto-mount for thunar"
yes | sudo pacman -S gvfs thunar-volman

echo "Setting wallpaper"
wget -P ~/Pictures/ https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/wallpaper/b1ivv4tgg9831.jpg

echo "Ricing waybar"
mkdir -p ~/.config/waybar
wget -P ~/.config/waybar https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/waybar/config
wget -P ~/.config/waybar https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/waybar/style.css

echo "Ricing Alacritty"
mkdir -p ~/.config/alacritty
wget -P ~/.config/alacritty https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/alacritty/alacritty.yml

echo "Blacklisting bluetooth"
sudo touch /etc/modprobe.d/nobt.conf
sudo tee /etc/modprobe.d/nobt.conf << END
blacklist btusb
blacklist bluetooth
END
sudo mkinitcpio -p linux

echo "Increasing the amount of inotify watchers"
echo fs.inotify.max_user_watches=524288 | sudo tee /etc/sysctl.d/40-max-user-watches.conf && sudo sysctl --system

echo "Enabling audio power saving"
sudo touch /etc/modprobe.d/audio_powersave.conf
echo "options snd_hda_intel power_save=1" | sudo tee /etc/modprobe.d/audio_powersave.conf

echo "Your setup is ready. You can reboot now!"
