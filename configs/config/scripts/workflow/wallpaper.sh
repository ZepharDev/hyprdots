#!/bin/bash


# Creator: zephardev
# Repository: https://github.com/zephardev
# Script to select wallpapers
# Optimized script to change wallpapers faster
# The configuration is located at: ~/.config/rofi/wallpapers.rasi
# This uses hyprpaper
# Advertence: The script may have bugsç
# WO proyect: Workflow optimization
#
# Is good.
# In process development

# Configuration Zephar
wallpaperDir="$HOME/.local/share/wallpapers"
config="$HOME/.config/hypr/hyprpaper.conf"
cacheDir="$HOME/.cache/hypr"
lastWall="$CACHE_DIR/last_wallpaper"

# Create directory if it does not exist
mkdir -p "$cacheDir"

# Function to handle errors
error_handler() {
    notify-send "Error" "Failed to aply wallpapers: $1" -u critical
    exit 1
}

# This list a most wallpapers extensions, Example.jpg

# Check necessary directories and files
[ ! -d "$wallpaperDir" ] && error_handler "Wallpaper directory not found"
[ ! -d "$(dirname "$config")" ] && error_handler "Configuration directory not found"


# And if the directory does not exist? I don't know.
# Create mkdir -p $wallpaperDir
# Example:
# mkdir -p $wallpaperDir 
# Just remove the # and run the script ONCE, or more simply,
# to to the terminal (kitty or any) and type mkdir -p $wallpaperDir
# If you have already cloned the Github repository, you  can do the following
# mv ~/hyprdots/configs/local/wallpapers ~/.local/share/wallpapers/ 


# Being able to selected a wallpaper
wall=$(find "$wallpaperDir" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) -printf "%f\n" | sort -V | \
  rofi -dmenu -config ~/.config/rofi/user/wall.rasi -i -p "Wallpaper")

# Verify
[ -z "$wall" ] && exit 0

# Write the full path of the wallpaper
wallPath="$wallpaperDir/$wall"
[ ! -f "$wallPath" ] && error_handler "archive no found"

# Obtener monitores activos
monitors=$(hyprctl monitors -j | jq -r '.[].name') || error_handler "Error getting monitors"

# Create new config
{
    echo "# WO configuration generated by wallpaper-menu.sh"
    echo "preload = $wallPath"
    echo ""
    for monitor in $monitors; do
        echo "wallpaper = $monitor,$wallPath"
    done
} > "$config"

# This saves the last selected wallpapers
echo "$wallPath" > "$lastWall"

# Load the wallpaper
if pgrep -x hyprpaper >/dev/null; then
    pkill -SIGUSR2 hyprpaper || {
        pkill hyprpaper
        sleep 0
        hyprpaper &
    }
else
    hyprpaper &
fi

# Check if hyprpaper is working
sleep 0
if ! pgrep -x hyprpaper >/dev/null; then
    hyprpaper &
    sleep 0
fi

# With this we finish the code, and it will send us a notification
# depending on whether it was applied or no
if pgrep -x hyprpaper >/dev/null; then
    notify-send "wallpaper appplied correctly" "$(basename "$WALL_PATH")" -i "$WALL_PATH"
else
    error_handler "Could not apply wallpaper"
fi
