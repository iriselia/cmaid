cmake_minimum_required( VERSION 2.8 )

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmaid")

include( scripts/Detail/Utils )
include( scripts/Detail/SetOutputDirectories )
include( scripts/Detail/CreateProject )
include( scripts/Detail/CreateBuild )

include( scripts/Detail/DotNetReferences )
