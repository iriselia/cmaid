#  Debug          : w/  debug symbols, w/o optimization
#  Release        : w/o debug symbols, w/  optimization
#  RelWithDebInfo : w/  debug symbols, w/  optimization
#  MinSizeRel     : w/o debug symbols, w/  optimization, stripped binaries
# ------------------------------------------------------------------#--|
# 							!!DANGERZONE!!							#  |
# ------------------------------------------------------------------#  |
cmake_minimum_required( VERSION 3.0 )
# Set module path
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/Purify")
# Include purify build scripts
include( Purify )
# ------------------------------------------------------------------#--|
# 							USER SETTINGS							#  |
# ------------------------------------------------------------------#--|
# Add global compile/link flags and preprocessor definitions
SET( GLOBAL_DEFINE
_CRT_SECURE_NO_WARNINGS
)

# Enable Unicode
#SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /UMBCS /D_UNICODE /DUNICODE")
															
# ------------------------------------------------------------------#--|
# 						END OF USER SETTINGS						#  |
# ------------------------------------------------------------------#--|
create_build( GLOBAL_DEFINE )
#EOF