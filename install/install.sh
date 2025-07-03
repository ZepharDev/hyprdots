#!/bin/bash

set -euo pipefail 
IFS=$'\n\t'

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # Sin color

DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
CACHE_DIR="$HOME/.dotfiles_cache"
LOG_FILE="$HOME/.dotfiles_install.log"
declare -A DOTFILES=(
    ["zshrc"]="$HOME/.zshrc"
    ["vimrc"]="$HOME/.vimrc"
    ["gitconfig"]="$HOME/.gitconfig"
)

log_message() {
    local type="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $type: $message" >> "$LOG_FILE"
    case "$type" in
        ERROR) echo -e "${RED}$message${NC}" ;;
        WARNING) echo -e "${YELLOW}$message${NC}" ;;
        INFO) echo -e "${GREEN}$message${NC}" ;;
    esac
}

check_dependencies() {
    local dependencies=("git" "bash" "ln" "mkdir" "rm" "cp")
    local missing=0

    log_message INFO "Verificando dependencias..."
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            log_message ERROR "Dependencia faltante: $dep"
            missing=1
        fi
    done

    if [ "$missing" -eq 1 ]; then
        log_message ERROR "Faltan dependencias. Por favor, instálalas e intenta de nuevo."
        exit 1
    fi
    log_message INFO "Todas las dependencias están instaladas."
}

backup_dotfiles() {
    log_message INFO "Creando respaldo en $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR" || {
        log_message ERROR "No se pudo crear el directorio de respaldo $BACKUP_DIR"
        exit 1
    }

    for src in "${!DOTFILES[@]}"; do
        local target="${DOTFILES[$src]}"
        if [ -f "$target" ] || [ -d "$target" ]; then
            cp -r "$target" "$BACKUP_DIR/" 2>/dev/null || {
                log_message WARNING "No se pudo respaldar $target"
            }
        fi
    done
    log_message INFO "Respaldo completado en $BACKUP_DIR."
}

create_cache() {
    log_message INFO "Creando cache en $CACHE_DIR..."
    mkdir -p "$CACHE_DIR" || {
        log_message ERROR "No se pudo crear el directorio de cache $CACHE_DIR"
        exit 1
    }
    cp -r "$DOTFILES_DIR/." "$CACHE_DIR/" 2>/dev/null || {
        log_message ERROR "No se pudo crear cache de los dotfiles"
        exit 1
    }
    log_message INFO "Cache creado en $CACHE_DIR."
}

restore_backup() {
    if [ -d "$BACKUP_DIR" ]; then
        log_message INFO "Restaurando desde respaldo $BACKUP_DIR..."
        for src in "${!DOTFILES[@]}"; do
            local target="${DOTFILES[$src]}"
            if [ -f "$BACKUP_DIR/$src" ] || [ -d "$BACKUP_DIR/$src" ]; then
                cp -r "$BACKUP_DIR/$src" "$target" 2>/dev/null || {
                    log_message WARNING "No se pudo restaurar $target"
                }
            fi
        done
        log_message INFO "Restauración completada."
    else
        log_message WARNING "No se encontró respaldo en $BACKUP_DIR."
    fi
}

install_dotfiles() {
    log_message INFO "Instalando dotfiles desde $DOTFILES_DIR..."
    for src in "${!DOTFILES[@]}"; do
        local source_file="$DOTFILES_DIR/$src"
        local target_file="${DOTFILES[$src]}"

        if [ ! -f "$source_file" ] && [ ! -d "$source_file" ]; then
            log_message WARNING "Archivo fuente $source_file no existe, omitiendo..."
            continue
        }

        mkdir -p "$(dirname "$target_file")" || {
            log_message ERROR "No se pudo crear el directorio $(dirname "$target_file")"
            continue
        }

        if [ -f "$target_file" ] || [ -d "$target_file" ]; then
            rm -rf "$target_file" 2>/dev/null || {
                log_message ERROR "No se pudo eliminar el archivo existente $target_file"
                continue
            }
        fi

        ln -s "$source_file" "$target_file" 2>/dev/null || {
            log_message ERROR "No se pudo crear el enlace simbólico para $source_file"
            continue
        }
        log_message INFO "Enlace creado: $target_file -> $source_file"
    done
}

check_permissions() {
    log_message INFO "Verificando permisos..."
    if [ ! -r "$DOTFILES_DIR" ] || [ ! -x "$DOTFILES_DIR" ]; then
        log_message ERROR "No se tienen permisos de lectura/escritura en $DOTFILES_DIR"
        exit 1
    fi
    log_message INFO "Permisos verificados correctamente."
}

main() {
    # Inicializar log
    touch "$LOG_FILE" 2>/dev/null || {
        echo "No se pudo crear el archivo de log $LOG_FILE" >&2
        exit 1
    }

    log_message INFO "Iniciando instalación de dotfiles..."

    if [ ! -d "$DOTFILES_DIR" ]; then
        log_message ERROR "El directorio de dotfiles $DOTFILES_DIR no existe."
        exit 1
    }

    check_dependencies
    check_permissions
    backup_dotfiles
    create_cache
    install_dotfiles

    log_message INFO "Instalación completada exitosamente."

    # Limpiar cache antiguo (mantener solo el más reciente)
    find "$HOME" -maxdepth 1 -type d -name ".dotfiles_cache_*" -not -path "$CACHE_DIR" -exec rm -rf {} \; 2>/dev/null
}

trap 'log_message ERROR "Error en línea $LINENO"; restore_backup; exit 1' ERR

if [ $# -gt 0 ]; then
    case "$1" in
        --help|-h)
            echo "Uso: $0"
            echo "Instala dotfiles desde $DOTFILES_DIR con respaldo y cache."
            exit 0
            ;;
        *)
            log_message ERROR "Argumento desconocido: $1"
            exit 1
            ;;
    esac
fi

main