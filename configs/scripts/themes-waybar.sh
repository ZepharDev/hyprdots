#!/bin/bash


THEMES_DIR="$HOME/.config/waybar/themes"
CACHE_DIR="$HOME/.cache/waybar-themes"
CURRENT_THEME="$CACHE_DIR/current_theme"


mkdir -p "$CACHE_DIR"

if [ ! -d "$THEMES_DIR" ]; then
    notify-send "Error" "The themes directory was not found" -u critical
    exit 1
fi

themes=($(find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort))

# Verificar si hay temas
if [ ${#themes[@]} -eq 0 ]; then
    notify-send "Error" "There are no topics available" -u critical
    exit 1
fi

selected_theme=$(printf '%s\n' "${themes[@]}" | rofi -dmenu \
    -i \
    -p "Selected topic" \
    -no-custom)

if [ -z "$selected_theme" ]; then
    exit 0
fi

if [ ! -d "$THEMES_DIR/$selected_theme" ]; then
    notify-send "Error" "The selected topic does not exist" -u critical
    exit 1
fi

if [ ! -f "$THEMES_DIR/$selected_theme/config.jsonc" ] || [ ! -f "$THEMES_DIR/$selected_theme/style.css" ]; then
    notify-send "Error" "Incomplete theme file" -u critical
    exit 1
fi

echo "$selected_theme" > "$CURRENT_THEME"


pkill waybar
sleep 0.5
waybar -c "$THEMES_DIR/$selected_theme/config.jsonc" -s "$THEMES_DIR/$selected_theme/style.css" &


sleep 1
if ! pgrep waybar >/dev/null; then
    notify-send "Error" "Waybar could not be started" -u critical
    exit 1
fi


notify-send "Waybar" "Subject changed to: $selected_theme" -i preferences-desktop-theme
