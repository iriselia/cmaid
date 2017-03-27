#  Debug          : w/  debug symbols, w/o optimization
#  Release        : w/o debug symbols, w/  optimization
#  RelWithDebInfo : w/  debug symbols, w/  optimization
#  MinSizeRel     : w/o debug symbols, w/  optimization, stripped binaries
cmake_minimum_required( VERSION 3.0 )

include( "${CMAKE_SOURCE_DIR}/Purify/Loader.cmake" )
# Add global compile/link flags and preprocessor definitions
SET( GLOBAL_DEFINE _CRT_SECURE_NO_WARNINGS)
# Enable Unicode
#SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /UMBCS /D_UNICODE /DUNICODE")
															
create_build( GLOBAL_DEFINE )
