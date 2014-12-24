cmake_minimum_required( VERSION 2.8 )

FOREACH(currDefine ${GLOBAL_DEFINE})
	add_definitions(${currDefine})
ENDFOREACH()

#create solution
get_folder_name(${CMAKE_CURRENT_SOURCE_DIR} SOLUTION_NAME)
project( ${SOLUTION_NAME} )
#[[message("
PROJECT_SOURCE_DIR ${PROJECT_SOURCE_DIR}
PROJECT-NAME_SOURCE_DIR ${${SOLUTION_NAME}_SOURCE_DIR}
PROJECT_BINARY_DIR ${PROJECT_BINARY_DIR}
PROJECT-NAME_BINARY_DIR ${${SOLUTION_NAME}_BINARY_DIR}
")
]]#

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
	#----- All Headers -----
	file(GLOB_RECURSE MY_HEADERS ${fileDir}/*.h ${fileDir}/*.hpp ${fileDir}/*.inl)
	if( NOT MY_HEADERS STREQUAL "" )
		create_source_group("" "${fileDir}/" ${MY_HEADERS})
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
		unset(${PROJECT_NAME}_ALL_INCLUDE_DIRS CACHE)
		set(${PROJECT_NAME}_ALL_INCLUDE_DIRS "${CURRENT_INCLUDE_DIRS}" CACHE STRING "")
	endif()
	
	#----- Private Headers -----
	file(GLOB_RECURSE MY_HEADERS ${fileDir}/*.pri.h ${fileDir}/*.pri.hpp ${fileDir}/*.pri.inl)
	if( NOT MY_HEADERS STREQUAL "" )
		create_source_group("" "${fileDir}/" ${MY_HEADERS})
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
		unset(${PROJECT_NAME}_PRIVATE_INCLUDE_DIRS CACHE)
		set(${PROJECT_NAME}_PRIVATE_INCLUDE_DIRS "${CURRENT_INCLUDE_DIRS}" CACHE STRING "")
		message("${PROJECT_NAME} Private: ${${PROJECT_NAME}_PRIVATE_INCLUDE_DIRS}")
	endif()
	
	#----- Protected Headers -----
	file(GLOB_RECURSE MY_HEADERS ${fileDir}/*.pro.h ${fileDir}/*.pro.hpp ${fileDir}/*.pro.inl)
	if( NOT MY_HEADERS STREQUAL "" )
		create_source_group("" "${fileDir}/" ${MY_HEADERS})
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
		unset(${PROJECT_NAME}_PROTECTED_INCLUDE_DIRS CACHE)
		set(${PROJECT_NAME}_PROTECTED_INCLUDE_DIRS "${CURRENT_INCLUDE_DIRS}" CACHE STRING "")
		message("${PROJECT_NAME} Protected: ${${PROJECT_NAME}_PROTECTED_INCLUDE_DIRS}")

	endif()
	
	#----- Public Headers -----
	file(GLOB_RECURSE MY_HEADERS ${fileDir}/*.pub.h ${fileDir}/*.pub.hpp ${fileDir}/*.pub.inl)
	if( NOT MY_HEADERS STREQUAL "" )
		create_source_group("" "${fileDir}/" ${MY_HEADERS})
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
		unset(${PROJECT_NAME}_PUBLIC_INCLUDE_DIRS CACHE)
		set(${PROJECT_NAME}_PUBLIC_INCLUDE_DIRS "${CURRENT_INCLUDE_DIRS}" CACHE STRING "")
		message("${PROJECT_NAME} Public: ${${PROJECT_NAME}_PUBLIC_INCLUDE_DIRS}")
	endif()
ENDFOREACH(curFile ${allProjects})

SET(PROJECT_COUNT 0)

#Include sub directories now
FOREACH(curFile ${allProjects})
	get_filename_component(fileDir ${curFile} DIRECTORY)
	get_folder_name(${fileDir} PROJECT_NAME)
	
	# unset all project-specific cache
	#message("unset ${fileDir} ${PROJECT_NAME}_SRC")
	unset(${PROJECT_NAME}_SRC CACHE)
	unset(${PROJECT_NAME}_INCLUDE_PROJECTS CACHE)
	#unset(${PROJECT_NAME}_SRC CACHE)
	#unset(${PROJECT_NAME}_SRC CACHE)

	add_subdirectory( ${fileDir} )
	MATH(EXPR PROJECT_COUNT "${PROJECT_COUNT}+1")
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

#----- Resolve public/protected/private include directories recursively -----
FOREACH(curFile ${allProjects})
	#get the directory of the cmakelists
	get_filename_component(fileDir ${curFile} DIRECTORY)
	
	#create_project_helper(${fileDir})
	
	#parse the directory name for caching project specific include dirs
	get_folder_name(${fileDir} PROJECT_NAME)
	#message("THIS GUY INCLUDES:${${PROJECT_NAME}_INCLUDE_PROJECTS}")
	if(${PROJECT_NAME}_INCLUDE_PROJECTS)
		#message("DOIN IT")
		foreach (includeProj ${${PROJECT_NAME}_INCLUDE_PROJECTS})
			#message("${PROJECT_NAME} included recursively: ${${includeProj}_PUBLIC_INCLUDE_DIRS}")
			#target_include_directories(PROJECT_NAME ${${includeProj}_PUBLIC_INCLUDE_DIRS})
			#add_executable(${PROJECT_NAME} IMPORTED)
			#set_property(TARGET generator PROPERTY IMPORTED_LOCATION "/path/to/build/tree/generator")
		endforeach()
	endif()
	#----- All Headers ----- 
	file(GLOB_RECURSE MY_HEADERS ${fileDir}/*.h ${fileDir}/*.hpp ${fileDir}/*.inl)
	if( NOT MY_HEADERS STREQUAL "" )
		create_source_group("" "${fileDir}/" ${MY_HEADERS})
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
		unset(${PROJECT_NAME}_ALL_INCLUDE_DIRS CACHE)
		set(${PROJECT_NAME}_ALL_INCLUDE_DIRS "${CURRENT_INCLUDE_DIRS}" CACHE STRING "")
	endif()
ENDFOREACH(curFile ${allProjects})
