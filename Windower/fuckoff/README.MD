# FuckOff

FuckOff is a Windower addon designed to filter out Real Money Trading (RMT) and mercenary yell/shouts in Final Fantasy XI.

## Description

FuckOff provides a simple yet effective way to block unwanted chat messages, helping to maintain a more enjoyable gaming experience by reducing spam and unwanted solicitations.

## Commands

The following commands are available for FuckOff:

- `//fo` or `//fuckoff`: Primary command prefix.
- `fo help`: Displays the help menu.
- `fo add <name>` or `fo add <name>*`: Adds a name or wildcard pattern to the blacklist.
- `fo list`: Prints a list of blacklisted names or wildcard patterns.
- `fo reload`: Reloads the addon.

## Note

When adding wildcard names to the `blacklist.lua` without using the in-game command, ensure to include `.*` at the end of the pattern. For example, `Bob.*` will wildcard any names starting with "Bob", matching to "Bobby", "Bobbo", "Bobba", etc.

## Credit

This addon was originally written by Chiaia. You can find the original repository [here](https://github.com/Chiaia/Windower-4-Addons/tree/main/fuckoff).
