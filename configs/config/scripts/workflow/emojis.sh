#!/bin/bash

# Emoji picker script using Rofi's built-in emoji mode.
# Inserts emojis directly into the active window or copies to clipboard as a fallback.
# Designed to be dynamic with recent emoji tracking and avoid clipboard overuse.
# Uses clean, human-readable code with camelCase variables.
# Requires: rofi, xdotool (X11) or wtype (Wayland), emoji-font.

# Configuration paths
configDir="$HOME/.cache"
recentFile="$configDir/rofi-emoji-recent"

# Rofi theme settings for a clean interface
themeArgs="-theme solarized -font 'Hack 12' -width 800"

# Maximum number of recent emojis to store
maxRecent=10

# Function to check for required dependencies
checkDependencies() {
    if ! command -v rofi &> /dev/null; then
        echo "Error: rofi is not installed. Please install it."
        exit 1
    fi
    if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
        if ! command -v wtype &> /dev/null; then
            echo "Error: wtype is required for Wayland. Please install it."
            exit 1
        fi
    else
        if ! command -v xdotool &> /dev/null; then
            echo "Error: xdotool is required for X11. Please install it."
            exit 1
        fi
    fi
}

# Create cache directory for recent emojis
setupConfig() {
    if [[ ! -d "$configDir" ]]; then
        mkdir -p "$configDir"
        echo "Created cache directory at $configDir"
    fi
    # Initialize recent file if it doesn't exist
    if [[ ! -f "$recentFile" ]]; then
        touch "$recentFile"
    fi
}

# Get recent emojis for quick access
getRecentEmojis() {
    if [[ -f "$recentFile" ]]; then
        head -n "$maxRecent" "$recentFile"
    fi
}

# Append a selected emoji to the recent file
updateRecentEmojis() {
    local selectedEmoji="$1"
    # Skip if empty
    [[ -z "$selectedEmoji" ]] && return
    # Remove duplicates and keep only the latest maxRecent entries
    grep -Fxv "$selectedEmoji" "$recentFile" | head -n $((maxRecent - 1)) > "${recentFile}.tmp"
    echo "$selectedEmoji" | cat - "${recentFile}.tmp" > "$recentFile"
    rm -f "${recentFile}.tmp"
}

# Insert emoji into the active window
insertEmoji() {
    local emoji="$1"
    if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
        wtype "$emoji"
    else
        xdotool type --clearmodifiers "$emoji"
    fi
}

# Copy emoji to clipboard as a fallback
copyToClipboard() {
    local emoji="$1"
    # Use wl-copy for Wayland, xclip for X11
    if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
        echo -n "$emoji" | wl-copy
    else
        echo -n "$emoji" | xclip -selection clipboard
    fi
    echo "Copied $emoji to clipboard"
}

# Launch Rofi in emoji mode
launchEmojiPicker() {
    # Combine recent emojis and full emoji list
    local emojiList=$(getRecentEmojis)
    # Run Rofi in emoji mode with custom theme
    local selected=$(rofi -show emoji -emoji-format "{emoji}" -p "Pick an emoji 😊" $themeArgs -kb-custom-1 "Alt+Shift+1")
    local exitCode=$?

    # Handle selection
    if [[ $exitCode -eq 0 ]]; then
        # Enter: Insert emoji directly
        insertEmoji "$selected"
        updateRecentEmojis "$selected"
    elif [[ $exitCode -eq 10 ]]; then
        # Alt+Shift+1: Copy to clipboard
        copyToClipboard "$selected"
        updateRecentEmojis "$selected"
    fi
}

# Main function to run the script
main() {
    checkDependencies
    setupConfig
    launchEmojiPicker
}

# Start the script
main
