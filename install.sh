#!/bin/bash

# No usar 'set -e' para permitir continuar en caso de errores

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

# 1. Xorg y xinit
echo "[+] Instalando Xorg..."
sudo pacman -S --noconfirm xorg xorg-xinit || true

# 2. Terminal gráfico: Alacritty
echo "[+] Instalando Alacritty..."
sudo pacman -S --noconfirm alacritty || true

# 3. Gestor de sesión (opcional)
read -p "[?] ¿Deseas instalar LightDM como login gráfico? (s/n): " usar_lightdm
if [[ "$usar_lightdm" == "s" ]]; then
    echo "[+] Instalando LightDM..."
    sudo pacman -S --noconfirm lightdm lightdm-gtk-greeter || true
    sudo systemctl enable lightdm || true
else
    echo "[+] Configurando inicio con startx..."
    echo "exec i3" >> ~/.xinitrc || true
fi

# 4. Reemplazo de i3-wm con i3-gaps
echo "[+] Reemplazando i3-wm con i3-gaps..."
sudo pacman -Rns --noconfirm i3-wm || true
sudo pacman -S --noconfirm i3-gaps || true

# 5. Polybar
echo "[+] Instalando Polybar..."
sudo pacman -S --noconfirm polybar || true

# 6. Fuentes necesarias
echo "[+] Instalando fuentes..."
sudo pacman -S --noconfirm \
    terminus-font \
    ttf-nerd-fonts-symbols \
    ttf-nerd-fonts-symbols-mono \
    ttf-hack-nerd \
    ttf-jetbrains-mono-nerd \
    ttf-font-awesome || true

# 7. Zsh y mejoras visuales
echo "[+] Instalando Zsh..."
sudo pacman -S --noconfirm zsh || true
chsh -s /bin/zsh || true

# 8. Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "[+] Instalando Oh My Zsh..."
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

fi

# 9. Powerlevel10k
echo "[+] Instalando Powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k || true

# 10. Plugins Zsh
echo "[+] Instalando plugins Zsh..."
git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true

# 11. Utilidades adicionales
echo "[+] Instalando utilidades: rofi, neofetch, nvim, flameshot..."
sudo pacman -S --noconfirm rofi feh nano

echo "[✔] Todo listo. Dependencias y utilidades instaladas correctamente."

# --- Clonación y copia de archivos ---

CONFIG_DIR="$HOME/.config/i3naro_temp"
if [ -d "$CONFIG_DIR" ]; then
    echo "[!] El directorio temporal $CONFIG_DIR ya existe. Eliminando..."
    rm -rf "$CONFIG_DIR" || true
fi

echo "[+] Clonando repositorio i3naro..."
git clone https://github.com/IamGenarov/i3naro.git "$CONFIG_DIR" || true

echo "[+] Copiando configuración a ~/.config/ ..."
mkdir -p "$HOME/.config" || true
cp -r "$CONFIG_DIR/HOME/.config/"* "$HOME/.config/" 2>/dev/null || true

echo "[+] Copiando archivos ocultos de HOME..."
cp "$CONFIG_DIR/HOME/."* "$HOME/" 2>/dev/null || true


cp "$CONFIG_DIR/i3/config" "$HOME/.config/i3/config" || true

# Crear carpetas estándar
echo "[+] Creando carpetas estándar..."
mkdir -p "$HOME/Documents" "$HOME/Pictures/.wallpapers" "$HOME/Downloads" "$HOME/Music" "$HOME/Videos" || true

echo "[+] Copiando wallpapers a ~/Pictures/.wallpapers ..."
cp -r "$CONFIG_DIR/wallpapers/"* "$HOME/Pictures/.wallpapers/" 2>/dev/null || true

echo "[+] Copiando fuentes locales..."
mkdir -p "$HOME/.local/share/fonts" || true
cp -r "$CONFIG_DIR/fonts/"* "$HOME/.local/share/fonts/" 2>/dev/null || true

echo "[+] Limpieza del directorio temporal..."
rm -rf "$CONFIG_DIR" || true


# Dar permisos de ejecución a scripts importantes
echo "[+] Dando permisos de ejecución a launch.sh y cambiar_pantalla.sh..."
chmod +x "$HOME/.config/polybar/launch.sh" 2>/dev/null || true
chmod +x "$HOME/.cambiar_fondo.sh" 2>/dev/null || true

# Recargar configuración de zsh si está instalada
if [ -f "$HOME/.zshrc" ]; then
    echo "[+] Ejecutando source ~/.zshrc..."
    source "$HOME/.zshrc" || true
fi

# Si existe configuración de Powerlevel10k
if [ -f "$HOME/.p10k.zsh" ]; then
    echo "[+] Ejecutando source ~/.p10k.zsh..."
    source "$HOME/.p10k.zsh" || true
fi


echo "[✔] Configuración copiada correctamente. ¡Listo para usar!"
