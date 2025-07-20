#
# ~/.zshrc
#

# testing git on vsc

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
    alias pipes="pipes.sh -R -r 0"

  # function aliases
    alias cmd="~/Scripts/CommandList.sh"
    alias virshstart="~/Scripts/VirshStart.sh"
    alias virshstop="~/Scripts/VirshStop.sh"

  # fun aliases
    alias claer="cowsay -f stegosaurus 'slow down the typing and make less errors'"


#zsh settings
  # zinit
    source ~/.zinit/bin/zinit.zsh
    zinit light zsh-users/zsh-autosuggestions
    zinit light zsh-users/zsh-syntax-highlighting
