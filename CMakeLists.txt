#  Debug          : w/  debug symbols, w/o optimization
#  Release        : w/o debug symbols, w/  optimization
#  RelWithDebInfo : w/  debug symbols, w/  optimization
#  MinSizeRel     : w/o debug symbols, w/  optimization, stripped binaries

if(WIN32)
	set(githint "$ENV{APPDATA}/../Local/Github/PortableGit*/bin")
	file( TO_CMAKE_PATH ${githint} githint )
	file(GLOB GitPath "${githint}/git.exe")
	set(Terminal $ENV{ComSpec})
endif()
# ------------------------------------------------------------------#--|
# 							!!DANGERZONE!!							#  |
# ------------------------------------------------------------------#  |
cmake_minimum_required( VERSION 3.0 )								#  |
SET( CMakeScriptRepo "https://github.com/piaoasd123/Purify.git" )	#  |
# Grab CMake Script													#  |
																	#  |
message(STATUS "Git Executable: ${GIT_EXECUTABLE}")					#  |
message(STATUS "CMake Script: ${CMakeScriptRepo}")					#  |
if(EXISTS ${CMAKE_SOURCE_DIR}/Purify/)								#  |
	execute_process(COMMAND ${Terminal}								#  |
		"/c" ${GitPath} "pull" ${CMakeScriptRepo}					#  |
		WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/Purify/")			#  |
else()																#  |
	execute_process(COMMAND ${Terminal}								#  |
		"/c" ${GitPath} "clone" ${CMakeScriptRepo}					#  |
		WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}")					#  |
endif()																#  |
# Set module path													#  |
if(IS_DIRECTORY "${CMAKE_SOURCE_DIR}/../Purify")					#  |
	set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../Purify")			#  |
else()																#  |
	set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/Purify")				#  |
endif()																#  |
message(STATUS "CMake Path: ${CMAKE_MODULE_PATH}")					#  |
																	#  |
# Include all modules												#  |
include( CustomModules )											#  |
																	#  |
# ------------------------------------------------------------------#  |
# 						  END OF DANGERZONE							#  |
# ------------------------------------------------------------------#--|

# ------------------------------------------------------------------#--|
# 							USER SETTINGS							#  |
# ------------------------------------------------------------------#--|
# Add global compile flags and preprocessor definitions
SET( GLOBAL_DEFINE
"-D_CRT_SECURE_NO_WARNINGS"
"/FC"
)

# Enable Unicode
#SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /UMBCS /D_UNICODE /DUNICODE")
															
# ------------------------------------------------------------------#--|
# 						END OF USER SETTINGS						#  |
# ------------------------------------------------------------------#--|
include( CreateBuild )												
#EOF