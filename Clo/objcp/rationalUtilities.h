//
//  rationalUtilities.h
//  Clo
//
//  Created by cpjm on 05/04/2018.
//
//

#ifndef Clo_rationalUtilities_h
#define Clo_rationalUtilities_h

#include "gmp.h"
#include "mpria.h"



static inline void mpq_set_from_d(mpq_t z, double dvalue) {
    if (dvalue == -INFINITY) {
        MPRIA_MPQ_SET_NEG_INF(z);
    } else if (dvalue == +INFINITY) {
        MPRIA_MPQ_SET_POS_INF(z);
    } else {
        mpq_set_d(z, dvalue);
    }
    mpq_canonicalize(z);
}


extern void mpri_set_from_d(mpri_t z, double inf, double sup);

extern void mpri_set_from_q(mpri_t z, const mpq_t inf, const mpq_t sup);

static inline double mpq_to_d(const mpq_t q) {
    switch (mpria_mpq_is_infinite(q)) {
        case -1: return -INFINITY;
        case +1: return +INFINITY;
        default: return mpq_get_d(q);
    }
}

extern void mpri_print(const char *s, const mpri_t x, const char *m);

extern int mpri_is_empty(const mpri_t x);

extern void mpri_union(mpri_t z, const mpri_t x, const mpri_t y);

extern void mpri_intersection(mpri_t z, const mpri_t x, const mpri_t y);

extern int mpri_proj_inter(mpri_t x, const mpri_t y);

extern int mpri_proj_inter_infsup(mpri_t x, const mpq_t inf, const mpq_t sup);


#endif
