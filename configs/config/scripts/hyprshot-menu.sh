#!/bin/bash 

# The script serves to selected different types of captures in Hyprshot 
# Path: ~/Pictures/HyprShot 
# Probably the repository doesn't exist... So we're going to create it just in case
# You create the folder with the command 
# mkdir -p ~/Pictures/screenshots
# If you pictures folder is named differently than "Pictures", just replace "Pictures" with the actual
# name of you folder. For example, if it's called "Imagenes", it would be: 
# Creator: ZepharDev
# Licence: GNU GPLV3
# Github: https://github.com/ZepharDev 
# GO 

rofiConfig="$HOME/.config/rofi/hyprshot.rasi"

options="  Screenshot \n  Capture Window \n  Capture complet \n 󰨡 Active Window \n  Exit " 

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
  ["  Screenshot "]="hyprshot -m region"
  ["  Capture window "]="hyprshot -m window"
  ["  Capture complet "]="hyprshot -m output" 
  [" 󰨡 Active Window "]="hyprshot -m active" 
  ["  Exit "]="exit 0"
)

run() {
  local cmd="${actions[$1]}"
  [[ -n "$cmd" ]] && $cmd || exit 0
  [[ $? -ne 0 ]] && log_error "Failed to execute: $cmd"
}

run "$selected"
