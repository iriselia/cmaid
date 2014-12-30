del *.sln
del *.lnk

for /d %%a in ("PortableCMake*") do (rmdir /s /q %%~fa)
@rmdir /s /q CMake
@rmdir /s /q Purify
@rmdir /s /q Build

cd Binaries/
del *.exe
del *.ilk
del *.dll
@rmdir /s /q Libraries
@rmdir /s /q Shaders
cd ../

@rmdir /q Binaries