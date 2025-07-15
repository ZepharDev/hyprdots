#!/bin/bash

user="$(whoami)"
host="$(hostname)"
rofi_theme="$HOME/.config/rofi/power-menu.rasi"
uptime="$(uptime)"

options="  \n   \n   \n   \n  󰍃 \n    "

rofi_cmd() {
  rofi -dmenu \
    -p " $user@$host" \
    -config $rofi_theme \
    -theme-str 'window {width: 50%;}'
}

selected=$(echo -e "$options" | rofi_cmd) || {
    echo "Rofi failed to execute or no option was selected." >&2
    exit 1
}

declare -A actions=(
  ["   "]="systemctl poweroff"
  ["   "]="systemctl reboot"
  ["   "]="systemctl suspend"
  ["   "]="systemctl hibernate"
  ["  󰍃 "]="systemctl dispatch exit"
  ["    "]="hyprlock"
)

run() {
  local cmd="${actions[$1]}"
  [[ -n "$cmd" ]] && $cmd || exit 0
  [[ $? -ne 0 ]] && log_error "Failed to execute: $cmd"
}
i
run "$selected"
