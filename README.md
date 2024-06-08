Purify
=======

A lazy cross-platform build manager for C++ written in [CMake](http://www.cmake.org/), Batch scripts, and Shell scripts and licensed under the BSD 2-clause License. 

A work-in-progress documentation can be found in the [wiki](https://github.com/fpark12/PurifyCore/wiki).

Motivation:
-------
The CMake scripting language is not the easiest to grasp for beginners. Even after one becomes proficient at CMake, changes to the codebase can still cause unnecessary time spent on maintaining CMake scripts.

Purify was designed to minimize the amount of labor required to create and maintain cross-platform C++ projects with CMake by:
 * offering helper functions that reduce the number of lines required to write fully functional `CMakeLists.txt` files,
 * automating certain build behaviors to simplify the process of writing `CMakeLists.txt` files, while
 * retaining the ability to extend complex build behaviors through traditional `CMakeLists.txt` scripting.

This approach brings many benefits, for example:
 * `CMakeLists.txt` files become shorter and easier to maintain and modify,
 * each project within a Purify-based build is highly modular, so a simple copy and paste would allow it to be reused in another Purify based project,
 * the source tree and the file system will be kept in sync through automatically creating source groups and naming projects based on the file system,
 * platform dependent features such as forced-include and precompiled headers which require careful manual maintenance have been automated,
 * common source files such as .ini, .vert, .frag, etc. can be placed in source folders, and be will automatically copied to the correct relative paths to the binaries folder,
 * automatic generation of symbol import/export API, i.e. `__declspec(dllexport)`, `__declspec(dllimport)`, and various macro chains,
 * writing CMake becomes optional. (Exceptions include complex build behaviors such as precompiling .proto files with Google's protobuf compiler.)

Examples:
-------
Here is a direct comparison of the traditional `CMakeLists.txt` approach and the Purify one. It is only meant to get you started using Purify's helper functions so that you can utilize other advanced features.

__Traditional CMake:__
 
Top-level: `cmake_example/CMakeLists.txt`:
```CMake
cmake_minimum_required (VERSION 3.0)
project (cmake_example)

add_definitions(-D_CRT_SECURE_NO_WARNINGS -DDemo_Macro)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

add_subdirectory (foo)
add_subdirectory (bar)
```

Static lib foo, `cmake_example/Source/foo/CMakeLists.txt`:
```CMake
project(foo)

# Manually manage source files and include directories
add_library (foo STATIC foo.cpp foo.h)
target_include_directories (foo PUBLIC ${CMAKE_SOURCE_DIR}/lib ${CMAKE_CURRENT_SOURCE_DIR})

# Confusing -D prefixes for macros
add_definitions("-Dfoo_macro -Dptr_size=8")
target_link_libraries(foo PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/lib/3rdparty.lib)

# Have to manually set project folder
set_target_properties(foo PROPERTIES FOLDER "foo")
```

Executable bar links foo, `cmake_example/Source/bar/CMakeLists.txt`:
```CMake
project(bar)

# Manually manage source files and include directories
add_executable (bar bar.cpp bar.h)
target_include_directories (bar PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

# Confusing -D prefixes for macros
add_definitions("-Dbar_macro -Dptr_size=8")
target_link_libraries(bar PUBLIC foo)

# Have to manually set project folder
set_target_properties(bar PROPERTIES FOLDER "bar")

message("My project name is: bar")
```

__With Purify:__
 
Top-level: `cmake_example/CMakeLists.txt`:
```CMake
cmake_minimum_required( VERSION 3.0 )
include( "${CMAKE_SOURCE_DIR}/Purify/Loader.cmake" )

SET( GLOBAL_DEFINITIONS _CRT_SECURE_NO_WARNINGS Demo_Macro)

create_build( GLOBAL_DEFINITIONS )
```

Static lib foo: `cmake_example/Source/foo/CMakeLists.txt`:
```CMake
set( DEFINE foo_macro ptr_size=8)
set( INCLUDE ${CMAKE_SOURCE_DIR}/lib)
set( LINK ${CMAKE_SOURCE_DIR}/lib/3rd_party.lib)

// Automatically manages source tree and creates include directories.
create_project(STATIC DEFINE INCLUDE LINK)
```

Executable bar links foo, `cmake_example/Source/bar/CMakeLists.txt`:
```CMake
set( DEFINE bar_macro ptr_size=8)
set( INCLUDE foo)
set( LINK foo)

// Automatically manages source tree and creates include directories.
create_project(CONSOLE DEFINE INCLUDE LINK)

# Purify automatically sets ${PROJECT_NAME} to the name of the folder where the `CMakeLists.h` is located.
message("My project name is: ${PROJECT_NAME}") 
```

Requirements:
-------
__Compiler:__

 - MSVC 2010 or above on Windows
 - Xcode on OS X
 - g++ (Experimental)
 
__Dependencies:__

 - [Git](https://git-scm.com/) or [GitHub for Desktop](https://desktop.github.com/) (Required for batch and shell scripts)
 
__Optional:__
 - [CMake](https://cmake.org/) (A portable version can be automatically downloaded by the shell scripts)
