#!/bin/bash

# catppuccin mocha color palette
color_base="1E1E2E"  # base
color_text="CDD6F4"  # text
color_rosewater="F5E0DC"  # rosewater
color_flamingo="F2CDCD"  # flamingo
color_pink="F5C2E7"    # pink
color_mauve="CBA6F7"   # mauve
color_red="F38BA8"     # red
color_maroon="EBA0AC"  # maroon
color_peach="FAB387"   # peach
color_yellow="F9E2AF"  # yellow
color_green="A6E3A1"   # green
color_teal="94E2D5"    # teal
color_sky="89DCEB"     # sky
color_sapphire="74C7EC" # sapphire
color_blue="89B4FA"    # blue
color_lavender="B4BEFE" # lavender

# reset color
reset="\033[0m"

# formatted print functions
print_info() { printf "\033[38;2;${color_text}m[*] %s${reset}\n" "$1"; }
print_success() { printf "\033[38;2;${color_green}m[+] %s${reset}\n" "$1"; }
print_error() { printf "\033[38;2;${color_red}m[-] %s${reset}\n" "$1"; }
print_warning() { printf "\033[38;2;${color_yellow}m[!] %s${reset}\n" "$1"; }

# dependencies to check/install
dependencies=("alacritty" "waybar" "rofi" "wlogout" "fastfetch" "kitty" "nvim" "cava" "btop" "swayosd" "swaync" "dunst")

# paths
config_dir="$HOME/.config"
backup_dir="$HOME/.hyprdots.bak"
local_share_dir="$HOME/.local/share"
repo_dir="$HOME/hyprdots"

# check if running as root
check_root() {
    if [ "$(id -u)" -eq 0 ]; then
        print_error "This script should not be run as root."
        exit 1
    fi
}

# check if git is installed
check_git() {
    if ! command -v git &>/dev/null; then
        print_error "Git is not installed. Please install git first."
        exit 1
    fi
}

# clone repository if not present
clone_repository() {
    if [ ! -d "$repo_dir" ]; then
        print_info "Cloning zephardev/hyprdots repository..."
        if ! git clone https://github.com/ZepharDev/hyprdots.git "$repo_dir"; then
            print_error "Failed to clone repository."
            exit 1
        fi
        print_success "Repository cloned successfully."
    else
        print_info "Repository already exists at $repo_dir."
    fi
}

# create backup of existing configurations
create_backup() {
    print_info "Creating backup of existing configurations..."
    if [ -d "$backup_dir" ]; then
        print_warning "Backup directory already exists. Overwriting..."
        rm -rf "$backup_dir" || { print_error "Failed to remove old backup."; exit 1; }
    fi
    mkdir -p "$backup_dir" || { print_error "Failed to create backup directory."; exit 1; }

    for dep in "${dependencies[@]}" hypr; do
        if [ -d "$config_dir/$dep" ]; then
            cp -r "$config_dir/$dep" "$backup_dir/" || { print_error "Failed to backup $dep config."; exit 1; }
        fi
    done

    if [ -d "$local_share_dir" ]; then
        cp -r "$local_share_dir" "$backup_dir/local_share" || { print_error "Failed to backup local/share."; exit 1; }
    fi
    print_success "Backup created at $backup_dir."
}

# check if dependencies are installed
check_dependencies() {
    print_info "Checking dependencies..."
    local missing_deps=()

    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing_deps+=("$dep")
        else
            print_success "$dep is installed."
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_warning "Missing dependencies: ${missing_deps[*]}"
        return 1
    fi
    print_success "All dependencies are installed."
    return 0
}

