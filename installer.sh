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
            doFlatpak=true
            break
        elif [[ "${userFlatpak,,}" == "n" ]]; then
            doFlatpak=false
            break
        else
            printf "please use a valid input\n"
            continue
        fi
    done
}

browserInstall () {
    printf "\n\n\n\n\n\n\n\n\n\n"
    while true; do
        printf "\nWhat browser do you want to install? [N/1/2/3]\n[N] - None\n[1] - Firefox\n[2] - LibreWolf\n[3] - Zen\n[4] - Brave\n[5] - Chrome\n "
        read -r userBrowser
        if [[ "$userBrowser" == "" || "${userBrowser,,}" == "n" ]]; then  
            printf "No browser chosen\n"
            chosenBrowser="No browser installed"
            break

        elif [[ "$userBrowser" == "1" ]]; then
            if [[ "$doFlatpak" == "false" ]]; then
                packageInstallPrefix firefox
            elif [[ "$doFlatpak" == "true" ]]; then
                flatpak install flathub org.mozilla.firefox
            fi
            chosenBrowser="Firefox"
            break

        elif [[ "$userBrowser" == "2" ]]; then
            if [[ "$doFlatpak" == "false" ]]; then
                if ! packageInstallPrefix LibreWolf; then
                    if [[ "$packageManager" == "pacman" ]]; then
                        git clone https://aur.archlinux.org/librewolf-bin.git
                        cd librewolf-bin
                        makepkg -si
                    elif [[ "$packageManager" == "apt" ]]; then
                        sudo apt update && sudo apt install extrepo -y
                        sudo extrepo enable librewolf
                        sudo apt update && sudo apt install librewolf -y
                    elif [[ "$packageManager" == "dnf" ]]; then
                        curl -fsSL https://repo.librewolf.net/librewolf.repo | pkexec tee /etc/yum.repos.d/librewolf.repo
                        sudo dnf install librewolf
                    else
                        printf "your distro may not have support from LibreWolf officially, but there are still other methods\nthese are soon to be implemented\nif you still want to install LibreWolf, i recommend using flatpak for now\n"
                    fi
                fi
            elif [[ "$doFlatpak" == "true" ]]; then
                sudo flatpak install flathub io.gitlab.librewolf-community
            fi
            chosenBrowser="LibreWolf"
            break

        elif [[ "$userBrowser" == "3" ]]; then
            if [[ "$doFlatpak" == "false" ]]; then
                cd ~/Downloads
                wget -O zen.linux-x86_64.tar.xz https://github.com/zen-browser/desktop/releases/download/1.14.11b/zen.linux-x86_64.tar.xz
                sudo tar -xf zen.linux-x86_64.tar.xz -C /opt/
                sudo chmod +x /opt/zen/zen
                sudo ln -sf /opt/zen/zen /usr/local/bin/zen
                sudo tee /usr/share/applications/zen.desktop >/dev/null << 'EOF'
[Desktop Entry]
Name=Zen Browser
GenericName=Web Browser
Comment=Zen Browser - Fast and Private Web Browser
Exec=/opt/zen/zen %U
Terminal=false
Type=Application
Categories=Network;WebBrowser;
Icon=/opt/zen/browser/chrome/icons/default/default128.png
StartupWMClass=zen
EOF
                sudo chmod 644 /usr/share/applications/zen.desktop
                sudo rm -f zen.linux-x86_64.tar.xz
                cd
            elif [[ "$doFlatpak" == "true" ]]; then
                sudo flatpak install flathub app.zen_browser.zen
            fi
            chosenBrowser="Zen"
            break

        elif [[ "$userBrowser" == "4" ]]; then
            if [[ "$doFlatpak" == "false" ]]; then
                if [[ "$packageManager" == "pacman" ]]; then
                    yay -Sy brave-bin
                elif [[ "$packageManager" == "apt" ]]; then
                    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
                    sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
                    sudo apt update
                    sudo apt install -y brave-browser
                elif [[ "$packageManager" == "dnf" ]]; then
                    sudo dnf install -y dnf-plugins-core
                    sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
                    sudo dnf install -y brave-browser

                else
                    curl -fsS https://dl.brave.com/install.sh | sh
                fi
            elif [[ "$doFlatpak" == "true" ]]; then
                sudo flatpak install flathub com.brave.Browser
            fi
            chosenBrowser="Brave"
            break

        elif [[ "$userBrowser" == "5" ]]; then
            printf "Are you sure? [y/N] "
            read -r confirm1
            if [[ "${confirm1,,}" == "y" ]]; then
                printf "Are you ABSOLUTELY CERTAIN that you want to use Google Chrome on linux, and not some other option? [y/N] "
                read -r confirm2
                if [[ "${confirm2,,}" == "y" ]]; then
                    if [[ "$doFlatpak" == "false" ]]; then
                        if ! packageInstallPrefix chromium; then
                            if [[ "$packageManager" == "apt" ]]; then
                                wget -O ~/Downloads/chromium.deb http://security.debian.org/debian-security/pool/updates/main/c/chromium/chromium_139.0.7258.127-1~deb13u1_amd64.deb
                                sudo apt install ~/Downloads/chromium.deb
                            # need to add more backup methods
                            else
                                printf "your distro may not have support for chromium officially, but there are still other methods\nthese are soon to be implemented\nif you still want to install chromium, i recommend using flatpak for now\n"
                            fi                            
                        fi
                    elif [[ "$doFlatpak" == "true" ]]; then
                        sudo flatpak install flathub com.google.Chrome
                    fi
                    chosenBrowser="Chromium"
                    break
                else
                    continue
                fi
            else
                continue
            fi
        else
            printf "invalid option - please use the numbers or 'N' to not install a browser\n"
            continue
        fi
    done
}

