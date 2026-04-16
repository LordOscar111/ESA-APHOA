//
// MATLAB Compiler: 8.4 (R2022a)
// Date: Wed Oct 16 16:44:16 2024
// Arguments:
// "-B""macro_default""-W""cpplib:benchlib""-T""link:lib""benchmark_func"
//

#ifndef benchlib_h
#define benchlib_h 1

#if defined(__cplusplus) && !defined(mclmcrrt_h) && defined(__linux__)
#  pragma implementation "mclmcrrt.h"
#endif
#include "mclmcrrt.h"
#include "mclcppclass.h"
#ifdef __cplusplus
extern "C" { // sbcheck:ok:extern_c
#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_benchlib_C_API 
#define LIB_benchlib_C_API /* No special import/export declaration */
#endif

/* GENERAL LIBRARY FUNCTIONS -- START */

extern LIB_benchlib_C_API 
bool MW_CALL_CONV benchlibInitializeWithHandlers(
       mclOutputHandlerFcn error_handler, 
       mclOutputHandlerFcn print_handler);

extern LIB_benchlib_C_API 
bool MW_CALL_CONV benchlibInitialize(void);

extern LIB_benchlib_C_API 
void MW_CALL_CONV benchlibTerminate(void);

extern LIB_benchlib_C_API 
void MW_CALL_CONV benchlibPrintStackTrace(void);

/* GENERAL LIBRARY FUNCTIONS -- END */

/* C INTERFACE -- MLX WRAPPERS FOR USER-DEFINED MATLAB FUNCTIONS -- START */

extern LIB_benchlib_C_API 
bool MW_CALL_CONV mlxBenchmark_func(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

/* C INTERFACE -- MLX WRAPPERS FOR USER-DEFINED MATLAB FUNCTIONS -- END */

#ifdef __cplusplus
}
#endif


/* C++ INTERFACE -- WRAPPERS FOR USER-DEFINED MATLAB FUNCTIONS -- START */

#ifdef __cplusplus

/* On Windows, use __declspec to control the exported API */
#if defined(_MSC_VER) || defined(__MINGW64__)

#ifdef EXPORTING_benchlib
#define PUBLIC_benchlib_CPP_API __declspec(dllexport)
#else
#define PUBLIC_benchlib_CPP_API __declspec(dllimport)
#endif

#define LIB_benchlib_CPP_API PUBLIC_benchlib_CPP_API

#else

#if !defined(LIB_benchlib_CPP_API)
#if defined(LIB_benchlib_C_API)
#define LIB_benchlib_CPP_API LIB_benchlib_C_API
#else
#define LIB_benchlib_CPP_API /* empty! */ 
#endif
#endif

#endif

extern LIB_benchlib_CPP_API void MW_CALL_CONV benchmark_func(int nargout, mwArray& fit, const mwArray& x, const mwArray& func_num);

/* C++ INTERFACE -- WRAPPERS FOR USER-DEFINED MATLAB FUNCTIONS -- END */
#endif

#endif
