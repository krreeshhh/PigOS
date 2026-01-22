#!/bin/bash

# get the directory of the current script
BASE_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")/../")

# source helper file
source $BASE_DIR/scripts/helper.sh

log_message "Installation started for prerequisites section"
print_info "\nStarting prerequisites setup..."

run_command "pacman -Syyu --noconfirm" "Update package database and upgrade packages (Recommended)" "yes" # no

if command -v yay > /dev/null; then
  print_warning "Skipping yay installation (already installed)."
elif run_command "pacman -S --noconfirm --needed git base-devel" "Install YAY (Must)/Breaks the script" "yes"; then
	run_command "bash -c 'cd /tmp && git clone https://aur.archlinux.org/yay-git.git /home/$SUDO_USER/yay-git && cd /home/$SUDO_USER/yay-git && makepkg --noconfirm -si'" "Clone and build YAY (Must)/Breaks the script" "no" "no" 
fi
run_command "pacman -S --noconfirm pipewire pipewire-pulse wireplumber pamixer pavucontrol playerctl brightnessctl" "Configuring audio and brightness (Recommended)" "yes"

run_command "pacman -S --noconfirm bluez bluez-utils blueman" "Configuring bluetooth services (Recommended)" "yes"
run_command "systemctl enable bluetooth.service && systemctl start bluetooth.service" "Enable and start bluetooth services (Recommended)" "yes"

run_command "pacman -S --noconfirm networkmanager network-manager-applet" "Configuring network services (Recommended)" "yes"
run_command "systemctl enable --now NetworkManager.service" "Enable and start network services (Recommended)" "yes"

run_command "pacman -S --noconfirm dunst libnotify" "Install Dunst notification daemon and libnotify (Recommended)" "yes"

run_command "pacman -S --noconfirm ttf-cascadia-code-nerd ttf-cascadia-mono-nerd ttf-fira-code ttf-fira-mono ttf-fira-sans ttf-firacode-nerd ttf-iosevka-nerd ttf-iosevkaterm-nerd ttf-jetbrains-mono-nerd ttf-jetbrains-mono ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono" "Installing Nerd Fonts and Symbols (Recommended)" "yes" 

run_command "pacman -S --noconfirm sddm && systemctl enable sddm.service" "Install and enable SDDM (Recommended)" "yes"

run_command "yay -S --sudoloop --noconfirm brave-bin" "Install Brave Browser" "yes" "no" 

run_command "pacman -S --noconfirm kitty" "Install Kitty (Recommended)" "yes"

run_command "pacman -S --noconfirm nano" "Install nano" "yes"

run_command "pacman -S --noconfirm tar" "Install tar for extracting files (Must)/needed for copying themes" "yes"

run_command "yay -S --sudoloop --noconfirm nautilus" "Install nautilus" "yes"

run_command "pacman -S --noconfirm flatpak" "Install flatpak" "yes"

run_command "flatpak install flathub io.github.kukuruzka165.materialgram -y" "Install Materialgram" "yes"

run_command "pacman -S --noconfirm code-oss" "Install code-oss" "yes"

run_command "yay -S --sudoloop --noconfirm spotify" "Install spotify" "yes"

run_command "pacman -S --noconfirm discord" "Install discord" "yes"

run_command "pacman -S --noconfirm fastfetch" "Install fastfetch" "yes"

echo "------------------------------------------------------------------------"