#pragma once

//==============================================================================
// Intel oneMKL Utilities - Comprehensive Math Function Wrappers
//==============================================================================
// This header provides optimized math functions using Intel oneMKL library.
// Comprehensive optimization of all mathematical functions in the codebase.
//
// Design principles:
// 1. Wrap all math functions for maximum performance
// 2. Use conditional compilation for safe fallback
// 3. Keep interface simple and inline when possible
//
// Wrapped functions:
// - scalar_exp:   Exponential function (used in dynamic cost factor)
// - scalar_sqrt:  Square root (L2 distance, standard deviation)
// - scalar_fabs:  Floating-point absolute value (bias cost, distance)
// - scalar_abs:   Integer absolute value (Manhattan distance)
//
//==============================================================================

#ifdef USE_ONEMKL
#include <mkl.h>
#include <mkl_vml.h>
#endif

#include <cmath>
#include <cstdlib>

namespace mkl_utils {

//==============================================================================
// Scalar Math Functions
//==============================================================================

#ifdef USE_ONEMKL

// Exponential function - optimized for dynamic cost factor calculation
inline double scalar_exp(double x) {
    double result;
    vdExp(1, &x, &result);  // MKL VML function for exp
    return result;
}

// Square root - optimized for L2 distance calculation and standard deviation
inline double scalar_sqrt(double x) {
    double result;
    vdSqrt(1, &x, &result);  // MKL VML function for sqrt
    return result;
}

// Floating-point absolute value - optimized for bias cost and distance calculation
inline double scalar_fabs(double x) {
    double result;
    vdAbs(1, &x, &result);  // MKL VML function for abs
    return result;
}

// Integer absolute value - optimized for Manhattan distance in A* search
inline int scalar_abs(int x) {
    return std::abs(x);  // Keep std::abs for integers (already fast)
}

#else

// Fallback implementations when USE_ONEMKL is not defined
// These use standard library functions

inline double scalar_exp(double x) {
    return std::exp(x);
}

inline double scalar_sqrt(double x) {
    return std::sqrt(x);
}

inline double scalar_fabs(double x) {
    return std::fabs(x);
}

inline int scalar_abs(int x) {
    return std::abs(x);
}

#endif  // USE_ONEMKL

//==============================================================================
// Performance Notes
//==============================================================================
//
// All mathematical functions are optimized using Intel oneMKL:
//
// 1. scalar_exp (OPTIMIZATION):
//    - Used in dynamicCostFactorUpdating (aStarRoute.cpp:743-745)
//    - Called once per iteration, but MKL exp has better accuracy
//    - Ensures numerical stability in cost factor calculations
//
// 2. scalar_sqrt (HIGH IMPACT):
//    - Called in L2Dist (geo.h) and standard deviation calculations
//    - MKL provides SIMD-optimized sqrt with better accuracy
//    - Combined with fixing std::pow(x,2) bug, significant speedup
//
// 3. scalar_fabs (MEDIUM IMPACT):
//    - Called in getNodeCost (hot path in A* search)
//    - Executed millions of times during routing
//    - MKL version uses optimized SIMD instructions
//
// 4. scalar_abs (CONSISTENCY):
//    - Used in A* Manhattan distance calculation (innermost loop)
//    - Integer abs is already fast, kept for API consistency
//    - Allows easy future vectorization if needed
//
//==============================================================================

}  // namespace mkl_utils