discordInstall () {
        printf "Do you want to install Discord? [Y/n] "
        read -r discordInstall
        if [[ "$discordInstall" == "" || "${discordInstall,,}" == "y" ]]; then
            if [[ "$doFlatpak" == "false" ]]; then
                if ! packageInstallPrefix discord; then
                    if [[ "$packageManager" == "apt" ]]; then

                    else
                        cd ~/Downloads
                        wget -O discord.tar.gz 'https://discord.com/api/download?platform=linux&format=tar.gz'
                        sudo tar -xzf discord.tar.gz -C /opt/
                        sudo chmod +x /opt/Discord/Discord
                        sudo ln -sf /opt/Discord/Discord /usr/local/bin/discord
                        sudo tee /usr/share/applications/discord.desktop >/dev/null << 'EOF'
[Desktop Entry]
Name=Discord
GenericName=Internet Messenger
Comment=Discord - Chat for Communities and Friends
Exec=/opt/Discord/Discord %U
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
Icon=/opt/Discord/discord.png
StartupWMClass=discord
EOF
                        sudo chmod 644 /usr/share/applications/discord.desktop
                        rm -f discord.tar.gz
                        cd
                    fi
                fi
                chosenDiscord="Successfully installed"
            elif [[ "$doFlatpak" == "true" ]]; then
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
    mkdir -p ~/Scripts
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
    printf "\n\n\n\n\nSummary\nDesktop Environment - ${deskEnv}\nTerminal Emmulator - ${termEmm}\nBrowser - ${chosenBrowser}\nDiscord - ${chosenDiscord}\n"

    # prompt reboot
    while true; do
        printf "Reboot is recommended. Want to reboot? [Y/n] " 
        read -r userReboot
        if [[ "$userReboot" == "" || "${userReboot,,}" == "y" ]]; then
            doReboot=true
        elif [[ "${userReboot,,}" == "n" ]]; then
            doReboot=false
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
    
    packageInstallPrefix wget curl git zsh cowsay ufw
    if [[ "$packageManager" == "pacman" ]]; then
        sudo pacman -S --needed --noconfirm base-devel
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si
    fi
    
    packageFlatpak
    # flatpak (if user wants to use it)
    if [[ "$doFlatpak" == "true" ]]; then
        packageInstallPrefix flatpak
        sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    fi

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
    mkdir -p ~/.zinit
    git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin

    sudo mkdir -p /opt

    browserInstall
    discordInstall
    installConfigs 
    summary
    if [[ "$doReboot" == "true" ]]; then
        sudo reboot
    fi
}

main "$@"
