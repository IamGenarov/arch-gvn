#!/bin/bash

set -euo pipefail

# Solicitar contraseña una vez
sudo -v
# Mantener la sesión sudo activa mientras dure el script
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Función para limpiar pantalla y mostrar el tren en una posición dada
print_train() {
    clear
    local pos=$1
    local space=$(printf "%${pos}s" "")
    cat <<EOF
${space}   ___     ____                                  
${space}  |_ _|   |__ /   _ _     __ _      _ _    ___   
${space}   | |     |_ \  | ' \   / _\` |    | '_|  / _ \  
${space}  |___|   |___/  |_||_|  \__,_|   _|_|_   \___/  
${space} _|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""| 
${space} "\`-0-0-'"\`-0-0-'"\`-0-0-'"\`-0-0-'"\`-0-0-'"\`-0-0-' 
EOF
}

# Animación
for i in {0..5}; do
    print_train $i
    sleep 0.3
done
for i in {5..0}; do
    print_train $i
    sleep 0.3
done

clear
echo "[+] Iniciando instalación de dependencias..."

# 1. Xorg y xinit
echo "[+] Instalando Xorg..."
sudo pacman -S --noconfirm --needed xorg xorg-xinit

# 2. Terminal gráfico: Alacritty
echo "[+] Instalando Alacritty..."
sudo pacman -S --noconfirm --needed alacritty

# 3. Gestor de sesión (opcional)
read -p "[?] ¿Deseas instalar LightDM como login gráfico? (s/n): " usar_lightdm
if [[ "$usar_lightdm" == "s" ]]; then
    echo "[+] Instalando LightDM..."
    sudo pacman -S --noconfirm --needed lightdm lightdm-gtk-greeter
    sudo systemctl enable lightdm
else
    echo "[+] Configurando inicio con startx..."
    grep -q "exec i3" ~/.xinitrc 2>/dev/null || echo "exec i3" >> ~/.xinitrc
fi

# 4. Reemplazo de i3-wm con i3-gaps
echo "[+] Instalando i3-gaps..."
sudo pacman -Rns --noconfirm i3-wm || true
sudo pacman -S --noconfirm --needed i3-gaps

# 5. Polybar
echo "[+] Instalando Polybar..."
sudo pacman -S --noconfirm --needed polybar

# 6. Fuentes necesarias
echo "[+] Instalando fuentes..."
sudo pacman -S --noconfirm --needed \
    terminus-font \
    ttf-nerd-fonts-symbols \
    ttf-nerd-fonts-symbols-mono \
    ttf-hack-nerd \
    ttf-jetbrains-mono-nerd \
    ttf-font-awesome

# 7. Zsh
echo "[+] Instalando Zsh..."
sudo pacman -S --noconfirm --needed zsh
chsh -s /bin/zsh

# 8. Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "[+] Instalando Oh My Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 9. Powerlevel10k
echo "[+] Instalando Powerlevel10k..."
THEME_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
[ ! -d "$THEME_DIR" ] && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$THEME_DIR"

# 10. Plugins Zsh
PLUG_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

echo "[+] Instalando plugins Zsh..."
[ ! -d "$PLUG_DIR/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUG_DIR/zsh-autosuggestions"

[ ! -d "$PLUG_DIR/zsh-syntax-highlighting" ] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUG_DIR/zsh-syntax-highlighting"

# 11. Utilidades adicionales
echo "[+] Instalando utilidades: rofi, neofetch, nvim, flameshot..."
sudo pacman -S --noconfirm --needed rofi neovim flameshot

# --- Clonación y configuración ---
CONFIG_DIR="$HOME/.config/i3naro_temp"
REPO_URL="https://github.com/IamGenarov/i3naro.git"

[ -d "$CONFIG_DIR" ] && rm -rf "$CONFIG_DIR"

echo "[+] Clonando repositorio i3naro..."
git clone "$REPO_URL" "$CONFIG_DIR"

echo "[+] Copiando configuración a ~/.config/ ..."
mkdir -p "$HOME/.config"
cp -rn "$CONFIG_DIR/HOME/.config/"* "$HOME/.config/"

echo "[+] Copiando archivos ocultos de HOME..."
cp -n "$CONFIG_DIR/HOME/."* "$HOME/" 2>/dev/null || true

# Carpetas estándar
echo "[+] Creando carpetas estándar..."
mkdir -p "$HOME/Documents" "$HOME/Pictures/.wallpapers" "$HOME/Downloads" "$HOME/Music" "$HOME/Videos"

echo "[+] Copiando wallpapers..."
cp -rn "$CONFIG_DIR/wallpapers/"* "$HOME/Pictures/.wallpapers/"

echo "[+] Copiando fuentes locales..."
mkdir -p "$HOME/.local/share/fonts"
cp -rn "$CONFIG_DIR/fonts/"* "$HOME/.local/share/fonts/"

echo "[+] Eliminando archivos temporales..."
rm -rf "$CONFIG_DIR"

echo "[✔] ¡Entorno i3naro instalado y configurado exitosamente!"
