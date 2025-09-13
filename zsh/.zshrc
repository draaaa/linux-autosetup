#
# ~/.zshrc
#

# If not running interactively, don't do anything
[[ -o interactive ]] || return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Equivalent PS1 in Zsh syntax
PROMPT='[%n@%m %1~]%# '

export PATH="$HOME/bin:$PATH"

# autoexec
  # fastfetch (commented out, if you want it later)
  pokemon-colorscripts -rn lucario,arcanine,blaziken,rayquaza,kyogre,luxray,zeraora

# aliases
  # independent aliases
    alias c="clear"

  # function aliases


  # fun aliases
    alias claer="cowsay -f stegosaurus 'slow down the typing and make less errors'"


#zsh settings
  # zinit
    source ~/.zinit/bin/zinit.zsh
    zinit light zsh-users/zsh-autosuggestions
    zinit light zsh-users/zsh-syntax-highlighting
