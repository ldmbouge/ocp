//
//  rationalUtilities.h
//  Clo
//
//  Created by remy on 05/04/2018.
//
//

#ifndef Clo_rationalUtilities_h
#define Clo_rationalUtilities_h

//#import <ORFoundation/ORFoundation.h>
#include "gmp.h"
#include "mpria.h"

/* DEFINITION OF RATIONAL EXTENDED TO INFINITY */
typedef struct {
   mpq_t rational;
   /* type :
    -2   -INFINITY
    -1   Negative number
    0   Zero
    1   Positive number
    2   INFINITY
    3   NaN
    */
   int  type;
} ORRational;

/*typedef struct {
   mpq_t rational;*/
   /* type :
    -2   -INFINITY
    -1   Negative number
     0   Zero
     1   Positive number
     2   INFINITY
     3   NaN
    */
   /*int  type;
} __ORRational*;*/

//typedef __ORRational* ORRational*[1];

/* DEFINITION OF RATIONAL INTERVAL */
typedef struct {
   ORRational inf;
   ORRational sup;
} ri;

/* RATIONAL FUNCTIONS */
extern void rational_init(ORRational* r);

extern void rational_clear(ORRational* r);

extern void rational_print(const ORRational* r);

extern char * rational_get_str(const ORRational* r);

extern void rational_set_d(ORRational* r, const double d);

extern void rational_set(ORRational* r, const ORRational* x);

extern double rational_get_d(const ORRational* r);

extern mpq_t* rational_get(ORRational* r);

extern void rational_addition(ORRational* z, const ORRational* x, const ORRational* y);

extern void rational_subtraction(ORRational* z, const ORRational* x, const ORRational* y);

extern void rational_multiplication(ORRational* z, const ORRational* x, const ORRational* y);

extern void rational_division(ORRational* z, const ORRational* x, const ORRational* y);

extern void rational_neg(ORRational* z, const ORRational* x);

extern void rational_abs(ORRational* z, const ORRational* x);

extern int rational_cmp(const ORRational* x, const ORRational* y);

extern int rational_cmp_ui(const ORRational* x, const long int num2, const long int den2);

extern int rational_lt(const ORRational* x, const ORRational* y);

extern int rational_gt(const ORRational* x, const ORRational* y);

extern int rational_leq(const ORRational* x, const ORRational* y);

extern int rational_geq(const ORRational* x, const ORRational* y);

extern int rational_eq(const ORRational* x, const ORRational* y);

extern int rational_neq(const ORRational* x, const ORRational* y);

/* RATIONAL INTERVAL FUNCTIONS */
extern void ri_set_d(ri* z, double inf, double sup);

extern void ri_set_q(ri* z, const ORRational* inf, const ORRational* sup);

extern void ri_set(ri* z, ri* x);

extern void ri_print(NSString *s, ri* x);

extern int ri_is_empty(const ri* x);

extern void ri_union(ri* z, const ri* x, const ri* y);

extern void ri_intersection(ri* z, const ri* x, const ri* y);

extern int ri_proj_inter(ri* x, const ri* y);

extern int ri_proj_inter_infsup(ri* x, const ORRational* inf, const ORRational* sup);

extern void ri_init(ri* a);

extern void ri_clear(ri* a);

extern void ri_add(ri* a, const ri* b, const ri* c);

extern void ri_sub(ri* a, const ri* b, const ri* c);

extern void ri_mul(ri* a, const ri* b, const ri* c);

extern void ri_div(ri* a, const ri* b, const ri* c);

extern void ri_neg(ri* z, const ri* x);

extern void ri_abs(ri* z, const ri* x);

extern int ri_cmp(const ri* x, const ri* y);

extern int ri_lt(const ri* x, const ri* y);

extern int ri_gt(const ri* x, const ri* y);

extern int ri_leq(const ri* x, const ri* y);

extern int ri_geq(const ri* x, const ri* y);

extern int ri_eq(const ri* x, const ri* y);

extern int ri_neq(const ri* x, const ri* y);

#endif
