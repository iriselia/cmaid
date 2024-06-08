cmake_minimum_required( VERSION 2.8 )

# function(create_source_group sourceGroupName relativeSourcePath sourceFiles)
#
#
#
function(create_source_group sourceGroupName relativeSourcePath sourceFiles)
	FOREACH(currentSourceFile ${ARGN})
		FILE(RELATIVE_PATH folder ${relativeSourcePath} ${currentSourceFile})
		get_filename_component(filename ${folder} NAME)
		string(REPLACE ${filename} "" folder ${folder})
		if(NOT folder STREQUAL "")
			string(REGEX REPLACE "/+$" "" folderlast ${folder})
			string(REPLACE "/" "\\" folderlast ${folderlast})
			SOURCE_GROUP("${sourceGroupName}\\${folderlast}" FILES ${currentSourceFile})
		endif(NOT folder STREQUAL "")
	ENDFOREACH(currentSourceFile ${ARGN})

	FOREACH(currentSourceFile ${sourceFiles})
		FILE(RELATIVE_PATH folder ${relativeSourcePath} ${currentSourceFile})
		get_filename_component(filename ${folder} NAME)
		string(REPLACE ${filename} "" folder ${folder})
		if(NOT folder STREQUAL "")
			string(REGEX REPLACE "/+$" "" folderlast ${folder})
			string(REPLACE "/" "\\" folderlast ${folderlast})
			SOURCE_GROUP("${sourceGroupName}\\${folderlast}" FILES ${currentSourceFile})
		endif(NOT folder STREQUAL "")
	ENDFOREACH(currentSourceFile ${sourceFiles})
endfunction(create_source_group)

# function(get_folder_name OUT_NAME)
#
#
#
function(get_folder_name IN_DIR OUT_NAME)
string(REPLACE "/" ";" p2list "${IN_DIR}")
list(REVERSE p2list)
list(GET p2list 0 temp)
set(${OUT_NAME} "${temp}" PARENT_SCOPE)
endfunction(get_folder_name OUT_NAME)

#
#
#
#
function(REMOVE_FILE_EXTENSION inFiles outFiles)
	foreach(currFile ${inFiles})
		GET_FILENAME_COMPONENT(filePath ${currFile} PATH)
		GET_FILENAME_COMPONENT(fileNameWithoutExtension ${currFile} NAME_WE)
		set(filePathWithoutExtension "${filePath}/${fileNameWithoutExtension}")
		list(APPEND newFiles ${filePathWithoutExtension})
	endforeach()
	SET(${outFiles} "${newFiles}" PARENT_SCOPE)
endfunction()


