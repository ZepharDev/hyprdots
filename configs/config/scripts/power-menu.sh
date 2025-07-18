#!/bin/bash

user="$(whoami)"
host="$(hostname)"
rofi_theme="$HOME/.config/rofi/power-menu.rasi"
uptime="$(uptime)"

options="  Power Off \n  Reboot \n  Suspend \n   Hibernate \n 󰍃 Logout \n    Lock "

rofi_cmd() {
  rofi -dmenu \
    -p " $user@$host" \
    -config $rofi_theme \
    -theme-str 'window {width: 50%;}'
}

selected=$(echo -e "$options" | rofi_cmd) || {
    echo "Rofi failed to execute or no option was selected." >&2
    exit 1
}

declare -A actions=(
  ["  Power Off "]="systemctl poweroff"
  ["  Reboot "]="systemctl reboot"
  ["   Suspend "]="systemctl suspend"
  ["   Hibernate "]="systemctl hibernate"
  [" 󰍃 Logout "]="systemctl dispatch exit"
  ["   Lock "]="hyprlock"
)

run() {
  local cmd="${actions[$1]}"
  [[ -n "$cmd" ]] && $cmd || exit 0
  [[ $? -ne 0 ]] && log_error "Failed to execute: $cmd"
}
i
run "$selected"
