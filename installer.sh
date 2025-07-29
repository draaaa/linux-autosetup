cat << EOF
    ___                                    __                  __            
   / (_)___  __  ___  __      ____ ___  __/ /_____  ________  / /___  ______ 
  / / / __ \/ / / / |/_/_____/ __ \`/ / / / __/ __ \/ ___/ _ \/ __/ / / / __ \\
 / / / / / / /_/ />  </_____/ /_/ / /_/ / /_/ /_/ (__  )  __/ /_/ /_/ / /_/ /
/_/_/_/ /_/\__,_/_/|_|      \__,_/\__,_/\__/\____/____/\___/\__/\__,_/ .___/ 
                                                                    /_/      
EOF
echo -e "made by draaaa :3\npls remember to submit an issue to the github if there are problems\nsupported distros - Arch, EndeavourOS***, Debian 13, Debian 12***, Void\n\n"


printf "Have you made your user a sudoer? [Y/n] "
read isSudoer
if [[ "$isSudoer" != "" && "$isSudoer" != "y" && "$isSudoer" != "Y" ]]; then
    echo "Make yourself a sudoer in the root user with 'usermod -aG sudo user'"
    exit 1
fi


# Check Distro
packageManager=""
source /etc/os-release

if [ "$ID" = "arch" ] || [ "$ID" = "endeavouros" ]; then
    packageManager="pacman"

elif [ "$ID" = "debian" ]; then  # Pretty much all other apt utilizing distros will go here as well. Likely to remove the special Debian 12 case
    if [ "$VERSION_ID" = "13" ]; then
        packageManager="apt"
    elif [ "$VERSION_ID" = "12" ]; then  # Untested, no longer priority for updates
        packageManager="aptDeb12"  
    fi

elif [ "$ID" = "fedora" ]; then
    packageManager="dnf"

elif [ "$ID" = "void" ]; then
    packageManager="xbps"

else
    echo -e "Your distro may be unsupported, or there may be an error with detecting your distro. The current list of supported distros are;\nArch\nEndeavourOS\nDebian 13\nFedora\nVoid\n\nIf your distro is not supported, please submit an issue requesting that your distro of choice be supported.\nDownstream distros may not be supported at the moment due to the current detection method being used.\n\n"
    exit 1
fi


# Later we can set up the install commands to be one line rather than multiple. Just seems unnecessary to have multiple lines
if [ "$packageManager" = "pacman" ]; then
    sudo pacman -Syu  # no '--noconfirm' because of the arch horror stories and updates bricking installs  
    # Dependencies
        sudo pacman -S --noconfirm wget git zsh tldr cowsay
        # pokemon-colorscripts
            yay -S --noconfirm pokemon-colorscripts-git
        # zinit
        mkdir ~/.zinit
        git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
    # Everything else
        sudo pacman -S --noconfirm fastfetch
        sudo pacman -S --noconfirm ufw

elif [ "$packageManager" = "apt" ]; then
    sudo apt update && sudo apt upgrade -y
    # Dependencies
        sudo apt install -y wget git zsh tldr cowsay
        # pokemon-colorscripts
            git clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git
            cd pokemon-colorscripts
            sudo ./install.sh
        # zinit
            mkdir ~/.zinit
            git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
    # Everything else
        sudo apt install -y fastfetch
        sudo apt install -y ufw

# Untested, no longer priority for updates
elif [ "$packageManager" = "aptDeb12" ]; then 
    sudo apt update && sudo apt upgrade -y
    # Dependencies
        sudo apt install -y wget zsh
        # fastfetch
            wget -O fastfetch.deb https://github.com/fastfetch-cli/fastfetch/releases/download/2.48.1/fastfetch-linux-amd64.deb # For now, we can just use one version. Maybe look into using the newest version later
            sudo apt install -y ./fastfetch.deb
            rm fastfetch.deb
    # Everything else
        sudo apt install -y ufw

elif [ "$packageManager" = "dnf" ]; then
    sudo dnf upgrade -y --refresh
    # Dependencies
        sudo dnf install -y wget git zsh tldr cowsay
        # pokemon-colorscripts
            git clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git
            cd pokemon-colorscripts
            sudo ./install.sh
        # zinit
            mkdir ~/.zinit
            git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
    # Everything else
        sudo dnf install -y fastfetch
        sudo dnf install -y ufw

elif [ "$packageManager" = "xbps" ]; then
    sudo xbps-install -Syu
    # Dependencies
        sudo xbps-install -y wget git zsh tldr cowsay
        # pokemon-colorscripts
            git clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git
            cd pokemon-colorscripts
            sudo ./install.sh
        # zinit
            mkdir ~/.zinit
            git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
    # Everything else
        sudo xbps-install -y fastfetch
        sudo xbps-install -y ufw
fi


# Use the raw github links like this - https://raw.githubusercontent.com/draaaa/linux-autosetup/main/file
# fastfetch
    mkdir -p ~/.config/fastfetch
    wget -O ~/.config/fastfetch/config.jsonc https://raw.githubusercontent.com/draaaa/linux-autosetup/main/fastfetch/config.jsonc
# ufw
    sudo ufw enable
# zsh
    # set zsh to default shell
        chsh -s $(which zsh)
    # get .zshrc and apply
        wget -O ~/.zshrc https://raw.githubusercontent.com/draaaa/linux-autosetup/main/zsh/.zshrc
    # get scripts
        mkdir ~/Scripts
        wget -O ~/Scripts/CommandList.sh https://raw.githubusercontent.com/draaaa/linux-autosetup/main/zsh/scripts/CommandList.sh
        chmod +x ~/Scripts/CommandList.sh
# pipes
    make install
    make PREFIX=$HOME/.local install


# Prompt reboot
printf "Reboot is recommended. Want to reboot? [Y/n] " 
read doReboot
if [[ "$doReboot" == "" || "$doReboot" == "y" || "$doReboot" == "Y" ]]; then
    sudo reboot
else
    printf "In order for zsh to properly become the default, you must at minimum log out then log back in.\nDoing so without rebooting may cause zinit to fail to work properly with zsh.\nAn alternative method will be found for this, but will be added at a later date.\nWhen you log out and log back in, you should run 'source ~/.zshrc' and 'source ~/.zinit/bin/zinit.zsh'"
fi

exit 0
