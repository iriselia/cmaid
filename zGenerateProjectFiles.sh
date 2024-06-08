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
if [ "$(uname)" = "Darwin" ]; then
	github="/Applications/GitHub.app/Contents/MacOS/github"
	if [ -f "$github" ]; then
		echo "found github"
	else
		echo "github not found"
	fi
	cmake="/Applications/CMake.app/Contents/bin/cmake"
	if [ -f "$cmake" ]; then
		echo "found cmake"
	else
		echo "cmake not found"
	fi

	purify="$(pwd)/Purify"


	if [ -d "$purify" ]; then
		echo "found purify"
	else
		echo $purify "purify not found"
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
