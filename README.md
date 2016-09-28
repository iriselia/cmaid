# Purify

This is a lazy cross-platform build manager for C++ written in [CMake](http://www.cmake.org/), Batch scripts, and Shell scripts and licensed under BSD 3-clause License. It was designed to minimize the effort to create and maintain cross-platform C++ projects.

# Features
- Off-the-shelf solution for lazy management of cross-platform C++ builds.
- CMake scripting is optional.
- Keeps the project clean by allowing the build tree to completely seperate from the source tree.
- Automatically creates include directory tree for external projects.
- Generates symbol export/import macros for dynamic library projects.
- Improves build speed by managing pre-compiled headers and forced-included headers based on config files


# Build
 - Install [Github Desktop](https://desktop.github.com/).
 - Clone PurifySampleProject to desktop or download ZIP.
 - Double click to execute "zGenerateProjectFiles.bat".
 - Build and run!
 - Optionally, you can install [CMake](http://www.cmake.org/) and "Add CMake to System PATH". This will accelerate build generation as CMake no longer needs to be downloaded from an externally repository.

