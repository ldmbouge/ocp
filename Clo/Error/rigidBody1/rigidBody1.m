//
//  rigidBody1.m
//  Clo
//
//  Created by Remy Garcia on 11/04/2018.
//

//
//  carbonGas.m
//
//  Created by Remy Garcia on 06/03/2018.
//
#import <ORProgram/ORProgram.h>
#include "gmp.h"

#define LOO_MEASURE_TIME(__message) \
for (CFAbsoluteTime startTime##__LINE__ = CFAbsoluteTimeGetCurrent(), endTime##__LINE__ = 0.0; endTime##__LINE__ == 0.0; \
NSLog(@"'%@' took %.3fs", (__message), (endTime##__LINE__ = CFAbsoluteTimeGetCurrent()) - startTime##__LINE__))

#define printFvar(name, var) NSLog(@""name" : [% 20.20e, % 20.20e]f (%s)",[(id<CPFloatVar>)[cp concretize:var] min],[(id<CPFloatVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 20.20e, % 20.20e]q",[(id<CPFloatVar>)[cp concretize:var] minErrF],[(id<CPFloatVar>)[cp concretize:var] maxErrF]);
#define getFmin(var) [(id<CPFloatVar>)[cp concretize:var] min]
#define getFminErr(var) *[(id<CPFloatVar>)[cp concretize:var] minErr]

#define printDvar(name, var) NSLog(@""name" : [% 24.24e, % 24.24e]d (%s)",[(id<CPDoubleVar>)[cp concretize:var] min],[(id<CPDoubleVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 3.2e, % 3.2e]q",[(id<CPDoubleVar>)[cp concretize:var] minErrF],[(id<CPDoubleVar>)[cp concretize:var] maxErrF]);
#define getDmin(var) [(id<CPDoubleVar>)[cp concretize:var] min]
#define getDminErr(var) *[(id<CPDoubleVar>)[cp concretize:var] minErr]

void check_it_rigidBody1_d(double x1, double x2, double x3, double z, id<ORRational> ez) {
   double cz = (((-(x1 * x2) - ((2.0 * x2) * x3)) - x1) - x3);
   
   if (cz != z)
      printf("WRONG: z  = % 24.24e while cz  = % 24.24e\n", z, cz);
   
   {
      mpq_t x1q, x2q, x3q, zq, tmp0, tmp1, tmp2;
      
      mpq_inits(x1q, x2q, x3q, zq, tmp0, tmp1, tmp2, NULL);
      mpq_set_d(x1q, x1);
      mpq_set_d(x2q, x2);
      mpq_set_d(x3q, x3);
      mpq_neg(tmp0, x1q);
      mpq_mul(tmp1, tmp0, x2q);
      mpq_set_d(tmp0, 2.0);
      mpq_mul(tmp2, tmp0, x2q);
      mpq_mul(tmp0, tmp2, x3q);
      mpq_sub(tmp2, tmp1, tmp0);
      mpq_sub(tmp1, tmp2, x1q);
      mpq_sub(zq, tmp1, x3q);
      mpq_set_d(tmp0, z);
      mpq_sub(tmp1, zq, tmp0);
      if (mpq_cmp(tmp1, ez.rational) != 0){
         NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
         NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
      }
      mpq_clears(x1q, x2q, x3q, zq, tmp0, tmp1, tmp2, NULL);
   }
   
}

void rigidBody1_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> x1 = [ORFactory doubleVar:mdl low:-15.0 up:15.0 elow:zero eup:zero name:@"x1"];
      id<ORDoubleVar> x2 = [ORFactory doubleVar:mdl low:-15.0 up:15.0 elow:zero eup:zero name:@"x2"];
      id<ORDoubleVar> x3 = [ORFactory doubleVar:mdl low:-15.0 up:15.0 elow:zero eup:zero name:@"x3"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl];
      [zero release];
      
      //[mdl add:[z set: [[[[@(0.0) sub: [x1 mul: x2]] sub: [[@(2.0) mul: x2] mul: x3]] sub: x1] sub: x3]]];
      
      [mdl add:[z set: [[[[[x1 mul: x2] minus] sub: [[@(2.0) mul: x2] mul: x3]] sub: x1] sub: x3]]];
      
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
         NSLog(@"z : [%f;%f]±[%@;%@] (%s)",[cp minD:z],[cp maxD:z],[cp minDQ:z],[cp maxDQ:z],[cp bound:z] ? "YES" : "NO");
         if (search) check_it_rigidBody1_d(getDmin(x1), getDmin(x2), getDmin(x3), getDmin(z), [cp minErrorDQ:z]);
      }];
   }
}

