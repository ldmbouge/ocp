//
//  kepler0.m
//  Clo
//
//  Created by Remy Garcia on 09/10/2019.
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

void check_it_kepler0_d(double x, double z, id<ORRational> ez) {
   double cz = ((0.954929658551372 * x) - (0.12900613773279798 * ((x * x) * x)));
   
   if (cz != z)
      printf("WRONG: z  = % 24.24e while cz  = % 24.24e\n", z, cz);
   
   {
      mpq_t xq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7;
      
      mpq_inits(xq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, NULL);
      mpq_set_d(xq, x);
 
      mpq_set_d(tmp1, 0.954929658551372);
      mpq_mul(tmp2, tmp1, xq);
      mpq_set_d(tmp3, 0.12900613773279798);
      mpq_mul(tmp4, xq, xq);
      mpq_mul(tmp5, tmp4, xq);
      mpq_mul(tmp6, tmp3, tmp5);
      mpq_sub(tmp7, tmp2, tmp6);
      mpq_set(zq, tmp7);
      
      mpq_set_d(tmp0, z);
      mpq_sub(tmp1, zq, tmp0);
      if (mpq_cmp(tmp1, ez.rational) != 0){
         NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
         NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
      }
      mpq_clears(xq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, NULL);
   }
   
}

void kepler0_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> x1 = [ORFactory doubleVar:mdl low:4 up:159/25 elow:zero eup:zero name:@"x"];
      id<ORDoubleVar> x2 = [ORFactory doubleVar:mdl low:4 up:159/25 elow:zero eup:zero name:@"x"];
      id<ORDoubleVar> x3 = [ORFactory doubleVar:mdl low:4 up:159/25 elow:zero eup:zero name:@"x"];
      id<ORDoubleVar> x4 = [ORFactory doubleVar:mdl low:4 up:159/25 elow:zero eup:zero name:@"x"];
      id<ORDoubleVar> x5 = [ORFactory doubleVar:mdl low:4 up:159/25 elow:zero eup:zero name:@"x"];
      id<ORDoubleVar> x6 = [ORFactory doubleVar:mdl low:4 up:159/25   elow:zero eup:zero name:@"x"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      [zero release];
      
      // x1*x4(-x1+x2+x3-x4+x5+x6) + x2*x5(x1-x2+x3+x4-x5+x6) + x3*x6(x1+x2-x3+x4+x5-x6) - x2*x3*x4 - x1*x3*x5 - x1*x2*x6 - x4*x5*x6
      
      [mdl add:[z set: [[[[[[[[x1 mul: x4] mul: [[[[[[x1 minus] plus: x2] plus: x3] sub: x4] plus: x5] plus: x6] ] plus: [[x2 mul: x5] mul:[[[[[x1 sub: x2] plus: x3] plus: x4] sub: x5] plus: x6]]] plus: [[x3 mul: x6] mul: [[[[[x1 plus: x2] sub: x3] plus: x4] plus: x5] sub: x6]]] sub: [[x2 mul: x3] mul: x4]] sub: [[x1 mul: x3] mul: x5]] sub: [[x1 mul: x2] mul: x6]] sub: [[x4 mul: x5] mul: x6]]]];
      
      NSLog(@"model: %@",mdl);
      id<ORDoubleVarArray> vs = [mdl doubleVars];
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
         if (search)
            [cp lexicalOrderedSearch:vars do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [cp floatSplit:i withVars:x];
            }];
         NSLog(@"%@",cp);
         NSLog(@"x1 : [%f;%f]±[%@;%@] (%s)",[cp minD:x1],[cp maxD:x1],[cp minDQ:x1],[cp maxDQ:x1],[cp bound:x1] ? "YES" : "NO");
         NSLog(@"x2 : [%f;%f]±[%@;%@] (%s)",[cp minD:x2],[cp maxD:x2],[cp minDQ:x2],[cp maxDQ:x2],[cp bound:x2] ? "YES" : "NO");
         NSLog(@"x3 : [%f;%f]±[%@;%@] (%s)",[cp minD:x3],[cp maxD:x3],[cp minDQ:x3],[cp maxDQ:x3],[cp bound:x3] ? "YES" : "NO");
         NSLog(@"x4 : [%f;%f]±[%@;%@] (%s)",[cp minD:x4],[cp maxD:x4],[cp minDQ:x4],[cp maxDQ:x4],[cp bound:x4] ? "YES" : "NO");
         NSLog(@"x5 : [%f;%f]±[%@;%@] (%s)",[cp minD:x5],[cp maxD:x5],[cp minDQ:x5],[cp maxDQ:x5],[cp bound:x5] ? "YES" : "NO");
         NSLog(@"x6 : [%f;%f]±[%@;%@] (%s)",[cp minD:x6],[cp maxD:x6],[cp minDQ:x6],[cp maxDQ:x6],[cp bound:x6] ? "YES" : "NO");

         NSLog(@"z : [%f;%f]±[%@;%@] (%s)",[cp minD:z],[cp maxD:z],[cp minDQ:z],[cp maxDQ:z],[cp bound:z] ? "YES" : "NO");
         //if (search) check_it_sineOrder3_d(getDmin(x1), getDmin(x1) getDmin(z), [cp minErrorDQ:z]);
      }];
   }
}

int main(int argc, const char * argv[]) {
   LOO_MEASURE_TIME(@"p"){
   kepler0_d(0, argc, argv);
   }
   return 0;
}