# install dependencies using package manager
install_dependencies() {
    print_info "Attempting to install missing dependencies..."
    local pkg_manager=""

    if command -v pacman &>/dev/null; then
        pkg_manager="pacman"
    elif command -v apt &>/dev/null; then
        pkg_manager="apt"
    else
        print_error "No supported package manager found (pacman or apt)."
        exit 1
    fi

    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            print_info "Installing $dep..."
            if [ "$pkg_manager" = "pacman" ]; then
                sudo pacman -S --noconfirm "$dep" || print_error "Failed to install $dep."
            elif [ "$pkg_manager" = "apt" ]; then
                sudo apt install -y "$dep" || print_error "Failed to install $dep."
            fi
        fi
    done
}

# install configurations
install_configurations() {
    create_backup
    print_info "Installing configurations..."

    # copy config files
    for dep in "${dependencies[@]}" hypr; do
        if [ -d "$repo_dir/.config/$dep" ]; then
            mkdir -p "$config_dir/$dep" || { print_error "Failed to create directory $config_dir/$dep."; exit 1; }
            cp -r "$repo_dir/.config/$dep/"* "$config_dir/$dep/" || { print_error "Failed to copy $dep config."; exit 1; }
            print_success "$dep configuration installed."
        fi
    done

    # copy local/share files
    if [ -d "$repo_dir/.local/share" ]; then
        mkdir -p "$local_share_dir" || { print_error "Failed to create directory $local_share_dir."; exit 1; }
        cp -r "$repo_dir/.local/share/"* "$local_share_dir/" || { print_error "Failed to copy local/share files."; exit 1; }
        print_success "local/share files installed."
    fi

    print_success "All configurations installed successfully."
}

# manual installation menu
manual_installation() {
    while true; do
        clear
        printf "\033[38;2;${color_mauve}m=== Manual Installation Menu ===${reset}\n"
        printf "\033[38;2;${color_text}mSelect components to install:${reset}\n"
        for i in "${!dependencies[@]}"; do
            printf "\033[38;2;${color_blue}m%d) %s${reset}\n" "$((i+1))" "${dependencies[$i]}"
        done
        printf "\033[38;2;${color_blue}m%d) Hyprland configuration${reset}\n" "$(( ${#dependencies[@]} + 1 ))"
        printf "\033[38;2;${color_pink}m%d) Back${reset}\n" "$(( ${#dependencies[@]} + 2 ))"
        printf "\033[38;2;${color_rosewater}mEnter choice (1-%d): ${reset}" "$(( ${#dependencies[@]} + 2 ))"
        read -r choice

        if [ "$choice" -eq "$(( ${#dependencies[@]} + 2 ))" ]; then
            break
        elif [ "$choice" -ge 1 ] && [ "$choice" -le "${#dependencies[@]}" ]; then
            dep=${dependencies[$((choice-1))]}
            print_info "Installing $dep configuration..."
            if [ -d "$repo_dir/.config/$dep" ]; then
                mkdir -p "$backup_dir/$dep" || { print_error "Failed to create backup directory."; exit 1; }
                [ -d "$config_dir/$dep" ] && cp -r "$config_dir/$dep" "$backup_dir/" || true
                mkdir -p "$config_dir/$dep" || { print_error "Failed to create directory $config_dir/$dep."; exit 1; }
                cp -r "$repo_dir/.config/$dep/"* "$config_dir/$dep/" || { print_error "Failed to install $dep config."; exit 1; }
                print_success "$dep configuration installed."
            else
                print_error "Configuration for $dep not found in repository."
            fi
        elif [ "$choice" -eq "$(( ${#dependencies[@]} + 1 ))" ]; then
            print_info "Installing Hyprland configuration..."
            mkdir -p "$backup_dir/hypr" || { print_error "Failed to create backup directory."; exit 1; }
            [ -d "$config_dir/hypr" ] && cp -r "$config_dir/hypr" "$backup_dir/" || true
            mkdir -p "$config_dir/hypr" || { print_error "Failed to create directory $config_dir/hypr."; exit 1; }
            cp -r "$repo_dir/.config/hypr/"* "$config_dir/hypr/" || { print_error "Failed to install Hyprland config."; exit 1; }
            print_success "Hyprland configuration installed."
        else
            print_error "Invalid choice."
        fi
        read -p "Press Enter to continue..."
    done
}

