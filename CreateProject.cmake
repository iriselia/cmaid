cmake_minimum_required( VERSION 2.8 )

MACRO(recursive_include out_dir projName)
	list(APPEND out_dir ${${currentName}_PUBLIC_INCLUDE_DIRS})
ENDMACRO()

#
#
#
#
MACRO(create_project mode in_macros includes linkLibs)

	#----- Create Project -----
	get_folder_name(${CMAKE_CURRENT_SOURCE_DIR} PROJECT_NAME)
	project( ${PROJECT_NAME} )
	
	#----- Unset Cached Arguments -----
	unset(${PROJECT_NAME}_INCLUDE_PROJECTS CACHE)
	unset(${PROJECT_NAME}_MODE CACHE)
	set(${PROJECT_NAME}_MODE "${mode}" CACHE STRING "")
	#----- SCAN SOURCE -----
	if( NOT ${PROJECT_NAME}_SRC )
		file(GLOB_RECURSE ${PROJECT_NAME}_SRC ${CMAKE_CURRENT_SOURCE_DIR}/*.cxx ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp ${CMAKE_CURRENT_SOURCE_DIR}/*.c)
		set( ${PROJECT_NAME}_SRC "${${PROJECT_NAME}_SRC}" CACHE STRING "" )
		if( ${PROJECT_NAME}_SRC )
			create_source_group("" "${CMAKE_CURRENT_SOURCE_DIR}/" ${${PROJECT_NAME}_SRC})
		endif()
		set(build_flag OFF)
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
	file(GLOB_RECURSE PRECOMPILED_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/*.pch.cpp)
		
	#------ DEPRECATRED RCC++ Include dirs -----
	FOREACH(currentDir ${CURRENT_INCLUDE_DIRS})
		list(APPEND RCC++_IncludeDirs "${currentDir}\@") 
	ENDFOREACH(currentDir ${CURRENT_INCLUDE_DIRS})

	#message(${RCC++_IncludeDirs})
	#string(REPLACE "/" "\\\\" WINDOWS_FORMAT_CURRENT_DIRS "${CMAKE_CURRENT_SOURCE_DIR}")
	#add_definitions("-DCURRENT_INCLUDE_DIRS=${WINDOWS_FORMAT_CURRENT_DIRS}")

	# Force C++ if there's any cpp file
	if(MY_CPP_SRC)
		set_source_files_properties(${${PROJECT_NAME}_SRC} PROPERTIES LANGUAGE CXX)
	endif()

	#----- Mark PRECOMPILED HEADER -----
	if( NOT PRECOMPILED_HEADER STREQUAL "" AND NOT PRECOMPILED_SOURCE STREQUAL "")
		IF(MSVC)
			GET_FILENAME_COMPONENT(PRECOMPILED_HEADER_NAME ${PRECOMPILED_HEADER} NAME)
			GET_FILENAME_COMPONENT(PRECOMPILED_SOURCE_NAME ${PRECOMPILED_SOURCE} NAME)			
			GET_FILENAME_COMPONENT(PRECOMPILED_BASENAME ${PRECOMPILED_HEADER_NAME} NAME_WE)
			SET(PRECOMPILED_BINARY "${PRECOMPILED_BASENAME}-$(Configuration).pch")
			
			SET_SOURCE_FILES_PROPERTIES(${${PROJECT_NAME}_SRC}
									PROPERTIES COMPILE_FLAGS "/Yu\"${PRECOMPILED_HEADER_NAME}\" /FI\"${PRECOMPILED_HEADER_NAME}\" /Fp\"${PRECOMPILED_BINARY}\""
											   OBJECT_DEPENDS "${PRECOMPILED_BINARY}")  
											   
			SET_SOURCE_FILES_PROPERTIES(${PRECOMPILED_SOURCE}
									PROPERTIES COMPILE_FLAGS "/Yc\"${PRECOMPILED_HEADER_NAME}\" /Fp\"${PRECOMPILED_BINARY}\""
										   OBJECT_OUTPUTS "${PRECOMPILED_BINARY}")
		ENDIF(MSVC)
	endif()

	if(NOT build_flag EQUAL OFF)
		#----- Add Preprocessor Definitions -----
		foreach(currMacro ${${PROJECT_NAME}_macros})
			add_definitions("-D${currMacro}")
		endforeach()
		#----- Add Project Name -----
		add_definitions("-DPROJECT_NAME=\"${PROJECT_NAME}\"")
		add_definitions("-DPROJECT_ID=${PROJECT_COUNT}")
		
		#------ INCLUDE DIRS AND LIBS -----
		include( ProjectSettingsTemplate )
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
				list(APPEND includeDirs ${${currentName}_PUBLIC_INCLUDE_DIRS})
				list(APPEND includeDirs ${${currentName}_PROTECTED_INCLUDE_DIRS})
				list(APPEND includeDirs ${${currentName}_SOURCE_DIR})
				list(APPEND includeProjs ${currentName})
			endif()
		ENDFOREACH(currentName ${includes})
		set(${PROJECT_NAME}_INCLUDE_PROJECTS "${includeProjs}" CACHE STRING "")
		include_directories(${includeDirs})
		# Add links
		link_libraries(${linkLibs})
				
		#----- CREATE TARGET -----
		if(${${PROJECT_NAME}_MODE} STREQUAL "STATIC")
			add_library (${PROJECT_NAME} STATIC ${${PROJECT_NAME}_SRC} ${MY_HEADERS} ${MY_MISC} ${MY_RESOURCES})
			add_definitions("-DIS_STATIC")
			add_definitions("-DSTATIC_ID=${PROJECT_COUNT}")
		elseif(${${PROJECT_NAME}_MODE} STREQUAL "DYNAMIC" OR ${${PROJECT_NAME}_MODE} STREQUAL "SHARED" )
			add_library (${PROJECT_NAME} SHARED ${${PROJECT_NAME}_SRC} ${MY_HEADERS} ${MY_MISC} ${MY_RESOURCES})
			add_definitions("-DIS_DYNAMIC")
			add_definitions("-DEXPORT_ID=${PROJECT_COUNT}")
		elseif(${${PROJECT_NAME}_MODE} STREQUAL "CONSOLE")
			add_executable (${PROJECT_NAME} ${${PROJECT_NAME}_SRC} ${MY_HEADERS} ${MY_SHADERS} ${MY_RESOURCES} ${MY_MISC})
		elseif(${${PROJECT_NAME}_MODE} STREQUAL "WIN32")
			add_executable (${PROJECT_NAME} WIN32 ${${PROJECT_NAME}_SRC} ${MY_HEADERS} ${MY_SHADERS} ${MY_RESOURCES} ${MY_MISC})
		endif()
		
		#------ force include PCH -----
		if( NOT MY_PRECOMPILED_HEADER STREQUAL "" AND NOT MY_PRECOMPILED_SOURCE STREQUAL "")
			###DON'T ENABLE get_target_property(FLAGS ${PROJECT_NAME} COMPILE_FLAGS)
			set_target_properties(${PROJECT_NAME} PROPERTIES COMPILE_FLAGS "${FLAGS} /FI\"${MY_PRECOMPILED_HEADER}\"")
		endif()
		
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
		# Flex and Bison
		if( USE_FLEX_AND_BISON )
			include( Optional/AddFlexBisonCustomTarget )
		endif()
		# Shader Copy
		if( NOT MY_SHADERS STREQUAL "" )
			add_custom_target(${PROJECT_NAME}PreBuild ALL
				COMMAND ${CMAKE_COMMAND}
				-DSrcDir=${CMAKE_CURRENT_SOURCE_DIR}
				-DDestDir=${CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG}
				-P ${CMAKE_MODULE_PATH}/CopyResource.cmake
				COMMENT "Copying resource files to the binary output directory")
				
			add_dependencies(${PROJECT_NAME} ${PROJECT_NAME}PreBuild)
				
			if( MSVC )
				SET_PROPERTY(GLOBAL PROPERTY USE_FOLDERS ON)
				SET_PROPERTY(TARGET ${PROJECT_NAME}PreBuild		PROPERTY FOLDER CMakePredefinedTargets)
			endif()
		endif()
	endif()
ENDMACRO(create_project mode linLibraries)

MACRO(create_project_helper target_folder)
	#----- Create Project -----
	get_folder_name(${target_folder} PROJECT_NAME)
	project( ${PROJECT_NAME} )

	FILE(RELATIVE_PATH rel_dir ${PROJECT_SOURCE_DIR} ${target_folder})
	

	message("${PROJECT_NAME} ${target_folder}")
	set(PROJECT_BINARY_DIR "${PROJECT_BINARY_DIR}/${rel_dir}")
	set(${PROJECT_NAME}_BINARY_DIR "${${PROJECT_NAME}_BINARY_DIR}/${rel_dir}")
	#----- Order is important!!! -----
	set(PROJECT_SOURCE_DIR ${target_folder})
	set(${PROJECT_NAME}_SOURCE_DIR ${target_folder})
	message("
	PROJECT_SOURCE_DIR ${PROJECT_SOURCE_DIR}
	PROJECT-NAME_SOURCE_DIR ${${PROJECT_NAME}_SOURCE_DIR}
	PROJECT_BINARY_DIR ${PROJECT_BINARY_DIR}
	PROJECT-NAME_BINARY_DIR ${${PROJECT_NAME}_BINARY_DIR}
	")

	#----- Add Preprocessor Definitions -----
	foreach(currMacro ${${PROJECT_NAME}_macros})
		add_definitions("-D${currMacro}")
	endforeach()
	#----- Add Project Name -----
	add_definitions("-DPROJECT_NAME=\"${PROJECT_NAME}\"")
	add_definitions("-DPROJECT_ID=${PROJECT_COUNT}")
	
	#------ INCLUDE DIRS AND LIBS -----
	include( ProjectSettingsTemplate )
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
			list(APPEND includeDirs ${${currentName}_PUBLIC_INCLUDE_DIRS})
			list(APPEND includeProjs ${currentName})
		endif()
	ENDFOREACH(currentName ${includes})
	set(${PROJECT_NAME}_INCLUDE_PROJECTS "${includeProjs}" CACHE STRING "")
	include_directories(${includeDirs})
	# Add links
	link_libraries(${linkLibs})
	
#	message("HELPER: ${PROJECT_NAME} src: ${${PROJECT_NAME}_SRC}")
	
	#----- CREATE TARGET -----
#	message("MODE: ${${PROJECT_NAME}_MODE}")
	if(${${PROJECT_NAME}_MODE} STREQUAL "STATIC")
		add_library (${PROJECT_NAME} STATIC ${${PROJECT_NAME}_SRC} ${MY_HEADERS} ${MY_MISC} ${MY_RESOURCES})
		add_definitions("-DIS_STATIC")
		add_definitions("-DSTATIC_ID=${PROJECT_COUNT}")
	elseif(${${PROJECT_NAME}_MODE} STREQUAL "DYNAMIC" OR ${${PROJECT_NAME}_MODE} STREQUAL "SHARED" )
		add_library (${PROJECT_NAME} SHARED ${MY_SRC} ${MY_HEADERS} ${MY_MISC} ${MY_RESOURCES})
		add_definitions("-DIS_DYNAMIC")
		add_definitions("-DEXPORT_ID=${PROJECT_COUNT}")
	elseif(${${PROJECT_NAME}_MODE} STREQUAL "CONSOLE")
		add_executable (${PROJECT_NAME} ${MY_SRC} ${MY_HEADERS} ${MY_SHADERS} ${MY_RESOURCES} ${MY_MISC})
	elseif(${${PROJECT_NAME}_MODE} STREQUAL "WIN32")
		add_executable (${PROJECT_NAME} WIN32 ${MY_SRC} ${MY_HEADERS} ${MY_SHADERS} ${MY_RESOURCES} ${MY_MISC})
	endif()
	
	#------ force include PCH -----
	if( NOT MY_PRECOMPILED_HEADER STREQUAL "" AND NOT MY_PRECOMPILED_SOURCE STREQUAL "")
		get_target_property(FLAGS ${PROJECT_NAME} COMPILE_FLAGS)
		set_target_properties(${PROJECT_NAME} PROPERTIES COMPILE_FLAGS "${FLAGS} /FI\"${MY_PRECOMPILED_HEADER}\"")
	endif()
	
	#------ set target filter -----
	if( MSVC )
		# TODO: OPTIMIZE THIS
		string(REPLACE "/" ";" sourceDirList "${CMAKE_SOURCE_DIR}")
		string(REPLACE "/" ";" currSourceDirList "${target_folder}")
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
	# Flex and Bison
	if( USE_FLEX_AND_BISON )
		include( Optional/AddFlexBisonCustomTarget )
	endif()
	# Shader Copy
	if( NOT MY_SHADERS STREQUAL "" )
		add_custom_target(${PROJECT_NAME}PreBuild ALL
			COMMAND ${CMAKE_COMMAND}
			-DSrcDir=${target_folder}
			-DDestDir=${CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG}
			-P ${CMAKE_MODULE_PATH}/CopyResource.cmake
			COMMENT "Copying resource files to the binary output directory")
			
		add_dependencies(${PROJECT_NAME} ${PROJECT_NAME}PreBuild)
			
		if( MSVC )
			SET_PROPERTY(GLOBAL PROPERTY USE_FOLDERS ON)
			SET_PROPERTY(TARGET ${PROJECT_NAME}PreBuild		PROPERTY FOLDER CMakePredefinedTargets)
		endif()
	endif()

ENDMACRO()