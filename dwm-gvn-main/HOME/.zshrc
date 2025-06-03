# ---------------------------------------------------------
# Powerlevel10k instant prompt (debe ir al inicio del zshrc)
# ---------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ----------------------------
# Oh My Zsh Configuración Base
# ----------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# -----------------------
# Powerlevel10k Configuración
# -----------------------
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# -----------------------
# Colores para LS
# -----------------------
LS_COLORS="di=38;2;0;255;0:fi=38;2;0;255;255:ex=38;2;255;255;0"

# -----------------------
# zsh-autosuggestions
# -----------------------
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
else
  echo "[!] zsh-autosuggestions not found at /usr/share/zsh/plugins/"
fi

# -----------------------
# zsh-syntax-highlighting
# -----------------------
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

  # Highlighting styles
  ZSH_HIGHLIGHT_STYLES[command]='fg=81'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=82'
  ZSH_HIGHLIGHT_STYLES[function]='fg=220'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=213'
  ZSH_HIGHLIGHT_STYLES[external]='fg=208'
  ZSH_HIGHLIGHT_STYLES[precommand]='fg=199'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=196'
else
  echo "[!] zsh-syntax-highlighting not found at /usr/share/zsh/plugins/"
fi

# -----------------------
# Funciones Personalizadas
# -----------------------

# extractPorts - Extrae IP y puertos abiertos únicos de archivo de nmap
extractPorts() {
  file="$1"

  # Colores
  GREEN="\033[1;32m"
  RED="\033[1;31m"
  CYAN="\033[1;36m"
  YELLOW="\033[1;33m"
  RESET="\033[0m"

  # Verifica si el archivo existe
  if [[ ! -f "$file" ]]; then
    echo -e "${RED}[✘] File not found: $file${RESET}"
    return 1
  fi

  # Extrae puertos abiertos e IP
  ports=$(grep -oP '\d{1,5}/open' "$file" | awk -F'/' '{print $1}' | sort -n | uniq | paste -sd, -)
  ip_address=$(grep -oP '\b\d{1,3}(\.\d{1,3}){3}\b' "$file" | sort -u | head -n 1)

  # Validaciones
  if [[ -z "$ip_address" ]]; then
    echo -e "${RED}[✘] No valid IP address found.${RESET}"
    return 1
  fi

  if [[ -z "$ports" ]]; then
    echo -e "${RED}[✘] No open ports found.${RESET}"
    return 1
  fi

  # Banner
  echo -e "\n${CYAN}╔══════════════════════════════════════════════╗"
  echo -e "║              	SCAN SUMMARY            	║"
  echo -e "╚══════════════════════════════════════════════╝${RESET}"
  echo -e "${GREEN}>> Target IP	:${RESET} $ip_address"
  echo -e "${GREEN}>> Open Ports   :${RESET} $ports"

  # Copia al portapapeles
  if command -v xclip &>/dev/null; then
    echo -n "$ports" | xclip -selection clipboard
    echo -e "${CYAN}[✔] Ports copied to clipboard (xclip)${RESET}"
  elif command -v wl-copy &>/dev/null; then
    echo -n "$ports" | wl-copy
    echo -e "${CYAN}[✔] Ports copied to clipboard (wl-copy)${RESET}"
  else
    echo -e "${YELLOW}[!] Clipboard tool not found (xclip/wl-copy)${RESET}"
  fi
}
