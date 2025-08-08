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

if [[ "$ID" == "arch" || "$ID_LIKE" == *arch* ]]; then
    packageManager="pacman"
    sudo pacman -Syu

elif [[ "$ID" == "debian" || "$ID_LIKE" == *debian* ]]; then  # Pretty much all other apt utilizing distros will go here as well. Likely to remove the special Debian 12 case
    packageManager="apt"
    sudo apt update && sudo apt upgrade -y

elif [[ "$ID" == "fedora" ]]; then
    packageManager="dnf"
    sudo dnf upgrade -y --refresh

elif [[ "$ID" == "void" ]]; then
    packageManager="xbps"
    sudo xbps-install -Syu

else
    echo -e "Your distro may be unsupported, or there may be an error with detecting your distro. Currently, the detection method is being reworked. If your distro is downstream from a supported distro then it's detection may not have been updated yet.\nPlease consult the list of supported distros, and create an issue saying that your distro is unsupported.\n"
    exit 1
fi

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


# !!!INSTALLER!!!
packageInstall wget git zsh tldr cowsay ufw flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
printf "\n\n\n\n\n\n\n\n\n\n"


# browser
while true; do
    printf "\nWhat browser do you want to install? [N/1/2/3]\n[N] - None\n[1] - Firefox\n[2] - LibreWolf\n[3] - Zen\n[4] - Brave\n[5] - Chrome\n "
    read userBrowser
    if [[ "$userBrowser" == "" || "$userBrowser" == "n" || "$userBrowser" == "N" ]]; then  
        echo "No browser chosen"
        break
    elif [[ "$userBrowser" == "1" ]]; then
        packageInstall firefox
        break
    elif [[ "$userBrowser" == "2" ]]; then
        flatpak install flathub io.gitlab.librewolf-community
        break
    elif [[ "$userBrowser" == "3" ]]; then
        flatpak install flathub app.zen_browser.zen
        break
    elif [[ "$userBrowser" == "4" ]]; then
        flatpak install flathub com.brave.Browser
        break
    elif [[ "$userBrowser" == "5" ]]; then
        printf "Are you sure? [y/N] "
        read confirm1
        if [[ "$confirm1" == "y" ]]; then
            printf "Are you ABSOLUTELY CERTAIN that you want to use Google Chrome on linux, and not some other option? [y/N] "
            read confirm2
            if [[ "$confirm2" == "y" ]]; then
                printf "Last time, I promise. I just wanna make sure you're not doing this by mistake. [y/N] "
                read confirm3
                if [[ "$confirm3" == "y" ]]; then
                    flatpak install flathub com.google.Chrome
                    break
                else
                    continue
                fi
            else
                continue
            fi
        else
            continue
        fi
    else
        echo "Invalid option - please use the numbers or 'N' to not install a browser"
        continue
    fi
done

# discord
printf "Do you want to install Discord? [Y/n] "
read discordInstall
if [[ "$discordInstall" == "" || "$discordInstall" == "y" || "$discordInstall" == "Y" ]]; then
    if [[ "$packageManager" == "pacman" ]]; then
        packageInstall discord
    elif [[ "$packageManager" == "apt" ]]; then
        if ! packageInstall discord; then
            wget -O ~/Downloads/discord.deb https://discord.com/api/download?platform=linux&format=deb
            sudo apt install ~/Downloads/discord.deb
        fi
    else
        # Flatpak is starting to feel like cheating. I should find other methods rather than using it as a copout. 
        flatpak install flathub com.discordapp.Discord
    fi
else
    echo "Not installing discord"
fi

# fastfetch
if [[ "$packageManager" == "apt" ]]; then
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
chsh -s $(which zsh)
wget -O ~/.zshrc https://raw.githubusercontent.com/draaaa/linux-autosetup/main/zsh/.zshrc
mkdir ~/Scripts
wget -O ~/Scripts/CommandList.sh https://raw.githubusercontent.com/draaaa/linux-autosetup/main/zsh/scripts/CommandList.sh
chmod +x ~/Scripts/CommandList.sh

# terminal emmulators
terminalEmm=$(ps -p $(ps -o ppid= -p $$) -o comm=)
if [[ "$terminalEmm" == "konsole" ]]; then
    wget -O ~/.local/share/konsole https://raw.githubusercontent.com/draaaa/linux-autosetup/main/terminal-profiles/Brogrammer.colorscheme
    wget -O ~/.local/share/konsole https://raw.githubusercontent.com/draaaa/linux-autosetup/main/terminal-profiles/konsole.profile
else
    printf "Your terminal emmulator may not be supported yet.\nAt the moment, I mostly use konsole, so support for your terminal may not exist yet.\nPlease submit an issue requesting support for your terminal emmulator, and I will work to create a profile and add it to the repo.\n"
fi

# Prompt reboot
printf "Reboot is recommended. Want to reboot? [Y/n] " 
read doReboot
if [[ "$doReboot" == "" || "$doReboot" == "y" || "$doReboot" == "Y" ]]; then
    sudo reboot
else
    printf "In order for zsh to properly become the default, you must at minimum log out then log back in.\nDoing so without rebooting may cause zinit to fail to work properly with zsh.\nAn alternative method will be found for this, but will be added at a later date.\nWhen you log out and log back in, you should run 'source ~/.zshrc' and 'source ~/.zinit/bin/zinit.zsh'"
fi

exit 0
