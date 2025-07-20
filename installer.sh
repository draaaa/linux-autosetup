# Heavy work in progress

# Check Distro 
# Instead, we could check for package manager? that may be more efficient so that we can just bypass checking for the distro
# I don't really think that checking for the distro is that important. But, it's 3:00 am. I'm tired. I'll keep working on this later. 
# source /etc/os-release doesn't mention the package manager though so it'd have to be a completely different system which I could start
# working on now, but I already complained about why I don't wanna. 
# Chances are I'll just delete this stuff and use a whole new method man. I'm too tired for this.

source /etc/os-release

if [ "$ID" = "arch" ]; then
    echo "Arch is the detected distro"
    # need to set a bool here so that pacman would be used rather than apt
elif [ "$ID" = "debian" ]; then
    echo "Debian is the detected distro"
    # need to set a bool here so that apt would be used rather than pacman
fi
