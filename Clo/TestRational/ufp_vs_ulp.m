//
//  ufp_vs_ulp.m
//  Clo
//
//  Created by Rémy Garcia on 16/10/2018.
//

#import <Foundation/Foundation.h>
#include "gmp.h"

int main(int argc, const char * argv[]) {
   /* f values
    1.23434297740459442139e-01
    7.17464813734306340313e-43
    1.12435501098632812500e+02
    */
   float f = powf(2, -140);
   double ulp_i = nextafterf(f, -INFINITY) - f;
   double ulp_s = nextafterf(f, +INFINITY) - f;
   double ufp = powf(2.0f, floorf(log2f(fabsf(f))));
   double ulp_from_ufp = powf(2.0f,1.0f-24.0f)*ufp;
   double ufp_from_ulp = powf(2.0f,24.0f-1.0f)*ulp_s;
   double min;
   
   NSLog(@"f     = %20.20e", f);
   NSLog(@"ulp_i = %20.20e", ulp_i);
   NSLog(@"ulp_s = %20.20e", ulp_s);
   NSLog(@"ufp   = %20.20e", ufp);
   NSLog(@"ulp_2 = %20.20e", ulp_from_ufp);
   NSLog(@"ufp_2 = %20.20e", ufp_from_ulp);
   min = MIN(ulp_s, ufp);
   NSLog(@"%s", min == ufp ? "ufp is smaller" : "ulp is smaller");
   
   float a = 12.3f;
   float b = 5.4f;
   double classic_bound = powf(2, -24);
   double new_bound = powf(2, -24) * powf(2.0f, floorf(log2f(fabsf(a + b))));
   double ulp_bound = (nextafterf((a + b), +INFINITY) - (a + b))/2.0;
   mpq_t a_q, b_q;
   mpq_inits(a_q, b_q, NULL);
   mpq_set_d(a_q, a);
   mpq_set_d(b_q, b);
   mpq_add(a_q, a_q, b_q);
   mpq_set_d(b_q, (a + b));
   mpq_sub(a_q, a_q, b_q);
   
   
   NSLog(@"");
   NSLog(@"a + b = %20.20e + %20.20e", a, b);
   NSLog(@"classic bound : %20.20e", classic_bound);
   NSLog(@"new bound     : %20.20e", new_bound);
   NSLog(@"ulp bound     : %20.20e", ulp_bound);
   NSLog(@"R - F bound   : %20.20e", mpq_get_d(a_q));
   
   mpq_clears(a_q, b_q, NULL);
   
   return 0;
}
