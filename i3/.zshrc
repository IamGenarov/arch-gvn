# -------------------------------------------
# Powerlevel10k instant prompt (al principio)
# -------------------------------------------
#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#fi

# ----------------------------
# Oh My Zsh Configuración Base
# ----------------------------
#export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
#source $ZSH/oh-my-zsh.sh

# ----------------------------
# No cargar ~/.p10k.zsh
# ----------------------------
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ----------------------------
# vcs_info para rama Git
# ----------------------------
autoload -Uz vcs_info

precmd() {
  vcs_info
}

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '%F{220}[%F{198}%f %F{220}%b%f]%f'
zstyle ':vcs_info:git:*' actionformats '%F{220}[%F{198}%f %F{220}%b%f %F{196}|%a%f]%f'


# ----------------------------
# Icono de directorio
# ----------------------------
function dir_icon {
  if [[ "$PWD" == "$HOME" ]]; then
    echo "%F{196}%f"
  else
    echo "%F{196}%f"
  fi
}

# ----------------------------
# Ruta acortada tipo ~/La/Bu/So/
# ----------------------------
function short_path {
  local full_path="${PWD/#$HOME/~}"
  local IFS='/'
  local -a parts result

  for part in ${(s:/:)full_path}; do
    if [[ "$part" == "~" || "$part" == "" ]]; then
      result+="$part"
    else
      result+="${part[1,2]}"  # Solo las dos primeras letras
    fi
  done
  echo "${(j:/:)result}/"
}

# ----------------------------
# Prompt personalizado
# ----------------------------
#PS1='%F{255}%f  %F{201}%n%f  $(dir_icon) %F{45}$(short_path)%f%F{129}${vcs_info_msg_0_}%f %F{243}┃%f '
PS1='%F{196}%f  %F{201}%n%f  $(dir_icon) %F{196}$(short_path)%f%F{129}${vcs_info_msg_0_}%f  %F{213}❯%f '

#PS1='%F{208}%f %F{201}%n%f %F{244}at%f $(dir_icon) %F{45}$(short_path)%f %F{129}${vcs_info_msg_0_}%f %F{213}➤%f '


LS_COLORS="di=38;2;129;161;193:fi=38;2;216;222;233:ex=38;2;163;190;140:ln=38;2;208;135;112:so=38;2;235;203;139:pi=38;2;180;142;173:bd=38;2;191;97;106:cd=38;2;143;188;187:or=38;2;255;85;85:mi=38;2;255;0;0"


ZSH_HIGHLIGHT_STYLES[command]='fg=81'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=82'
ZSH_HIGHLIGHT_STYLES[function]='fg=220'
ZSH_HIGHLIGHT_STYLES[alias]='fg=213'
ZSH_HIGHLIGHT_STYLES[external]='fg=208'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=199'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=196'


export PATH="$HOME/.bin:$PATH"
