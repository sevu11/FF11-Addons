# POL TOOL

## Graphical Interface for executing PS1 scripts

This application will launch and copy `bin` files for Playonline Viewer for users that needs to use more than 4 characters.

### Instructions (IMPORTANT, READ CAREFULLY)

1. Open POL and add your characters to the main page (4 max. – assuming you've already done this). These characters get saved in the PlayOnline directory `(..PlayOnlineViewer\usr\all)` in a file called `login_w.bin`.
2. Navigate to this directory and make a copy of `login_w.bin`. Name it `char1.bin`.
3. Delete the original `login_w.bin`.
4. Open POL. It will have no characters again. Add up to 4 more.
5. Repeat step 2 but name the copied file `char2.bin`. If this is the final lot of characters being added, we're done.
6. Download char1.ps1 and also place it in the above directory. Also download (https://github.com/jaku/POL-Proxy/releases)[PolProxy.exe] if you’re using that. Doesn't matter where this is placed.
7. Edit $shortcutPath = "X:\PathTo\Windower\windower.lnk" by replacing the text between the "" marks with the directory of your windower profile shortcut.
7b. Edit $proxyPath in the same way but with the directory where you placed `PolProxy.exe`
8. Make a copy of char1.ps1 and name it char2.ps1 (do same step as for char1).

Assuming you've followed the steps correctly, now you can launch the scripts from the `Launch.exe`. Important you save these to the folder in step 1. If you wish to put it on your desktop or a different location, make a shortcut of it.

### Compile from source

If you wish to compile the exe from source, install the `requirements.txt` and compile it using pyinstaller.
