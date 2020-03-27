cmake_minimum_required( VERSION 2.8 )

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/Purify")

include( Detail/Utils )
include( Detail/SetOutputDirectories )
include( Detail/ProjectSettingsTemplate )
include( Detail/CreateProject )
include( Detail/CreateBuild )

include( Detail/DotNetReferences )
