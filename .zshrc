### zsh config (~/.zshrc)
### byte @ n-co.de 

# History
HISTFILE=~/.config/zsh/history
HISTSIZE=1000
SAVEHIST=5000

# Export variables
export PATH=$PATH:$HOME/bin
export ZDOTDIR=$HOME
export EDITOR="vim"
#export PAGER="vimpager"
LS_COLORS='rs=0:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32:';
export LS_COLORS

# Aliases and functions
source ~/.config/zsh/aliases
source ~/.config/zsh/functions

# Delete key usable
bindkey    "^[[3~"          delete-char
bindkey    "^[3;5~"         delete-char

# Auto complete
zmodload zsh/complist 
autoload -Uz compinit promptinit
compinit
promptinit; prompt gentoo
zstyle :compinstall filename '${HOME}/.zshrc'
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always
zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*'   force-list always



# Prompt
setprompt(){
  setopt prompt_subst
  autoload colors zsh/terminfo
  if [[ "$terminfo[colors]" -ge 8 ]]; then
    colors
  fi
  for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
      eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
      eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
      (( count = $count + 1 ))
  done
  PR_NO_COLOUR="%{$terminfo[sgr0]%}"

  if [[ $UID -ge 1000 ]]; then
    eval PR_USER='${PR_LIGHT_BLUE}%n${PR_NO_COLOR}'
    eval PR_USER_OP='${PR_LIGHT_BLUE}\$${PR_NO_COLOR}'
  elif [[ $UID -eq 0 ]]; then
    eval PR_USER='${PR_RED}%n${PR_NO_COLOR}'
    eval PR_USER_OP='${PR_RED}#${PR_NO_COLOR}'
  fi
  eval PR_HOST='${PR_BLUE}%M${PR_NO_COLOR}'
  eval PR_DATE='${PR_BLUE}%D{%H:%M}${PR_NO_COLOR}'
  
  PS1=$'${PR_CYAN}[${PR_USER}${PR_CYAN}@${PR_HOST}${PR_CYAN}] (${PR_LIGHT_MAGENTA}%2c${PR_CYAN})${PR_USER_OP} ${PR_NO_COLOUR}'
  RPS1=$'${PR_CYAN}(${PR_DATE}${PR_CYAN})${PR_NO_COLOUR}'
  PS2=$'${PR_CYAN}[${PR_USER}${PR_CYAN}@${PR_HOST}${PR_CYAN}] (${PR_LIGHT_MAGENTA}%2c${PR_CYAN})${PR_USER_OP} ${PR_NO_COLOUR}'
  RPS2=$'${PR_CYAN}(${PR_DATE}${PR_CYAN})${PR_NO_COLOUR}'
}
setprompt

# Todo list
source ~/.config/zsh/todo
