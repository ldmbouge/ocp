//
//  rationalUtilities.m
//  Clo
//
//  Created by cpjm on 05/04/2018.
//
//

#include "rationalUtilities.h"


void mpri_set_from_d(mpri_t z, double inf, double sup) {
    mpq_set_from_d(mpri_lepref(z), inf);
    mpq_set_from_d(mpri_repref(z), sup);
    mpq_canonicalize(mpri_lepref(z));
    mpq_canonicalize(mpri_repref(z));
}

void mpri_set_from_q(mpri_t z, const mpq_t inf, const mpq_t sup) {
    mpq_set(mpri_lepref(z), inf);
    mpq_set(mpri_repref(z), sup);
}


void mpri_print(const char *s, const mpri_t x, const char *m) {
    printf("%s[% 24.24e, % 24.24e]%s", s, mpq_to_d(mpri_lepref(x)), mpq_to_d(mpri_repref(x)), m);
}

int mpri_is_empty(const mpri_t x) {
    return (mpq_cmp(mpri_lepref(x), mpri_repref(x)) > 0);
}

void mpri_union(mpri_t z, const mpri_t x, const mpri_t y) {
    if (mpq_cmp(mpri_lepref(x), mpri_lepref(y)) >= 0)
        mpq_set(mpri_lepref(z),  mpri_lepref(y));
    else
        mpq_set(mpri_lepref(z),  mpri_lepref(x));
    
    if (mpq_cmp(mpri_repref(x), mpri_repref(y)) <= 0)
        mpq_set(mpri_repref(z),  mpri_repref(y));
    else
        mpq_set(mpri_repref(z),  mpri_repref(x));
}

void mpri_intersection(mpri_t z, const mpri_t x, const mpri_t y) {
    if (mpq_cmp(mpri_lepref(x), mpri_lepref(y)) <= 0)
        mpq_set(mpri_lepref(z),  mpri_lepref(y));
    else
        mpq_set(mpri_lepref(z),  mpri_lepref(x));
    
    if (mpq_cmp(mpri_repref(x), mpri_repref(y)) >= 0)
        mpq_set(mpri_repref(z),  mpri_repref(y));
    else
        mpq_set(mpri_repref(z),  mpri_repref(x));
}


int mpri_proj_inter(mpri_t x, const mpri_t y) {
    int changed = 0;
    double o_size = mpq_get_d(mpri_repref(x)) - mpq_get_d(mpri_lepref(x));
    
    if (mpq_cmp(mpri_lepref(x), mpri_lepref(y)) < 0) {
        mpq_set(mpri_lepref(x),  mpri_lepref(y));
        changed = 1;
    }
    
    if (mpq_cmp(mpri_repref(x), mpri_repref(y)) > 0) {
        mpq_set(mpri_repref(x),  mpri_repref(y));
        changed |= 2;
    }
    
    if(mpq_cmp(mpri_lepref(x), mpri_repref(x)) > 0) failNow(); // empty !
    
    
    if (changed) { // cpjm: Added to avoid some slow convergence issues
        double n_size = mpq_get_d(mpri_repref(x)) - mpq_get_d(mpri_lepref(x));
        
        if ((o_size - n_size)/o_size <= 0.05) changed = 0; // cpjm: Ignore change when less than 5%
    }
    
    return changed;
}

int mpri_proj_inter_infsup(mpri_t x, const mpq_t inf, const mpq_t sup) {
    int changed = 0;
    double o_size = mpq_get_d(mpri_repref(x)) - mpq_get_d(mpri_lepref(x));
    
    if (mpq_cmp(mpri_lepref(x), inf) < 0) {
        mpq_set(mpri_lepref(x),  inf);
        changed = 1;
    }
    
    if (mpq_cmp(mpri_repref(x), sup) > 0) {
        mpq_set(mpri_repref(x),  sup);
        changed |= 2;
    }
    
    if(mpq_cmp(mpri_lepref(x), mpri_repref(x)) > 0) failNow(); // empty !
    
    if (changed) { // cpjm: Added to avoid some slow convergence issues
        double n_size = mpq_get_d(mpri_repref(x)) - mpq_get_d(mpri_lepref(x));
        
        if ((o_size - n_size)/o_size <= 0.05) changed = 0; // cpjm: Ignore change when less than 5%
    }
    
    return changed;
}

