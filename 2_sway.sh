#!/bin/bash

echo "Downloading and running base script"
wget https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/2_base.sh
chmod +x 2_base.sh
sh ./2_base.sh

echo "Installing xwayland"
sudo pacman -S --noconfirm xorg-server-xwayland

echo "Creating user's folders"
sudo pacman -S --noconfirm xdg-user-dirs

echo "Installing Alacritty terminal"
sudo pacman -S --noconfirm alacritty

echo "Installing office applications"
sudo pacman -S --noconfirm tumbler evince thunderbird

echo "Importing sway specific zsh configurations"
wget -P ~/ https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/zsh/sway/.zprofile
mkdir -p ~/.zshrc.d
wget -P ~/.zshrc.d https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/zsh/sway/.zshrc.d/environ.zsh
wget -P ~/.zshrc.d https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/zsh/sway/.zshrc.d/wayland.zsh

echo "Installing sway and additional packages"
sudo pacman -S --noconfirm sway swaylock swayidle waybar otf-font-awesome wl-clipboard pulseaudio pavucontrol rofi slurp grim thunar mousepad nnn light feh qalculate-gtk
mkdir -p ~/Pictures/screenshots
mkdir -p ~/.config/sway
wget -P ~/.config/sway/ https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/sway/config
wget -P ~/.config/sway/ https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/sway/colors.ayu
wget -P ~/.config/sway/ https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/sway/colors.ayu-dark
wget -P ~/.config/sway/ https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/sway/colors.ayu-mirage

echo "Enabling auto-mount and archives creation/deflation for thunar"
sudo pacman -S --noconfirm gvfs thunar-volman thunar-archive-plugin ark file-roller xarchiver

echo "Setting wallpaper"
wget -P ~/Pictures/ https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/wallpapers/andre-benz-cXU6tNxhub0-unsplash.jpg

echo "Ricing waybar"
mkdir -p ~/.config/waybar
wget -P ~/.config/waybar https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/waybar/config
wget -P ~/.config/waybar https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/waybar/style.css

echo "Ricing swaynag"
mkdir -p ~/.config/swaynag
wget -P ~/.config/swaynag https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/swaynag/config

echo "Ricing Alacritty"
mkdir -p ~/.config/alacritty
wget -P ~/.config/alacritty https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/alacritty/alacritty.yml

echo "Ricing rofi"
mkdir -p ~/.config/rofi
wget -P ~/.config/rofi https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/rofi/config.rasi
wget -P ~/.config/rofi https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/rofi/ayu-mirage.rasi
wget -P ~/.config/rofi https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/rofi/ayu-dark.rasi
wget -P ~/.config/rofi https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/rofi/ayu.rasi
wget -P ~/.config/rofi https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/rofi/defaults.rasi

echo "Ricing neovim"
mkdir -p "$HOME"/.config/nvim
wget -P "$HOME"/.config/nvim https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/nvim/init.vim

echo "Installing vim-plug"
curl -fLo "$HOME"/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim +'PlugInstall --sync' +qa

echo "Installing GTK theme and dependencies"
sudo pacman -S --noconfirm gtk-engine-murrine gtk-engines
sudo mkdir -p /usr/share/themes/
sudo wget -P /usr/share/themes/ https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/themes/ayu-gtk-themes.tar.gz
sudo tar -xzf /usr/share/themes/ayu-gtk-themes.tar.gz -C /usr/share/themes/
sudo rm -f /usr/share/themes/ayu-gtk-themes.tar.gz

echo "Installing icons"
sudo pacman -S --noconfirm papirus-icon-theme
git clone https://aur.archlinux.org/papirus-folders-git.git
cd papirus-folders-git
yes | makepkg -si
cd ..
rm -rf papirus-folders-git
papirus-folders -C yellow --theme Papirus-Dark

echo "Setting GTK theme, font and icons"
FONT="SF Pro Text Regular 10"
GTK_THEME="Ayu-Mirage-Dark"
GTK_ICON_THEME="Papirus-Dark"
GTK_SCHEMA="org.gnome.desktop.interface"
gsettings set $GTK_SCHEMA gtk-theme "$GTK_THEME"
gsettings set $GTK_SCHEMA icon-theme "$GTK_ICON_THEME"
gsettings set $GTK_SCHEMA font-name "$FONT"
gsettings set $GTK_SCHEMA document-font-name "$FONT"

echo "Your setup is ready. You can reboot now!"