cat << EOF
    ___                                    __                  __            
   / (_)___  __  ___  __      ____ ___  __/ /_____  ________  / /___  ______ 
  / / / __ \/ / / / |/_/_____/ __ \`/ / / / __/ __ \/ ___/ _ \/ __/ / / / __ \\
 / / / / / / /_/ />  </_____/ /_/ / /_/ / /_/ /_/ (__  )  __/ /_/ /_/ / /_/ /
/_/_/_/ /_/\__,_/_/|_|      \__,_/\__,_/\__/\____/____/\___/\__/\__,_/ .___/ 
                                                                    /_/      
EOF
echo -e "made by draaaa :3\npls remember to submit an issue to the github if there are problems\n\n"


printf "Have you made your user a sudoer? [Y/n] "
read isSudoer
if [[ "$isSudoer" != "" && "$isSudoer" != "y" && "$isSudoer" != "Y" ]]; then
    echo "Make yourself a sudoer in the root user with 'usermod -aG sudo user'"
    exit 1
fi


# !!!DETECT DISTRO!!!
packageManager=""
source /etc/os-release

if [[ "$ID" = "arch" || "$ID_LIKE" == *arch* ]]; then
    packageManager="pacman"
    sudo pacman -Syu

elif [[ "$ID" = "debian" || "$ID_LIKE" == *debian* ]]; then  # Pretty much all other apt utilizing distros will go here as well. Likely to remove the special Debian 12 case
    packageManager="apt"
    sudo apt update && sudo apt upgrade -y

elif [[ "$ID" = "fedora" ]]; then
    packageManager="dnf"
    sudo dnf upgrade -y --refresh

elif [[ "$ID" = "void" ]]; then
    packageManager="xbps"
    sudo xbps-install -Syu

else
    echo -e "Your distro may be unsupported, or there may be an error with detecting your distro. Currently, the detection method is being reworked. If your distro is downstream from a supported distro then it's detection may not have been updated yet.\nPlease consult the list of supported distros, and create an issue saying that your distro is unsupported.\n"
    exit 1
fi


# !!!INSTALLER!!!
packageInstall () {
    case $packageManager in
        pacman)
            sudo pacman -S --noconfirm "$@" ;;
        apt)
            sudo apt install -y "$@" ;;
        dnf)
            sudo dnf install -y "$@" ;;
        xbps)
            sudo xbps-install -y "$@" ;;
        *)
            printf "Your distro is using an unsupported package manager, or the distro was detected incorrectly.\nPlease create an issue on the main repository with the name of your distro and package manager."
            exit 1
            ;;
    esac
}

packageInstall wget git zsh tldr cowsay ufw 

# fastfetch
if [[ "$packageManager" = "apt" ]]; then
    if ! packageInstall fastfetch; then
        wget -O ~/Downloads/fastfetch.deb https://github.com/fastfetch-cli/fastfetch/releases/download/2.48.1/fastfetch-linux-amd64.deb
        sudo apt install ~/Downloads/fastfetch.deb
    fi
else
    packageInstall fastfetch
fi

# pokemon-colorscripts
git clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git
cd pokemon-colorscripts
sudo ./install.sh

# zinit
mkdir ~/.zinit
git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin


# !!!CONFIGS!!!
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


# Prompt reboot
printf "Reboot is recommended. Want to reboot? [Y/n] " 
read doReboot
if [[ "$doReboot" == "" || "$doReboot" == "y" || "$doReboot" == "Y" ]]; then
    sudo reboot
else
    printf "In order for zsh to properly become the default, you must at minimum log out then log back in.\nDoing so without rebooting may cause zinit to fail to work properly with zsh.\nAn alternative method will be found for this, but will be added at a later date.\nWhen you log out and log back in, you should run 'source ~/.zshrc' and 'source ~/.zinit/bin/zinit.zsh'"
fi

exit 0
