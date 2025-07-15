#!/bin/bash
# filepath: ~/.config/scripts/menu-scripts.sh

# Folder where scripts are stored
scriptDir="$HOME/.config/scripts"

# List all executable scripts (exclude menu-scripts.sh)
options=$(find "$SCRIPTS_DIR" -maxdepth 1 -type f -executable ! -name "menu-scripts.sh" -exec basename {} \;)

# Show rofi
selected=$(echo "$options" | rofi -show -config ~/.config/rofi/scripts.rasi -dmenu -p "Exec Script")
# Run the script if it's not empty
if [[ -n "$selected" ]]; then
    bash "$scriptDir/$selected"
fi
