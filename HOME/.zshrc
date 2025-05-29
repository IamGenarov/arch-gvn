# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(git)

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# LS Colors
export LS_COLORS='di=1;31:fi=0;37:ex=1;35'

# zsh-autosuggestions
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
else
  echo "[!] zsh-autosuggestions not found at /usr/share/zsh/plugins/"
fi

# zsh-syntax-highlighting (should be at the end)
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  
  # Highlighting styles
  ZSH_HIGHLIGHT_STYLES[command]='fg=160'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=160'
  ZSH_HIGHLIGHT_STYLES[function]='fg=160'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=160'
  ZSH_HIGHLIGHT_STYLES[external]='fg=160'
  ZSH_HIGHLIGHT_STYLES[precommand]='fg=magenta'
else
  echo "[!] zsh-syntax-highlighting not found at /usr/share/zsh/plugins/"
fi

# Neofetch at startup
if command -v neofetch &>/dev/null; then
  neofetch
else
  echo "[!] neofetch not installed"
fi

# ----------------------------------------
# Custom Methods

# extractPorts - Extracts IP and unique open ports from nmap file
extractPorts() {
  file="$1"

  # Colors
  GREEN="\033[1;32m"
  RED="\033[1;31m"
  CYAN="\033[1;36m"
  YELLOW="\033[1;33m"
  RESET="\033[0m"

  # Check if file exists
  if [[ ! -f "$file" ]]; then
    echo -e "${RED}[✘] File not found: $file${RESET}"
    return 1
  fi

  # Extract open ports and IP address
  ports=$(grep -oP '\d{1,5}/open' "$file" | awk -F'/' '{print $1}' | sort -n | uniq | paste -sd, -)
  ip_address=$(grep -oP '\b\d{1,3}(\.\d{1,3}){3}\b' "$file" | sort -u | head -n 1)

  # Validate extraction
  if [[ -z "$ip_address" ]]; then
    echo -e "${RED}[✘] No valid IP address found.${RESET}"
    return 1
  fi

  if [[ -z "$ports" ]]; then
    echo -e "${RED}[✘] No open ports found.${RESET}"
    return 1
  fi

  # Output aesthetic banner
  echo -e "\n${CYAN}╔══════════════════════════════════════════════╗"
  echo -e "║                  SCAN SUMMARY                ║"
  echo -e "╚══════════════════════════════════════════════╝${RESET}"
  echo -e "${GREEN}>> Target IP    :${RESET} $ip_address"
  echo -e "${GREEN}>> Open Ports   :${RESET} $ports"

  # Copy to clipboard
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