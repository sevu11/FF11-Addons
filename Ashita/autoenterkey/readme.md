# Autoenterkey

## Basic addon to automatically send the Enter key when opening FFXI to accept the TOS.

OS configuration is handled in the `.lua` script with these settings:

```lua
is_Windows = true
is_Linux = false
```

Tested on Linux but the script should work, see dependencies below.

## !! Dependencies !!

For Linux, you'll need to install `xdotool`, depending on your distro, it might already be installed.
You might need `sudo` depending on your linux setup.

| Distribution    | Installation Command         |
|-----------------|------------------------------|
| Debian and Ubuntu | `sudo apt-get install xdotool` |
| Fedora           | `sudo dnf install xdotool`    |
| FreeBSD          | `sudo pkg install xdotool`    |
| OpenSUSE         | `sudo zypper install xdotool` |
| Arch Linux       | `sudo pacman -S xdotool`      |

If you're on Windows, you also need a command-line utility, `nircmd`:

| Architecture | Download Link                                    |
|--------------|--------------------------------------------------|
| 32-bit       | [nircmd.zip](https://www.nirsoft.net/utils/nircmd.zip) |
| 64-bit       | [nircmd-x64.zip](https://www.nirsoft.net/utils/nircmd-x64.zip) |
