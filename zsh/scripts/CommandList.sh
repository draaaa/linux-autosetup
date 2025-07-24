#!/usr/bin/env zsh
# many of the commands in this list are rudimentary, and while i'm aware of that, i use this command list as a reference
# dont make fun of me for commands that i cant remember in the moment lol


# color names
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
MAGENTA='\e[35m'
CYAN='\e[36m'
WHITE='\e[37m'

BRIGHT_RED='\e[91m'
BRIGHT_GREEN='\e[92m'
BRIGHT_YELLOW='\e[93m'
BRIGHT_BLUE='\e[94m'
BRIGHT_MAGENTA='\e[95m'
BRIGHT_CYAN='\e[96m'
BRIGHT_WHITE='\e[97m'

RESET='\e[0m'

# system commands
echo -e "${RED}system${RESET}"
echo -e "  ${BRIGHT_RED}tldr arg${RESET}"
echo -e "    returns a basic explanation and (sometimes) a list of args - essentially a better 'command -h'"
echo -e "    it doesnt work with every command, mostly only default commands that come with linux"
echo -e ""
echo -e "  ${BRIGHT_RED}fastfetch${RESET}"
echo -e "    returns a sorted list of information about the computer, similar to ${MAGENTA}neofetch${RESET}"
echo -e "    you can find the ${MAGENTA}fastfetch${RESET} config at ${MAGENTA}~/.config/fastfetch/config.jsonc${RESET}"
echo -e ""

# fun commands
echo -e "${YELLOW}fun${RESET}"
echo -e "  ${BRIGHT_YELLOW}pipes${RESET}"
echo -e "    executes ${MAGENTA}pipes.sh${RESET}, which creates pipes in the terminal"
echo -e ""
echo -e "  ${BRIGHT_YELLOW}cowsay "str"${RESET}"
echo -e "    funny cow says words"
echo -e ""