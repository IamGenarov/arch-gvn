#!/bin/bash
set -e

echo "Actualizando sistema e instalando paquetes base..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm base-devel xorg xorg-xinit libx11 libxft libxinerama picom feh xclip brightnessctl playerctl network-manager-applet lxappearance
sudo pacman -S --noconfirm alacritty xorg-xos4-terminus neofetch rofi zsh xclip wl-clipboard ttf-meslo-nerd-font-powerlevel10k

echo "Instalando Oh My Zsh..."
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Instalando Powerlevel10k y plugins..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo "Cambiando shell predeterminado a Zsh..."
chsh -s $(which zsh)

echo "Creando carpetas necesarias..."
mkdir -p "$HOME/Pictures/.wallpapers"
mkdir -p "$HOME/.config"

echo "Copiando wallpapers..."
cp -v ./wallpapers/fp1.png "$HOME/Pictures/.wallpapers/"
cp -v ./wallpapers/fp2.png "$HOME/Pictures/.wallpapers/"
cp -v ./wallpapers/fp3.png "$HOME/Pictures/.wallpapers/"
cp -v ./wallpapers/fp4.png "$HOME/Pictures/.wallpapers/"

echo "Copiando archivos ocultos de HOME al directorio $HOME..."
cp -v ./HOME/.cambiar_fondo.sh "$HOME/"
cp -v ./HOME/.p10k.zsh "$HOME/"
cp -v ./HOME/.zshrc "$HOME/"

echo "Copiando configuración .config al directorio $HOME/.config..."
cp -rv ./ .config "$HOME/.config"

# Corrijo esa línea, porque la estructura en tu repo es: tienes carpeta .config
# Así que la línea correcta sería:
cp -rv ./.config/* "$HOME/.config/"

echo "Configurando permisos de scripts..."
chmod +x "$HOME/.cambiar_fondo.sh"

echo "Copiando genwm a ~/.config/genwm..."
mkdir -p "$HOME/.config/genwm"
cp -rv ./genwm/* "$HOME/.config/genwm/"

echo "¡Instalación completada!"
echo "Abre una nueva terminal o ejecuta 'zsh' para comenzar a usar Zsh con Powerlevel10k."
echo "Usa el comando 'cambiar_fondo' para cambiar el fondo de pantalla fácilmente."
