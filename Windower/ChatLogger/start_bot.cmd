@echo off
start "" pythonw Bot/incoming_tells.pyw
timeout /t 1 >nul
taskkill /f /im cmd.exe
exit
