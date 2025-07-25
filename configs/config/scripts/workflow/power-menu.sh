#!/bin/bash

rofi_theme="$HOME/.config/rofi/user/power-menu.rasi"
uptime="`uptime -p | sed -e 's/up //g'`"

# Orden: lock, logout, suspend, hibernate, reboot, poweroff
options=" \n󰍃 \n \n \n \n "

rofi_cmd() {
  rofi -dmenu \
    -p "$uptime" \
    -config "$rofi_theme" \
    -theme-str 'window {width: 65%;}' 
}

selected=$(echo -e "$options" | rofi_cmd) || {
    echo "Rofi failed to execute or no option was selected." >&2
    exit 1
}

declare -A actions=(
  [" "]="hyprlock"
  ["󰍃 "]="systemctl dispatch exit"
  [" "]="systemctl suspend"
  [" "]="systemctl hibernate"
  [" "]="systemctl reboot"
  [" "]="systemctl poweroff"
)

run() {
  local cmd="${actions[$1]}"
  [[ -n "$cmd" ]] && $cmd || exit 0
  [[ $? -ne 0 ]] && echo "Failed to execute: $cmd" >&2
}

run "$selected"
