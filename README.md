**IMPORTANT**

*Debian 13 (Trixie) was announced to be released on August 9th. Because of the update, Debian 12 support will no longer be prioritized. There will still be support for Debian 12 eventually, but compatability with Debian 12 does not currently fit the main purpose of this project, being to make it easier to reinstall a distro for daily use. It will likely be added at some point in the lifespan of this project's development, but I have no estimate as to when that will be. For now, the focus will shift to tackling the compatibility issues.*

**Purpose of linux-autosetup**

This repo serves two purposes - firstly, and more importantly, it is an archive of the configs that I use for GNU/Linux. It's second purpose *(which has yet to be implemented)* is to automatically install applications that I use, so that I do not have to manually reinstall every app that I use on a daily basis. Simply put, it is an online backup of my setup so that I do not have to manually reinstall everything on each install.

**Goals of linux-autosetup**
1. To implement a detection method for common distributions for compatability with the different package managers of different distributions
2. To automatically install apps and their respective preferred configurations that are set within the repo
3. To maintain an organized list of configurations that are modifiable by anybody for any* distribution
4. To further develop an understanding of git as well as GNU/Linux

**On Updating Compatability**

One of the constraints that is coming with this script is the detection method that's being used. The ID that 'source /etc/os-release' returns is being used as the identifier for the distro. The most notable issue with this is that each ID in the os-release information has to be manually added. While it is true that simple commands that work on Arch will also work on EndeavourOS, for example, I'm choosing to personally vett the compatibility for each distro. This may be streamlined at another date, but as it stands within the scope of this project, I would prefer having personally vetted the compatibility. There may be an option to implement compatibility based on the ID_LIKE that is returned in distros downstream from others, but it requires more testing and further investigation. I will continue to explore downstream distributions to see if the ID_LIKE is a reoccuring element of downstream distributions. 