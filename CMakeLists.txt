# CMake version
cmake_minimum_required(VERSION 3.21)

# C++ standard version
set(CMAKE_CXX_STANDARD 20)

set(PROJECT_NAME project_name)

# initiating project given its name
project(${PROJECT_NAME})

add_subdirectory(externals)
add_subdirectory(internal)
add_subdirectory(lib)
add_subdirectory(src)
