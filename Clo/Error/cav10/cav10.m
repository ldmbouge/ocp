//
//  cav10.m
//  Clo
//
//  Created by Rémy Garcia on 28/04/2019.
//

#import <ORProgram/ORProgram.h>
#include "gmp.h"
#include <signal.h>
#include <stdlib.h>
#include <time.h>

#define LOO_MEASURE_TIME(__message) \
for (CFAbsoluteTime startTime##__LINE__ = CFAbsoluteTimeGetCurrent(), endTime##__LINE__ = 0.0; endTime##__LINE__ == 0.0; \
NSLog(@"'%@' took %.3fs", (__message), (endTime##__LINE__ = CFAbsoluteTimeGetCurrent()) - startTime##__LINE__))

#define printFvar(name, var) NSLog(@""name" : [% 20.20e, % 20.20e]f (%s)",[(id<CPFloatVar>)[cp concretize:var] min],[(id<CPFloatVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 20.20e, % 20.20e]q",[(id<CPFloatVar>)[cp concretize:var] minErrF],[(id<CPFloatVar>)[cp concretize:var] maxErrF]);
#define getFmin(var) [(id<CPFloatVar>)[cp concretize:var] min]
#define getFminErr(var) *[(id<CPFloatVar>)[cp concretize:var] minErr]

#define printDvar(name, var) NSLog(@""name" : [% 24.24e, % 24.24e]d (%s)",[(id<CPDoubleVar>)[cp concretize:var] min],[(id<CPDoubleVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 1.2e, % 1.2e]q",[(id<CPDoubleVar>)[cp concretize:var] minErrF],[(id<CPDoubleVar>)[cp concretize:var] maxErrF]);
#define getDmin(var) [(id<CPDoubleVar>)[cp concretize:var] min]
#define getDminErr(var) *[(id<CPDoubleVar>)[cp concretize:var] minErr]

void check_it_sqroot_d(double x, double z, id<ORRational> ez) {
   double cz = ((((1.0 + (0.5 * x)) - ((0.125 * x) * x)) + (((0.0625 * x) * x) * x)) - ((((0.0390625 * x) * x) * x) * x));
   
   if (cz != z)
      printf("WRONG: z  = % 24.24e while cz  = % 24.24e\n", z, cz);
   
   {
      mpq_t xq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19;
      
      mpq_inits(xq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19, NULL);
      
      mpq_set_d(xq, x);
      
      mpq_set_d(tmp1, 1.0);
      mpq_set_d(tmp2, 0.5);
      mpq_mul(tmp3, tmp2, xq);
      mpq_add(tmp4, tmp1, tmp3);
      mpq_set_d(tmp5, 0.125);
      mpq_mul(tmp6, tmp5, xq);
      mpq_mul(tmp7, tmp6, xq);
      mpq_sub(tmp8, tmp4, tmp7);
      mpq_set_d(tmp9, 0.0625);
      mpq_mul(tmp10, tmp9, xq);
      mpq_mul(tmp11, tmp10, xq);
      mpq_mul(tmp12, tmp11, xq);
      mpq_add(tmp13, tmp8, tmp12);
      mpq_set_d(tmp14, 0.0390625);
      mpq_mul(tmp15, tmp14, xq);
      mpq_mul(tmp16, tmp15, xq);
      mpq_mul(tmp17, tmp16, xq);
      mpq_mul(tmp18, tmp17, xq);
      mpq_sub(tmp19, tmp13, tmp18);
      mpq_set(zq, tmp19);
      
      mpq_set_d(tmp0, z);
      mpq_sub(tmp1, zq, tmp0);
      if (mpq_cmp(tmp1, ez.rational) != 0){
         NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
         NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
      }
      mpq_clears(xq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19, NULL);
   }
   
}

void cav10_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      //srand(time(NULL));
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> x = [ORFactory doubleVar:mdl low:0 up:100 elow:zero eup:zero name:@"x"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      //id<ORRationalVar> zR = [ORFactory rationalVar:mdl name:@"zR"];
      //id<ORRationalVar> ZR = [ORFactory rationalVar:mdl name:@"ZR"];

      /*
       def cav10(x: Real): Real = {
         require(0 < x && x < 10)
         if (x∗x − x >= 0)
            x/10
         else
            x∗x + 2
       } ensuring(res ⇒ 0 <= res && res <= 3.0 && res +/− 3.0)
       */
      
      //[mdl add:[[[x mul: x] sub: x] geq: @(0.0)]];
      //[mdl add:[z set:[x div: @(10.0)]]];
      //[mdl add:[z geq: @(0.0)]];
      //[mdl add:[z leq: @(3.0)]];
      
      [mdl add:[z set: [[x mul: x] plus: x]]];
      [mdl add:[z leq: @(1)]];
      //[mdl add:[ORFactory channel:z with:zR]];
      
      [mdl add: [ezAbs eq: [ez abs]]];
      //[mdl add:[[zR plus: ez] geq: zero]];
      [mdl maximize:ezAbs];
      
      [zero release];
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBBController proto]];
      //id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<ORDoubleVarArray> vs = [mdl doubleVars];
      id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
         //if (search)
            [cp branchAndBoundSearchD:vars out:ezAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [cp floatSplit:i withVars:x];
            }];
         NSLog(@"a : [%20.20e;%20.20e] (%s)",[cp minD:x],[cp maxD:x],[cp bound:x] ? "YES" : "NO");
         NSLog(@"ea: [%@;%@]",[cp minDQ:x],[cp  maxDQ:x]);
         NSLog(@"b : [%20.20e;%20.20e] (%s)",[cp minD:z],[cp maxD:z],[cp bound:z] ? "YES" : "NO");
         NSLog(@"eb: [%@;%@]",[cp minDQ:z],[cp  maxDQ:z]);
      }];
   }
}

void exitfunc(int sig)
{
   exit(sig);
}

int main(int argc, const char * argv[]) {
   sranddev();
   //   signal(SIGKILL, exitfunc);
   //   alarm(60);
      LOO_MEASURE_TIME(@"rigidbody2"){
   cav10_d(0, argc, argv);
   //sqroot_f(1, argc, argv);
   }
   ORDouble one = 1.01;
   NSLog(@"%20.20e", (nextafter(one, +INFINITY) - one)/2);
   return 0;
}
