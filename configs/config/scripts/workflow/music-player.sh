#!/bin/bash

# Rofi theme path
rofi_theme="$HOME/.config/rofi/user/mpd-theme.rasi"

# 
player=$(playerctl -l | head -n 1)

# Info actual
title=$(playerctl -p "$player" metadata title)
artist=$(playerctl -p "$player" metadata artist)
album=$(playerctl -p "$player" metadata album)
artUrl=$(playerctl -p "$player" metadata mpris:artUrl | sed 's/^file:\/\///')

# 
info="🎵 $title — $artist [$album]"

# 
options="$info\n󰒭 Next\n▶ Play\n󰒮 Previous\n Stop\n📤 Show Info"
#
choice=$(echo -e "$options" | rofi -dmenu -config "$rofi_theme" -p "🎶 Control ($player)" -i)

case "$choice" in
    "󰒭 Next") playerctl -p "$player" next ;;
    "▶ Play") playerctl -p "$player" play ;;
    "󰒮 Previous") playerctl -p "$player" previous ;;
    " Stop") playerctl -p "$player" stop ;;
    "📤 Show Info")
        if [[ -f "$artUrl" ]]; then
            notify-send "🎶 $title" "$artist — $album" --icon="$artUrl"
        else
            notify-send "🎶 $title" "$artist — $album"
        fi
        ;;
esac
