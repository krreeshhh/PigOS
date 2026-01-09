#!/bin/bash

cat <<"EOF"

 -------------------------------------------------
__________.___  ________ ________    _________
\______   \   |/  _____/ \_____  \  /   _____/
 |     ___/   /   \  ___  /   |   \ \_____  \ 
 |    |   |   \    \_\  \/    |    \/        \
 |____|   |___|\______  /\_______  /_______  /
                      \/         \/        \/
-------------------------------------------------

EOF

# get the directory of the current script
BASE_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# source helper file
source $BASE_DIR/scripts/helper.sh

# trap for unexpected exits
trap 'trap_message' INT TERM

# script start
log_message "Installation started"
print_bold_blue "\nSimple Hyprland"
echo "---------------"

# check if running as root
check_root

# check if OS is Arch Linux
check_os

# run child scripts
run_script "prerequisites.sh" "Prerequisites Setup"
run_script "hyprland.sh" "Hyprland & Critical Softwares Setup"
run_script "utilities.sh" "Basic Utilities & Configs Setup"
run_script "final.sh" "Final Setup"

print_bold_blue "\n🌟 Setup Complete\n"
log_message "Installation completed successfully"