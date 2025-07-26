#!/usr/bin/env bash

# Catppuccin Mocha color palette
mocha_rosewater="\e[38;2;245;224;220m"
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
mocha_subtext1="\e[38;2;186;200;222m"
mocha_subtext0="\e[38;2;147;153;178m"
mocha_overlay2="\e[38;2;147;153;178m"
mocha_overlay1="\e[38;2;127;132;156m"
mocha_overlay0="\e[38;2;108;112;134m"
mocha_surface2="\e[38;2;88;91;112m"
mocha_surface1="\e[38;2;69;71;90m"
mocha_surface0="\e[38;2;49;50;68m"
mocha_base="\e[38;2;30;30;46m"
mocha_mantle="\e[38;2;24;24;37m"
mocha_crust="\e[38;2;17;17;27m"
reset="\e[0m"

# Formatted print functions with enhanced styling
print_info() { printf "${mocha_teal}[*] %s${reset}\n" "$1"; }
print_success() { printf "${mocha_green}[+] %s${reset}\n" "$1"; }
print_error() { printf "${mocha_red}[-] %s${reset}\n" "$1"; }
print_warning() { printf "${mocha_yellow}[!] %s${reset}\n" "$1"; }
print_title() { printf "${mocha_mauve}== %s ==${reset}\n" "$1"; }

# Dependencies to check/install
dependencies=("alacritty" "waybar" "rofi" "wlogout" "fastfetch" "kitty" "nvim" "cava" "btop" "swayosd" "swaync" "dunst")

# Paths
config_dir="$HOME/.config"
backup_dir="$HOME/.hyprdots.bak"
local_share_dir="$HOME/.local/share"
repo_dir="$HOME/hyprdots"

# Check if running as root
check_root() {
    if [ "$(id -u)" -eq 0 ]; then
        print_error "This script must not be run as root."
        exit 1
    fi
}

# Check if git is installed
check_git() {
    if ! command -v git &>/dev/null; then
        print_error "Git is required but not installed. Please install git."
        exit 1
    fi
}

# Clone repository if not present
clone_repository() {
    print_title "Repository Setup"
    if [ ! -d "$repo_dir" ]; then
        print_info "Cloning zephardev/hyprdots repository..."
        if ! git clone https://github.com/zephardev/hyprdots.git "$repo_dir"; then
            print_error "Failed to clone repository."
            exit 1
        fi
        print_success "Repository cloned to $repo_dir."
    else
        print_info "Repository already exists at $repo_dir."
    fi
}

# Create backup of existing configurations
create_backup() {
    print_title "Creating Backup"
    print_info "Backing up existing configurations to $backup_dir..."
    if [ -d "$backup_dir" ]; then
        print_warning "Backup directory exists. Overwriting..."
        rm -rf "$backup_dir" || { print_error "Failed to remove old backup."; exit 1; }
    fi
    mkdir -p "$backup_dir" || { print_error "Failed to create backup directory."; exit 1; }

    for dep in "${dependencies[@]}" hypr; do
        if [ -d "$config_dir/$dep" ]; then
            cp -r "$config_dir/$dep" "$backup_dir/" || { print_error "Failed to backup $dep config."; exit 1; }
            print_success "$dep configuration backed up."
        fi
    done

    if [ -d "$local_share_dir" ]; then
        cp -r "$local_share_dir" "$backup_dir/local_share" || { print_error "Failed to backup local/share."; exit 1; }
        print_success "local/share backed up."
    fi
}

