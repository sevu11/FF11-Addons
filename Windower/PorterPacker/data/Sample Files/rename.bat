@echo off
setlocal enabledelayedexpansion

set /p userinputname="Enter the new prefix to replace the existing one: "

for %%f in (*.lua) do (
    set "filename=%%~nf"
    set "extension=%%~xf"

    for /f "tokens=1,2 delims=_" %%a in ("!filename!") do (
        if "%%b" neq "" (
            ren "%%f" "!userinputname!_%%b!extension!"
        )
    )
)

echo Files have been renamed.
endlocal
