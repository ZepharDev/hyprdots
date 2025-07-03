#!/bin/bash

# Robust power menu script for Hyprland using Rofi with Nerd Font icons
# Designed for a clean, relaxing, and visually appealing setup

# Exit immediately on errors
set -euo pipefail

# Log errors to stderr
log_error() {
    echo "Error: $1" >&2
    exit 1
}

# Check for required dependencies
for cmd in rofi hyprctl systemctl loginctl hyprlock; do
    command -v "$cmd" >/dev/null 2>&1 || log_error "$cmd is not installed. Please install it."
done

# Verify Rofi theme exists
ROFI_THEME="$HOME/.config/rofi/power-menu.rasi"
[ -f "$ROFI_THEME" ] || log_error "Rofi theme 'power-menu.rasi' not found at $ROFI_THEME."

# Define power menu options with Nerd Font icons (relaxing and aesthetic)
OPTIONS="  Power Off\n  Reboot\n  Suspend\n  Hibernate\n󰗽  Logout\n  Lock"

# Rofi command with dmenu style, using power-menu.rasi theme
ROFI_CMD="rofi -dmenu -i -p '' -theme $ROFI_THEME -width 15 -lines 6"

# Execute rofi and capture the selected option
SELECTED=$(echo -e "$OPTIONS" | $ROFI_CMD) || {
    log_error "Rofi failed to execute or no option was selected."
}

# Handle the selected option (matching full line with icon)
case "$SELECTED" in
    "  Power Off")
        systemctl poweroff || log_error "Failed to power off."
        ;;
    "  Reboot")
        systemctl reboot || log_error "Failed to reboot."
        ;;
    "  Suspend")
        systemctl suspend || log_error "Failed to suspend."
        ;;
    "  Hibernate")
        systemctl hibernate || log_error "Failed to hibernate."
        ;;
    "󰗽  Logout")
        hyprctl dispatch exit || log_error "Failed to logout from Hyprland."
        ;;
    "  Lock")
        hyprlock || log_error "Failed to lock with hyprlock."
        ;;
    *)
        exit 0  # Exit gracefully if no valid option is selected
        ;;
esac