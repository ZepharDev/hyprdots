#!/bin/bash 

# The script serves to selected different types of captures in Hyprshot 
# Path: ~/.local/share/screenshots/ 
# Probably the repository doesn't exist... So we're going to create it just in case
# You create the folder with the command 
# mkdir -p ~/.local/share//screenshots
# If you pictures folder is named differently than "Pictures", just replace "Pictures" with the actual
# name of you folder. For example, if it's called "Imagenes", it would be: 
# Creator: ZepharDev
# Licence: GNU GPLV3
# Github: https://github.com/ZepharDev 
# GO 

hyprshotSave="$HOME/.local/share/screenshots/"
rofiConfig="$HOME/.config/rofi/user/hyprshot.rasi"

options="  Screenshot \n  Capture Window \n  Capture complet \n 󰨡 Active Window \n  Exit " 
x
rofi_cmd() {
  rofi -dmenu \
    -p "Screenshot  " \
    -config $rofiConfig \
    -theme-str 'window {width: 50%;}'
}

selected=$(echo -e "$options" | rofi_cmd || {
   exit 1
})

declare -A actions=(
  ["  Screenshot "]="hyprshot -m region -o $hyprshotSave"
  ["  Capture window "]="hyprshot -m window -o $hyprshotSave"
  ["  Capture complet "]="hyprshot -m output -o $hyprshotSave" 
  [" 󰨡 Active Window "]="hyprshot -m window -m active -o $hyprshotSave" 
  ["  Exit "]="exit 0"
)

run() {
  local cmd="${actions[$1]}"
  [[ -n "$cmd" ]] && $cmd || exit 0
  [[ $? -ne 0 ]] && log_error "Failed to execute: $cmd"
}

run "$selected"
