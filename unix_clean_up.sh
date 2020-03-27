#!/bin/sh
cd "`dirname "$0"`"

rm -rf *.sln
rm -rf *.xcodeproj
rm -rf *.lnk

#for /d %%a in ("PortableCMake*") do (rmdir /s /q %%~fa)
#rm -rf CMake
#rm -rf Purify
rm -rf Build

if [ -d "$(pwd)/Binaries" ]; then
	cd Binaries/
	rm -rf *.a
	rm -rf *.dylib
	rm -rf Backup
	rm -rf Libraries
	rm -rf Shaders
	cd ../
fi

#rm -d Binaries > /dev/null 2>&1