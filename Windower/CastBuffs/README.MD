# CastBuffs

**Author:** Sevu  
**Version:** 0.1  
**Commands:** `//castbuffs`, `//cb`

## Overview

CastBuffs is a Lua addon for Final Fantasy XI that automates the process of casting a predefined list of buffs on the player character. This addon casts buffs sequentially with a fixed wait time between each cast.

## Installation

1. Download the latest version of CastBuffs from the releases page.
2. Extract the contents of the zip file into the `addons` folder of your Final Fantasy XI installation directory.
3. Load it using `lua load castbuffs` 
4. (Optional) Add it to your `script\init.txt` to autoload it on login.

## Usage

To start casting buffs, use the following command in the game chat:

`//cb start` or `//castbuffs start`

This will initiate the buffing process, casting each buff in the predefined list with a fixed delay between each cast.

## Customization

You can customize the list of buffs to cast by modifying the `spells.lua` file located in the addon folder. Simply add or remove spells from the list as needed.

## Settings

- **Wait Time:** The fixed wait time (in seconds) between each cast. Default value: `6.5 seconds`, adjust it accordingly to your own fast cast values.

## Notes

- Make sure to review and comply with the rules and policies of the game before using this addon.
- Use of third-party addons may violate the Terms of Service of Final Fantasy XI. Use at your own risk.