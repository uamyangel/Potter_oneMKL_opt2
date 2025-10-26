cmake_minimum_required(VERSION 3.17)

message(STATUS "CUHK FPGA ROUTE")
message(STATUS "project directory ${PROJECT_SOURCE_DIR}")

set(CMAKE_CXX_STANDARD 17)
# set(CMAKE_VERBOSE_MAKEFILE ON)

project(FPGA_ROUTE)
set(PATH_SRC ${PROJECT_SOURCE_DIR}/src)
set(PATH_LIB ${PROJECT_SOURCE_DIR}/libs)

file(GLOB_RECURSE SRC_FILES ${PATH_SRC}/*.cpp)

# Disable capnproto tests to avoid compilation issues with Intel icpx
set(BUILD_TESTING OFF CACHE BOOL "Disable testing" FORCE)

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

# =============================================================================
# Intel icpx + oneMKL Optimization
# =============================================================================

# Step 1: Force check Intel compiler
if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Intel")
    message(FATAL_ERROR
        "\n"
        "===============================================================\n"
        "ERROR: This project MUST be compiled with Intel icpx compiler!\n"
        "===============================================================\n"
        "Current compiler: ${CMAKE_CXX_COMPILER_ID} (${CMAKE_CXX_COMPILER})\n"
        "\n"
        "Please use Intel icpx compiler:\n"
        "  1. Load oneAPI environment:\n"
        "     source /opt/intel/oneapi/setvars.sh\n"
        "\n"
        "  2. Configure with icpx:\n"
        "     cmake -B build -DCMAKE_CXX_COMPILER=icpx \\\n"
        "           -DCMAKE_BUILD_TYPE=Release .\n"
        "\n"
        "Or use the provided build script:\n"
        "  ./scripts/build_intel.sh clean release -j 40\n"
        "===============================================================\n"
    )
endif()

message(STATUS "✓ Intel Compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")

# Step 2: Force check Intel oneMKL
if(NOT DEFINED ENV{MKLROOT})
    message(FATAL_ERROR
        "\n"
        "===============================================================\n"
        "ERROR: Intel oneMKL NOT found!\n"
        "===============================================================\n"
        "MKLROOT environment variable is not set.\n"
        "\n"
        "Please install Intel oneAPI Base Toolkit and load environment:\n"
        "  source /opt/intel/oneapi/setvars.sh\n"
        "\n"
        "Or use the installation script:\n"
        "  ./scripts/install-oneapi.sh\n"
        "===============================================================\n"
    )
endif()

set(MKL_ROOT $ENV{MKLROOT})
message(STATUS "✓ Found MKLROOT: ${MKL_ROOT}")

# Step 3: Configure MKL include and library paths
set(MKL_INCLUDE_DIRS "${MKL_ROOT}/include")

if(APPLE)
    set(MKL_LIB_DIR "${MKL_ROOT}/lib")
else()
    set(MKL_LIB_DIR "${MKL_ROOT}/lib/intel64")
endif()

# Step 4: Link oneMKL libraries (Intel threading layer for icpx)
target_include_directories(route PRIVATE ${MKL_INCLUDE_DIRS})
target_link_directories(route PRIVATE ${MKL_LIB_DIR})

# MKL library linking: lp64 interface + Intel thread + core
target_link_libraries(route
    mkl_intel_lp64      # 32-bit integer interface
    mkl_intel_thread    # Intel OpenMP threading (best for icpx)
    mkl_core            # MKL core functions
)

# Step 5: Link threading and math libraries
find_package(Threads REQUIRED)
target_link_libraries(route Threads::Threads)
target_link_libraries(route m dl)

# Step 6: Configure OpenMP for Intel compiler
target_compile_options(route PRIVATE -qopenmp)
target_link_options(route PRIVATE -qopenmp)

# Step 7: Define USE_ONEMKL macro for conditional compilation
target_compile_definitions(route PRIVATE USE_ONEMKL)

# Step 8: Add performance optimization flags for Intel icpx
target_compile_options(route PRIVATE
    -O3                          # Maximum optimization
    -march=native                # Use all CPU instructions available
    -mtune=native                # Tune for current CPU
    -fno-semantic-interposition  # Better optimization across translation units
    -finline-functions           # Aggressive function inlining
    -funroll-loops               # Loop unrolling
)

# Optional: Disable AVX-512 if thermal throttling is a concern
# Uncomment the line below if CPU frequency drops during execution
# target_compile_options(route PRIVATE -mno-avx512f)

message(STATUS "✓ oneMKL optimization ENABLED (with critical scalar function fixes)")
message(STATUS "  - MKL Include: ${MKL_INCLUDE_DIRS}")
message(STATUS "  - MKL Library: ${MKL_LIB_DIR}")
message(STATUS "  - Threading: mkl_intel_thread (Intel OpenMP)")
message(STATUS "=============================================================================")
message(STATUS "Build Configuration:")
message(STATUS "  Compiler: Intel ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "  oneMKL:   ${MKL_ROOT}")
message(STATUS "  OpenMP:   -qopenmp")
message(STATUS "  Optimize: USE_ONEMKL, -O3, -march=native")
message(STATUS "  Note:     scalar_sqrt/fabs use std lib (not VML) for performance")
message(STATUS "=============================================================================")