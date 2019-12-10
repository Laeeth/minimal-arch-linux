#!/bin/bash

echo "Updating databases"
sudo pacman -Syu --noconfirm

echo "Installing DKMS packages"
sudo pacman -S --noconfirm dkms

echo "Adding Firefox and LibreOffice AppArmor profiles"
sudo wget -P /etc/apparmor.d/ https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/apparmor/profiles.tar.gz
sudo tar -xzf /etc/apparmor.d/profiles.tar.gz -C /etc/apparmor.d/
sudo rm -f /etc/apparmor.d/profiles.tar.gz
sudo aa-enforce /etc/apparmor.d/usr.bin.firefox
sudo aa-enforce /etc/apparmor.d/usr.lib.libreoffice.program.oosplash
sudo aa-enforce /etc/apparmor.d/usr.lib.libreoffice.program.senddoc
sudo aa-enforce /etc/apparmor.d/usr.lib.libreoffice.program.soffice.bin
sudo aa-enforce /etc/apparmor.d/usr.lib.libreoffice.program.xpdfimport

echo "Installing and configuring UFW"
sudo pacman -S --noconfirm ufw
sudo systemctl enable ufw
sudo systemctl start ufw
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing

echo "Improving Intel GPU support"
sudo pacman -S --noconfirm vulkan-intel intel-media-driver

echo "Installing common applications"
sudo pacman -S --noconfirm firefox chromium keepassxc git openssh neovim links upower htop powertop p7zip ripgrep unzip

echo "Installing fonts"
sudo pacman -S --noconfirm ttf-roboto ttf-droid ttf-opensans ttf-dejavu ttf-liberation ttf-hack ttf-fira-code noto-fonts ttf-font-awesome

echo "Installing San Francisco Fonts"
git clone https://aur.archlinux.org/otf-san-francisco-pro.git
cd otf-san-francisco-pro
yes | makepkg -si
cd ..
rm -rf otf-san-francisco-pro

echo "Installing and setting zsh, oh-my-zsh and powerlevel10k"
sudo pacman -S --noconfirm zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME"/.oh-my-zsh/custom/themes/powerlevel10k
rm -rf "$HOME"/.zshrc
wget -P "$HOME" https://raw.githubusercontent.com/exah-io/minimal-arch-linux/master/configs/zsh/.zshrc

echo "Installing Node.js LTS"
sudo pacman -S --noconfirm nodejs-lts-erbium npm

echo "Changing default npm directory"
mkdir "$HOME"/.npm-global
npm config set prefix "$HOME/.npm-global"
touch "$HOME"/.profile
tee "$HOME"/.profile << END
export PATH=$HOME/.npm-global/bin:$PATH
END
source "$HOME"/.profile

echo "Installing VS Code"
sudo pacman -S --noconfirm code

echo "Installing VS Code theme + icons"
code --install-extension teabyii.ayu
code --install-extension pkief.material-icon-theme
code --install-extension esbenp.prettier-vscode

echo "Blacklisting bluetooth"
sudo touch /etc/modprobe.d/nobt.conf
sudo tee /etc/modprobe.d/nobt.conf << END
blacklist btusb
blacklist bluetooth
END
sudo mkinitcpio -p linux-lts
sudo mkinitcpio -p linux

echo "Increasing the amount of inotify watchers"
echo fs.inotify.max_user_watches=524288 | sudo tee /etc/sysctl.d/40-max-user-watches.conf && sudo sysctl --system