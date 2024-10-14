cmake_minimum_required( VERSION 3.0 )

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmaid")

include( scripts/Utils )
include( scripts/SetOutputDirectories )
include( scripts/CreateProject )
include( scripts/CreateBuild )

include( scripts/DotNetReferences )