cmake_minimum_required( VERSION 2.8 )

#create solution
get_folder_name(${CMAKE_CURRENT_SOURCE_DIR} SOLUTION_NAME)
project( ${SOLUTION_NAME} )

#find all cmakelists files
file(GLOB_RECURSE allProjects ${CMAKE_SOURCE_DIR}/CMakeLists.txt)
list(REMOVE_ITEM allProjects ${CMAKE_SOURCE_DIR}/CMakeLists.txt)
	
#Pre-Configure cache include dirs prior to adding subdirectories
FOREACH(curFile ${allProjects})
	#get the directory of the cmakelists
	get_filename_component(fileDir ${curFile} DIRECTORY)
		
	# Pre-Pre-Configure Processing
	# Source file update and generation (flex and bison, github)
	# Flex and Bison
	if( USE_FLEX_AND_BISON )
		include( Optional/PrecompileFlexBison )
	endif()
	
	#parse the directory name for caching project specific include dirs
	get_folder_name(${fileDir} PROJECT_NAME)
	#scan all headers
	file(GLOB_RECURSE MY_HEADERS ${fileDir}/*.h ${fileDir}/*.hpp ${fileDir}/*.inl)
	if( NOT MY_HEADERS STREQUAL "" )
		create_source_group("" "${fileDir}/" ${MY_HEADERS})
	endif()
		
	#remove duplicates and parse directories
	set(CURRENT_INCLUDE_DIRS "")
	set(_headerFile "")
	foreach (_headerFile ${MY_HEADERS})
		get_filename_component(_dir ${_headerFile} PATH)
		FILE(RELATIVE_PATH newdir ${CMAKE_CURRENT_BINARY_DIR} ${_dir})
		list (APPEND CURRENT_INCLUDE_DIRS ${_dir})
	endforeach()
	list(REMOVE_DUPLICATES CURRENT_INCLUDE_DIRS)
	#include current include dirs and cache the content
	unset(${PROJECT_NAME}_INCLUDE_DIRS CACHE)
	set(${PROJECT_NAME}_INCLUDE_DIRS "${CURRENT_INCLUDE_DIRS}" CACHE STRING "")
		
ENDFOREACH(curFile ${allProjects})

#Include sub directories now
FOREACH(curFile ${allProjects})
	get_filename_component(fileDir ${curFile} DIRECTORY)
	add_subdirectory( ${fileDir} )
	FILE(RELATIVE_PATH folder ${CMAKE_SOURCE_DIR} ${fileDir})
	set(newFolder folder)
	string(REPLACE "/" ";" folderList "${folder}")
	string(REPLACE "/" ";" newFolderList "${newFolder}")
	list(REVERSE folderList)
	list(GET folderList 0 pName) 
	list(REMOVE_AT folderList 0)
	list(REVERSE folderList)
	string(REPLACE ";" "/" newFolder "${folderList}")
	
	if(NOT (PreviousFolder STREQUAL newFolder))
		if(newFolder STREQUAL "")
		message("Root/")
		else()
		message("${newFolder}/")
		endif()
	endif()
	message(STATUS " *   ${pName}")
	set( PreviousFolder ${newFolder} )
ENDFOREACH(curFile ${allProjects})