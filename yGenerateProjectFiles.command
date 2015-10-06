# Simple wrapper around GenerateProjectFiles.sh using the
# .command extension enables it to be run from the OSX Finder.

currentDir="`dirname \"$0\"`"
cd ${currentDir}
currentFolder=${PWD##*/}

sh ${currentDir}/zGenerateProjectFiles.sh

osDir=:Macintosh\ HD${currentDir//[\/]/\:}

if ! [ -f "${currentFolder}.xcodeproj" ]; then
	osascript -e "tell application \"Finder\" to make alias to \"${osDir}:Build:${currentFolder}.xcodeproj\" at \"${osDir}\""
fi
