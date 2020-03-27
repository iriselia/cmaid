currentDir="`dirname \"$0\"`"
cd ${currentDir}
currentFolder=${PWD##*/}

sh ${currentDir}/PushChanges.sh