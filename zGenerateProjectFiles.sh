#!/bin/sh
# Author: Frank Park

set -e

cd "`dirname "$0"`"
BASEDIR=$(dirname $0)
username="$(whoami)"

# if MacOS
if [ "$(uname)" = "Darwin" ]; then
	CMake="/Applications/CMake.app/Contents/bin/cmak1e"
	PortableCMake="${BASEDIR}/CMake/bin/cmake"
	GitHub="/Applications/GitHub Desktop.app/Contents/Resources/git/bin/git"
	GitHubUser="/Users/$username/Applications/GitHub Desktop.app/Contents/Resources/git/bin/git"


	echo "$PortableCMake"

	if [ -f "$GitHub" ]; then		
		printf "\e[0;32mFound GitHub Desktop. \e[0m \n"
	elif [ -f "$GitHubUser" ]; then
		GitHub ="$GitHubUser"
		printf "\e[0;32mFound GitHub Desktop. \e[0m \n"
	else
		printf "\e[0;31mFatal Error: Could not find GitHub Desktop. \e[0m \n"
	fi
	if [ -f "$CMake" ]; then
		printf "\e[0;32mFound CMake \e[0m \n"
	elif [ -f "$PortableCMake" ]; then
		CMake="$PortableCMake"
		printf "\e[0;32mFound Portable CMake. \e[0m \n"
	else
		printf "\e[0;33mWarning: Could not find CMake, start downloading CMake. \e[0m \n"
		mkdir CMake
		chflags hidden CMake
		git clone "https://github.com/piaoasd123/PortableCMake-MacOSX.git" CMake
		chmod 777 "$PortableCMake"
		if [ -f "$PortableCMake" ]; then
			CMake="$PortableCMake"
			printf "\e[0;32mDownload Complete: Portable CMake for MacOS. \e[0m \n"
		else
			printf "\e[0;31mFatal Error: Could not download Portable CMake. \e[0m \n"

		fi
	fi

	purify="$(pwd)/Purify"

	if [ -d "$purify" ]; then
		printf "\e[0;32mPulling latest build script from GitHub.\e[0m \n"
		cd Purify
		git pull "https://github.com/piaoasd123/Purify.git"
		cd ..
	else
		printf "\e[0;32mDownloading Purify.\e[0m \n"
		mkdir Purify
		chflags hidden Purify
		git clone "https://github.com/piaoasd123/Purify.git"
		
		if [ -d "$purify" ]; then
			printf "\e[0;32mDownload complete: Purify.\e[0m \n"
		fi
	fi


	currentFolder=${PWD##*/}
	cmakeListsDir="$(pwd)"
	#ln -s "$cmakeListsDir/Build/$currentFolder.xcodeproj" "${currentFolder}.xcodeproj"

	if [ -d "./Build" ]; then
		printf "\e[0;32mUpdating build.\e[0m \n"
	else
		printf "\e[0;32mGenerating build.\e[0m \n"
		mkdir Build
		#chflags hidden Build
	fi
	cd $(pwd)/Build
	printf "\e[0;32m$(pwd)\e[0m \n"
	"$CMake" -G Xcode "$cmakeListsDir"
	"$CMake" -G Xcode "$cmakeListsDir"
	cd ..

	
	exit
else
	echo "assume (GNU/)Linux"
#    # assume (GNU/)Linux
#	cd Engine/Build/BatchFiles/Linux
#	bash ./GenerateProjectFiles.sh $@
fi
