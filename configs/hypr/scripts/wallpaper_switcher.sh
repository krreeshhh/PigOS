#!/bin/bash

# Directory containing wallpapers
DIR="$HOME/.config/assets/backgrounds"

# Get the list of files in the directory
PICS=$(ls "$DIR")

# Use tofi to select a wallpaper
CHOICE=$(echo "$PICS" | tofi -c ~/.config/tofi/configA --prompt-text "Wallpapers: ")

# Declare transition types
TRANSITIONS=("outer" "center" "any" "wipe" "grow")
TRANSITION=${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}

# If a selection was made, set it as the wallpaper
if [ -n "$CHOICE" ]; then
    swww img "$DIR/$CHOICE" --transition-fps 255 --transition-type "$TRANSITION" --transition-duration 1.0
    notify-send "Wallpaper Changed" "New wallpaper: $CHOICE" -i "$DIR/$CHOICE"
fi
