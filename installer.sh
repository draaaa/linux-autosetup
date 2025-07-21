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


#TODO
# Test Debian 12 compatability


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
# I'll leave it like this for now because of inexperience with shell, but this is absolutely something that will need to be reworked. 
# For now, since my sandbox laptop is on Debian 13, most of this will be tested on Debian 13 first, then tested on Arch when I 
# install it onto the sandbox.
# For now, fastfetch will be the main package used for testing. 
if [ "$packageManager" = "pacman" ]; then
    sudo pacman -Syu
    # fastfetch
        sudo pacman -S fastfetch

elif [ "$packageManager" = "apt" ]; then
    sudo apt update && sudo apt upgrade -y
    # fastfetch
        sudo apt install fastfetch -y

elif [ "$packageManager" = "aptDeb12" ]; then  # Untested
    sudo apt update && sudo apt upgrade -y
    # fastfetch
        wget https://github.com/fastfetch-cli/fastfetch/releases/download/2.48.1/fastfetch-linux-amd64.deb -0 fastfetch.deb # For now, we can just use one version. Maybe look into using the newest version later
        sudo apt install ./fastfetch.deb
        rm fastfetch.deb
fi