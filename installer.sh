#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'
trap 'rc=$?; printf "Error @ %s:%s (exit %s)\n" "${BASH_SOURCE[0]}" "${LINENO}" "$rc"; exit "$rc"' ERR


detectDistro () {
    source /etc/os-release
    while true; do
        printf "update system? [Y/n] "
        read -r userUpdate
        if [[ "$userUpdate" == "" || "${userUpdate,,}" == "y" ]]; then
            doUpdate=true
            break
        elif [[ "${userUpdate,,}" == "n" ]]; then
            doUpdate=false
            break
        else
            printf "please use a valid input\n"
            continue
        fi
    done
    shopt -s nocasematch
    if [[ "$ID" == *arch* || "${ID_LIKE:-}" == *arch* ]]; then
        packageManager="pacman"
        if [[ "$doUpdate" == "true" ]]; then
            sudo pacman -Syu --noconfirm
        fi
    elif [[ "$ID" == *debian* || "${ID_LIKE:-}" == *debian* ]]; then
        packageManager="apt"
        if [[ "$doUpdate" == "true" ]]; then
            sudo apt update && sudo apt upgrade -y
        fi
    elif [[ "$ID" == *fedora* ]]; then
        packageManager="dnf"
        if [[ "$doUpdate" == "true" ]]; then
            sudo dnf upgrade -y --refresh
        fi
    elif [[ "$ID" == *void* ]]; then
        packageManager="xbps"
        if [[ "$doUpdate" == "true" ]]; then
            sudo xbps-install -Syu
        fi
    else
        printf "your distro was not detected\nthis is a necessary function of the script. please submit an issue that says your distro and that this error was encountered"
        return 1
    fi
    shopt -u nocasematch
}

detectDeskEnv () {
    desktopEnvironment="${XDG_CURRENT_DESKTOP:-}"
    if [[ "${desktopEnvironment,,}" == *kde* || "${desktopEnvironment,,}" == *plasma* ]]; then
        deskEnv="kde"
        printf "kde detected\nkde profiles havent been added as a feature yet. this is still in the works"
    else
        deskEnv="none"
        printf "no supported environment detected; no profiles will be applied\n"
    fi
}

packageInstallPrefix () {
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
            printf "your package manager was not detected\nthis is a necessary function of the script. please submit an issue that says your distro and that this error was encountered"
            exit 1
            ;;
    esac
}

packageFlatpak () {
    while true; do
        printf "do you wanna use flatpak? without using flatpak, some of the features may not be supported for your particular distro [y/n] "
        read -r userFlatpak
        if [[ "${userFlatpak,,}" == "y" ]]; then
            useFlatpak=true
            break
        elif [[ "${userFlatpak,,}" == "n" ]]; then
            useFlatpak=false
            break
        else
            printf "please use a valid input\n"
            continue
        fi
    done
}

browserInstall () {
    # need to add non-flatpak method and implement it into the list
    if [[ "$useFlatpak" == "false" ]]; then
        printf "if you want to install a browser, please use flatpak\nat the moment, the only method implemented to install a browser is with flatpak\nthis is currently in the works, please be patient!\n"
        return 0
    
    elif [[ "$useFlatpak" == "true" ]]; then
        printf "\n\n\n\n\n\n\n\n\n\n"
        while true; do
            printf "\nWhat browser do you want to install? [N/1/2/3]\n[N] - None\n[1] - Firefox\n[2] - LibreWolf\n[3] - Zen\n[4] - Brave\n[5] - Chrome\n "
            read -r userBrowser
            if [[ "$userBrowser" == "" || "${userBrowser,,}" == "n" ]]; then  
                printf "No browser chosen\n"
                chosenBrowser="No browser installed"
                break
            elif [[ "$userBrowser" == "1" ]]; then
                packageInstallPrefix firefox
                chosenBrowser="Firefox"
                break
            elif [[ "$userBrowser" == "2" ]]; then
                sudo flatpak install flathub io.gitlab.librewolf-community
                chosenBrowser="LibreWolf"
                break
            elif [[ "$userBrowser" == "3" ]]; then
                sudo flatpak install flathub app.zen_browser.zen
                chosenBrowser="Zen"
                break
            elif [[ "$userBrowser" == "4" ]]; then
                sudo flatpak install flathub com.brave.Browser
                chosenBrowser="Brave"
                break
            elif [[ "$userBrowser" == "5" ]]; then
                printf "Are you sure? [y/N] "
                read -r confirm1
                if [[ "${confirm1,,}" == "y" ]]; then
                    printf "Are you ABSOLUTELY CERTAIN that you want to use Google Chrome on linux, and not some other option? [y/N] "
                    read -r confirm2
                    if [[ "${confirm2,,}" == "y" ]]; then
                        printf "Last time, I promise. I just wanna make sure you're not doing this by mistake. [y/N] "
                        read -r confirm3
                        if [[ "${confirm3,,}" == "y" ]]; then
                            sudo flatpak install flathub com.google.Chrome
                            chosenBrowser="Google Chrome"
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
                printf "Invalid option - please use the numbers or 'N' to not install a browser\n"
                continue
            fi
        done
    fi
}

