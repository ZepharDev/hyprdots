#!/bin/bash

# Catppuccin Mocha color scheme
mocha_rosewater="\e[38;2;245;194;231m"
mocha_flamingo="\e[38;2;242;205;205m"
mocha_pink="\e[38;2;245;194;231m"
mocha_mauve="\e[38;2;203;166;247m"
mocha_red="\e[38;2;243;139;168m"
mocha_peach="\e[38;2;250;179;135m"
mocha_yellow="\e[38;2;249;226;175m"
mocha_green="\e[38;2;166;227;161m"
mocha_teal="\e[38;2;148;226;213m"
mocha_blue="\e[38;2;137;180;250m"
mocha_lavender="\e[38;2;180;190;254m"
mocha_text="\e[38;2;205;214;244m"
mocha_subtext0="\e[38;2;147;153;178m"
mocha_surface0="\e[38;2;49;50;68m"
mocha_base="\e[38;2;30;30;46m"
mocha_mantle="\e[38;2;24;24;37m"
reset="\e[0m"

# Directory variables :

hyprdotsdir="$HOME/hyprdots"
configsdir="$HOME"
configdir="$HOME/.config" # Directory of configurations.
localdir="$HOME/.local"
wallpapersdir="$HOME/hyprdots/configs/local/wallpapers"
catppuccinDir="$HOME/hyprdots/configs/local/catppuccin"
bakupDir="$HOME/.hyprdots.bak"
repoUrl="https://github.com/zephardev/hyprdots.git"
githubUrl="https://github.com/zephardev"
contacteMail="zephartw@gmail.com"
redditUrl="https://reddit.com/Zephar_WO/s/GlplWuhn2H"
Unninstall="$backupDir"

# Banner function
print_banner() {
    clear
    echo -e "${mocha_mauve}┌──────────────────────────────────────────────────┐${reset}"
    echo -e "${mocha_mauve}│${mocha_pink}       Hyprdots Installation Script               ${mocha_mauve}│${reset}"
    echo -e "${mocha_mauve}│${mocha_flamingo}   Aesthetic, Customizable, Catppuccin Mocha Vibes${mocha_mauve}│${reset}"
    echo -e "${mocha_mauve}└──────────────────────────────────────────────────┘${reset}"
    echo -e "${mocha_red} WARNING: This script may overwrite existing configurations!${reset}"
    echo -e "${mocha_red} Backing up to $backupDir. Ensure you review backups.${reset}"
    echo
}

# support o help
show_help() {
    echo -e "${mocha_lavender}Help:${reset}"
    echo -e "${mocha_teal}GitHub:${reset} ${githubUrl}"
    echo -e "${mocha_teal}Contact:${reset} ${contacteMail}"
    echo -e "${mocha_blue}Reddit:${reset} ${redditUrl}"
    echo -e "${mocha_subtext0}Check the repository or email for support.${reset}"
    echo
    read -p "Press Enter to continue..."
}

# Check dependence function :), ¡Advertence!.
# Uninstalled dependencies will be iinstalled automaticaly if you say yes

check_dependencies() {
    echo -e "${mocha_blue}Checking dependencies...${reset}"
    local deps=("git" "nvim" "hyprlock" "waybar" "rofi" "hypridle" "kitty" "zsh" "clipse" "dunst" "swaync" "swayosd" "fastfetch" "wlogout" "cava" "hyprpaper" "NetworkManager" "btop" "hyprshot" "alacritty")
    local missing=()
    for dep in "${deps[@]}"; do
        if command -v "$dep" &>/dev/null; then
            echo -e "${mocha_green}✓ $dep is installed${reset}"
        else
            echo -e "${mocha_red}✗ $dep is not installed${reset}"
            missing+=("$dep")
        fi
    done
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${mocha_yellow}Please install: ${missing[*]}${reset}"
        exit 1
    fi
    echo
}
# Backup existing configurations
backup_configs() {
    echo -e "${mocha_blue}Backing up existing configurations to $backupdir...${reset}"
    mkdir -p "$backupDir"
    [ -d "$configDir" ] && cp -r "$configDir" "$backupDir/config" 2>/dev/null
    [ -d "$localDir" ] && cp -r "$localDir" "$backupDir/local" 2>/dev/null
    for file in "$configsdir"/.*; do
        [ -f "$file" ] && cp "$file" "$backupDir" 2>/dev/null
    done
    echo -e "${mocha_green}✓ Backup completed :)${reset}"
    echo
}

# Create directories function
create_directories() {
    echo -e "${mocha_blue}Creating directories...${reset}"
    mkdir -p "$wallpapersdir" "$catppuccindir" "$backupdir"
    echo -e "${mocha_green}✓ Created $wallpapersdir${reset}"
    echo -e "${mocha_green}✓ Created $catppuccindir${reset}"
    echo -e "${mocha_green}✓-created $backupdir${reset}"
    echo
}

prompt_local_import() {
    local scope="$1"
    echo -e "${mocha_peach}Do you want to import local configurations for $scope? (y/n)${reset}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo -e "${mocha_blue}Copying local configurations to $catppuccinDir and $wallpapersdir...${reset}"
        cp -r "$hyprdotsdir/configs/." "$catppuccinDir and "$wallpapersdir" /" 2>/dev/null || { echo -e "${mocha_red}✗ Failed to import local configs${reset}"; exit 1; }
        echo -e "${mocha_green}✓ Local configurations imported${reset}"
    else
        echo -e "${mocha_yellow}Skipping local import${reset}"
    fi
    echo
}

install_full_setup() {
    echo -e "${mocha_blue}Installing full hyprdots setup...${reset}"
    backup_configs
    create_directories
    prompt_local_import "full setup"
    for dir in "$hyprdotsdir"/configs/*; do
        [ -d "$dir" ] && stow -t "$configsDir" -d "$hyprdotsdir/configs" "$(basename "$dir")" || echo -e "${mocha_red}✗ Failed to stow $(basename "$dir")${reset}"
    done
    for dir in "$hyprdotsdir"/config/*; do
        [ -d "$dir" ] && stow -t "$configDir" -d "$hyprdotsdir/config" "$(basename "$dir")" || echo -e "${mocha_red}✗ Failed to stow $(basename "$dir")${reset}"
    done
    for dir in "$hyprdotsdir"/local/*; do
        [ -d "$dir" ] && stow -t "$localdir" -d "$hyprdotsdir/local" "$(basename "$dir")" || echo -e "${mocha_red}✗ Failed to stow $(basename "$dir")${reset}"
    done
    echo -e "${mocha_green}✓ Full setup installed${reset}"
    echo
}

# Main menu
main_menu() {
    while true; do
        print_banner
        echo -e "${mocha_lavender}Select an option:${reset}"
        echo -e "${mocha_teal}1) Help${reset}"
        echo -e "${mocha_teal}2) Check Dependencies${reset}"
        echo -e "${mocha_teal}3) Install Full Setup${reset}"
        echo -e "${mocha_teal}4) Config Manual${reset}"
        echo -e "${mocha_teal}5) Exit${reset}"
        read -p "$(echo -e "${mocha_peach}Enter your choice [1-5]: ${reset}")" choice
        case $choice in
            1) show_help ;;
            2) check_dependencies ;;
            3) install_full_setup ;;
            4) install_selected_configs ;;
            5) echo -e "${mocha_yellow}Exiting...${reset}"; exit 0 ;;
            *) echo -e "${mocha_red}Invalid option, please try again${reset}" ;;
        esac
    done
}

# Execute main menu
main_menu
