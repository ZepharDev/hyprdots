#!/bin/bash

# Rofi theme path (ajusta a tu ruta si es necesario)
ROFI_THEME="$HOME/.config/rofi/mpd-theme.rasi"

# Detecta reproductores disponibles
PLAYER=$(playerctl -l | head -n 1)

# Info actual
TITLE=$(playerctl -p "$PLAYER" metadata title)
ARTIST=$(playerctl -p "$PLAYER" metadata artist)
ALBUM=$(playerctl -p "$PLAYER" metadata album)
ARTURL=$(playerctl -p "$PLAYER" metadata mpris:artUrl | sed 's/^file:\/\///')

# Texto descriptivo en el menú
INFO="🎵 $TITLE — $ARTIST [$ALBUM]"

# Opciones del menú
OPTIONS="$INFO\n󰒭 Next\n▶ Play\n󰒮 Previous\n Stop\n📤 Show Info"

# Mostrar Rofi
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -config "$ROFI_THEME" -p "🎶 Control ($PLAYER)" -i)

case "$CHOICE" in
    "󰒭 Next") playerctl -p "$PLAYER" next ;;
    "▶ Play") playerctl -p "$PLAYER" play ;;
    "󰒮 Previous") playerctl -p "$PLAYER" previous ;;
    " Stop") playerctl -p "$PLAYER" stop ;;
    "📤 Show Info")
        if [[ -f "$ARTURL" ]]; then
            notify-send "🎶 $TITLE" "$ARTIST — $ALBUM" --icon="$ARTURL"
        else
            notify-send "🎶 $TITLE" "$ARTIST — $ALBUM"
        fi
        ;;
esac
