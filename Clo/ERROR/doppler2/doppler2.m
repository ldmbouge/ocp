//
//  doppler2.m
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

void check_it_doppler2_d(double u, double v, double t, double t1, double z, id<ORRational> ez) {
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
      
      if (mpq_cmp(tmp1, ez.rational) != 0){
         NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
         NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
      }
      mpq_clears(uq, vq, tq, t1q, zq, tmp0, tmp1, tmp2, NULL);
   }
   
}

void doppler2_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> u = [ORFactory doubleVar:mdl low:-125.0 up:125.0 elow:zero eup:zero name:@"u"];
      id<ORDoubleVar> v = [ORFactory doubleVar:mdl low:15.0 up:25000.0 elow:zero eup:zero name:@"v"];
      id<ORDoubleVar> t = [ORFactory doubleVar:mdl low:-40.0 up:60.0 elow:zero eup:zero name:@"t"];
      id<ORDoubleVar> t1 = [ORFactory doubleVar:mdl name:@"t1"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      [zero release];
      
      [mdl add:[t1 set: [@(331.4) plus:[@(0.6) mul: t]]]];
      [mdl add:[z set: [[[@(-1.0) mul: t1] mul: v] div: [[t1 plus: u] mul: [t1 plus: u]]]]];
      
      NSLog(@"model: %@",mdl);
      id<ORDoubleVarArray> vs = [mdl doubleVars];
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
         if (search)
            [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
               [cp floatSplitD:i call:s withVars:x];
            }];
         NSLog(@"%@",cp);
         //NSLog(@"%@ (%s)",[p concretize:x],[p bound:x] ? "YES" : "NO");
         /* format of 8.8e to have the same value displayed as in FLUCTUAT */
         /* Use printRational(ORRational r) to print a rational inside the solver */
         NSLog(@"u : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:u],[cp maxD:u],[cp minDQ:u],[cp maxDQ:u],[cp bound:u] ? "YES" : "NO");
         NSLog(@"v : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:v],[cp maxD:v],[cp minDQ:v],[cp maxDQ:v],[cp bound:v] ? "YES" : "NO");
         NSLog(@"t : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:t],[cp maxD:t],[cp minDQ:t],[cp maxDQ:t],[cp bound:t] ? "YES" : "NO");
         NSLog(@"t1 : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:t1],[cp maxD:t1],[cp minDQ:t1],[cp maxDQ:t1],[cp bound:t1] ? "YES" : "NO");
         NSLog(@"z : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:z],[cp maxD:z],[cp minDQ:z],[cp maxDQ:z],[cp bound:z] ? "YES" : "NO");
         if (search) check_it_doppler2_d(getDmin(u), getDmin(v), getDmin(t), getDmin(t1), getDmin(z), [cp minErrorDQ:z]);
      }];
   }
}

int main(int argc, const char * argv[]) {
   LOO_MEASURE_TIME(@"r"){
   doppler2_d(1, argc, argv);
   }
   return 0;
}
