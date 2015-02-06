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
		cd Purify
		git pull "https://github.com/piaoasd123/Purify.git"
		cd ..
	else
		echo $purify "purify not found"
		mkdir Purify
		chflags hidden Purify
		git clone "https://github.com/piaoasd123/Purify.git"
	fi

	cmakeListsDir="$(pwd)"
	if [ -d "./Build" ]; then
		echo "found build"
	else
		echo "building..."
		mkdir Build
		#chflags hidden Build
	fi
	cd $(pwd)/Build
	"$cmake" -G Xcode "$cmakeListsDir"
	"$cmake" -G Xcode "$cmakeListsDir"
	cd ..
#	cd Engine/Build/BatchFiles/Mac
#	sh ./GenerateLLDBInit.sh
#	sh ./GenerateProjectFiles.sh $@
else
	echo "assume (GNU/)Linux"
#    # assume (GNU/)Linux
#	cd Engine/Build/BatchFiles/Linux
#	bash ./GenerateProjectFiles.sh $@
fi
