#!/bin/bash

set -e

# Función para limpiar pantalla y mostrar el tren en una posición dada (espacios delante)
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

# Animación: mueve el tren 5 posiciones hacia la derecha y vuelve
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

# Aquí va todo el script de instalación que ya definiste
echo "[+] Instalando dependencias para entorno i3 personalizado..."

# 1. Xorg y xinit
echo "[+] Instalando Xorg..."
sudo pacman -S --noconfirm xorg xorg-xinit

# 2. Terminal gráfico: Alacritty
echo "[+] Instalando Alacritty..."
sudo pacman -S --noconfirm alacritty

# 3. Gestor de sesión (opcional)
read -p "[?] ¿Deseas instalar LightDM como login gráfico? (s/n): " usar_lightdm
if [[ "$usar_lightdm" == "s" ]]; then
    echo "[+] Instalando LightDM..."
    sudo pacman -S --noconfirm lightdm lightdm-gtk-greeter
    sudo systemctl enable lightdm
else
    echo "[+] Configurando inicio con startx..."
    echo "exec i3" >> ~/.xinitrc
fi

# 4. Reemplazo de i3-wm con i3-gaps
echo "[+] Reemplazando i3-wm con i3-gaps..."
sudo pacman -Rns --noconfirm i3-wm || true
sudo pacman -S --noconfirm i3-gaps

# 5. Polybar
echo "[+] Instalando Polybar..."
sudo pacman -S --noconfirm polybar

# 6. Fuentes necesarias
echo "[+] Instalando fuentes..."
sudo pacman -S --noconfirm \
    terminus-font \
    ttf-nerd-fonts-symbols \
    ttf-nerd-fonts-symbols-mono \
    ttf-hack-nerd \
    ttf-fira-code-nerd \
    ttf-jetbrains-mono-nerd \
    ttf-font-awesome \
    ttf-material-design-icons

# 7. Zsh y mejoras visuales
echo "[+] Instalando Zsh..."
sudo pacman -S --noconfirm zsh
chsh -s /bin/zsh

# 8. Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "[+] Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 9. Powerlevel10k
echo "[+] Instalando Powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# 10. Plugins Zsh
echo "[+] Instalando plugins Zsh..."
git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 11. Utilidades adicionales
echo "[+] Instalando utilidades: rofi, neofetch, nvim, flameshot..."
sudo pacman -S --noconfirm rofi neofetch neovim flameshot

echo "[✔] Todo listo. Dependencias y utilidades instaladas correctamente."

# --- Aquí empieza la clonación y copia de archivos ---

CONFIG_DIR="$HOME/.config/i3naro_temp"
if [ -d "$CONFIG_DIR" ]; then
    echo "[!] El directorio temporal $CONFIG_DIR ya existe. Eliminando..."
    rm -rf "$CONFIG_DIR"
fi

echo "[+] Clonando repositorio i3naro..."
git clone https://github.com/IamGenarov/i3naro.git "$CONFIG_DIR"

echo "[+] Copiando configuración a ~/.config/ ..."
mkdir -p "$HOME/.config"
cp -r "$CONFIG_DIR/HOME/.config/"* "$HOME/.config/"

echo "[+] Copiando archivos ocultos de HOME..."
cp "$CONFIG_DIR/HOME/."* "$HOME/" 2>/dev/null || true

# Crear carpetas estándar si no existen
echo "[+] Creando carpetas estándar..."
mkdir -p "$HOME/Documents"
mkdir -p "$HOME/Pictures/.wallpapers"
mkdir -p "$HOME/Downloads"
mkdir -p "$HOME/Music"
mkdir -p "$HOME/Videos"

echo "[+] Copiando wallpapers a ~/Pictures/.wallpapers ..."
cp -r "$CONFIG_DIR/wallpapers/"* "$HOME/Pictures/.wallpapers/"

echo "[+] Copiando fuentes locales..."
mkdir -p "$HOME/.local/share/fonts"
cp -r "$CONFIG_DIR/fonts/"* "$HOME/.local/share/fonts/"

echo "[+] Limpieza del directorio temporal..."
rm -rf "$CONFIG_DIR"

echo "[✔] Configuración copiada correctamente. ¡Listo para usar!"