# selective backup and restore
selective_backup_restore() {
    while true; do
        clear
        printf "\033[38;2;${color_mauve}m=== Selective Backup/Restore Menu ===${reset}\n"
        printf "\033[38;2;${color_text}m1) Create selective backup${reset}\n"
        printf "\033[38;2;${color_text}m2) Restore selective backup${reset}\n"
        printf "\033[38;2;${color_pink}m3) Back${reset}\n"
        printf "\033[38;2;${color_rosewater}mEnter choice (1-3): ${reset}"
        read -r choice

        case $choice in
            1)
                clear
                printf "\033[38;2;${color_mauve}m=== Select configurations to backup ===${reset}\n"
                for i in "${!dependencies[@]}"; do
                    printf "\033[38;2;${color_blue}m%d) %s${reset}\n" "$((i+1))" "${dependencies[$i]}"
                done
                printf "\033[38;2;${color_blue}m%d) Hyprland configuration${reset}\n" "$(( ${#dependencies[@]} + 1 ))"
                printf "\033[38;2;${color_rosewater}mEnter choices (space-separated, e.g., 1 2 3): ${reset}"
                read -r -a selections

                mkdir -p "$backup_dir" || { print_error "Failed to create backup directory."; exit 1; }
                for sel in "${selections[@]}"; do
                    if [ "$sel" -ge 1 ] && [ "$sel" -le "${#dependencies[@]}" ]; then
                        dep=${dependencies[$((sel-1))]}
                        if [ -d "$config_dir/$dep" ]; then
                            cp -r "$config_dir/$dep" "$backup_dir/" || print_error "Failed to backup $dep."
                            print_success "$dep configuration backed up."
                        fi
                    elif [ "$sel" -eq "$(( ${#dependencies[@]} + 1 ))" ]; then
                        if [ -d "$config_dir/hypr" ]; then
                            cp -r "$config_dir/hypr" "$backup_dir/" || print_error "Failed to backup Hyprland config."
                            print_success "Hyprland configuration backed up."
                        fi
                    else
                        print_error "Invalid selection: $sel"
                    fi
                done
                ;;
            2)
                if [ ! -d "$backup_dir" ]; then
                    print_error "No backup directory found at $backup_dir."
                    read -p "Press Enter to continue..."
                    continue
                fi
                clear
                printf "\033[38;2;${color_mauve}m=== Select configurations to restore ===${reset}\n"
                local backups=($(ls "$backup_dir"))
                for i in "${!backups[@]}"; do
                    printf "\033[38;2;${color_blue}m%d) %s${reset}\n" "$((i+1))" "${backups[$i]}"
                done
                printf "\033[38;2;${color_rosewater}mEnter choices (space-separated, e.g., 1 2 3): ${reset}"
                read -r -a selections

                for sel in "${selections[@]}"; do
                    if [ "$sel" -ge 1 ] && [ "$sel" -le "${#backups[@]}" ]; then
                        item=${backups[$((sel-1))]}
                        mkdir -p "$config_dir/$item" || { print_error "Failed to create directory $config_dir/$item."; exit 1; }
                        cp -r "$backup_dir/$item/"* "$config_dir/$item/" || print_error "Failed to restore $item."
                        print_success "$item configuration restored."
                    else
                        print_error "Invalid selection: $sel"
                    fi
                done
                ;;
            3)
                break
                ;;
            *)
                print_error "Invalid choice."
                ;;
        esac
        read -p "Press Enter to continue..."
    done
}

