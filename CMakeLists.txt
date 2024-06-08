cmake_minimum_required( VERSION 2.8 )
# Set the build type.  Options are:
#  Coverage       : w/  debug symbols, w/o optimization, w/ code-coverage
#  Debug          : w/  debug symbols, w/o optimization
#  Release        : w/o debug symbols, w/  optimization
#  RelWithDebInfo : w/  debug symbols, w/  optimization
#  MinSizeRel     : w/o debug symbols, w/  optimization, stripped binaries

SET( CMakeScriptRepo "https://github.com/piaoasd123/CMake.git" )
# Grab CMake Script
# Requires Git.exe added to system path
find_package(Git)
if(GIT_FOUND)
	message(STATUS "Git Executable: ${GIT_EXECUTABLE}")
	message(STATUS "CMake Script: ${CMakeScriptRepo}")
	if(EXISTS ${CMAKE_SOURCE_DIR}/CMake/)
		execute_process(COMMAND ${GIT_EXECUTABLE}
			"pull" ${CMakeScriptRepo}
			WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/CMake/")
	else()
		execute_process(COMMAND ${GIT_EXECUTABLE}
			"clone" ${CMakeScriptRepo}
			WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}")
	endif()
endif()
# Set module path
if(IS_DIRECTORY "${CMAKE_SOURCE_DIR}/../CMake")
	set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../CMake")
else()
	set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/CMake")
endif()
message(STATUS "CMake Path: ${CMAKE_MODULE_PATH}")

# Include all modules
include( CustomModules )

# --------------------------------------
# DO NOT EDIT ANYTHING ABOVE THIS LINE |
# --------------------------------------

# Add global compile flags and preprocessor definitions
add_definitions(
"-D_CRT_SECURE_NO_WARNINGS"
"/FC")

# Enable Unicode
#SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /UMBCS /D_UNICODE /DUNICODE")

# Automatic build generation procedure
include( CreateBuild )
#EOF