@echo off

if not exist "%programfiles%\LOVE\love.exe" (
    echo The LOVE runtime is not installed. Please install it from https://www.love2d.org.
    pause
    goto :end
)

"%programfiles%\LOVE\love.exe" --console .

:end
