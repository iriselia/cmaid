#!/bin/sh
# Author: Frank Park

set -e

cd "`dirname "$0"`"
BASEDIR=$(dirname $0)
username="$(whoami)"
isNetworkAvailable=false
#!/bin/bash

#wget -q --tries=10 --timeout=20 --spider http://google.com
#echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

case "$(curl -s --max-time 2 -I http://google.com | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
  [23])	isNetworkAvailable=true;;
		#echo "HTTP connectivity is up";;
  5)	isNetworkAvailable=false;;
		#echo "The web proxy won't let us through";;
  *)	isNetworkAvailable=false;;
		#echo "The network is down or very slow";;
esac

if [ "${isNetworkAvailable}" = true ]; then
	isNetworkAvailable=true
	printf "Network Connection: \e[0;32mAll Green\e[0m \n"
else
	isNetworkAvailable=false
	printf "Network Connection: \e[0;33mOffline\e[0m \n"
	printf "Warning: \e[0;33mPurify will proceed with limited functionality\e[0m \n"
	sleep 2
fi

# if MacOS
if [ "$(uname)" = "Darwin" ]; then
	CMake="/Applications/CMake.app/Contents/bin/cmak1e"
	PortableCMake="$(pwd)/CMake/bin/cmake"
	GitHub="/Applications/GitHub Desktop.app/Contents/Resources/app/git/bin/git"
	GitHubUser="/Users/$username/Applications/GitHub Desktop.app/Contents/Resources/app/git/bin/git"
	isGitHubAvailable=false

	if [ -f "$GitHub" ]; then
		isGitHubAvailable=true
		printf "\e[0;32mFound GitHub Desktop. \e[0m \n"
	elif [ -f "$GitHubUser" ]; then
		GitHub ="$GitHubUser"
		isGitHubAvailable=true
		printf "\e[0;32mFound GitHub Desktop. \e[0m \n"
	else
		printf "\e[0;33mWarning: Could not find GitHub Desktop. Purify will not be able to automatically update build scripts. \e[0m \n"
	fi
	if [ -f "$CMake" ]; then
		printf "\e[0;32mFound CMake \e[0m \n"
	elif [ -f "$PortableCMake" ]; then
		CMake="$PortableCMake"
		printf "\e[0;32mFound Portable CMake.\e[0m \n"
	else
		if [ "${isGitHubAvailable}" = true -a "${isNetworkAvailable}" = true ]; then
			printf "\e[0;33mWarning: Could not find CMake, start downloading CMake. \e[0m \n"
			mkdir CMake
			chflags hidden CMake
			git clone "https://github.com/jpark730/PortableCMake-MacOSX.git" CMake
			chmod 777 "$PortableCMake"
			if [ -f "$PortableCMake" ]; then
				CMake="$PortableCMake"
				printf "\e[0;32mDownload Complete: Portable CMake for MacOS. \e[0m \n"
			else
				printf "\e[0;31mFatal Error: Could not download Portable CMake. \e[0m \n"
			fi
		else
			printf "\e[0;31mFatal Error: Unable to download CMake due to lack of GitHub Desktop or network connection.\e[0m \n"
			exit
		fi
	fi

	purify="$(pwd)/Purify/Loader.cmake"

	if [ -f "$purify" ]; then
		if [ "${isGitHubAvailable}" = true -a "${isNetworkAvailable}" = true ]; then
			printf "\e[0;32mPulling latest build script from GitHub.\e[0m \n"
			cd Purify
			git pull "https://github.com/jpark730/Purify.Core.git"
			cd ..
		else
			printf "\e[0;33mWarning: Skip updating Purify due to lack of network connection. \e[0m \n"
	
		fi
	else
		if [ "${isGitHubAvailable}" = true -a "${isNetworkAvailable}" = true ]; then
			printf "\e[0;32mDownloading Purify.\e[0m \n"
			printf "$(pwd)/Purify/Loader.cmake\n"
			mkdir Purify
			chflags hidden Purify
			git clone "https://github.com/jpark730/Purify.Core.git" Purify
			
			if [ -d "$purify" ]; then
				printf "\e[0;32mDownload complete: Purify.\e[0m \n"
			fi
		else
			printf "\e[0;31mFatal Error: Unable to download Purify due to lack of GitHub Desktop or network connection.\e[0m \n"
			exit
		fi
	fi


	currentFolder=${PWD##*/}
	cmakeListsDir="$(pwd)"
	#ln -s "$cmakeListsDir/Build/$currentFolder.xcodeproj" "${currentFolder}.xcodeproj"

	if [ -d "./Build" ]; then
		printf "\e[0;32mUpdating build at $(pwd)/Build.\e[0m \n"
	else
		printf "\e[0;32mGenerating build at $(pwd)/Build.\e[0m \n"
		mkdir Build
		#chflags hidden Build
	fi
	cd $(pwd)/Build
	#printf "\e[0;32m$(pwd)\e[0m \n"
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