discordInstall () {
    if [[ "$useFlatpak" == "false" ]]; then
        printf "if you want to install a browser, please use flatpak\nat the moment, the only method implemented to install a browser is with flatpak\nthis is currently in the works, please be patient!\n"
        return 0
    elif [[ "$useFlatpak" == "true" ]]; then
        printf "Do you want to install Discord? [Y/n] "
        read -r discordInstall
        if [[ "$discordInstall" == "" || "${discordInstall,,}" == "y" ]]; then
            if [[ "$packageManager" == "pacman" ]]; then
                if packageInstallPrefix discord; then
                    chosenDiscord="Successfully installed"
                else
                    chosenDiscord="Failed to install"
                fi
            #elif [[ "$packageManager" == "apt" ]]; then   !!!This fails on Debian 13, and has been tested in the past and did work on Debian Based distros.!!!
                #if ! packageInstall discord; then         !!! This could be patched later down the line, but at the moment, to resolve the issue, we'll keep using flatpak.!!!
                    #wget -O ~/Downloads/discord.deb https://discord.com/api/download?platform=linux&format=deb
                    #sudo apt install ~/Downloads/discord.deb
                #fi
            else
                # Flatpak is starting to feel like cheating. I should find other methods rather than using it as a copout. 
                if sudo flatpak install flathub com.discordapp.Discord; then
                    chosenDiscord="Successfully installed"
                else
                    chosenDiscord="Failed to install"
                fi
            
            fi
        else
            echo "Not installing discord"
            chosenDiscord="Not installed"
        fi
}


installConfigs () {
    # for consistency, use links like this - https://raw.githubusercontent.com/draaaa/linux-autosetup/main/file
    # next feature to be added would be using links to custom configs rather than my own preset configs
    
    # konsole
    if [[ -n "$KONSOLE_VERSION" ]]; then
        wget -O ~/.local/share/konsole/Brogrammer.colorscheme https://raw.githubusercontent.com/draaaa/linux-autosetup/main/terminal-profiles/Brogrammer.colorscheme
        wget -O ~/.local/share/konsole/las_profile.profile https://raw.githubusercontent.com/draaaa/linux-autosetup/main/terminal-profiles/konsole.profile
        termEmm="konsole"
    else
        printf "Your terminal emmulator may not be supported yet.\nAt the moment, I mostly use konsole, so support for your terminal may not exist yet.\nPlease submit an issue requesting support for your terminal emmulator, and I will work to create a profile and add it to the repo.\n"
        termEmm="No supported terminal emmulator detected; no profiles will be applied"
    fi

    # zsh
    chsh -s $(which zsh)
    wget -O ~/.zshrc https://raw.githubusercontent.com/draaaa/linux-autosetup/main/zsh/.zshrc
    mkdir ~/Scripts
    wget -O ~/Scripts/CommandList.sh https://raw.githubusercontent.com/draaaa/linux-autosetup/main/zsh/scripts/CommandList.sh
    chmod +x ~/Scripts/CommandList.sh

    # fastfetch
    mkdir -p ~/.config/fastfetch
    wget -O ~/.config/fastfetch/config.jsonc https://raw.githubusercontent.com/draaaa/linux-autosetup/main/fastfetch/config.jsonc

    # ufw
    sudo ufw enable
}


summary () {
    # too barebones and needs updating. more will be added to the summary with time
    printf "\n\n\n\n\nSummary\nDesktop Environment - ${deskEnv}\nTerminal Emmulator - ${termEmm}\nBrowser - ${chosenBrowser}\nDiscord - ${chosenDiscord}"

    # prompt reboot
    while true; do
        printf "Reboot is recommended. Want to reboot? [Y/n] " 
        read -r userReboot
        if [[ "$userReboot" == "" || "${userReboot,,}" == "y" ]]; then
            doReboot=true
        elif [[ "${userReboot,,}" == "n" ]]; then
            printf "i recommend manually rebooting soon, especially since alot of things have just been downloaded and installed\nif something breaks before you reboot because you ignored the recommendation, thats on you\n"
        else
            printf "please use a valid input\n"
            continue
        fi
        break
    done
}

main () {
    cat << EOF
    ___                                    __                  __            
       / (_)___  __  ___  __      ____ ___  __/ /_____  ________  / /___  ______ 
      / / / __ \/ / / / |/_/_____/ __ \`/ / / / __/ __ \/ ___/ _ \/ __/ / / / __ \\
     / / / / / / /_/ />  </_____/ /_/ / /_/ / /_/ /_/ (__  )  __/ /_/ /_/ / /_/ /
    /_/_/_/ /_/\__,_/_/|_|      \__,_/\__,_/\__/\____/____/\___/\__/\__,_/ .___/ 
                                                                        /_/      
EOF
    printf "made by draaaa :3\npls remember to submit an issue to the github if there are problems\n\n"

    printf "Have you made your user a sudoer? [Y/n] "
    read -r isSudoer
    if [[ "$isSudoer" != "" && "${isSudoer,,}" != "y" ]]; then
        printf "Make yourself a sudoer in the root user with 'usermod -aG sudo user'\n"
        return 1
    fi

    detectDistro  # returns packageManager
    detectDeskEnv  # returns deskEnv
    
    packageInstallPrefix wget git zsh cowsay ufw flatpak
    # fastfetch
    if [[ "$packageManager" == "apt" ]]; then
        if ! packageInstallPrefix fastfetch; then
            wget -O ~/Downloads/fastfetch.deb https://github.com/fastfetch-cli/fastfetch/releases/download/2.48.1/fastfetch-linux-amd64.deb
            sudo apt install ~/Downloads/fastfetch.deb
        fi
    else
        packageInstallPrefix fastfetch
    fi

    #tldr (tealdeer)
    if ! packageInstallPrefix tldr; then
        packageInstallPrefix tealdeer
    fi

    #pokemon-colorscripts
    git clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git
    cd pokemon-colorscripts
    sudo ./install.sh

    # zinit
    mkdir ~/.zinit
    git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin

    browserInstall
    discordInstall
    installConfigs 
    summary
    if [[ "$doReboot" == "true" ]]; then
        sudo reboot
    fi
}

main "$@"
