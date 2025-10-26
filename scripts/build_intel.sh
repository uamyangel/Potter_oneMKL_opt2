#!/bin/bash

#==============================================================================
# Potter FPGA Router - Intel Compiler Build Script
#==============================================================================
# This script automates the build process using Intel icpx compiler and oneMKL
#
# Usage:
#   ./scripts/build_intel.sh [clean] [release|debug] [-j N]
#
# Examples:
#   ./scripts/build_intel.sh clean release -j 40
#   ./scripts/build_intel.sh debug -j 32
#
#==============================================================================

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
BUILD_TYPE="Release"
CLEAN=false
PARALLEL_JOBS=8
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

#==============================================================================
# Parse arguments
#==============================================================================
while [[ $# -gt 0 ]]; do
    case $1 in
        clean)
            CLEAN=true
            shift
            ;;
        release|Release|RELEASE)
            BUILD_TYPE="Release"
            shift
            ;;
        debug|Debug|DEBUG)
            BUILD_TYPE="Debug"
            shift
            ;;
        -j)
            PARALLEL_JOBS="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Unknown argument: $1${NC}"
            echo "Usage: $0 [clean] [release|debug] [-j N]"
            exit 1
            ;;
    esac
done

#==============================================================================
# Print header
#==============================================================================
echo -e "${BLUE}=============================================================================${NC}"
echo -e "${BLUE}Potter FPGA Router - Intel Compiler Build${NC}"
echo -e "${BLUE}=============================================================================${NC}"
echo ""

#==============================================================================
# Step 1: Check Intel oneAPI environment
#==============================================================================
echo -e "${YELLOW}[1/5] Checking Intel oneAPI environment...${NC}"

# Function to find Intel compiler
find_intel_compiler() {
    if command -v icpx &> /dev/null; then
        echo "icpx"
    elif command -v icpc &> /dev/null; then
        echo "icpc"
    else
        echo ""
    fi
}

INTEL_COMPILER=$(find_intel_compiler)

# If Intel compiler not found, try to load oneAPI environment
if [ -z "$INTEL_COMPILER" ]; then
    echo -e "${YELLOW}Intel compiler not found in PATH, searching for oneAPI...${NC}"

    # Common oneAPI installation paths
    ONEAPI_PATHS=(
        "/xrepo/App/oneAPI/setvars.sh"
        "$HOME/intel/oneapi/setvars.sh"
        "/intel/oneapi/setvars.sh"
    )

    FOUND_ONEAPI=false
    for SETVARS_PATH in "${ONEAPI_PATHS[@]}"; do
        if [ -f "$SETVARS_PATH" ]; then
            echo -e "${GREEN}Found oneAPI at: $SETVARS_PATH${NC}"
            echo -e "${YELLOW}Loading oneAPI environment...${NC}"
            source "$SETVARS_PATH" --force > /dev/null 2>&1
            FOUND_ONEAPI=true
            break
        fi
    done

    if [ "$FOUND_ONEAPI" = false ]; then
        echo -e "${RED}=============================================================================${NC}"
        echo -e "${RED}ERROR: Intel oneAPI NOT found!${NC}"
        echo -e "${RED}=============================================================================${NC}"
        echo ""
        echo "Please install Intel oneAPI Base Toolkit:"
        echo "  https://www.intel.com/content/www/us/en/developer/tools/oneapi/base-toolkit.html"
        echo ""
        echo "Or manually load the environment:"
        echo "  source /xrepo/App/oneAPI/setvars.sh"
        echo ""
        exit 1
    fi

    # Recheck compiler after loading environment
    INTEL_COMPILER=$(find_intel_compiler)
fi

# Final check
if [ -z "$INTEL_COMPILER" ]; then
    echo -e "${RED}=============================================================================${NC}"
    echo -e "${RED}ERROR: Intel compiler (icpx/icpc) not found!${NC}"
    echo -e "${RED}=============================================================================${NC}"
    echo ""
    echo "Please ensure Intel oneAPI is properly installed and loaded."
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ Intel ${INTEL_COMPILER} compiler found: $(which ${INTEL_COMPILER})${NC}"

