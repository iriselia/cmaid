# Purify

This is a lazy, cross-platform build manager for C++ written in [CMake](http://www.cmake.org/), Batch scripts, and Shell scripts and licensed under BSD 3-clause License. It was designed to minimize the effort to create and maintain cross-platform C++ projects.

# Features
- Off-the-shelf solution for lazy management of cross-platform C++ builds.
- CMake scripting is optional.
- Keeps the project clean by seperating the source tree from the build tree.
- Automatically creates include directory tree for external projects.
- Generates symbol export/import macros for dynamic library projects.
- Improves build speed by managing pre-compiled headers and forced-included headers based on config files


Sample program to demonstrate the robust features provided by [Purify](https://github.com/piaoasd123/Purify).

 - Install [Github Desktop](https://desktop.github.com/).
 - Clone PurifySampleProject to desktop or download ZIP.
 - Double click to execute "zGenerateProjectFiles.bat".
 - Build and run!
 - Optionally, you can install [CMake](http://www.cmake.org/) and "Add CMake to System PATH". This will accelerate build generation as CMake no longer needs to be downloaded from an externally repository.


 
[Purify](https://github.com/piaoasd123/Purify) is a [CMake](http://www.cmake.org/)-based automated build tool Developed by [Frank Park](https://www.linkedin.com/in/fpark12). Purify aims to significantly reduce the amount of learning required to fully utilize the productivity of CMake. It is designed to enable fast iteration and allow programmers create and maintain source code with ease.

Purify is particularly suited for C++ development with [Visual Studio](http://www.visualstudio.com/) and [XCode](https://developer.apple.com/xcode/) while being mostly compatible with any other build environments supported by CMake.

**Purify is a work in progress.** If you are not familiar with CMake, it is strongly advisable to use Purify only under Windows or Mac OS X.

License
-------

Purify is distributed under the OSI-approved BSD 3-clause License.
See [LICENSE](https://raw.github.com/piaoasd123/PurifySampleProject/master/LICENSE) for details.

Reporting Bugs
--------------

If you have found a bug, please consider formulating a pull request!

Contributing
------------

If you enjoy using Purify and would like to contribute email me: y.piao.us@ieee.org
