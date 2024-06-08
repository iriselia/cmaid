cmake_minimum_required( VERSION 3.0 )
cmake_policy( SET CMP0054 NEW )

macro( cmaid_build )

	set(options) #set(options OPTIONAL FAST)
	set(oneValueArgs) #set(oneValueArgs DESTINATION RENAME)
	set(multiValueArgs DEFINE )
	cmake_parse_arguments(MY_INSTALL "${options}" "${oneValueArgs}"
	"${multiValueArgs}" ${ARGN} )

	# Add solution-wide commandline definitions
	# For example: set( global_define _CRT_SECURE_NO_WARNINGS ) will
	# add _CRT_SECURE_NO_WARNINGS macro to all c++ projects in the current solution.
	foreach(define ${global_define})
		string(SUBSTRING ${define} 0 1 firstLetter)
		if(firstLetter STREQUAL "/")
			add_definitions(${define})
		else()
			add_definitions("-D${define}")
		endif()
	endforeach()

	# First tell CMake to create a solution based on our directory name.
	# This nullifies whatever project(...) command is in the root CMakeLists.txt.
	get_folder_name(${CMAKE_CURRENT_SOURCE_DIR} SOLUTION_NAME)
	project( ${SOLUTION_NAME} )

	#find all CMakeLists.txt files in the project folder recursively.
	file(GLOB_RECURSE normalPriorityProjects ${CMAKE_SOURCE_DIR}/CMakeLists.txt)
	list(REMOVE_ITEM normalPriorityProjects ${CMAKE_SOURCE_DIR}/CMakeLists.txt)
	list(FILTER normalPriorityProjects EXCLUDE REGEX "^${CMAKE_MODULE_PATH}") 

	# Find out if there are high priority projects
	# High priority projects are meant to facilitate custom source code generation steps
	# such as compiling .proto files for protobuf
	# There is currently no explicit way of marking a project as high priority, because
	# this feature is rarely used.
	foreach(file ${normalPriorityProjects})
		#get the directory of the cmakelists
		get_filename_component(fileDir ${file} DIRECTORY)
		get_folder_name(${fileDir} projName)
		list(APPEND PROJECT_NAMES ${projName})
		#assume it's protobuf if descriptor.pb.cc is present
		file(GLOB_RECURSE protobufSource ${fileDir}/descriptor.pb.cc)
		if(protobufSource)
			list(REMOVE_ITEM normalPriorityProjects ${fileDir}/CMakeLists.txt)
			list(APPEND highPriorityProjects ${fileDir}/CMakeLists.txt)
		endif()
	endforeach()

	#Pre-Configure cache include dirs prior to adding subdirectories
	foreach(file ${normalPriorityProjects})
		#get the directory of the cmakelists
		get_filename_component(fileDir ${file} DIRECTORY)
		
		# Currently disabled:
		# Source file update and generation (flex and bison, github)
		# Flex and Bison
		#if( USE_FLEX_AND_BISON )
		#	include( Optional/PrecompileFlexBison )
		#endif()

		get_folder_name(${fileDir} PROJECT_NAME)
		set(${PROJECT_NAME}_SOURCE_DIR_CACHED "${fileDir}" CACHE STRING "" FORCE)

		# Scan for header files recursively. This also includes generated headers such as
		# protobuf headers
		file(RELATIVE_PATH relPath ${CMAKE_SOURCE_DIR} ${fileDir})
		set(binariesPath "${CMAKE_BINARY_DIR}/${relPath}")

		file(GLOB_RECURSE projectHeaders ${fileDir}/*.h ${fileDir}/*.hpp ${fileDir}/*.inl ${fileDir}/*.ixx ${fileDir}/*.rc ${fileDir}/*.r ${fileDir}/*.resx ${binariesPath}/*.pb.h)
		if( NOT projectHeaders STREQUAL "" )
			# Source file folders/filters for IDEs
			create_source_group("" "${fileDir}/" ${projectHeaders})
			
			set(projectIncludeDirs "")

			# Optional Feature: Recursively compile a list of include directories
			#foreach (headerFile ${projectHeaders})
			#	get_filename_component(directory ${headerFile} PATH)
			#	FILE(RELATIVE_PATH newdir ${CMAKE_CURRENT_BINARY_DIR} ${directory})
			#	#list (APPEND projectIncludeDirs ${directory})
			#endforeach()
			#list(REMOVE_DUPLICATES projectIncludeDirs)

			#include current include dirs and cache the content
			set(${PROJECT_NAME}_INCLUDE_DIRS "${projectIncludeDirs}" CACHE STRING "" FORCE)
			
	#------------------- REFACTOR PROGRESS --------------------
			# Project Dir only Include
			#set(${PROJECT_NAME}_ALL_INCLUDE_DIRS "${${PROJECT_NAME}_SOURCE_DIR_CACHED}" CACHE STRING "")

		endif()
		
		#----- pre-compiled Header -----
		file(GLOB_RECURSE projectHeaders ${fileDir}/*.pch.h)
		if( NOT projectHeaders STREQUAL "" )
			create_source_group("" "${fileDir}/" ${projectHeaders})
			#remove duplicates and parse directories
			set(projectIncludeDirs "")
			set(_headerFile "")
			foreach (_headerFile ${projectHeaders})
				get_filename_component(_dir ${_headerFile} PATH)
				file(RELATIVE_PATH newdir ${CMAKE_CURRENT_BINARY_DIR} ${_dir})
				list (APPEND projectIncludeDirs ${_dir})
			endforeach()
			list(REMOVE_DUPLICATES projectIncludeDirs)
			#include current include dirs and cache the content
			set(${PROJECT_NAME}_PRECOMPILED_INCLUDE_DIRS "${projectIncludeDirs}" CACHE STRING "" FORCE)
			set(${PROJECT_NAME}_PRECOMPILED_INCLUDE_FILES "${projectHeaders}" CACHE STRING "" FORCE)
		endif()

#					#----- Private Headers -----
#					file(GLOB_RECURSE projectHeaders ${fileDir}/*.pri.h ${fileDir}/*.pri.hpp ${fileDir}/*.pri.inl)
#					unset(${PROJECT_NAME}_PRIVATE_INCLUDE_DIRS CACHE)
#					unset(${PROJECT_NAME}_PRIVATE_INCLUDE_FILES CACHE)
#					if( NOT projectHeaders STREQUAL "" )
#						create_source_group("" "${fileDir}/" ${projectHeaders})
#						#remove duplicates and parse directories
#						set(projectIncludeDirs "")
#						set(_headerFile "")
#						foreach (_headerFile ${projectHeaders})
#							get_filename_component(_dir ${_headerFile} PATH)
#							FILE(RELATIVE_PATH newdir ${CMAKE_CURRENT_BINARY_DIR} ${_dir})
#							list (APPEND projectIncludeDirs ${_dir})
#						endforeach()
#						list(REMOVE_DUPLICATES projectIncludeDirs)
#						#include current include dirs and cache the content
#						set(${PROJECT_NAME}_PRIVATE_INCLUDE_DIRS "${projectIncludeDirs}" CACHE STRING "")
#						set(${PROJECT_NAME}_PRIVATE_INCLUDE_FILES "${projectHeaders}" CACHE STRING "")
#					endif()
#					
#					#----- Protected Headers -----
#					file(GLOB_RECURSE projectHeaders ${fileDir}/*.pro.h ${fileDir}/*.pro.hpp ${fileDir}/*.pro.inl)
#					unset(${PROJECT_NAME}_PROTECTED_INCLUDE_DIRS CACHE)
#					unset(${PROJECT_NAME}_PROTECTED_INCLUDE_FILES CACHE)
#					if( NOT projectHeaders STREQUAL "" )
#						create_source_group("" "${fileDir}/" ${projectHeaders})
#						#remove duplicates and parse directories
#						set(projectIncludeDirs "")
#						set(_headerFile "")
#						foreach (_headerFile ${projectHeaders})
#							get_filename_component(_dir ${_headerFile} PATH)
#							FILE(RELATIVE_PATH newdir ${CMAKE_CURRENT_BINARY_DIR} ${_dir})
#							list (APPEND projectIncludeDirs ${_dir})
#						endforeach()
#						list(REMOVE_DUPLICATES projectIncludeDirs)
#						#include current include dirs and cache the content
#						set(${PROJECT_NAME}_PROTECTED_INCLUDE_DIRS "${projectIncludeDirs}" CACHE STRING "")
#						set(${PROJECT_NAME}_PROTECTED_INCLUDE_FILES "${projectHeaders}" CACHE STRING "")
#			
#					endif()
#					
#					#----- Public Headers -----
#					file(GLOB_RECURSE projectHeaders ${fileDir}/*.pub.h ${fileDir}/*.pub.hpp ${fileDir}/*.pub.inl)
#					if( NOT projectHeaders STREQUAL "" )
#						create_source_group("" "${fileDir}/" ${projectHeaders})
#						#remove duplicates and parse directories
#						set(projectIncludeDirs "")
#						set(_headerFile "")
#						foreach (_headerFile ${projectHeaders})
#							get_filename_component(_dir ${_headerFile} PATH)
#							FILE(RELATIVE_PATH newdir ${CMAKE_CURRENT_BINARY_DIR} ${_dir})
#							list (APPEND projectIncludeDirs ${_dir})
#						endforeach()
#						list(REMOVE_DUPLICATES projectIncludeDirs)
#						#include current include dirs and cache the content
#						unset(${PROJECT_NAME}_PUBLIC_INCLUDE_DIRS CACHE)
#						set(${PROJECT_NAME}_PUBLIC_INCLUDE_DIRS "${projectIncludeDirs}" CACHE STRING "")
#						unset(${PROJECT_NAME}_PUBLIC_INCLUDE_FILES CACHE)
#						set(${PROJECT_NAME}_PUBLIC_INCLUDE_FILES "${projectHeaders}" CACHE STRING "")
#					endif()
	endforeach(file ${normalPriorityProjects})

	set(PROJECT_COUNT 0)

	# All CMakeLists.txt files are processed in 2 stages. First run a preprocess pass
	# to resolve project and include/link dependencies, then add a project in the second pass.
	AddProjectPrepass(highPriorityProjects)
	AddProjectPrepass(normalPriorityProjects)
	AddProject(highPriorityProjects)
	AddProject(normalPriorityProjects)
	
#	add_custom_target(
#		UPDATE_RESOURCES
#		DEPENDS always_rebuild
#	)
#
#	add_custom_command(
#    	OUTPUT always_rebuild
#    	COMMAND ${CMAKE_COMMAND} -E echo
#    )
#	
#	foreach(file ${highPriorityProjects})
#		get_filename_component(fileDir ${file} DIRECTORY)
#		get_folder_name(${fileDir} PROJECT_NAME)
#		list(APPEND PROJECT_DIRS ${fileDir})
#	endforeach()
#
#	foreach(file ${normalPriorityProjects})
#		get_filename_component(fileDir ${file} DIRECTORY)
#		get_folder_name(${fileDir} PROJECT_NAME)
#		list(APPEND PROJECT_DIRS ${fileDir})
#	endforeach()
#
#	add_custom_command(
#		TARGET UPDATE_RESOURCES
#		PRE_BUILD
#		COMMAND ${CMAKE_COMMAND}
#		-DSrcDirs="${PROJECT_DIRS}"
#		-DDestDir=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/../
#		-P ${CMAKE_MODULE_PATH}/CopyResource.cmake
#		#COMMENT "Copying resource files to the binary output directory"
#		)
#
#	set_property(GLOBAL PROPERTY USE_FOLDERS ON)
#	if( MSVC )
#		set_property(TARGET UPDATE_RESOURCE		PROPERTY FOLDER CMakePredefinedTargets)
#	else()
#		set_property(TARGET UPDATE_RESOURCE		PROPERTY FOLDER ZERO_CHECK/CMakePredefinedTargets)				
#	endif()
endmacro()

macro(AddProjectPrepass projects)
	foreach(file ${${projects}})
		get_filename_component(fileDir ${file} DIRECTORY)
		get_folder_name(${fileDir} PROJECT_NAME)
		string(LENGTH ${CMAKE_SOURCE_DIR} firDirStrSize)
		string(SUBSTRING ${fileDir} ${firDirStrSize} -1 protoFileDirSubStr)

		set(${PROJECT_NAME}_SOURCE_DIR "${fileDir}")
		set(PROJECT_SOURCE_DIR "${fileDir}")
		set(${PROJECT_NAME}_BINARY_DIR "${CMAKE_BINARY_DIR}/${protoFileDirSubStr}")
		set(PROJECT_BINARY_DIR "${CMAKE_BINARY_DIR}/${protoFileDirSubStr}")

		# Run create_project etc without actually creating projects.
		# This way we can process project information for deferred resolution.
		include(${file})
		set(${PROJECT_NAME}_INITIALIZED ON)
	endforeach(file ${${projects}})
endmacro()

macro(AddProject projects)
	foreach(file ${${projects}})
		get_filename_component(fileDir ${file} DIRECTORY)
		get_folder_name(${fileDir} PROJECT_NAME)

		string(LENGTH ${CMAKE_SOURCE_DIR} firDirStrSize)
		string(SUBSTRING ${fileDir} ${firDirStrSize} -1 protoFileDirSubStr)

		# This step actually creates the projects we need. We must make sure all projects have been
		# preprocessed through AddProjectPrepass.
		set(PROJECT_SOURCE_DIR "${fileDir}")
		set(PROJECT_BINARY_DIR "${CMAKE_BINARY_DIR}/${protoFileDirSubStr}")
		add_subdirectory( ${fileDir} )

		# Add symbol export file for each project
		if( ("${${PROJECT_NAME}_MODE}" STREQUAL "CONSOLE") OR ("${${PROJECT_NAME}_MODE}" STREQUAL "WIN32") )
		else()
			CONFIGURE_FILE(${CMAKE_MODULE_PATH}/scripts/Misc/SymbolExportAPITemplate.template ${${PROJECT_NAME}_BINARY_DIR}/${PROJECT_NAME}_API.generated.h @ONLY)
			set(${PROJECT_NAME}_EXPORT_API "${PROJECT_NAME}_ExportAPI.generated.h" CACHE STRING "")
		endif()

		# Print out the a formatted string to help display the solution structure
		math(EXPR PROJECT_COUNT "${PROJECT_COUNT}+1")
		file(RELATIVE_PATH folder ${CMAKE_SOURCE_DIR} ${fileDir})
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

	endforeach(file ${${projects}})
endmacro()