//
//  turbine2.m
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

void check_it_turbine2_d(double v, double w, double r, double z, ORRational* ez) {
   double cz = (((6.0 * v) - (((0.5 * v) * (((w * w) * r) * r)) / (1.0 - v))) - 2.5);
   
   if (cz != z)
      printf("WRONG: z  = % 24.24e while cz  = % 24.24e\n", z, cz);
   
   {
      mpq_t vq, wq, rq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14;
      
      mpq_inits(vq, wq, rq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, NULL);
      
      mpq_set_d(vq, v);
      mpq_set_d(wq, w);
      mpq_set_d(rq, r);
      
      mpq_set_d(tmp1, 6.0);
      mpq_mul(tmp2, tmp1, vq);
      mpq_set_d(tmp3, 0.5);
      mpq_mul(tmp4, tmp3, vq);
      mpq_mul(tmp5, wq, wq);
      mpq_mul(tmp6, tmp5, rq);
      mpq_mul(tmp7, tmp6, rq);
      mpq_mul(tmp8, tmp4, tmp7);
      mpq_set_d(tmp9, 1.0);
      mpq_sub(tmp10, tmp9, vq);
      mpq_div(tmp11, tmp8, tmp10);
      mpq_sub(tmp12, tmp2, tmp11);
      mpq_set_d(tmp13, 2.5);
      mpq_sub(tmp14, tmp12, tmp13);
      mpq_set(zq, tmp14);
      
      mpq_set_d(tmp0, z);
      mpq_sub(tmp1, zq, tmp0);
      if (mpq_cmp(tmp1, ez.rational) != 0){
         NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
         NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
      }
      mpq_clears(vq, wq, rq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, NULL);
   }
   
}

void turbine2_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      ORRational* zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> v = [ORFactory doubleVar:mdl low:-4.5 up:-0.3 elow:zero eup:zero name:@"v"];
      id<ORDoubleVar> w = [ORFactory doubleVar:mdl low:0.4 up:0.9 elow:zero eup:zero name:@"w"];
      id<ORDoubleVar> r = [ORFactory doubleVar:mdl low:3.8 up:7.8 elow:zero eup:zero name:@"r"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl];
      [zero release];
      
      [mdl add:[z set: [[[@(6.0) mul: v] sub: [[[@(0.5) mul: v] mul: [[[w mul: w] mul: r] mul: r]] div: [@(1.0) sub: v]]] sub: @(2.5)]]];
      
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
         NSLog(@"v : [%f;%f]±[%@;%@] (%s)",[cp minD:v],[cp maxD:v],[cp minDQ:v],[cp maxDQ:v],[cp bound:v] ? "YES" : "NO");
         NSLog(@"w : [%f;%f]±[%@;%@] (%s)",[cp minD:w],[cp maxD:w],[cp minDQ:w],[cp maxDQ:w],[cp bound:w] ? "YES" : "NO");
         NSLog(@"r : [%f;%f]±[%@;%@] (%s)",[cp minD:r],[cp maxD:r],[cp minDQ:r],[cp maxDQ:r],[cp bound:r] ? "YES" : "NO");
         NSLog(@"z : [%f;%f]±[%@;%@] (%s)",[cp minD:z],[cp maxD:z],[cp minDQ:z],[cp maxDQ:z],[cp bound:z] ? "YES" : "NO");
            if (search) check_it_turbine2_d(getDmin(v), getDmin(w), getDmin(r), getDmin(z), [cp minErrorDQ:z]);
      }];
   }
}

int main(int argc, const char * argv[]) {
   LOO_MEASURE_TIME(@"p"){
   turbine2_d(1, argc, argv);
   }
   return 0;
}
