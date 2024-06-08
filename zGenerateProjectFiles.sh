#!/bin/sh
# Copyright 1998-2014 Epic Games, Inc. All Rights Reserved.

set -e

cd "`dirname "$0"`"
#if [ ! -f Engine/Build/BatchFiles/Mac/GenerateProjectFiles.sh ]; then
#	echo "GenerateProjectFiles ERROR: This script does not appear to be located \
#       in the root UE4 directory and must be run from there."
#  exit 1
#fi 
#
username="$(whoami)"

if [ "$(uname)" = "Darwin" ]; then
	github="/Applications/GitHub Desktop.app/Contents/Resources/git/bin/git"
	githubUser="/Users/$username/Applications/GitHub Desktop.app/Contents/Resources/git/bin/git"
	if [ -f "$github" ]; then		
		printf "\e[0;32mFound GitHub Desktop. \e[0m \n"
	elif [ -f "$githubUser" ]; then
		github="$githubUser"
		printf "\e[0;32mFound GitHub Desktop. \e[0m \n"
	else
		printf "\e[0;31mFatal Error: Could not find GitHub Desktop. \e[0m \n"
	fi
	cmake="/Applications/CMake.app/Contents/bin/cmake"
	if [ -f "$cmake" ]; then
		printf "\e[0;32mFound CMake \e[0m \n"
	else
		printf "\e[0;31m Fatal Error: Could not find CMake. \e[0m \n"
		exit
	fi

	purify="$(pwd)/Purify"


	if [ -d "$purify" ]; then
		echo "found purify"
	else
		echo $purify "purify not found"
		mkdir Purify
		chflags hidden Purify
		git clone "https://github.com/piaoasd123/Purify.git"
	fi

	
	
#	cd Engine/Build/BatchFiles/Mac
#	sh ./GenerateLLDBInit.sh
#	sh ./GenerateProjectFiles.sh $@
else
	echo "assume (GNU/)Linux"
#    # assume (GNU/)Linux
#	cd Engine/Build/BatchFiles/Linux
#	bash ./GenerateProjectFiles.sh $@
fi
