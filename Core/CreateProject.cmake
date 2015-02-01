cmake_minimum_required( VERSION 2.8 )

MACRO(force_include_protected compileFlags includeProjs outString)
	string(CONCAT ${outString} ${${outString}} "\n/* Protected Headers */\n")
	if(NOT "${includeProjs}" STREQUAL "EMPTY")
		message("${PROJECT_NAME} 1,${includeProjs},")
		FOREACH(includeProj ${includeProjs})
			string(CONCAT ${outString} ${${outString}} "/* ${includeProj}: */ ")
			if(NOT ${${includeProj}_PROTECTED_INCLUDE_FILES} STREQUAL "")
				FOREACH(proFile ${${includeProj}_PROTECTED_INCLUDE_FILES})
					FILE(RELATIVE_PATH folder ${${includeProj}_SOURCE_DIR_CACHED} ${proFile})
					string(CONCAT ${outString} ${${outString}} "\#include \"${folder}\"\n")
					string(CONCAT ${compileFlags} ${${compileFlags}} " " "/FI\"${folder}\"")
				ENDFOREACH()
			else()
				string(CONCAT ${outString} ${${outString}} "/* Not found */\n")
			endif()
			#string(CONCAT ${outString} ${${outString}} "\n")
		ENDFOREACH()
	else()
	message("${PROJECT_NAME} 2")
		string(CONCAT ${outString} ${${outString}} "\n/* NO DEPENDENCY */")
	endif()
	#string(CONCAT ${outString} ${${outString}} "\n")
ENDMACRO()

MACRO(force_include_public_recursive compileFlags includeProj outString)
	include_directories(${${includeProj}_SOURCE_DIR_CACHED})
	
	string(CONCAT ${outString} ${${outString}} "/* ${includeProj}: */ ")
	if(NOT ${${includeProj}_PUBLIC_INCLUDE_FILES} STREQUAL "")
		foreach(pubFile ${${includeProj}_PUBLIC_INCLUDE_FILES})
			FILE(RELATIVE_PATH folder ${${includeProj}_SOURCE_DIR_CACHED} ${pubFile})
			string(CONCAT ${outString} ${${outString}} "\#include \"${folder}\"\n")
			string(CONCAT ${compileFlags} ${${compileFlags}} " " "/FI\"${folder}\"")
		endforeach()
	else()
		string(CONCAT ${outString} ${${outString}} "/* Not found */\n")
	endif()
	#string(CONCAT ${outString} ${${outString}} "\n")
	message("INCLUDES: ${${includeProj}_INCLUDES}")
	foreach(subIncludeProj ${${includeProj}_INCLUDES})
		force_include_public_recursive(${compileFlags} ${subIncludeProj} ${outString})
	endforeach()
ENDMACRO()

MACRO(force_include_public compileFlags includeProjs outString)
	string(CONCAT ${outString} ${${outString}} "\n/* Public Headers */\n")
	if(NOT "${includeProjs}" STREQUAL "EMPTY")
		foreach(includeProj ${includeProjs})
			force_include_public_recursive(${compileFlags} ${includeProj} ${outString})
		endforeach()
	else()
		string(CONCAT ${outString} ${${outString}} "\n/* NO DEPENDENCY */")
	endif()
	#string(CONCAT ${outString} ${${outString}} "\n")
ENDMACRO()

MACRO(force_include_recursive compileFlags includeProjs outString)
	message("called ${includeProjs}")
	force_include_protected(${compileFlags} "${includeProjs}" ${outString})
	force_include_public(${compileFlags} "${includeProjs}" ${outString})
ENDMACRO()

