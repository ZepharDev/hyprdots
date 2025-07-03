#!/bin/bash

set -euo pipefail
IFS=$'\n\t'       

# Colores para mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # Sin color

# Directorios y configuraciones
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR_PREFIX="$HOME/.dotfiles_backup_"
CACHE_DIR="$HOME/.dotfiles_cache"
LOG_FILE="$HOME/.dotfiles_uninstall.log"
declare -A DOTFILES=(
    ["zshrc"]="$HOME/.zshrc"
    ["vimrc"]="$HOME/.vimrc"
    ["gitconfig"]="$HOME/.gitconfig"
    # Agrega más dotfiles aquí en el futuro
)

# Función para registrar mensajes
log_message() {
    local type="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $mediatype="text/plain"> $type: $message" >> "$LOG_FILE"
    case "$type" in
        ERROR) echo -e "${RED}$message${NC}" ;;
        WARNING) echo -e "${YELLOW}$message${NC}" ;;
        INFO) echo -e "${GREEN}$message${NC}" ;;
    esac
}

# Función para verificar dependencias
check_dependencies() {
    local dependencies=("bash" "rm" "cp" "find" "ls")
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

# Función para encontrar el respaldo más reciente
find_latest_backup() {
    local latest_backup
    latest_backup=$(find "$HOME" -maxdepth 1 -type d -name ".dotfiles_backup_*" | sort -r | head -n 1)
    if [ -z "$latest_backup" ]; then
        log_message ERROR "No se encontró ningún directorio de respaldo con el prefijo $BACKUP_DIR_PREFIX."
        exit 1
    fi
    echo "$latest_backup"
}

# Función para restaurar desde respaldo
restore_backup() {
    local backup_dir
    backup_dir=$(find_latest_backup)
    log_message INFO "Restaurando desde el respaldo más reciente: $backup_dir..."

    for src in "${!DOTFILES[@]}"; do
        local target="${DOTFILES[$src]}"
        local backup_file="$backup_dir/$src"

        if [ -f "$backup_file" ] || [ -d "$backup_file" ]; then
            # Eliminar enlace simbólico o archivo existente
            if [ -e "$target" ]; then
                rm -rf "$target" 2>/dev/null || {
                    log_message ERROR "No se pudo eliminar $target"
                    continue
                }
            fi

            # Restaurar desde respaldo
            cp -r "$backup_file" "$target" 2>/dev/null || {
                log_message WARNING "No se pudo restaurar $backup_file a $target"
                continue
            }
            log_message INFO "Restaurado: $target desde $backup_file"
        else
            log_message WARNING "No se encontró respaldo para $src en $backup_dir"
        fi
    done
    log_message INFO "Restauración desde respaldo completada."
}

# Función para eliminar enlaces simbólicos
remove_symlinks() {
    log_message INFO "Eliminando enlaces simbólicos..."
    for src in "${!DOTFILES[@]}"; do
        local target="${DOTFILES[$src]}"

        if [ -L "$target" ]; then
            rm -f "$target" 2>/dev/null || {
                log_message ERROR "No se pudo eliminar el enlace simbólico $target"
                continue
            }
            log_message INFO "Enlace simbólico eliminado: $target"
        elif [ -e "$target" ]; then
            log_message WARNING "$target existe pero no es un enlace simbólico, no se eliminará."
        else
            log_message INFO "$target no existe, omitiendo."
        fi
    done
}

# Función para limpiar cache
clean_cache() {
    if [ -d "$CACHE_DIR" ]; then
        log_message INFO "Limpiando cache en $CACHE_DIR..."
        rm -rf "$CACHE_DIR" 2>/dev/null || {
            log_message ERROR "No se pudo limpiar el directorio de cache $CACHE_DIR"
            return 1
        }
        log_message INFO "Cache limpiado."
    else
        log_message INFO "No se encontró directorio de cache en $CACHE_DIR."
    fi
}

# Función para verificar permisos
check_permissions() {
    log_message INFO "Verificando permisos..."
    for src in "${!DOTFILES[@]}"; do
        local target="${DOTFILES[$src]}"
        if [ -e "$target" ] && [ ! -w "$target" ]; then
            log_message ERROR "No se tienen permisos de escritura en $target"
            exit 1
        fi
    done
    log_message INFO "Permisos verificados correctamente."
}

# Función principal
main() {
    # Inicializar log
    touch "$LOG_FILE" 2>/dev/null || {
        echo "No se pudo crear el archivo de log $LOG_FILE" >&2
        exit 1
    }

    log_message INFO "Iniciando desinstalación de dotfiles..."

    # Ejecutar pasos de desinstalación
    check_dependencies
    check_permissions
    remove_symlinks
    restore_backup
    clean_cache

    log_message INFO "Desinstalación completada exitosamente."
}

# Manejo de errores global
trap 'log_message ERROR "Error en línea $LINENO"; exit 1' ERR

# Verificar argumentos
if [ $# -gt 0 ]; then
    case "$1" in
        --help|-h)
            echo "Uso: $0"
            echo "Desinstala dotfiles, restaura desde el respaldo más reciente y limpia el cache."
            exit 0
            ;;
        *)
            log_message ERROR "Argumento desconocido: $1"
            exit 1
            ;;
    esac
fi

main