void rigidBody1_f(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0f];
      id<ORFloatVar> x1 = [ORFactory floatVar:mdl low:-15.0f up:15.0f elow:zero eup:zero name:@"x1"];
      id<ORFloatVar> x2 = [ORFactory floatVar:mdl low:-15.0f up:15.0f elow:zero eup:zero name:@"x2"];
      id<ORFloatVar> x3 = [ORFactory floatVar:mdl low:-15.0f up:15.0f elow:zero eup:zero name:@"x3"];
      id<ORFloatVar> z = [ORFactory floatVar:mdl];
      [zero release];
      
      //[mdl add:[z set: [[[[@(0.0) sub: [x1 mul: x2]] sub: [[@(2.0) mul: x2] mul: x3]] sub: x1] sub: x3]]];
      
      [mdl add:[z set: [[[[[x1 mul: x2] minus] sub: [[@(2.0f) mul: x2] mul: x3]] sub: x1] sub: x3]]];
      
      NSLog(@"model: %@",mdl);
      id<ORFloatVarArray> vs = [mdl floatVars];
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
         if (search)
            [cp lexicalOrderedSearch:vars do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [cp floatSplit:i withVars:x];
            }];
         NSLog(@"%@",cp);
         NSLog(@"x1 : [%f;%f]±[%@;%@] (%s)",[cp minF:x1],[cp maxF:x1],[cp minFQ:x1],[cp maxFQ:x1],[cp bound:x1] ? "YES" : "NO");
         NSLog(@"x2 : [%f;%f]±[%@;%@] (%s)",[cp minF:x2],[cp maxF:x2],[cp minFQ:x2],[cp maxFQ:x2],[cp bound:x2] ? "YES" : "NO");
         NSLog(@"x3 : [%f;%f]±[%@;%@] (%s)",[cp minF:x3],[cp maxF:x3],[cp minFQ:x3],[cp maxFQ:x3],[cp bound:x3] ? "YES" : "NO");
         NSLog(@"z : [%f;%f]±[%@;%@] (%s)",[cp minF:z],[cp maxF:z],[cp minFQ:z],[cp maxFQ:z],[cp bound:z] ? "YES" : "NO");
         if (search) check_it_rigidBody1_d(getFmin(x1), getFmin(x2), getFmin(x3), getFmin(z), [cp minErrorFQ:z]);
      }];
   }
}

void rigidBody1_d_QF(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> x1 = [ORFactory doubleVar:mdl low:-15.0 up:15.0 elow:zero eup:zero name:@"x1"];
      id<ORDoubleVar> x2 = [ORFactory doubleVar:mdl low:-15.0 up:15.0 elow:zero eup:zero name:@"x2"];
      id<ORDoubleVar> x3 = [ORFactory doubleVar:mdl low:-15.0 up:15.0 elow:zero eup:zero name:@"x3"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl];
      
      id<ORRationalVar> x1Q = [ORFactory rationalVar:mdl name:@"x1Q"];
      id<ORRationalVar> x2Q = [ORFactory rationalVar:mdl name:@"x2Q"];
      id<ORRationalVar> x3Q = [ORFactory rationalVar:mdl name:@"x3Q"];
      id<ORRationalVar> zQ = [ORFactory rationalVar:mdl name:@"zQ"];
      id<ORRationalVar> zq = [ORFactory rationalVar:mdl name:@"zq"];
      id<ORRationalVar> ez = [ORFactory rationalVar:mdl name:@"ez"];
      id<ORRationalVar> Zero = [ORFactory rationalVar:mdl low:zero up:zero name:@"ez"];
      [zero set_d: 2.0];
      id<ORRationalVar> two = [ORFactory rationalVar:mdl low:zero up:zero name:@"ez"];
      
      
      [mdl add:[ORFactory channel:x1 with:x1Q]];
      [mdl add:[ORFactory channel:x2 with:x2Q]];
      [mdl add:[ORFactory channel:x3 with:x3Q]];
      [mdl add:[ORFactory channel:z with:zq]];

      [zero release];
      
      [mdl add:[z set: [[[[@(0.0) sub: [x1 mul: x2]] sub: [[@(2.0) mul: x2] mul: x3]] sub: x1] sub: x3]]];
      
      [mdl add:[zQ eq: [[[[Zero sub: [x1Q mul: x2Q]] sub: [[two mul: x2Q] mul: x3Q]] sub: x1Q] sub: x3Q]]];
      
      [mdl add:[ez eq:[zQ sub: zq]]];

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
         NSLog(@"z : [%f;%f]±[%@;%@] (%s)",[cp minD:z],[cp maxD:z],[cp minDQ:z],[cp maxDQ:z],[cp bound:z] ? "YES" : "NO");
         NSLog(@"");
         NSLog(@"x1Q: [%@;%@] (%s)",[cp minQ:x1Q],[cp maxQ:x1Q],[cp bound:x1Q] ? "YES" : "NO");
         NSLog(@"x2Q: [%@;%@] (%s)",[cp minQ:x2Q],[cp maxQ:x2Q],[cp bound:x1Q] ? "YES" : "NO");
         NSLog(@"x3Q: [%@;%@] (%s)",[cp minQ:x3Q],[cp maxQ:x3Q],[cp bound:x1Q] ? "YES" : "NO");
         NSLog(@"zQ: [%@;%@] (%s)",[cp minQ:zQ],[cp maxQ:zQ],[cp bound:zQ] ? "YES" : "NO");
         NSLog(@"ez: [%@;%@] (%s)",[cp minQ:ez],[cp maxQ:ez],[cp bound:ez] ? "YES" : "NO");


         if (search) check_it_rigidBody1_d(getDmin(x1), getDmin(x2), getDmin(x3), getDmin(z), [cp minErrorDQ:z]);
      }];
   }
}

int main(int argc, const char * argv[]) {
   LOO_MEASURE_TIME(@"d"){
   rigidBody1_d(0, argc, argv);
   //rigidBody1_f(0, argc, argv);
   //rigidBody1_d_QF(1, argc, argv);
   }
   return 0;
}
