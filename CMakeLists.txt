cmake_minimum_required(VERSION 3.17)

message(STATUS "CUHK FPGA ROUTE")
message(STATUS "project directory ${PROJECT_SOURCE_DIR}")

set(CMAKE_CXX_STANDARD 17)
# set(CMAKE_VERBOSE_MAKEFILE ON)

project(FPGA_ROUTE)
set(PATH_SRC ${PROJECT_SOURCE_DIR}/src)
set(PATH_LIB ${PROJECT_SOURCE_DIR}/libs)

file(GLOB_RECURSE SRC_FILES ${PATH_SRC}/*.cpp)

add_subdirectory(${PATH_LIB}/capnproto)

find_package(ZLIB REQUIRED)
find_package(Boost COMPONENTS serialization REQUIRED)

add_executable(route ${SRC_FILES})

target_include_directories(route PRIVATE ${PATH_SRC})
target_include_directories(route PRIVATE ${PATH_LIB}/capnproto/c++/src/)
target_include_directories(route PRIVATE ${PATH_LIB}/interchange/)
target_include_directories(route PRIVATE ${PATH_LIB}/cxxopts/)
target_include_directories(route PRIVATE ${Boost_INCLUDE_DIRS})

target_link_libraries(route capnp)
target_link_libraries(route Boost::serialization)
target_link_libraries(route z)