#
#
#
#
MACRO(create_project mode defines includes links)

	#----- Create Project -----
	get_folder_name(${CMAKE_CURRENT_SOURCE_DIR} PROJECT_NAME)
	if( ${PROJECT_NAME}_SRC )
		project( ${PROJECT_NAME} )
		set(${PROJECT_NAME}_INITIALIZED ON CACHE BOOL "")
		set(should_build ON)
	endif()
	
	#----- Unset Cached Arguments -----
	unset(${PROJECT_NAME}_INCLUDES CACHE)
	unset(${PROJECT_NAME}_MODE CACHE)
	set(${PROJECT_NAME}_MODE "${mode}" CACHE STRING "")
	set(${PROJECT_NAME}_INCLUDES "${includes}" CACHE STRING "")
	
	#----- SCAN SOURCE -----
	
	if( NOT ${PROJECT_NAME}_SRC )
		set(should_build OFF)
	else()
		unset(${PROJECT_NAME}_SRC)
	endif()
	
	file(GLOB_RECURSE ${PROJECT_NAME}_SRC ${CMAKE_CURRENT_SOURCE_DIR}/*.cxx ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp ${CMAKE_CURRENT_SOURCE_DIR}/*.c)
	set( ${PROJECT_NAME}_SRC "${${PROJECT_NAME}_SRC}" CACHE STRING "" )
	if( NOT ${PROJECT_NAME}_SRC STREQUAL "" )
		create_source_group("" "${CMAKE_CURRENT_SOURCE_DIR}/" ${${PROJECT_NAME}_SRC})
	endif()
	
	file(GLOB_RECURSE MY_CPP_SRC ${CMAKE_CURRENT_SOURCE_DIR}/*.cxx ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp)

	file(GLOB_RECURSE MY_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/*.h ${CMAKE_CURRENT_SOURCE_DIR}/*.hpp ${CMAKE_CURRENT_SOURCE_DIR}/*.inl ${CMAKE_CURRENT_SOURCE_DIR}/*.resx)
	if( NOT MY_HEADERS STREQUAL "" )
		create_source_group("" "${CMAKE_CURRENT_SOURCE_DIR}/" ${MY_HEADERS})
	endif()

	file(GLOB_RECURSE MY_RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/*.rc)
	if( NOT MY_RESOURCES STREQUAL "" )
		create_source_group("" "${CMAKE_CURRENT_SOURCE_DIR}/" ${MY_RESOURCES})
	endif()

	file(GLOB_RECURSE MY_MISC ${CMAKE_CURRENT_SOURCE_DIR}/*.l ${CMAKE_CURRENT_SOURCE_DIR}/*.y)
	if( NOT MY_MISC STREQUAL "" )
		create_source_group("" "${CMAKE_CURRENT_SOURCE_DIR}/" ${MY_MISC})
	endif()

	if( (${PROJECT_NAME}_SRC STREQUAL "") AND (MY_HEADERS STREQUAL "") )
		message(STATUS "Project is empty, a stub C header was created to set compiler language.")
		file(WRITE Stub.h "")
		LIST(APPEND MY_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/Stub.h)
		#message(FATAL_ERROR "Please insert at least one source file to use the CMakeLists.txt.")
	endif()

	#----- Scan Shader Files -----
	file(GLOB_RECURSE MY_SHADERS ${CMAKE_CURRENT_SOURCE_DIR}/*.vert	${CMAKE_CURRENT_SOURCE_DIR}/*.frag	${CMAKE_CURRENT_SOURCE_DIR}/*.glsl)
	if( NOT MY_SHADERS STREQUAL "" )
		create_source_group("" "${CMAKE_CURRENT_SOURCE_DIR}/" ${MY_SHADERS})
	endif()
	#----- Scan Precompiled Headers -----
	file(GLOB_RECURSE PRECOMPILED_HEADER ${CMAKE_CURRENT_SOURCE_DIR}/*.pch.h)

	#----- The follow code will only be executed if build project is being run the second time -----
	if( should_build )
		#----- Add Preprocessor Definitions -----
		foreach(currMacro ${defines})
			add_definitions("-D${currMacro}")
		endforeach()
		#----- Add Project Name -----
		add_definitions("-DPROJECT_NAME=\"${PROJECT_NAME}\"")
		add_definitions("-DPROJECT_ID=${PROJECT_COUNT}")
		
		#------ INCLUDE DIRS AND LIBS -----
		CreateVSProjectSettings() # From ProjectSettingsTemplate.cmake
		# Must include self
		include_directories( ${${PROJECT_NAME}_ALL_INCLUDE_DIRS} )
		# Process include list, an element could be a list of dirs or a target name
		set(includeDirs "")
		set(includeProjs "")
		FOREACH(currentName ${includes})
			if(EXISTS ${currentName})
				# if exists, it is a directory
				list(APPEND includeDirs ${currentName})
			else()
				# if doesn't exist, it is a target, we retrieve the include dirs by appending _INCLUDE_DIRS to its name
				#list(APPEND includeDirs ${${currentName}_PUBLIC_INCLUDE_DIRS})
				#list(APPEND includeDirs ${${currentName}_PROTECTED_INCLUDE_DIRS})
				#message("${currentName}_PRECOMPILED_INCLUDE_FILES: ${${currentName}_PRECOMPILED_INCLUDE_FILES}")
				
				# make the project completely public if it does not contain a .pch.h
				if( "${${currentName}_PRECOMPILED_INCLUDE_FILES}" STREQUAL "")
					list(APPEND includeDirs ${${currentName}_ALL_INCLUDE_DIRS} )
				endif()
				list(APPEND includeDirs ${${currentName}_SOURCE_DIR})
				list(APPEND includeProjs ${currentName})
			endif()
		ENDFOREACH(currentName ${includes})
		set(${PROJECT_NAME}_INCLUDES "${includeProjs}" CACHE STRING "")
		include_directories(${includeDirs})
		# Add links
		link_libraries(${links})
		
		#----- Mark PRECOMPILED HEADER -----
		if( NOT ${PRECOMPILED_HEADER} STREQUAL "")
			IF(MSVC)
				GET_FILENAME_COMPONENT(PRECOMPILED_HEADER_NAME ${PRECOMPILED_HEADER} NAME)
				GET_FILENAME_COMPONENT(PRECOMPILED_BASENAME ${PRECOMPILED_HEADER_NAME} NAME_WE)
				SET(PRECOMPILED_BINARY "${PRECOMPILED_BASENAME}-$(Configuration).pch")
				
				#list(APPEND USE_PRECOMPILED ${PRECOMPILED_HEADER_NAME})
				#list(APPEND FORCE_INCLUDE ${PRECOMPILED_HEADER_NAME})
				#list(APPEND PRECOMPILED_OUTPUT ${PRECOMPILED_BINARY})
			ENDIF(MSVC)
		endif()
		
		#------ Create Auto-Include Header ------
		if( NOT ${PRECOMPILED_HEADER} STREQUAL "")
			set(generatedHeader "${${PROJECT_NAME}_BINARY_DIR}/${PROJECT_NAME}.generated.pch.h")
			set(generatedSource "${${PROJECT_NAME}_BINARY_DIR}/${PROJECT_NAME}.generated.pch.cpp")
			set(generatedHeaderContent "")
			set(generatedSourceContent "")
			GET_FILENAME_COMPONENT(generatedHeaderName ${generatedHeader} NAME)
			set(generatedBinary "${PROJECT_NAME}-$(Configuration).generated.pch")
			set(usePrecompiled ${generatedHeaderName})
			set(forceInclude ${generatedHeaderName})
			set(precompiledOutputBinary ${generatedBinary})
			file(GLOB existingGeneratedHeader ${generatedHeader} )
			file(GLOB existingGeneratedSource ${generatedSource} )
			
			string(CONCAT generatedHeaderContent ${generatedHeaderContent} "/* GENERATED HEADER FILE. DO NOT EDIT. */\n\n")
			string(CONCAT generatedSourceContent ${generatedSourceContent} "/* GENERATED SOURCE FILE. DO NOT EDIT. */ \n\#include \"${generatedHeaderName}\"")
			
			# Add user-defined precompiled header to generated precompiled header
			string(CONCAT generatedHeaderContent ${generatedHeaderContent} "/* Private pre-compiled header */\n")
			if(NOT ${PRECOMPILED_HEADER_NAME} STREQUAL "")
				#message("project name: ${PROJECT_NAME},${PRECOMPILED_HEADER_NAME}\"")
				string(CONCAT generatedHeaderContent ${generatedHeaderContent} "\#include \"${PRECOMPILED_HEADER_NAME}\"\n")
			else()
				string(CONCAT generatedHeaderContent ${generatedHeaderContent} "/* ${PROJECT_NAME} does not contain pre-compiled header .pch.h */\n")
			endif()
			
			
			set(outCompileFlags "")
			if(NOT "${includes}" STREQUAL "")
				message(STATUS "Before: ${PROJECT_NAME}, includes ${includeProjs}")
				force_include_recursive(outCompileFlags "${includeProjs}" generatedHeaderContent)
				#message("After: ${generatedHeaderContent}")
			else()
				force_include_recursive(outCompileFlags "EMPTY" generatedHeaderContent)
			endif()
			
			if(NOT existingGeneratedHeader STREQUAL "" AND NOT existingGeneratedSource STREQUAL "")
				file(READ ${existingGeneratedHeader} existingGeneratedHeaderContent)
				if(NOT ${existingGeneratedHeaderContent} STREQUAL ${generatedHeaderContent})
					file(WRITE ${existingGeneratedHeader} ${generatedHeaderContent})
				endif()
				file(READ ${existingGeneratedSource} existingGeneratedSourceContent)
				if(NOT ${existingGeneratedSourceContent} STREQUAL ${generatedSourceContent})
					file(WRITE ${existingGeneratedSource} ${generatedSourceContent})
				endif()
			else()
				file(WRITE ${generatedHeader} ${generatedHeaderContent})
				file(WRITE ${generatedSource} ${generatedSourceContent})
			endif()

			SOURCE_GROUP("Generated" FILES ${generatedHeader})
			SOURCE_GROUP("Generated" FILES ${generatedSource})
			list(APPEND MY_HEADERS ${generatedHeader})
			list(APPEND ${PROJECT_NAME}_SRC ${generatedSource})

		SET_SOURCE_FILES_PROPERTIES(${${PROJECT_NAME}_SRC}
			PROPERTIES COMPILE_FLAGS
			"/Yu\"${usePrecompiled}\"
			/FI\"${forceInclude}\"
			/FI\"${${PROJECT_NAME}_PRIVATE_INCLUDE_FILES}\"
			/Fp\"${precompiledOutputBinary}\""
										   OBJECT_DEPENDS "${precompiledOutputBinary}")
		
		SET_SOURCE_FILES_PROPERTIES(${generatedSource}
			PROPERTIES COMPILE_FLAGS "/Yc\"${generatedHeaderName}\" /Fp\"${generatedBinary}\""
			OBJECT_OUTPUTS "${generatedBinary}")
		else( NOT ${PRECOMPILED_HEADER} STREQUAL "")
			file(WRITE "${${PROJECT_NAME}_BINARY_DIR}/${PROJECT_NAME}.generated.pub.h" )
		endif()
		
		
		# Force C++ if there's any cpp file
		if(MY_CPP_SRC)
			set_source_files_properties(${${PROJECT_NAME}_SRC} PROPERTIES LANGUAGE CXX)
		endif()
		
		#----- CREATE TARGET -----
		set(projectExtension "")
		if(${${PROJECT_NAME}_MODE} STREQUAL "STATIC")
			add_library (${PROJECT_NAME} STATIC ${${PROJECT_NAME}_SRC} ${MY_HEADERS} ${MY_MISC} ${MY_RESOURCES})
			add_definitions("-DIS_STATIC")
			add_definitions("-DSTATIC_ID=${PROJECT_COUNT}")
		elseif(${${PROJECT_NAME}_MODE} STREQUAL "DYNAMIC" OR ${${PROJECT_NAME}_MODE} STREQUAL "SHARED" )
			add_library (${PROJECT_NAME} SHARED ${${PROJECT_NAME}_SRC} ${MY_HEADERS} ${MY_MISC} ${MY_RESOURCES})
			add_definitions("-DIS_DYNAMIC")
			add_definitions("-DEXPORT_ID=${PROJECT_COUNT}")
			set(projectExtension "dll")
		elseif(${${PROJECT_NAME}_MODE} STREQUAL "CONSOLE")
			add_executable (${PROJECT_NAME} ${${PROJECT_NAME}_SRC} ${MY_HEADERS} ${MY_SHADERS} ${MY_RESOURCES} ${MY_MISC})
			set(projectExtension "exe")
		elseif(${${PROJECT_NAME}_MODE} STREQUAL "WIN32")
			add_executable (${PROJECT_NAME} WIN32 ${${PROJECT_NAME}_SRC} ${MY_HEADERS} ${MY_SHADERS} ${MY_RESOURCES} ${MY_MISC})
			set(projectExtension "exe")
		endif()
		
		get_target_property(FLAGS ${PROJECT_NAME} COMPILE_FLAGS)
		if(FLAGS STREQUAL "FLAGS-NOTFOUND")
			set(FLAGS "")
		endif()
		set_target_properties(${PROJECT_NAME} PROPERTIES COMPILE_FLAGS "${FLAGS} ${outCompileFlags}")
		
		#------ set target filter -----
		if( MSVC )
			# TODO: OPTIMIZE THIS
			string(REPLACE "/" ";" sourceDirList "${CMAKE_SOURCE_DIR}")
			string(REPLACE "/" ";" currSourceDirList "${CMAKE_CURRENT_SOURCE_DIR}")
			list(REVERSE currSourceDirList)
			list(REMOVE_AT currSourceDirList 0)
			list(REVERSE currSourceDirList)
			foreach(sourceDir ${sourceDirList})
				list(REMOVE_AT currSourceDirList 0)
			endforeach()
			list(LENGTH currSourceDirList listLength)
			string(REPLACE ";" "/" filterDir "${currSourceDirList}")
		
			SET_PROPERTY(GLOBAL PROPERTY USE_FOLDERS ON)
			SET_PROPERTY(TARGET ${PROJECT_NAME}		PROPERTY FOLDER ${filterDir})
		endif()
		
		#------ need linker language flag for header only static libraries -----
		SET_TARGET_PROPERTIES(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)
		
		#----- Custom PreBuild Target ------
		# Copy Binaries from Backup folder to Binaries folder


		# Flex and Bison
		if( USE_FLEX_AND_BISON )
			include( Optional/AddFlexBisonCustomTarget )
		endif()

		#set(arg1 "${CMAKE_CURRENT_SOURCE_DIR}")
		if(MSVC)
			if(NOT projectExtension STREQUAL "")
				string(REPLACE "/" "\\" arg1 "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${PROJECT_NAME}*.${projectExtension}")
				string(REPLACE "/" "\\" arg2 "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/../")
				add_custom_command(TARGET ${PROJECT_NAME}
				   POST_BUILD
				   COMMAND "COPY"
				   ARGS "1>Nul" "2>Nul" "${arg1}" "${arg2}" "/Y"
				   COMMENT "Copying resource files to the binary output directory...")
			endif()
		else()
			message("FIX COPY")
		endif()

		# Shader Copy
		if( NOT MY_SHADERS STREQUAL "" )
			add_custom_target(${PROJECT_NAME}PreBuild ALL
				COMMAND ${CMAKE_COMMAND}
				-DSrcDir=${CMAKE_CURRENT_SOURCE_DIR}
				-DDestDir=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/../
				-P ${CMAKE_MODULE_PATH}/Core/CopyResource.cmake
				COMMENT "Copying resource files to the binary output directory")
				
			add_dependencies(${PROJECT_NAME} ${PROJECT_NAME}PreBuild)
				
			if( MSVC )
				SET_PROPERTY(GLOBAL PROPERTY USE_FOLDERS ON)
				SET_PROPERTY(TARGET ${PROJECT_NAME}PreBuild		PROPERTY FOLDER CMakePredefinedTargets)
			endif()
		endif()
	endif()
ENDMACRO(create_project mode linLibraries)