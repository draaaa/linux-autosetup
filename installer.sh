#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'
trap 'rc=$?; printf "Error @ %s:%s (exit %s)\n" "${BASH_SOURCE[0]}" "${LINENO}" "$rc"; exit "$rc"' ERR


detectDistro () {
    source /etc/os-release
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
            return 1
            ;;
    esac
}


browserInstall () {
    if [[ "${BROWSER,,}" == "firefox" ]]; then
        if [[ "$doFlatpak" == "false" ]]; then
            packageInstallPrefix firefox
        elif [[ "$doFlatpak" == "true" ]]; then
            flatpak install flathub org.mozilla.firefox
        fi
        chosenBrowser="Firefox"
        return 0

    elif [[ "${BROWSER,,}" == "librewolf" ]]; then
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
        return 0

    elif [[ "${BROWSER,,}" == "zen" ]]; then
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
        return 0

    elif [[ "${BROWSER,,}" == "brave" ]]; then
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
        return 0

    elif [[ "${BROWSER,,}" == "chrome" ]]; then
        #printf "Are you sure? [y/N] "
        #read -r confirm1
        #if [[ "${confirm1,,}" == "y" ]]; then
            #printf "Are you ABSOLUTELY CERTAIN that you want to use Google Chrome on linux, and not some other option? [y/N] "
            # read -r confirm2
            #if [[ "${confirm2,,}" == "y" ]]; then
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
                return 0
    fi
}

discordInstall () {
        if [[ "$discordInstall" == "true" ]]; then
            if [[ "$doFlatpak" == "false" ]]; then
                if ! packageInstallPrefix discord; then
                    if [[ "$packageManager" == "apt" ]]; then
                        :
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
    if [[ "$doFlatpak" == "false" ]]; then
        printf "not installing dot files"
        return 0
    fi

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


main () {
    if whiptail --title "linux-autosetup" --yesno \
        "Are you a sudoer?" 10 50; then
            :
    else
        whiptail --title "linux-autosetup" --msgbox \
        "Make yourself a sudoer in the root user with\n\n'usermod -aG sudo user'\n\nPress 'enter' to close" \
        12 75
        exit 1
    fi

    APPS=$(whiptail --title "linux-autosetup" --checklist \
    "Choose apps to install" 20 75 10 \
    "Browser" "Install a browser from a list of options" OFF \
    "Discord" "Install Discord" OFF \
    3>&1 1>&2 2>&3)
    APPS=$(echo "$APPS" | tr -d '"')

    if [[ "$APPS" == *Browser* ]]; then
        BROWSER=$(whiptail --title "linux-autosetup" --menu \
        "Choose a browser to install" 20 75 10 \
        "Firefox" "Install Firefox" \
        "LibreWolf" "Install LibreWolf" \
        "Zen" "Install Zen" \
        "Brave" "Install Brave" \
        "Chrome" "Install Chrome" \
        3>&1 1>&2 2>&3)
        BROWSER=$(echo "$BROWSER" | tr -d '"')
    fi

    UTILS=$(whiptail --title "linux-autosetup" --checklist \
    "Choose utilities to install" 20 75 10 \
    "zsh" "Download and install zsh as the default shell" OFF \
    "Fastfetch" "Download and install Fastfetch" OFF \
    "UFW" "Download, install, and enable Uncomplicated Fire Wall" OFF \
    "Mullvad VPN" "Download and install Mullvad VPN" OFF \
    3>&1 1>&2 2>&3)
    UTILS=$(echo "$UTILS" | tr -d '"')

    if whiptail --title "linux-autosetup" --yesno \
        "The system should update before being ran\n\nUpdate?" 10 75; then
            doUpdate=true
    else
        doUpdate=false
    fi

    if [[ "${APPS,,}" == *discord* || -n "${BROWSER:-}" ]]; then
        if whiptail --title "linux-autosetup" --yesno \
            "You have selected to install apps where flatpak can be used\n\nDo you want to use flatpak?\n\nOptions will be listed soon" 10 75; then
                doFlatpak=true
        else
            doFlatpak=false
        fi
    fi

    if [[ "${APPS,,}" == *discord* ]]; then
        discordInstall=true
    fi

    if whiptail --title "linux-autosetup" --yesno \
        "Do you want to install my personal dot files?\n\nThis includes zsh config, fastfetch config, and konsole profile" 10 75; then
            doDotFiles=true
    else
        doDotFiles=false
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

    if whiptail --title "linux-autosetup" --yesno \
        "The system must be rebooted to apply some of the features\n\nReboot?" 10 50; then
            sudo reboot now
    else
        whiptail --title "linux-autosetup" --msgbox \
        "Make sure that you reboot at some point to ensure stability of your system" \
        10 75
        exit 0
    fi
}

main "$@"