# Check if dependencies are installed
check_dependencies() {
    print_title "Dependency Check"
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

# Install dependencies using package manager
install_dependencies() {
    print_title "Installing Dependencies"
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

# Install configurations
install_configurations() {
    create_backup
    print_title "Installing Configurations"

    for dep in "${dependencies[@]}" hypr; do
        if [ -d "$repo_dir/.config/$dep" ]; then
            mkdir -p "$config_dir/$dep" || { print_error "Failed to create directory $config_dir/$dep."; exit 1; }
            cp -r "$repo_dir/.config/$dep/"* "$config_dir/$dep/" || { print_error "Failed to copy $dep config."; exit 1; }
            print_success "$dep configuration installed."
        fi
    done

    if [ -d "$repo_dir/.local/share" ]; then
        mkdir -p "$local_share_dir" || { print_error "Failed to create directory $local_share_dir."; exit 1; }
        cp -r "$repo_dir/.local/share/"* "$local_share_dir/" || { print_error "Failed to copy local/share files."; exit 1; }
        print_success "local/share files installed."
    fi

    print_success "Installation completed successfully."
}

# Manual installation menu
manual_installation() {
    while true; do
        clear
        print_title "Manual Installation"
        printf "${mocha_text}Select components to install:${reset}\n"
        for i in "${!dependencies[@]}"; do
            printf "${mocha_lavender}%2d) %s${reset}\n" "$((i+1))" "${dependencies[$i]}"
        done
        printf "${mocha_lavender}%2d) Hyprland configuration${reset}\n" "$(( ${#dependencies[@]} + 1 ))"
        printf "${mocha_pink}%2d) Back${reset}\n" "$(( ${#dependencies[@]} + 2 ))"
        printf "${mocha_rosewater}Enter choice: ${reset}"
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
        read -p "${mocha_rosewater}Press Enter to continue...${reset}"
    done
}

# Selective backup and restore
selective_backup_restore() {
    while true; do
        clear
        print_title "Selective Backup/Restore"
        printf "${mocha_text}1) Create selective backup${reset}\n"
        printf "${mocha_text}2) Restore selective backup${reset}\n"
        printf "${mocha_pink}3) Back${reset}\n"
        printf "${mocha_rosewater}Enter choice: ${reset}"
        read -r choice

        case $choice in
            1)
                clear
                print_title "Selective Backup"
                printf "${mocha_text}Select configurations to backup:${reset}\n"
                for i in "${!dependencies[@]}"; do
                    printf "${mocha_lavender}%2d) %s${reset}\n" "$((i+1))" "${dependencies[$i]}"
                done
                printf "${mocha_lavender}%2d) Hyprland configuration${reset}\n" "$(( ${#dependencies[@]} + 1 ))"
                printf "${mocha_rosewater}Enter choices (space-separated): ${reset}"
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
                    read -p "${mocha_rosewater}Press Enter to continue...${reset}"
                    continue
                fi
                clear
                print_title "Selective Restore"
                printf "${mocha_text}Select configurations to restore:${reset}\n"
                local backups=($(ls "$backup_dir"))
                for i in "${!backups[@]}"; do
                    printf "${mocha_lavender}%2d) %s${reset}\n" "$((i+1))" "${backups[$i]}"
                done
                printf "${mocha_rosewater}Enter choices (space-separated): ${reset}"
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
        read -p "${mocha_rosewater}Press Enter to continue...${reset}"
    done
}

# Uninstall configurations
uninstall_configurations() {
    print_title "Uninstalling Configurations"
    if [ ! -d "$backup_dir" ]; then
        print_error "No backup directory found at $backup_dir."
        return 1
    fi

    print_info "Restoring configurations from backup..."
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

    print_success "Uninstallation completed. Original configurations restored."
}

# Display help
display_help() {
    clear
    print_title "Hyprdots Installation Script Help"
    printf "${mocha_text}Welcome to the Hyprdots installation script!${reset}\n"
    printf "${mocha_subtext1}This script simplifies the installation and management of zephardev/hyprdots configurations.${reset}\n\n"
    printf "${mocha_lavender}Available Options:${reset}\n"
    printf "${mocha_blue}  1) Install configuration:${reset} Installs all configurations to ~/.config and ~/.local/share, with a backup at ~/.hyprdots.bak.\n"
    printf "${mocha_blue}  2) Check dependencies:${reset} Verifies if required dependencies (alacritty, waybar, etc.) are installed.\n"
    printf "${mocha_blue}  3) Manual installation:${reset} Install individual component configurations selectively.\n"
    printf "${mocha_blue}  4) Selective backup/restore:${reset} Backup or restore specific configurations.\n"
    printf "${mocha_blue}  5) Uninstall:${reset} Removes installed configurations and restores from backup.\n"
    printf "${mocha_blue}  6) Help:${reset} Displays this help message.\n"
    printf "${mocha_blue}  7) Exit:${reset} Exits the script.\n\n"
    printf "${mocha_rosewater}Notes:${reset}\n"
    printf "${mocha_subtext0}- Ensure git is installed and you have appropriate permissions.${reset}\n"
    printf "${mocha_subtext0}- Backups are stored in ~/.hyprdots.bak for safety.${reset}\n"
    printf "${mocha_subtext0}- Use the selective backup/restore option to manage specific configurations.${reset}\n"
    read -p "${mocha_rosewater}Press Enter to return to the main menu...${reset}"
}

# Main menu
main_menu() {
    check_root
    check_git
    clone_repository

    while true; do
        clear
        printf "${mocha_mauve}┌──────────────────────────────┐${reset}\n"
        printf "${mocha_mauve}│ Hyprdots Installation Script │${reset}\n"
        printf "${mocha_mauve}└──────────────────────────────┘${reset}\n"
        printf "${mocha_text}  1) Install configuration${reset}\n"
        printf "${mocha_text}  2) Check dependencies${reset}\n"
        printf "${mocha_text}  3) Manual installation${reset}\n"
        printf "${mocha_text}  4) Selective backup/restore${reset}\n"
        printf "${mocha_text}  5) Uninstall${reset}\n"
        printf "${mocha_text}  6) Help${reset}\n"
        printf "${mocha_pink}  7) Exit${reset}\n"
        printf "${mocha_rosewater}Enter choice: ${reset}"
        read -r choice

        case $choice in
            1)
                install_configurations
                read -p "${mocha_rosewater}Press Enter to continue...${reset}"
                ;;
            2)
                check_dependencies || install_dependencies
                read -p "${mocha_rosewater}Press Enter to continue...${reset}"
                ;;
            3)
                manual_installation
                ;;
            4)
                selective_backup_restore
                ;;
            5)
                uninstall_configurations
                read -p "${mocha_rosewater}Press Enter to continue...${reset}"
                ;;
            6)
                display_help
                ;;
            7)
                print_success "Thank you for using the Hyprdots installer. Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please select 1-7."
                read -p "${mocha_rosewater}Press Enter to continue...${reset}"
                ;;
        esac
    done
}

# Trap errors and provide rescue option
trap 'print_error "An error occurred. Restore from backup? (y/n)"; read -r ans; if [[ $ans == "y" || $ans == "Y" ]]; then uninstall_configurations; fi; exit 1' ERR

# Start the script
main_menu
