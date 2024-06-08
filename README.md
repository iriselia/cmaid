Purify
=======

A lazy cross-platform build manager for C++ written in [CMake](http://www.cmake.org/), Batch scripts, and Shell scripts and licensed under the BSD 2-clause License. 

A work-in-progress documentation can be found in the [wiki](https://github.com/fpark12/PurifyCore/wiki).

Motivation:
-------
The CMake scripting language is not the easiest to grasp for beginners. Even if one become highly proficient at using CMake, there still can be much unnecessary time spent on maintaining CMake scripts.

Purify was designed to minimize the amount of labor required to create and maintain cross-platform C++ projects with CMake by:
   * offering helper functions that reduce the number of lines required to write fully functional `CMakeLists.txt` files,
   * automating certain build behavior to simplify the process of writing `CMakeLists.txt` files to generate a project, while
   * retaining the ability to extend complex build behaviors through traditional `CMakeLists.txt` scripting.

Examples:
-------
`cmake_example/foo/CMakeLists.txt`, a subdirectory `CMakeLists.txt` with traditional CMake:
```CMake
project(foo)

add_library (foo foo.cpp foo.h)

add_definitions("-Dfoo_macro -Dptr_size=8")
target_include_directories (foo PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
set_target_properties(foo PROPERTIES FOLDER "foo")
```
With Purify:
```CMake
set( DEFINE foo_macro ptr_size=8)
set( INCLUDE ${CMAKE_CURRENT_SOURCE_DIR} bar) # Notice INCLUDE can handle both folders and targets
set( LINK ${CMAKE_SOURCE_DIR}/lib/3rd_party.lib bar) # LINK can handle both absolute directories and targets

create_project(CONSOLE DEFINE INCLUDE LINK)
```

`cmake_example/CMakeLists.txt`, a top-level `CMakeLists.txt` with traditional CMake:
```CMake
cmake_minimum_required (VERSION 3.0)
project (cmake_example)

add_definitions(-D_CRT_SECURE_NO_WARNINGS -DDemo_Macro)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

add_subdirectory (foo)
add_subdirectory (bar)
add_subdirectory (myproject)
```

With Purify:

```CMake
cmake_minimum_required( VERSION 3.0 )
include( "${CMAKE_SOURCE_DIR}/Purify/Main.cmake" )

SET( GLOBAL_DEFINITIONS _CRT_SECURE_NO_WARNINGS Demo_Macro)

create_build( GLOBAL_DEFINITIONS )
```

Features:
-------
- Off-the-shelf solution for lazy management of cross-platform C++ builds.
- CMake scripting is optional.
- Keeps the project clean by allowing the build tree to completely seperate from the source tree.
- Automatically creates include directory tree for external projects.
- Generates symbol export/import macros for dynamic library projects.
- Improves build speed by managing pre-compiled headers and forced-included headers based on config files


# Build
 - Install [Github Desktop](https://desktop.github.com/).
 - Clone Purify to desktop.
 - Execute the appropriate "GenerateProjectFiles" script for your platform to generate the project file.
 - Optionally, you can install [CMake](http://www.cmake.org/) and "Add CMake to System PATH". This will accelerate the first build generation for a Purify-based project as CMake no longer needs to be downloaded from an externally repository.

