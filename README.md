# Purify

This is a lazy cross-platform build manager for C++ written in [CMake](http://www.cmake.org/), Batch scripts, and Shell scripts and licensed under the BSD 2-clause License. It was designed to minimize the effort to create and maintain cross-platform C++ projects.
A work-in-progress documentation can be found in the [wiki](https://github.com/fpark12/PurifyCore/wiki).

# Features
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

