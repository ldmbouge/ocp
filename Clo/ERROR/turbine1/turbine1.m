//
//  turbine1.m
//  Clo
//
//  Created by Remy Garcia on 11/04/2018.
//

#import <ORProgram/ORProgram.h>
#include "gmp.h"

#define LOO_MEASURE_TIME(__message) \
for (CFAbsoluteTime startTime##__LINE__ = CFAbsoluteTimeGetCurrent(), endTime##__LINE__ = 0.0; endTime##__LINE__ == 0.0; \
NSLog(@"'%@' took %.3fs", (__message), (endTime##__LINE__ = CFAbsoluteTimeGetCurrent()) - startTime##__LINE__))

#define printFvar(name, var) NSLog(@""name" : [% 20.20e, % 20.20e]f (%s)",[(id<CPFloatVar>)[cp concretize:var] min],[(id<CPFloatVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 20.20e, % 20.20e]q",[(id<CPFloatVar>)[cp concretize:var] minErrF],[(id<CPFloatVar>)[cp concretize:var] maxErrF]);
#define getFmin(var) [(id<CPFloatVar>)[cp concretize:var] min]
#define getFminErr(var) *[(id<CPFloatVar>)[cp concretize:var] minErr]

#define printDvar(name, var) NSLog(@""name" : [% 24.24e, % 24.24e]d (%s)",[(id<CPDoubleVar>)[cp concretize:var] min],[(id<CPDoubleVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 1.2e, % 1.2e]q",[(id<CPDoubleVar>)[cp concretize:var] minErrF],[(id<CPDoubleVar>)[cp concretize:var] maxErrF]);
#define getDmin(var) [(id<CPDoubleVar>)[cp concretize:var] min]
#define getDminErr(var) *[(id<CPDoubleVar>)[cp concretize:var] minErr]

void check_it_turbine1_d(double u, double v, double t, double t1, double z, ORRational ez) {
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

void turbine1_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORDoubleRange> r0 = [ORFactory doubleRange:mdl low:-4.5 up:-0.3];
      id<ORDoubleRange> r1 = [ORFactory doubleRange:mdl low:0.4 up:0.9];
      id<ORDoubleRange> r2 = [ORFactory doubleRange:mdl low:3.8 up:7.8];
      id<ORDoubleVar> v = [ORFactory doubleVar:mdl domain:r0];
      id<ORDoubleVar> w = [ORFactory doubleVar:mdl domain:r1];
      id<ORDoubleVar> r = [ORFactory doubleVar:mdl domain:r2];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl];
      
      [mdl add:[z set: [[[@(3.0) plus: [@(2.0) div: [r mul: r]]] sub: [[[@(0.125) mul: [@(3.0) sub: [@(2.0) mul: v]]] mul: [[[w mul: w] mul: r] mul: r]] div: [@(1.0) sub: v]]] sub: @(4.5)]]];
      
      NSLog(@"model: %@",mdl);
      id<ORDoubleVarArray> vs = [mdl doubleVars];
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp setMaxErrorDD:v maxErrorF:0.0];
      [cp setMinErrorDD:v minErrorF:0.0];
      [cp setMaxErrorDD:w maxErrorF:0.0];
      [cp setMinErrorDD:w minErrorF:0.0];
      [cp setMaxErrorDD:r maxErrorF:0.0];
      [cp setMinErrorDD:r minErrorF:0.0];
      [cp setMinErrorDD:z minErrorF:nextafter(0.0f, +INFINITY)];
      //[cp setMaxErrorDD:z maxErrorF:0.0];
      //[cp setMinErrorDD:z minErrorF:0.0];
      [cp solve:^{
         if (search)
            [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
               [cp floatSplitD:i call:s withVars:x];
            }];
         NSLog(@"%@",cp);
         //NSLog(@"%@ (%s)",[p concretize:x],[p bound:x] ? "YES" : "NO");
         /* format of 8.8e to have the same value displayed as in FLUCTUAT */
         /* Use printRational(ORRational r) to print a rational inside the solver */
         printDvar("v", v);
         printDvar("w", w);
         printDvar("r", r);
         printDvar("z", z);
         //if (search) check_it_turbine3_d(getDmin(u), getDmin(v), getDmin(t), getDmin(t1), getDmin(z), getDminErr(z));
      }];
   }
}

int main(int argc, const char * argv[]) {
   LOO_MEASURE_TIME(@"g"){
   turbine1_d(1, argc, argv);
   }
   return 0;
}
