//
// MATLAB Compiler: 8.4 (R2022a)
// Date: Wed Oct 16 16:45:10 2024
// Arguments:
// "-B""macro_default""-W""cpplib:bchecklib""-T""link:lib""boundaryCheck"
//

#ifndef bchecklib_h
#define bchecklib_h 1

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
#ifndef LIB_bchecklib_C_API 
#define LIB_bchecklib_C_API /* No special import/export declaration */
#endif

/* GENERAL LIBRARY FUNCTIONS -- START */

extern LIB_bchecklib_C_API 
bool MW_CALL_CONV bchecklibInitializeWithHandlers(
       mclOutputHandlerFcn error_handler, 
       mclOutputHandlerFcn print_handler);

extern LIB_bchecklib_C_API 
bool MW_CALL_CONV bchecklibInitialize(void);

extern LIB_bchecklib_C_API 
void MW_CALL_CONV bchecklibTerminate(void);

extern LIB_bchecklib_C_API 
void MW_CALL_CONV bchecklibPrintStackTrace(void);

/* GENERAL LIBRARY FUNCTIONS -- END */

/* C INTERFACE -- MLX WRAPPERS FOR USER-DEFINED MATLAB FUNCTIONS -- START */

extern LIB_bchecklib_C_API 
bool MW_CALL_CONV mlxBoundaryCheck(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

/* C INTERFACE -- MLX WRAPPERS FOR USER-DEFINED MATLAB FUNCTIONS -- END */

#ifdef __cplusplus
}
#endif


/* C++ INTERFACE -- WRAPPERS FOR USER-DEFINED MATLAB FUNCTIONS -- START */

#ifdef __cplusplus

/* On Windows, use __declspec to control the exported API */
#if defined(_MSC_VER) || defined(__MINGW64__)

#ifdef EXPORTING_bchecklib
#define PUBLIC_bchecklib_CPP_API __declspec(dllexport)
#else
#define PUBLIC_bchecklib_CPP_API __declspec(dllimport)
#endif

#define LIB_bchecklib_CPP_API PUBLIC_bchecklib_CPP_API

#else

#if !defined(LIB_bchecklib_CPP_API)
#if defined(LIB_bchecklib_C_API)
#define LIB_bchecklib_CPP_API LIB_bchecklib_C_API
#else
#define LIB_bchecklib_CPP_API /* empty! */ 
#endif
#endif

#endif

extern LIB_bchecklib_CPP_API void MW_CALL_CONV boundaryCheck(int nargout, mwArray& X, const mwArray& X_in1, const mwArray& lb, const mwArray& ub);

/* C++ INTERFACE -- WRAPPERS FOR USER-DEFINED MATLAB FUNCTIONS -- END */
#endif

#endif
