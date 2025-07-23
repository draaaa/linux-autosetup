cat << EOF
    ___                                    __                  __            
   / (_)___  __  ___  __      ____ ___  __/ /_____  ________  / /___  ______ 
  / / / __ \/ / / / |/_/_____/ __ \`/ / / / __/ __ \/ ___/ _ \/ __/ / / / __ \\
 / / / / / / /_/ />  </_____/ /_/ / /_/ / /_/ /_/ (__  )  __/ /_/ /_/ / /_/ /
/_/_/_/ /_/\__,_/_/|_|      \__,_/\__,_/\__/\____/____/\___/\__/\__,_/ .___/ 
                                                                    /_/      
EOF
echo -e "made by draaaa :3\npls remember to submit an issue to the github if there are problems\nsupported distros - Arch, Debian 13, Debian 12***\n\n"


printf "Have you made your user a sudoer? [Y/n] "
read isSudoer
if [[ "$isSudoer" != "" && "$isSudoer" != "y" && "$isSudoer" != "Y" ]]; then
    echo "Make yourself a sudoer in the root user with 'usermod -aG sudo user'"
    exit 1
fi


# Check Distro
packageManager=""
source /etc/os-release

if [ "$ID" = "arch" ]; then
    packageManager="pacman"
elif [ "$ID" = "debian" ]; then  # Pretty much all other apt utilizing distros will go here as well. Likely to remove the special Debian 12 case
    if [ "$VERSION_ID" = "13" ]; then
        packageManager="apt"
    elif [ "$VERSION_ID" = "12" ]; then  # Untested, no longer priority for updates
        packageManager="aptDeb12"  
    fi
elif [ "$ID" = "fedora" ]; then  # Untested
    packageManager="dnf"
else
    echo -e "Your distro may be unsupported, or there may be an error with detecting your distro. The current list of supported distros are;\nArch\nDebian 13\nFedora (testing)\n If you are on Fedora, please submit an issue regarding a bad detection method.\nIf you are NOT on Fedora, please submit an issue saying that your distro is not supported."
fi


# Later we can set up the install commands to be one line rather than multiple. Just seems unnecessary to have multiple lines
if [ "$packageManager" = "pacman" ]; then
    sudo pacman -Syu  # no '--noconfirm' because of the arch horror stories and updates bricking installs  
    # Dependencies
        sudo pacman -S --noconfirm wget zsh
    # Everything else
        sudo pacman -S --noconfirm fastfetch
        sudo pacman -S --noconfirm ufw

elif [ "$packageManager" = "apt" ]; then
    sudo apt update && sudo apt upgrade -y
    # Dependencies
        sudo apt install -y wget zsh
    # Everything else
        sudo apt install -y fastfetch
        sudo apt install -y ufw
# Untested, no longer priority for updates
elif [ "$packageManager" = "aptDeb12" ]; then 
    sudo apt update && sudo apt upgrade -y
    # Dependencies
        sudo ap tinstlal -y wget zsh
    # Everything else
        # fastfetch
            wget -O fastfetch.deb https://github.com/fastfetch-cli/fastfetch/releases/download/2.48.1/fastfetch-linux-amd64.deb # For now, we can just use one version. Maybe look into using the newest version later
            sudo apt install -y ./fastfetch.deb
            rm fastfetch.deb
        sudo apt install -y ufw
fi


# Use the raw github links like this - https://raw.githubusercontent.com/draaaa/linux-autosetup/main/file
# fastfetch
    mkdir -p ~/.config/fastfetch
    wget -O ~/.config/fastfetch/config.jsonc https://raw.githubusercontent.com/draaaa/linux-autosetup/main/fastfetch/config.jsonc
# ufw
    sudo ufw enable
# zsh
    chsh -s $(which zsh) 
    
# Prompt reboot
printf "Reboot is recommended. Want to reboot? [Y/n] " 
read doReboot
if [[ "$doReboot" == "" || "$doReboot" == "y" || "$doReboot" == "Y" ]]; then
    sudo reboot
fi
