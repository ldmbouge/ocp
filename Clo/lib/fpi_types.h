
/************************************************/
/* fpi_types.h :                                */
/*   basic types for                            */
/*   floating point constraints                 */
/*                                              */
/* copyright Claude Michel                      */
/*                                              */
/************************************************/



#ifndef _FPI_TYPES_H
#define _FPI_TYPES_H

#include <stdio.h>

#include <math.h>
#include <float.h>

#ifdef __APPLE__
#include <limits.h>
#else
#include <fpu_control.h>
#include <values.h>
#endif

#include <fenv.h>


/* Minimum and maximum values a `signed long long int' can hold.  */
#ifndef LLONG_MAX
#   define LLONG_MAX    9223372036854775807LL
#endif
#ifndef LLONG_MIN
#   define LLONG_MIN    (-LLONG_MAX - 1LL)
#endif

/* Maximum value an `unsigned long long int' can hold.  (Minimum is 0.)  */
#ifndef ULLONG_MAX
#   define ULLONG_MAX   18446744073709551615ULL
#endif


#ifndef TRUE
#define TRUE 1
#endif
#ifndef FALSE
#define FALSE 0
#endif

#ifdef __cplusplus
extern "C"
{
#endif

typedef union {
  short short_nb;
  int int_nb;
  long long llong_nb;
  unsigned short ushort_nb;
  unsigned int uint_nb;
  unsigned long long ullong_nb;
  float float_nb;
  double double_nb;
  long double ldouble_nb;
} fp_number;

typedef long double internal_float;
typedef long double internal_double;

typedef struct {
  float inf;
  float sup;
} float_interval;

typedef struct {
  internal_float inf;
  internal_float sup;
} internal_float_interval;

typedef struct {
  double inf;
  double sup;
} double_interval;

typedef struct {
  internal_double inf;
  internal_double sup;
} internal_double_interval;

typedef struct {
  long double inf;
  long double sup;
} ldouble_interval;

typedef struct {
  short inf;
  short sup;
} short_interval;

typedef struct {
  unsigned short inf;
  unsigned short sup;
} ushort_interval;

typedef struct {
  int inf;
  int sup;
} int_interval;

typedef struct {
  unsigned int inf;
  unsigned int sup;
} uint_interval;

typedef struct {
  long long inf;
  long long sup;
} llong_interval;

typedef struct {
  unsigned long long inf;
  unsigned long long sup;
} ullong_interval;

#ifdef __cplusplus
}
#endif

#endif
