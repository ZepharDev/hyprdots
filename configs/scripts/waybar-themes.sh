#!/bin/bash


THEMES_DIR="$HOME/.config/waybar/themes"
CACHE_DIR="$HOME/.cache/waybar-themes"
CURRENT_THEME="$CACHE_DIR/current_theme"


mkdir -p "$CACHE_DIR"

if [ ! -d "$THEMES_DIR" ]; then
    notify-send "Error" "No se encontró el directorio de temas" -u critical
    exit 1
fi

themes=($(find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort))

# Verificar si hay temas
if [ ${#themes[@]} -eq 0 ]; then
    notify-send "Error" "No hay temas disponibles" -u critical
    exit 1
fi

selected_theme=$(printf '%s\n' "${themes[@]}" | rofi -dmenu \
    -i \
    -p "Seleccionar tema" \
    -no-custom)

if [ -z "$selected_theme" ]; then
    exit 0
fi

if [ ! -d "$THEMES_DIR/$selected_theme" ]; then
    notify-send "Error" "El tema seleccionado no existe" -u critical
    exit 1
fi

if [ ! -f "$THEMES_DIR/$selected_theme/config.jsonc" ] || [ ! -f "$THEMES_DIR/$selected_theme/style.css" ]; then
    notify-send "Error" "Archivos del tema incompletos" -u critical
    exit 1
fi

echo "$selected_theme" > "$CURRENT_THEME"


pkill waybar
sleep 0.5
waybar -c "$THEMES_DIR/$selected_theme/config.jsonc" -s "$THEMES_DIR/$selected_theme/style.css" &


sleep 1
if ! pgrep waybar >/dev/null; then
    notify-send "Error" "No se pudo iniciar Waybar" -u critical
    exit 1
fi


notify-send "Waybar" "Tema cambiado a: $selected_theme" -i preferences-desktop-theme