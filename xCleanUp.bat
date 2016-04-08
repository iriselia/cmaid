rem ## back up CWD
pushd "%~dp0"
cd "%~dp0"

del *.sln
del *.lnk
for /d %%a in ("PortableCMake*") do (rmdir /s /q %%~fa)
#@rmdir /s /q CMake
#@rmdir /s /q Purify
@rmdir /s /q Build
cd Binaries/
del *.exe
del *.dll
@rmdir /s /q Backup
@rmdir /s /q Libraries
@rmdir /s /q Shaders
cd ../
@rmdir /q Binaries