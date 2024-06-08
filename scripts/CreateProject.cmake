cmake_minimum_required( VERSION 3.0 )
cmake_policy(SET CMP0054 NEW)
include(ProcessorCount)

MACRO(create_project mode defines includes links)
ENDMACRO()

MACRO(cmaid_project)

	set(options) #set(options OPTIONAL FAST)
	set(oneValueArgs CONFIGURATION NAME) #set(oneValueArgs DESTINATION RENAME)
	set(multiValueArgs DEFINE INCLUDE EXCLUDE LINK)
	cmake_parse_arguments(PROJECT_ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

	string(TOUPPER "${PROJECT_ARG_CONFIGURATION}" PROJECT_ARG_CONFIGURATION_UPPER)
	set(PROJECT_CONFIGURATION "${PROJECT_ARG_CONFIGURATION_UPPER}")
	set(PROJECT_DEFINES "${PROJECT_ARG_DEFINE}")
	set(PROJECT_INCLUDES "${PROJECT_ARG_INCLUDE}")
	set(PROJECT_EXCLUDES "${PROJECT_ARG_EXCLUDE}")
	set(PROJECT_LINKS "${PROJECT_ARG_LINK}")

	# Restore default name if no new name is specified.
	if(PROJECT_ARG_NAME)
		set(PROJECT_NAME ${PROJECT_ARG_NAME})
	endif()

	# Cache args for resolving project dependencies
	if(${PROJECT_NAME}_INITIALIZED)
		project(${PROJECT_NAME})
	else()
		set(${PROJECT_NAME}_DEFINES "${PROJECT_ARG_DEFINE}" CACHE STRING "" FORCE)
		set(${PROJECT_NAME}_INCLUDES "${PROJECT_ARG_INCLUDE}" CACHE STRING "" FORCE)
		set(${PROJECT_NAME}_EXCLUDES "${PROJECT_ARG_EXCLUDE}" CACHE STRING "" FORCE)
		set(${PROJECT_NAME}_LINKS "${PROJECT_ARG_LINK}" CACHE STRING "" FORCE)
		set(${PROJECT_NAME}_CONFIGURATION "${PROJECT_ARG_CONFIGURATION}" CACHE STRING "" FORCE)
		set(${PROJECT_NAME}_BUILD_TYPE "${PROJECT_NAME}_IS_${PROJECT_ARG_CONFIGURATION}" CACHE STRING "" FORCE)
		set(${PROJECT_NAME}_ID "${PROJECT_COUNT}" CACHE STRING "" FORCE)
	endif()


	GetIncludeProjectsRecursive(${PROJECT_NAME} ${PROJECT_NAME}_RECURSIVE_INCLUDES)
	GetLinkLibsRecursive(${PROJECT_NAME} ${PROJECT_NAME}_RECURSIVE_LINKS)


	#----- The follow code will only be executed if build project is being run a second time -----
	if( ${PROJECT_NAME}_INITIALIZED )

		#----- Add Preprocessor Definitions -----
		foreach(macro ${PROJECT_DEFINES})
			add_definitions("-D${macro}")
		endforeach()
		#----- Add Project Name -----
		add_definitions("-D_PROJECT_NAME=\"${PROJECT_NAME}\"")
		add_definitions("-D_PROJECT_ID=${${PROJECT_NAME}_ID}")

		# Most important step, scan for source files and headers recursively
		ScanSourceFiles() #----- Utils.cmake

		#------ EXCLUDES and INCLUDES -----
		# Process include list, an element could be a list of dirs or a target name
		set(PROJECT_INCLUDE_DIRS "${PROJECT_SOURCE_DIR}")
		set(PROJECT_LINK_LIBS "")
		set(includeProjs "")

		# Excludes
		foreach(excluded_entry ${PROJECT_EXCLUDES})
			# is directory
			if(IS_DIRECTORY ${excluded_entry})
			# is file
			elseif(EXISTS ${excluded_entry})
			# something else, regex?
			else()
				list(FILTER PROJECT_SOURCE EXCLUDE REGEX "${excluded_entry}")
				list(FILTER PROJECT_SOURCE_CPP EXCLUDE REGEX "${excluded_entry}")
				list(FILTER PROJECT_HEADERS EXCLUDE REGEX "${excluded_entry}")
			endif()
		endforeach()

		list(APPEND PROJECT_INCLUDE_DIRS ${${PROJECT_NAME}_PUBLIC_INCLUDE_DIRS})
		list(APPEND PROJECT_INCLUDE_DIRS ${${PROJECT_NAME}_PROTECTED_INCLUDE_DIRS})
		list(APPEND PROJECT_INCLUDE_DIRS ${${PROJECT_NAME}_PRIVATE_INCLUDE_DIRS})
		list(APPEND PROJECT_INCLUDE_DIRS ${${PROJECT_NAME}_PRECOMPILED_INCLUDE_DIRS})
		# make the project completely public if it does not contain a .pri.h
		if( "${${PROJECT_NAME}_PRIVATE_INCLUDE_FILES}" STREQUAL "")
			#message("${PROJECT_NAME} has no file, ${${currentName}_ALL_INCLUDE_DIRS}")
			list(APPEND PROJECT_INCLUDE_DIRS ${${PROJECT_NAME}_INCLUDE_DIRS} )
		endif()

		foreach(include_entry ${${PROJECT_NAME}_RECURSIVE_INCLUDES})
			# if exists, it is either a full path or a rel path, like c:/github/project/library/libabcd
			if(EXISTS ${include_entry})
				if(IS_DIRECTORY ${include_entry})
					if(NOT IS_ABSOLUTE ${include_entry})
						# or if it is a rel path to a folder within the cmake source dir,
						# e.g. /3rdparty/libabcd
						list(APPEND PROJECT_INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/${include_entry})
					else()
						list(APPEND PROJECT_INCLUDE_DIRS ${include_entry})
					endif()
				# probably a file, in which case we link it against our current project or include as a source file
				else()
					set(header_extensions ".h" ".hpp" ".inl" ".ixx" ".ipp")
					set(source_extensions ".cxx" ".cpp" ".cc" ".c++" ".c")
					set(source_cpp_extensions ".cxx" ".cpp" ".cc" ".c++")
					set(link_lib_extensions ".lib")
			
					get_filename_component(entry_ext "${include_entry}" LAST_EXT)

					foreach(header_extension ${header_extensions})
						if(${entry_ext} STREQUAL ${header_extension})
							list(APPEND PROJECT_HEADERS "${include_entry}")
						endif()
					endforeach()

					foreach(source_extension ${source_extensions})
						if(${entry_ext} STREQUAL ${source_extension})
							list(APPEND PROJECT_SOURCE "${include_entry}")
						endif()
					endforeach()

					foreach(source_cpp_extension ${source_cpp_extensions})
						if(${entry_ext} STREQUAL ${source_cpp_extension})
							list(APPEND PROJECT_SOURCE_CPP "${include_entry}")
						endif()
					endforeach()

					foreach(link_lib_extension ${link_lib_extensions})
						if(${entry_ext} STREQUAL ${link_lib_extensions})
							list(APPEND PROJECT_SOURCE_CPP "${include_entry}")
						endif()
					endforeach()

					list(APPEND PROJECT_LINK_LIBS ${include_entry})
				endif()
			elseif(TARGET ${include_entry})
					# if doesn't exist, it is a target, we retrieve the include dirs by appending _INCLUDE_DIRS to its name
					list(APPEND PROJECT_INCLUDE_DIRS ${${include_entry}_PUBLIC_INCLUDE_DIRS})
					list(APPEND PROJECT_INCLUDE_DIRS ${${include_entry}_PROTECTED_INCLUDE_DIRS})
					list(APPEND PROJECT_INCLUDE_DIRS ${${include_entry}_PRIVATE_INCLUDE_DIRS})
					list(APPEND PROJECT_INCLUDE_DIRS ${${include_entry}_PRECOMPILED_INCLUDE_DIRS})
					#message("${include_entry}_PRECOMPILED_INCLUDE_FILES: ${${include_entry}_PRECOMPILED_INCLUDE_FILES}")

					# include the bare minimum
					list(APPEND PROJECT_INCLUDE_DIRS ${${include_entry}_SOURCE_DIR} )
					# make the project completely public if it does not contain a .pri.h
					if( "${${include_entry}_PRIVATE_INCLUDE_FILES}" STREQUAL "")
						#message("${include_entry} has no file, ${${include_entry}_ALL_INCLUDE_DIRS}")
						list(APPEND PROJECT_INCLUDE_DIRS ${${include_entry}_INCLUDE_DIRS} )
					else()
					endif()
					#message("${include_entry} has : ${${include_entry}_ALL_INCLUDE_DIRS} ")
					foreach(define ${${include_entry}_DEFINES})
						add_definitions("-D${define}")
					endforeach()
					#list(APPEND PROJECT_INCLUDE_DIRS ${${include_entry}_SOURCE_DIR})
					#list(APPEND PROJECT_INCLUDE_DIRS ${${include_entry}_BINARY_DIR})
					list(APPEND includeProjs ${include_entry})


					# now link the target against our current project
					foreach(current_build_config ${CMAKE_CONFIGURATION_TYPES})
						GetTargetOutputExtension(${include_entry} ${include_entry}_output_extension)
						if (${current_build_config} STREQUAL "Debug")
							list(APPEND PROJECT_LINK_LIBS_${current_build_config} "${CMAKE_BINARY_DIR}/${current_build_config}/${include_entry}${CMAKE_DEBUG_POSTFIX}${${include_entry}_output_extension}")
						else()
							list(APPEND PROJECT_LINK_LIBS_${current_build_config} "${CMAKE_BINARY_DIR}/${current_build_config}/${include_entry}${${include_entry}_output_extension}")
						endif()
					endforeach()
			endif()
		ENDFOREACH(include_entry ${includes})

		#[[
		# Resolve link libraries. Link entry can be a lib file or a project name
		foreach(linkEntry ${${PROJECT_NAME}_RECURSIVE_LINKS})
			# If link entry is a file
			if(EXISTS ${linkEntry})
				list(APPEND PROJECT_LINK_LIBS ${linkEntry})
			# Else if link entry is a project
			elseif(TARGET ${linkEntry})
				foreach(current_build_config ${CMAKE_CONFIGURATION_TYPES})
					GetTargetOutputExtension(${linkEntry} ${linkEntry}_output_extension)
					if (${current_build_config} STREQUAL "Debug")
						list(APPEND PROJECT_LINK_LIBS_${current_build_config} "${CMAKE_BINARY_DIR}/${current_build_config}/${linkEntry}${CMAKE_DEBUG_POSTFIX}${${linkEntry}_output_extension}")
					else()
						list(APPEND PROJECT_LINK_LIBS_${current_build_config} "${CMAKE_BINARY_DIR}/${current_build_config}/${linkEntry}${${linkEntry}_output_extension}")
					endif()
				endforeach()
			endif()
		endforeach()
		#]]

		#list(APPEND ${PROJECT_NAME}_ALL_INCLUDE_DIRS ${PROJECT_INCLUDE_DIRS})
		unset(${PROJECT_NAME}_RECURSIVE_INCLUDES CACHE)
		set(${PROJECT_NAME}_RECURSIVE_INCLUDES "${PROJECT_INCLUDE_DIRS}" CACHE STRING "")

		# Add links
		GeneratePrecompiledHeader()

		# Force C++ if there's any cpp file
		if(PROJECT_CPP_SOURCE)
			set_source_files_properties(${PROJECT_SOURCE} PROPERTIES LANGUAGE CXX)
		else()
			set_source_files_properties(${PROJECT_SOURCE} PROPERTIES LANGUAGE C)
		endif()

		if(XCODE)
			if( PROJECT_SOURCE STREQUAL "")
				file(WRITE ${${PROJECT_BINARY_DIR}/stub.c "")
				list(APPEND PROJECT_SOURCE ${${PROJECT_BINARY_DIR}/stub.c)
			endif()
		endif()		
		#----- CREATE TARGET -----
		set(projectExtension "")
		add_definitions("-DCURRENT_PROJECT_NAME_IS_${PROJECT_NAME}")
		add_definitions("-D${PROJECT_NAME}_PROJECT_ID=${PROJECT_COUNT}")
		add_definitions("-DCURRENT_PROJECT_ID=${PROJECT_COUNT}")
		add_definitions("-D${${PROJECT_NAME}_BUILD_TYPE}")

		if(${PROJECT_CONFIGURATION} STREQUAL "STATIC")
			add_library (${PROJECT_NAME} STATIC ${PROJECT_SOURCE} ${PROJECT_HEADERS} ${${PROJECT_NAME}_MISC} ${${PROJECT_NAME}_RESOURCES})
			add_definitions("-DCOMPILING_STATIC")
		elseif(${PROJECT_CONFIGURATION} STREQUAL "DYNAMIC" OR ${PROJECT_CONFIGURATION} STREQUAL "SHARED" )
			#message("its: ${PROJECT_NAME} with ${${PROJECT_NAME}_HEADERS}")
			add_library (${PROJECT_NAME} SHARED ${PROJECT_SOURCE} ${PROJECT_HEADERS} ${${PROJECT_NAME}_MISC} ${${PROJECT_NAME}_RESOURCES})
			add_definitions("-D${${PROJECT_NAME}_BUILD_TYPE}")
			add_definitions("-DCOMPILING_SHARED")
			#add_definitions("-D${PROJECT_NAME}_IS_DYNAMIC" "-D${PROJECT_NAME}_IS_SHARED" )
			if(MSVC)
				set(projectExtension ".dll")
			elseif(MACOS)
				set(projectExtension ".dylib")
			endif()
		elseif(${PROJECT_CONFIGURATION} STREQUAL "MODULE" )
			#message("its: ${PROJECT_NAME} with ${${PROJECT_NAME}_HEADERS}")
			add_library (${PROJECT_NAME} MODULE ${PROJECT_SOURCE} ${PROJECT_HEADERS} ${${PROJECT_NAME}_MISC} ${${PROJECT_NAME}_RESOURCES})
			add_definitions("-D${${PROJECT_NAME}_BUILD_TYPE}")
			add_definitions("-DCOMPILING_MODULE")
			##add_definitions("-D${PROJECT_NAME}_IS_DYNAMIC" "-D${PROJECT_NAME}_IS_MODULE")
			add_definitions("-DEXPORT_ID=${PROJECT_COUNT}")
			if(MSVC)
				set(projectExtension ".dll")
			elseif(MACOS)
				set(projectExtension ".dylib")
			endif()
		elseif(${PROJECT_CONFIGURATION} STREQUAL "CONSOLE")
			add_executable (${PROJECT_NAME} ${PROJECT_SOURCE} ${PROJECT_HEADERS} ${${PROJECT_NAME}_SHADERS} ${${PROJECT_NAME}_MISC} ${${PROJECT_NAME}_RESOURCES})
			if(MSVC)
				set(projectExtension ".exe")
			elseif(MACOS)
				set(projectExtension "")
			endif()
		elseif(${PROJECT_CONFIGURATION} STREQUAL "WIN32")
			add_executable (${PROJECT_NAME} WIN32 ${PROJECT_SOURCE} ${PROJECT_HEADERS} ${${PROJECT_NAME}_SHADERS} ${${PROJECT_NAME}_MISC} ${${PROJECT_NAME}_RESOURCES})
			if(MSVC)
				set(projectExtension ".exe")
			elseif(MACOS)
				set(projectExtension "")
			endif()
		endif()
		
		if(MSVC)
			set_property(TARGET ${PROJECT_NAME} PROPERTY VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/binaries")
			#add_definitions(/wd4251) # x needs to have dll-interface to be used by clients of class "y"
		endif()

		if(XCODE)
			SET_TARGET_PROPERTIES(${PROJECT_NAME} PROPERTIES XCODE_ATTRIBUTE_GCC_PREFIX_HEADER "${generatedHeader}")
			SET_TARGET_PROPERTIES(${PROJECT_NAME} PROPERTIES XCODE_ATTRIBUTE_GCC_PRECOMPILE_PREFIX_HEADER "YES")
		endif()
		
		
		#----- Target Dependency -----
		# disabled for now, needs to be enabled in createbuild.cmake as well
		#add_dependencies(${PROJECT_NAME} UPDATE_RESOURCE) #----- globally shared resource update

		#----- Exclude from all (Disabled)-----
		#set_target_properties(${PROJECT_NAME} PROPERTIES EXCLUDE_FROM_ALL 1 EXCLUDE_FROM_DEFAULT_BUILD 1)

		#----- Handle includes -----
		if(PROJECT_INCLUDE_DIRS)
			list(REMOVE_DUPLICATES PROJECT_INCLUDE_DIRS)
		endif()

		target_include_directories(${PROJECT_NAME} PUBLIC "${PROJECT_INCLUDE_DIRS}" )

		#----- Handle Links -----
		search_and_link_libraries("${${PROJECT_NAME}_LINKS}")

		#----- compile flags -----
		get_target_property(FLAGS ${PROJECT_NAME} COMPILE_FLAGS)
		if(FLAGS STREQUAL "FLAGS-NOTFOUND")
			set(FLAGS "")
		endif()
		set_target_properties(${PROJECT_NAME} PROPERTIES COMPILE_FLAGS "${FLAGS} ${outCompileFlags}")

		# Enable Unicode, disable min max macros
		if( MSVC )
			SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /FC /UMBCS /D_UNICODE /DUNICODE /DNOMINMAX")
		endif()

		# Store compiler flags as macro
		if(MSVC)
			string(REPLACE " " "\\\",\\\"" compilerFlags_Debug "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}" )
			string(REPLACE " " "\\\",\\\"" compilerFlags_Release "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}" )
			string(REPLACE " " "\\\",\\\"" compilerFlags_MinSizeRel "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_MINSIZEREL}" )
			string(REPLACE " " "\\\",\\\"" compilerFlags_RelWithDebInfo "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELWITHDEBINFO}" )
			set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /D_COMPILER_FLAGS={\\\"${compilerFlags_Debug}\\\"}" )
			set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /D_COMPILER_FLAGS={\\\"${compilerFlags_Release}\\\"}" )
			set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL} /D_COMPILER_FLAGS={\\\"${compilerFlags_MinSizeRel}\\\"}" )
			set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} /D_COMPILER_FLAGS={\\\"${compilerFlags_RelWithDebInfo}\\\"}" )
		endif()

		# Store linker flags as macro
		if(MSVC)
			if(${PROJECT_CONFIGURATION} STREQUAL "STATIC")
				string(REPLACE " " "\\\",\\\"" linkerFlags_Debug "${CMAKE_STATIC_LINKER_FLAGS}" )
				string(REPLACE " " "\\\",\\\"" linkerFlags_Release "${CMAKE_STATIC_LINKER_FLAGS}" )
				string(REPLACE " " "\\\",\\\"" linkerFlags_MinSizeRel "${CMAKE_STATIC_LINKER_FLAGS}" )
				string(REPLACE " " "\\\",\\\"" linkerFlags_RelWithDebInfo "${CMAKE_STATIC_LINKER_FLAGS}" )
			elseif(${PROJECT_CONFIGURATION} STREQUAL "DYNAMIC" OR ${PROJECT_CONFIGURATION} STREQUAL "SHARED" OR ${PROJECT_CONFIGURATION} STREQUAL "MODULE" )

				string(REPLACE " " "\\\",\\\"" linkerFlags_Debug "${CMAKE_SHARED_LINKER_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS_DEBUG}" )
				string(REPLACE " " "\\\",\\\"" linkerFlags_Release "${CMAKE_SHARED_LINKER_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS_RELEASE}" )
				string(REPLACE " " "\\\",\\\"" linkerFlags_MinSizeRel "${CMAKE_SHARED_LINKER_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL}" )
				string(REPLACE " " "\\\",\\\"" linkerFlags_RelWithDebInfo "${CMAKE_SHARED_LINKER_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO}" )

			elseif(${PROJECT_CONFIGURATION} STREQUAL "CONSOLE" OR ${PROJECT_CONFIGURATION} STREQUAL "WIN32")
				string(REPLACE " " "\\\",\\\"" linkerFlags_Debug "${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS_DEBUG}" )
				string(REPLACE " " "\\\",\\\"" linkerFlags_Release "${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS_RELEASE}" )
				string(REPLACE " " "\\\",\\\"" linkerFlags_MinSizeRel "${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS_MINSIZEREL}" )
				string(REPLACE " " "\\\",\\\"" linkerFlags_RelWithDebInfo "${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO}" )

			endif()

			set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /D_LINKER_FLAGS={\\\"${linkerFlags_Debug}\\\"}" )
			set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /D_LINKER_FLAGS={\\\"${linkerFlags_Release}\\\"}" )
			set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL} /D_LINKER_FLAGS={\\\"${linkerFlags_MinSizeRel}\\\"}" )
			set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} /D_LINKER_FLAGS={\\\"${linkerFlags_RelWithDebInfo}\\\"}" )

		endif()

		# Store root dir, build dir, and bin dir as macros
		if( MSVC )
			file(RELATIVE_PATH rel_path ${CMAKE_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR})

			SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /D_ROOT_DIR=\\\"${CMAKE_SOURCE_DIR}\\\"")
			SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /D_BUILD_DIR=\\\"${CMAKE_BINARY_DIR}\\\"")
			SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /D_TARGET_PATH=\\\"${rel_path}\\\"")
			SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /D_BINARIES_DIR=\\\"${CMAKE_SOURCE_DIR}/Binaries\\\"")
		endif()

		# Store include dirs as macro
		if( MSVC )		
			string(REPLACE ";" "\\\",\\\"" PROJECT_INCLUDE_DIRS "${PROJECT_INCLUDE_DIRS}" )
			SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /D_INCLUDE_DIRS={\\\"${PROJECT_INCLUDE_DIRS}\\\"}")
		endif()

		# Store link libs as macro
		if(MSVC)
			string(REPLACE ";" "\\\",\\\"" PROJECT_LINK_LIBS_Debug "${PROJECT_LINK_LIBS_Debug}" )
			string(REPLACE ";" "\\\",\\\"" PROJECT_LINK_LIBS_Release "${PROJECT_LINK_LIBS_Release}" )
			string(REPLACE ";" "\\\",\\\"" PROJECT_LINK_LIBS_MinSizeRel "${PROJECT_LINK_LIBS_MinSizeRel}" )
			string(REPLACE ";" "\\\",\\\"" PROJECT_LINK_LIBS_RelWithDebInfo "${PROJECT_LINK_LIBS_RelWithDebInfo}" )
			#SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /D_LINK_LIBS=\"${PROJECT_LINK_LIBS_Debug}\"")
			set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /D_LINK_LIBS={\\\"${PROJECT_LINK_LIBS_Debug}\\\"}" )
			set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /D_LINK_LIBS={\\\"${PROJECT_LINK_LIBS_Release}\\\"}" )
			set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL} /D_LINK_LIBS={\\\"${PROJECT_LINK_LIBS_MinSizeRel}\\\"}" )
			set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} /D_LINK_LIBS={\\\"${PROJECT_LINK_LIBS_RelWithDebInfo}\\\"}" )
		endif()
		
		ProcessorCount(ProcCount)

		if( MSVC )
			#if(${PROJECT_CONFIGURATION} STREQUAL "STATIC")
				set(CompilerFlags
					CMAKE_CXX_FLAGS
					CMAKE_CXX_FLAGS_DEBUG
					CMAKE_CXX_FLAGS_RELEASE
					CMAKE_CXX_FLAGS_MINSIZEREL
					CMAKE_CXX_FLAGS_RELWITHDEBINFO
					CMAKE_C_FLAGS
					CMAKE_C_FLAGS_DEBUG
					CMAKE_C_FLAGS_RELEASE
					CMAKE_C_FLAGS_MINSIZEREL
					CMAKE_C_FLAGS_RELWITHDEBINFO
				)


				if (MSVC)
					foreach(CompilerFlag ${CompilerFlags})
						set(${CompilerFlag} "/MP${ProcCount} ${${CompilerFlag}}")
					endforeach()
				endif()
			#endif()

			# utils.cmake
			#get_WIN32_WINNT(ver)
			#add_definitions(-D_WIN32_WINNT=${ver})
		endif()

		#------ set target filter -----
		#if( MSVC )
			# TODO: OPTIMIZE THIS
			string(REPLACE "/" ";" sourceDirList "${CMAKE_SOURCE_DIR}")
			string(REPLACE "/" ";" currSourceDirList "${${PROJECT_NAME}_SOURCE_DIR}")
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
		#endif()
		
		#------ need linker language flag for header only static libraries -----
		if(PROJECT_SOURCE_CPP)
			#message("has cpp ${${PROJECT_NAME}_CPP_SRC}")
			#set_source_files_properties(${${PROJECT_NAME}_SRC} PROPERTIES LANGUAGE CXX)
		else()
			SET_TARGET_PROPERTIES(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C)
		endif()
		#------ need linker language flag for header only static libraries -----
		if(APPLE)
			SET_TARGET_PROPERTIES(${PROJECT_NAME} PROPERTIES MACOSX_RPATH ON)

			EXEC_PROGRAM(/usr/bin/sw_vers OUTPUT_VARIABLE OSX_VERSION_STRING)
			STRING(REGEX REPLACE "\n" ";" OSX_VERSION_STRING "${OSX_VERSION_STRING}")
			LIST(GET OSX_VERSION_STRING 1 OSX_VERSION_STRING)
			STRING(REGEX REPLACE "\t" ";" OSX_VERSION_STRING "${OSX_VERSION_STRING}")
			LIST(GET OSX_VERSION_STRING 1 OSX_VERSION_STRING)
			STRING(REPLACE "." ";" OSX_VERSION_STRING "${OSX_VERSION_STRING}")
			LIST(GET OSX_VERSION_STRING 0 OSX_MAJOR_VERSION)
			LIST(GET OSX_VERSION_STRING 1 OSX_MINOR_VERSION)
			SET(OSX_VERSION_STRING "${OSX_MAJOR_VERSION}.${OSX_MINOR_VERSION}")
			#MESSAGE("${OSX_VERSION_STRING}")
			SET(CMAKE_OSX_DEPLOYMENT_TARGET ${OSX_VERSION_STRING} CACHE STRING "Deployment target for OSX" FORCE)

			target_compile_features(${PROJECT_NAME} PRIVATE cxx_range_for)
