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

# Directory variables
dotfilesdir="$HOME/hyprdots"
configsdir="$HOME"
configdir="$HOME/.config"
localdir="$HOME/.local"
wallpapersdir="$HOME/.local/share/wallpapers"
catppuccindir="$HOME/.local/share/catppuccin"
backupdir="$HOME/.hyprdots.backup"
repourl="https://github.com/zephardev/dotfiles.git"
githuburl="https://github.com/zephardev"
contactemail="zephartw@gmail.com"

# Banner function
print_banner() {
    clear
    echo -e "${mocha_mauve}┌──────────────────────────────────────────────────┐${reset}"
    echo -e "${mocha_mauve}│${mocha_pink}       Hyprdots Installation Script                ${mocha_mauve}│${reset}"
    echo -e "${mocha_mauve}│${mocha_flamingo}   Aesthetic, Customizable, Catppuccin Mocha Vibes ${mocha_mauve}│${reset}"
    echo -e "${mocha_mauve}└──────────────────────────────────────────────────┘${reset}"
    echo -e "${mocha_red}⚠️ WARNING: This script may overwrite existing configurations!${reset}"
    echo -e "${mocha_red}⚠️ Backing up to $backupdir. Ensure you review backups.${reset}"
    echo
}

# Help function
show_help() {
    echo -e "${mocha_lavender}Help Menu:${reset}"
    echo -e "${mocha_teal}GitHub:${reset} ${githuburl}"
    echo -e "${mocha_teal}Contact:${reset} ${contactemail}"
    echo -e "${mocha_subtext0}Check the repository or email for support.${reset}"
    echo
    read -p "Press Enter to continue..."
}

# Check dependencies function
check_dependencies() {
    echo -e "${mocha_blue}Checking dependencies...${reset}"
    local deps=("git" "stow")
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
    mkdir -p "$backupdir"
    [ -d "$configdir" ] && cp -r "$configdir" "$backupdir/config" 2>/dev/null
    [ -d "$localdir" ] && cp -r "$localdir" "$backupdir/local" 2>/dev/null
    for file in "$configsdir"/.*; do
        [ -f "$file" ] && cp "$file" "$backupdir" 2>/dev/null
    done
    echo -e "${mocha_green}✓ Backup completed${reset}"
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

# Clone or update repository function
clone_or_update_repo() {
    if [ -d "$dotfilesdir" ]; then
        echo -e "${mocha_blue}Updating hyprdots repository...${reset}"
        cd "$dotfilesdir" || exit 1
        git pull origin main || { echo -e "${mocha_red}✗ Failed to update repository${reset}"; exit 1; }
    else
        echo -e "${mocha_blue}Cloning hyprdots repository...${reset}"
        git clone "$repourl" "$dotfilesdir" || { echo -e "${mocha_red}✗ Failed to clone repository${reset}"; exit 1; }
        cd "$dotfilesdir" || exit 1
    fi
    echo
}

# Prompt for local import
prompt_local_import() {
    local scope="$1"
    echo -e "${mocha_peach}Do you want to import local configurations for $scope? (y/n)${reset}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo -e "${mocha_blue}Copying local configurations to $catppuccindir...${reset}"
        cp -r "$dotfilesdir/config/." "$catppuccindir/" 2>/dev/null || { echo -e "${mocha_red}✗ Failed to import local configs${reset}"; exit 1; }
        echo -e "${mocha_green}✓ Local configurations imported${reset}"
    else
        echo -e "${mocha_yellow}Skipping local import${reset}"
    fi
    echo
}

# Full setup installation function
install_full_setup() {
    echo -e "${mocha_blue}Installing full hyprdots setup...${reset}"
    backup_configs
    create_directories
    clone_or_update_repo
    prompt_local_import "full setup"
    for dir in "$dotfilesdir"/configs/*; do
        [ -d "$dir" ] && stow -t "$configsdir" -d "$dotfilesdir/configs" "$(basename "$dir")" || echo -e "${mocha_red}✗ Failed to stow $(basename "$dir")${reset}"
    done
    for dir in "$dotfilesdir"/config/*; do
        [ -d "$dir" ] && stow -t "$configdir" -d "$dotfilesdir/config" "$(basename "$dir")" || echo -e "${mocha_red}✗ Failed to stow $(basename "$dir")${reset}"
    done
    for dir in "$dotfilesdir"/local/*; do
        [ -d "$dir" ] && stow -t "$localdir" -d "$dotfilesdir/local" "$(basename "$dir")" || echo -e "${mocha_red}✗ Failed to stow $(basename "$dir")${reset}"
    done
    echo -e "${mocha_green}✓ Full setup installed${reset}"
    echo
}

# Selective installation function
install_selective() {
    echo -e "${mocha_blue}Available configurations:${reset}"
    local configs=()
    for dir in "$dotfilesdir"/config/* "$dotfilesdir"/configs/* "$dotfilesdir"/local/*; do
        [ -d "$dir" ] && configs+=("$(basename "$dir")")
    done
    if [ ${#configs[@]} -eq 0 ]; then
        echo -e "${mocha_red}✗ No configurations found in repository${reset}"
        exit 1
    fi
    PS3="$(echo -e "${mocha_peach}Select a configuration to install (or 'Quit'):${reset} ")"
    select config in "${configs[@]}" "Quit"; do
        if [ "$config" = "Quit" ]; then
            break
        elif [ -n "$config" ]; then
            backup_configs
            create_directories
            clone_or_update_repo
            prompt_local_import "$config"
            if [ -d "$dotfilesdir/config/$config" ]; then
                stow -t "$configdir" -d "$dotfilesdir/config" "$config" || echo -e "${mocha_red}✗ Failed to stow $config${reset}"
            elif [ -d "$dotfilesdir/configs/$config" ]; then
                stow -t "$configsdir" -d "$dotfilesdir/configs" "$config" || echo -e "${mocha_red}✗ Failed to stow $config${reset}"
            elif [ -d "$dotfilesdir/local/$config" ]; then
                stow -t "$localdir" -d "$dotfilesdir/local" "$config" || echo -e "${mocha_red}✗ Failed to stow $config${reset}"
            else
                echo -e "${mocha_red}✗ Configuration $config not found${reset}"
            fi
            echo -e "${mocha_green}✓ $config installed${reset}"
            break
        else
            echo -e "${mocha_red}Invalid selection${reset}"
        fi
    done
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
        echo -e "${mocha_teal}4) Apply Selectively${reset}"
        echo -e "${mocha_teal}5) Exit${reset}"
        read -p "$(echo -e "${mocha_peach}Enter your choice [1-5]: ${reset}")" choice
        case $choice in
            1) show_help ;;
            2) check_dependencies ;;
            3) install_full_setup ;;
            4) install_selective ;;
            5) echo -e "${mocha_yellow}Exiting...${reset}"; exit 0 ;;
            *) echo -e "${mocha_red}Invalid option, please try again${reset}" ;;
        esac
    done
}

# Execute main menu
main_menu
