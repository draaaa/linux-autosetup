# There's gonna be a bunch of comments that I don't keep and will remove later in this file. I'm using it for the development process.


# Ideation
#   The Goal
#     Remove the need to manually install apps, transfer configs, and set up profiles that I use daily. 
#     If I have to reinstall a distro or got a new computer, the idea is that I wouldn't have to manually transfer config files,
#     tediously install a long list of things that I use, etc
#
#   How do we go about this?
#     1. Identify the package manager <-- MOSTLY HERE
#          honestly, I'm not sure how I should do this yet. I feel that it'd just be more optimal to base it on the package manager, but the 
#          'source /etc/os-release' method with detecting distros seems to be the most universal. I'll have to do more research. 
#     2. Install apps <-- PARTIALLY HERE
#          Once we have the package manager identified, it should be fairly easy to install the list of packages that I use. 
#          Something I need to remember, however, is that not all package managers are as up to date. In particular, if I tried to use 
#          this command with Debian 12 when it was designed for Debian 13, then there would be some packages that are unable to be installed
#          like 'sudo apt install fastfetch'. This can be performed only on Debian 13 but not Debian 12. 
#          I'm not sure how this will be handled yet. Requires more research and ideation.
#     3. Apply preferred configs to apps
#          We'll continue ideating later. I don't want to look too far into the future before I barely even have a base to start with.


#TODO Priority
# Test Debian 12 compatability
# Test config application
# Test shell conversion (bash to zsh)

# Check Distro
packageManager=""
source /etc/os-release

if [ "$ID" = "arch" ]; then
    packageManager="pacman"
elif [ "$ID" = "debian" ]; then 
    if [ "$VERSION_ID" = "13" ]; then
        packageManager="apt"
    elif [ "$VERSION_ID" = "12" ]; then
        packageManager="aptDeb12"  # For now, we can use a separate name for Debian 12 until I can come up with a workaround for the version issues.
    fi
fi

# Separating the if structures seems a bit redundant and unnecessary for anything beyond structure, which isn't the main priority.
# I'll leave it like this for now because of inexperience with shell, but this is something that should probably be reworked. 
# For now, since my sandbox laptop is on Debian 13, most of this will be tested on Debian 13 first, then tested on Arch when I 
# install it onto the sandbox.
# For now, fastfetch will be the main package used for testing. 
# !!! IMPORTANT !!! - should consider doing one install command if possible rather than doing multiple. would make things slightly more optimized.
# Once there are enough packages for me to be satisfied, I'll update it so that there aren't this many unneeded install commands
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

elif [ "$packageManager" = "aptDeb12" ]; then  # Untested
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


# Now that everything is (ideally) installed, we should begin applying the configs from the repo
# We should use wget since it comes with most distributions. Just found out it doesn't come with Arch, so I'll add that to a download dependency list
# Use the raw github links like this - https://raw.githubusercontent.com/draaaa/linux-autosetup/main/file
# fastfetch
    mkdir -p ~/.config/fastfetch
    wget -O ~/.config/fastfetch/config.jsonc https://raw.githubusercontent.com/draaaa/linux-autosetup/main/fastfetch/config.jsonc
# ufw
    sudo ufw enable
# zsh
    chsh -s $(which zsh)  # should ideally set zsh to default terminal 
    # Once we know that this script successfully sets zsh to be the default shell, then we can worry about importing the profile, config, etc
    