//
//  sineOrder3.m
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

void check_it_sineOrder3_d(double x, double z, id<ORRational> ez) {
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

void sineOrder3_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> x = [ORFactory doubleVar:mdl low:-2 up:2 elow:zero eup:zero name:@"x"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      [zero release];
      
      [mdl add:[z set: [[@(0.954929658551372) mul: x] sub: [@(0.12900613773279798) mul: [[x mul: x] mul: x]]]]];
      
      [mdl add:[z lt: @(1.0)]];
      [mdl add:[z gt: @(-1.0)]];
      
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
         NSLog(@"x : [%f;%f]±[%@;%@] (%s)",[cp minD:x],[cp maxD:x],[cp minDQ:x],[cp maxDQ:x],[cp bound:x] ? "YES" : "NO");
         NSLog(@"z : [%f;%f]±[%@;%@] (%s)",[cp minD:z],[cp maxD:z],[cp minDQ:z],[cp maxDQ:z],[cp bound:z] ? "YES" : "NO");
         if (search) check_it_sineOrder3_d(getDmin(x), getDmin(z), [cp minErrorDQ:z]);
      }];
   }
}

int main(int argc, const char * argv[]) {
   LOO_MEASURE_TIME(@"p"){
   sineOrder3_d(0, argc, argv);
   }
   return 0;
}
