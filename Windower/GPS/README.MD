Author: Garyfromwork@Asura. Modified by Melucine

```
Changes by Melucine
    Adding output to Texts element
    Adding additional commands
    Added settings from file
    Added feature if Texts window is hidden, results will be populated into the chat instead.    
```



Purpose: 
	To make navigating FFXI's zones a bit easier for new players, and save players
 	from alt-tabbing to various websites to see how zones connect.

Commands:
	Load the addon:
		//lua l gps

    Get help and all available commands:
        //gps help

	Find exits for current zone:
		//gps zone

	Find exits for a specific zone (don't send with auto-translate format), with or without quotes ("):
		//gps "zone name" 

    Hide the window and display in chat
		//gps hide
        
    Hide the chat output and display in window
		//gps show

Known Issues:
	This addon currently cannot process auto-translated phrases or zone names.
	A work around is to auto-translate the zone name in game and backspace a few characters and then retype them.
	This removes the auto-translate but keeps the name of the zone.