#==============================================================================
# Step 2: Display compiler and library information
#==============================================================================
echo ""
echo -e "${YELLOW}[2/5] Compiler and Library Information:${NC}"
echo -e "${BLUE}----------------------------------------${NC}"
${INTEL_COMPILER} --version | head -n 2

# Check MKLROOT
if [ -z "$MKLROOT" ]; then
    echo -e "${RED}ERROR: MKLROOT not set!${NC}"
    echo "Please load oneAPI environment: source /xrepo/App/oneAPI/setvars.sh"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ MKLROOT: $MKLROOT${NC}"

#==============================================================================
# Step 3: Clean build directory if requested
#==============================================================================
echo ""
echo -e "${YELLOW}[3/5] Build preparation...${NC}"

BUILD_DIR="${PROJECT_DIR}/build"

if [ "$CLEAN" = true ]; then
    if [ -d "$BUILD_DIR" ]; then
        echo "Cleaning build directory..."
        rm -rf "$BUILD_DIR"
        echo -e "${GREEN}✓ Clean complete${NC}"
    else
        echo "Build directory doesn't exist, skipping clean."
    fi
fi

mkdir -p "$BUILD_DIR"

#==============================================================================
# Step 4: Configure with CMake
#==============================================================================
echo ""
echo -e "${YELLOW}[4/5] Configuring project with CMake...${NC}"
echo "Build type: ${BUILD_TYPE}"
echo "Parallel jobs: ${PARALLEL_JOBS}"

cd "$PROJECT_DIR"

cmake -B "${BUILD_DIR}" \
      -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
      -DCMAKE_CXX_COMPILER="${INTEL_COMPILER}" \
      .

if [ $? -ne 0 ]; then
    echo -e "${RED}CMake configuration failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Configuration complete${NC}"

#==============================================================================
# Step 5: Build the project
#==============================================================================
echo ""
echo -e "${YELLOW}[5/5] Building project...${NC}"

cmake --build "${BUILD_DIR}" --parallel ${PARALLEL_JOBS}

if [ $? -ne 0 ]; then
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi

#==============================================================================
# Success
#==============================================================================
echo ""
echo -e "${GREEN}=============================================================================${NC}"
echo -e "${GREEN}✓ Build successful!${NC}"
echo -e "${GREEN}=============================================================================${NC}"
echo "Executable: ${BUILD_DIR}/route"
echo "Build type: ${BUILD_TYPE}"
echo "Compiler: ${INTEL_COMPILER}"

if [ -f "${BUILD_DIR}/route" ]; then
    EXECUTABLE_SIZE=$(du -h "${BUILD_DIR}/route" | cut -f1)
    echo "Executable size: ${EXECUTABLE_SIZE}"
fi

echo ""
echo -e "${BLUE}=============================================================================${NC}"
echo -e "${YELLOW}IMPORTANT: Performance Optimization Settings${NC}"
echo -e "${BLUE}=============================================================================${NC}"
echo ""
echo "Before running, ensure optimal performance with these settings:"
echo ""
echo "1. Set CPU to performance mode (requires sudo):"
echo -e "   ${GREEN}echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor${NC}"
echo ""
echo "2. Configure MKL threading (recommended for this application):"
echo -e "   ${GREEN}export MKL_NUM_THREADS=1${NC}"
echo -e "   ${GREEN}export OMP_NUM_THREADS=1${NC}"
echo -e "   ${GREEN}export MKL_DYNAMIC=FALSE${NC}"
echo ""
echo "3. Run the router:"
echo -e "   ${GREEN}./build/route -i input.phys -o output.phys -d xcvu3p.device -t 80${NC}"
echo ""
echo -e "${YELLOW}Note:${NC} This build uses optimized scalar math functions for performance."
echo "      MKL VML is NOT used for scalar operations to avoid overhead."
echo ""
echo -e "${BLUE}=============================================================================${NC}"
echo ""
echo "Quick test command (copy and paste):"
echo ""
echo -e "${GREEN}export MKL_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_DYNAMIC=FALSE${NC}"
echo -e "${GREEN}./build/route -i benchmarks/koios_dla_like_large_unrouted.phys -o benchmarks/koios_dla_like_large_routed.phys -t 80${NC}"
echo ""
echo -e "${BLUE}=============================================================================${NC}"