#TODO: CLEAN UP.

# use, i.e. don't skip the full RPATH for the build tree
#SET(CMAKE_SKIP_BUILD_RPATH  FALSE)
#			MESSAGE("A ${CMAKE_SKIP_BUILD_RPATH}")



# don't add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
#			MESSAGE("D ${CMAKE_INSTALL_RPATH_USE_LINK_PATH}")
#SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)
# when building, don't use the install RPATH already
# (but later on when installing)
#SET(CMAKE_BUILD_WITH_INSTALL_RPATH true) 
#			MESSAGE("B ${CMAKE_BUILD_WITH_INSTALL_RPATH}")
# the RPATH to be used when installing
#SET(CMAKE_INSTALL_RPATH "@loader_path")
#			MESSAGE("C ${CMAKE_INSTALL_RPATH}")

			#UNNECESSARY. ONLY AFFECTS DLL, AND @RPATH IS THE DEFAULT INSTALL PATH.
			SET_TARGET_PROPERTIES(${PROJECT_NAME} PROPERTIES BUILD_WITH_INSTALL_RPATH ON INSTALL_NAME_DIR "@rpath")
			
			#SET_TARGET_PROPERTIES(${PROJECT_NAME} PROPERTIES INSTALL_RPATH_USE_LINK_PATH ON)
			#SET_TARGET_PROPERTIES(${PROJECT_NAME} PROPERTIES SKIP_BUILD_RPATH OFF)
			SET_TARGET_PROPERTIES(${PROJECT_NAME} PROPERTIES INSTALL_RPATH "@loader_path") #"@loader_path/../lib")
		endif()

		#----- Custom PreBuild Target ------
		# Copy Binaries from Backup folder to Binaries folder


		# Flex and Bison
		if( USE_FLEX_AND_BISON )
			include( Optional/AddFlexBisonCustomTarget )
		endif()

		#set(arg1 "${${PROJECT_NAME}_SOURCE_DIR}")
		if(MSVC)
			if(NOT projectExtension STREQUAL "")
				string(REPLACE "/" "\\" arg1 "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${PROJECT_NAME}*${projectExtension}")
				string(REPLACE "/" "\\" arg2 "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/../")
				add_custom_command(
					TARGET ${PROJECT_NAME}
					#OUTPUT always_rebuild
					POST_BUILD
					COMMAND "COPY"
					ARGS "1>Nul" "2>Nul" "${arg1}" "${arg2}" "/Y"
					COMMENT "Copying resource files to the binary output directory...")
			endif()
		else()
				add_custom_command(
					TARGET ${PROJECT_NAME}
					PRE_BUILD
					COMMAND "mkdir"
					ARGS  "-p" "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")

				set(arg1 "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${PROJECT_NAME}${projectExtension}")
				set(arg2 "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/../${PROJECT_NAME}${projectExtension}")
				add_custom_command(
					TARGET ${PROJECT_NAME}
					POST_BUILD
					COMMAND "cp"
					ARGS  "${arg1}" "${arg2}"
					COMMENT "Copying resource files to the binary output directory...")
			##message("FIX COPY")
		endif()


		#install(SCRIPT ${CMAKE_MODULE_PATH}/Core/Install.cmake)
	endif()
endmacro()
