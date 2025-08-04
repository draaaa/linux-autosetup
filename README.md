# What is linux-autosetup?
linux-autosetup is a shell script that targets the pesky process of reinstalling a distro and needing to reinstall and reconfigure everything. Forget to back up your OS and need to reinstall? Trying a new OS entirely out of curiousity? linux-autosetup is built specifically for this. It automatically downloads and installs packages that people use daily. It automatically detects your distro and works with little input from the user. For the most part, input will be choosing what you'd want to install, like choosing from a list of browsers and whether or not to install non-essential, less used packages. 

# Using linux-autosetup
Run the following commands;

```
wget -O ~/Downloads/installer.sh https://raw.githubusercontent.com/draaaa/linux-autosetup/main/installer.sh
chmod +x ~/Downloads/installer.sh
bash ~/Downloads/installer.sh
```

### Have your own config?
No problem! Simply change the links in the code for any program with your working config and it should automatically apply seamlessly. linux-autosetup is designed to be easy to modify from the ground up.

# Experience any bugs or issues? Want to give advice or criticism?
Feel free to submit an issue outlining what ever your concern may be. This is my first decent project with shell, so I'm always looking for room to improve. I will work to fix any issues submitted within a reasonable time frame. Lesser priority issues or bugs that aren't fatal may not be prioritized in the case that another part of the project is being worked on, but I will continue the work needed to improve the script and flatten any issues that arise from my work. 