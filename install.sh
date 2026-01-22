#!/bin/bash

# get the directory of the current script
BASE_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# source helper file
source $BASE_DIR/scripts/helper.sh

# trap for unexpected exits
trap 'trap_message' INT TERM

echo -e "${CYAN} -------------------------------------------------${NC}"
echo -e "${CYAN}__________.___  ________ ________    _________${NC}"
echo -e "${BLUE}\______   \   |/  _____/ \_____  \  /   _____/${NC}"
echo -e "${BLUE} |     ___/   /   \  ___  /   |   \ \_____  \ ${NC}"
echo -e "${MAGENTA} |    |   |   \    \_\  \/    |    \/        \ ${NC}"
echo -e "${MAGENTA} |____|   |___|\______  /\_______  /_______  /${NC}"
echo -e "${MAGENTA}                      \/         \/        \/${NC}"
echo -e "${CYAN}-------------------------------------------------${NC}"

# script start
log_message "Installation started"
print_bold_blue "\nSimple Hyprland"
echo "---------------"

# check if running as root
check_root

# check if OS is Arch Linux
check_os

# run child scripts
run_command "chmod +x $BASE_DIR/scripts/*.sh" "Making all scripts executable" "no"
run_script "prerequisites.sh" "Prerequisites Setup"
run_script "hyprland.sh" "Hyprland & Critical Softwares Setup"
run_script "fastfetch.sh" "Fastfetch Setup"
run_script "utilities.sh" "Basic Utilities & Configs Setup"
run_script "final.sh" "Final Setup"

print_bold_blue "\n🌟 Setup Complete\n"
log_message "Installation completed successfully"