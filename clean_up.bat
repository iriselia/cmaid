@echo off
rem ## back up CWD
pushd "%~dp0/../"

del *.sln >nul 2>&1
del *.lnk >nul 2>&1
for /d %%a in ("PortableCMake*") do (rmdir /s /q %%~fa)
rem @rmdir /s /q CMake
@rmdir /s /q Build >nul 2>&1
cd Binaries/
del *.exe >nul 2>&1
del *.dll >nul 2>&1
@rmdir /s /q Backup >nul 2>&1
@rmdir /s /q Libraries >nul 2>&1
@rmdir /s /q Shaders >nul 2>&1
cd ../
@rmdir /q Binaries >nul 2>&1

popd