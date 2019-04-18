//
//  main.m
//  testFloat
//
//  Created by Rémy Garcia on 12/04/2019.
//
//

#import <ORProgram/ORProgram.h>
#include "gmp.h"
#include <signal.h>
#include <stdlib.h>

#define LOO_MEASURE_TIME(__message) \
for (CFAbsoluteTime startTime##__LINE__ = CFAbsoluteTimeGetCurrent(), endTime##__LINE__ = 0.0; endTime##__LINE__ == 0.0; \
NSLog(@"'%@' took %.3fs", (__message), (endTime##__LINE__ = CFAbsoluteTimeGetCurrent()) - startTime##__LINE__))

#define printFvar(name, var) NSLog(@""name" : [% 20.20e, % 20.20e]f (%s)",[(id<CPFloatVar>)[cp concretize:var] min],[(id<CPFloatVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 20.20e, % 20.20e]q",[(id<CPFloatVar>)[cp concretize:var] minErrF],[(id<CPFloatVar>)[cp concretize:var] maxErrF]);
#define getFmin(var) [(id<CPFloatVar>)[cp concretize:var] min]
#define getFminErr(var) *[(id<CPFloatVar>)[cp concretize:var] minErr]

#define printDvar(name, var) NSLog(@""name" : [% 24.24e, % 24.24e]d (%s)",[(id<CPDoubleVar>)[cp concretize:var] min],[(id<CPDoubleVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 1.2e, % 1.2e]q",[(id<CPDoubleVar>)[cp concretize:var] minErrF],[(id<CPDoubleVar>)[cp concretize:var] maxErrF]);
#define getDmin(var) [(id<CPDoubleVar>)[cp concretize:var] min]
#define getDminErr(var) *[(id<CPDoubleVar>)[cp concretize:var] minErr]

void check_it_d(double x, double r, double k, double z, id<ORRational> ez) {
   double cz = (r*x)/(1+x/k);
   mpq_t xq, rq, kq, zq, errq, tmp0, tmp1;
   
   if (cz != z)
      printf("WRONG: z = % 20.20e while cz = % 20.20e\n", z, cz);
   
   mpq_inits(xq, rq, kq, zq, errq, tmp0, tmp1, NULL);
   
   mpq_set_d(xq, x);
   mpq_set_d(rq, r);
   mpq_set_d(kq, k);
   
   mpq_div(errq, xq, kq);
   mpq_set_d(tmp1, 1.0f);
   mpq_add(tmp0, errq, tmp1);
   mpq_mul(tmp1, rq, xq);
   mpq_div(zq, tmp1, tmp0);
   
   mpq_set_d(tmp0, cz);
   mpq_sub(errq, zq, tmp0);
   
   if (mpq_cmp(errq, ez.rational) != 0){
      NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
      NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
   }
   mpq_clears(xq, rq, kq, zq, errq, tmp0, tmp1, NULL);
}

void verhulst_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> x = [ORFactory doubleVar:mdl low:0.1 up:0.3 elow:zero eup:zero name:@"x"];
      id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
      id<ORDoubleVar> k = [ORFactory doubleVar:mdl name:@"k"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      [zero release];
      
      [mdl add:[r set: @(4.0)]];
      [mdl add:[k set: @(1.11)]];
      [mdl add:[z set:[[r mul: x] div: [@(1.0) plus: [x div: k]]]]];
      
      [mdl add: [ezAbs eq: [ez abs]]];
      [mdl maximize:ezAbs];
      
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBBController proto]];
      id<ORDoubleVarArray> vs = [mdl doubleVars];
      id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
            [cp branchAndBoundSearchD:vars out:ezAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [cp floatSplit:i withVars:x];
            }];
      }];
   }
}

void check_it_f(float x, float r, float k, float z, id<ORRational> ez) {
   float cz = (r*x)/(1+x/k);
   mpq_t xq, rq, kq, zq, errq, tmp0, tmp1;
   
   if (cz != z)
      printf("WRONG: z = % 20.20e while cz = % 20.20e\n", z, cz);
   
   mpq_inits(xq, rq, kq, zq, errq, tmp0, tmp1, NULL);
   mpq_set_d(xq, x);
   mpq_set_d(rq, r);
   mpq_set_d(kq, k);
   
   mpq_div(errq, xq, kq);
   mpq_set_d(tmp1, 1.0f);
   mpq_add(tmp0, errq, tmp1);
   mpq_mul(tmp1, rq, xq);
   mpq_div(zq, tmp1, tmp0);
   
   mpq_set_d(tmp0, cz);
   mpq_sub(errq, zq, tmp0);
   
   if (mpq_cmp(errq, ez.rational) != 0){
      NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
      NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
   }    mpq_clears(xq, rq, kq, zq, errq, tmp0, tmp1, NULL);
}

void verhulst_f(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORFloatVar> x = [ORFactory floatVar:mdl low:0.1 up:0.3 elow:zero eup:zero name:@"x"];
      id<ORFloatVar> r = [ORFactory floatVar:mdl name:@"r"];
      id<ORFloatVar> k = [ORFactory floatVar:mdl name:@"k"];
      id<ORFloatVar> z = [ORFactory floatVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      [zero release];
      
      [mdl add:[r set: @(4.0f)]];
      [mdl add:[k set: @(1.11f)]];
      [mdl add:[z set:[[r mul: x] div: [@(1.0f) plus: [x div: k]]]]];
      
      [mdl add: [ezAbs eq: [ez abs]]];
      [mdl maximize:ezAbs];
      
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBBController proto]];
      id<ORFloatVarArray> vs = [mdl floatVars];
      id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
         if (search)
            [cp branchAndBoundSearch:vars out:ezAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [cp floatSplit:i withVars:x];
            }];
      }];
   }
}

void exitfunc(int sig)
{
   exit(sig);
}

int main(int argc, const char * argv[]) {
   signal(SIGKILL, exitfunc);
   alarm(60);
   //   LOO_MEASURE_TIME(@"rigidbody2"){
      //verhulst_f(1, argc, argv);
      verhulst_d(1, argc, argv);
   //}
   return 0;
}