# uninstall configurations
uninstall_configurations() {
    if [ ! -d "$backup_dir" ]; then
        print_error "No backup directory found at $backup_dir."
        return 1
    fi

    print_info "Uninstalling configurations and restoring from backup..."
    for dep in "${dependencies[@]}" hypr; do
        if [ -d "$config_dir/$dep" ]; then
            rm -rf "$config_dir/$dep" || { print_error "Failed to remove $dep config."; exit 1; }
            if [ -d "$backup_dir/$dep" ]; then
                cp -r "$backup_dir/$dep" "$config_dir/" || print_error "Failed to restore $dep config."
                print_success "$dep configuration restored."
            fi
        fi
    done

    if [ -d "$backup_dir/local_share" ]; then
        rm -rf "$local_share_dir" || { print_error "Failed to remove local/share."; exit 1; }
        cp -r "$backup_dir/local_share" "$local_share_dir" || print_error "Failed to restore local/share."
        print_success "local/share restored."
    fi

    print_success "Uninstallation complete. All configurations restored from backup."
}

# display help
display_help() {
    clear
    printf "\033[38;2;${color_mauve}m=== Hyprdots Installation Script Help ===${reset}\n"
    printf "\033[38;2;${color_text}mThis script manages the installation of zephardev/hyprdots configurations.${reset}\n\n"
    printf "\033[38;2;${color_lavender}mOptions:${reset}\n"
    printf "\033[38;2;${color_blue}m1) Install configuration:${reset} Installs all configurations from the repository to ~/.config and ~/.local/share, creating a backup at ~/.hyprdots.bak.\n"
    printf "\033[38;2;${color_blue}m2) Check dependencies:${reset} Verifies if required dependencies (alacritty, waybar, rofi, etc.) are installed.\n"
    printf "\033[38;2;${color_blue}m3) Manual installation:${reset} Allows selective installation of individual component configurations.\n"
    printf "\033[38;2;${color_blue}m4) Selective backup/restore:${reset} Backs up or restores specific configurations.\n"
    printf "\033[38;2;${color_blue}m5) Uninstall:${reset} Removes installed configurations and restores from backup.\n"
    printf "\033[38;2;${color_blue}m6) Help:${reset} Displays this help message.\n"
    printf "\033[38;2;${color_blue}m7) Exit:${reset} Exits the script.\n\n"
    printf "\033[38;2;${color_rosewater}mNote:${reset} Ensure you have git installed and sufficient permissions. Backups are stored in ~/.hyprdots.bak.\n"
    read -p "Press Enter to return to the main menu..."
}

# main menu
main_menu() {
    check_root
    check_git
    clone_repository

    while true; do
        clear
        printf "\033[38;2;${color_mauve}m=====================================${reset}\n"
        printf "\033[38;2;${color_mauve}m Hyprdots Installation Script${reset}\n"
        printf "\033[38;2;${color_mauve}m=====================================${reset}\n"
        printf "\033[38;2;${color_text}m1) Install configuration${reset}\n"
        printf "\033[38;2;${color_text}m2) Check dependencies${reset}\n"
        printf "\033[38;2;${color_text}m3) Manual installation${reset}\n"
        printf "\033[38;2;${color_text}m4) Selective backup/restore${reset}\n"
        printf "\033[38;2;${color_text}m5) Uninstall${reset}\n"
        printf "\033[38;2;${color_text}m6) Help${reset}\n"
        printf "\033[38;2;${color_pink}m7) Exit${reset}\n"
        printf "\033[38;2;${color_rosewater}mEnter choice (1-7): ${reset}"
        read -r choice

        case $choice in
            1)
                install_configurations
                read -p "Press Enter to continue..."
                ;;
            2)
                check_dependencies || install_dependencies
                read -p "Press Enter to continue..."
                ;;
            3)
                manual_installation
                ;;
            4)
                selective_backup_restore
                ;;
            5)
                uninstall_configurations
                read -p "Press Enter to continue..."
                ;;
            6)
                display_help
                ;;
            7)
                print_success "Exiting script."
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please select 1-7."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# trap errors and provide rescue option
trap 'print_error "An error occurred. Do you want to restore from backup? (y/n)"; read -r ans; if [[ $ans == "y" || $ans == "Y" ]]; then uninstall_configurations; fi; exit 1' ERR

# start the script
main_menu
