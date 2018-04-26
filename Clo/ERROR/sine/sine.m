//
//  sine.m
//  ORUtilities
//
//  Created by Remy Garcia on 11/04/2018.
//

#import <ORProgram/ORProgram.h>
#include "gmp.h"

#define printFvar(name, var) NSLog(@""name" : [% 20.20e, % 20.20e]f (%s)",[(id<CPFloatVar>)[cp concretize:var] min],[(id<CPFloatVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 20.20e, % 20.20e]q",[(id<CPFloatVar>)[cp concretize:var] minErrF],[(id<CPFloatVar>)[cp concretize:var] maxErrF]);
#define getFmin(var) [(id<CPFloatVar>)[cp concretize:var] min]
#define getFminErr(var) *[(id<CPFloatVar>)[cp concretize:var] minErr]

#define printDvar(name, var) NSLog(@""name" : [% 24.24e, % 24.24e]d (%s)",[(id<CPDoubleVar>)[cp concretize:var] min],[(id<CPDoubleVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 24.24e, % 24.24e]q",[(id<CPDoubleVar>)[cp concretize:var] minErrF],[(id<CPDoubleVar>)[cp concretize:var] maxErrF]);
#define getDmin(var) [(id<CPDoubleVar>)[cp concretize:var] min]
#define getDminErr(var) *[(id<CPDoubleVar>)[cp concretize:var] minErr]

void check_it_sine_d(double u, double v, double t, double t1, double z, ORRational ez) {
   double ct1 = 331.4 + (0.6 * t);
   double cz = ((-1.0 * t1) * v) / ((t1 + u) * (t1 + u));
   
   if (ct1 != t1)
      printf("WRONG: t1 = % 24.24e while ct1 = % 24.24e\n", t1, ct1);
   
   if (cz != z)
      printf("WRONG: z  = % 24.24e while cz  = % 24.24e\n", z, cz);
   
   {
      mpq_t uq, vq, tq, t1q, zq, tmp0, tmp1, tmp2;
      
      mpq_inits(uq, vq, tq, t1q, zq, tmp0, tmp1, tmp2, NULL);
      mpq_set_d(uq, u);
      mpq_set_d(vq, v);
      mpq_set_d(tq, t);
      mpq_set_d(tmp0, 0.6);
      mpq_mul(tmp1, tq, tmp0);
      mpq_set_d(tmp0, 331.4);
      mpq_add(t1q, tmp0, tmp1);
      mpq_set_d(tmp0, -1.0);
      mpq_mul(tmp1, tmp0, t1q);
      mpq_mul(tmp0, tmp1, vq);
      mpq_add(zq, t1q, uq);
      mpq_mul(tmp1, zq, zq);
      mpq_div(zq, tmp0, tmp1);
      mpq_set_d(tmp0, z);
      mpq_sub(tmp1, zq, tmp0);
      if (mpq_cmp(tmp1, ez) != 0)
         printf("WRONG: ez = % 24.24e while cze = % 24.24e\n", mpq_get_d(ez), mpq_get_d(tmp0));
      mpq_clears(uq, vq, tq, t1q, zq, tmp0, tmp1, tmp2, NULL);
   }
   
}

void sine_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORDoubleRange> r0 = [ORFactory doubleRange:mdl low:-1.57079632679 up:1.57079632679];
      id<ORDoubleVar> x = [ORFactory doubleVar:mdl domain:r0];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl];
      
      [mdl add:[z set: [[[x sub: [[[x mul: x] mul: x] div: @(6.0)]] plus: [[[[[x mul: x] mul: x] mul: x] mul: x] div: @(120.0)]] sub: [[[[[[x mul: x] mul: x] mul: x] mul: x] mul: x] div: @(5040.0)]]]];
      
      [mdl add:[z lt: @(1.0)]];
      [mdl add:[z gt: @(-1.0)]];
            
      NSLog(@"model: %@",mdl);
      id<ORDoubleVarArray> vs = [mdl doubleVars];
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp setMaxErrorDD:x maxErrorF:0.0];
      [cp setMinErrorDD:x minErrorF:0.0];
      [cp solve:^{
         if (search)
            [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
               [cp floatSplitD:i call:s withVars:x];
            }];
         NSLog(@"%@",cp);
         //NSLog(@"%@ (%s)",[p concretize:x],[p bound:x] ? "YES" : "NO");
         /* format of 8.8e to have the same value displayed as in FLUCTUAT */
         /* Use printRational(ORRational r) to print a rational inside the solver */
         printDvar("x", x);
         printDvar("z", z);
         //if (search) check_it_turbine3_d(getDmin(u), getDmin(v), getDmin(t), getDmin(t1), getDmin(z), getDminErr(z));
      }];
   }
}

int main(int argc, const char * argv[]) {
   sine_d(1, argc, argv);
   return 0;
}
