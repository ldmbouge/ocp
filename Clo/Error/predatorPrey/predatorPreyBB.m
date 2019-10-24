//
//  predatorPrey.m
//  Clo
//
//  Created by Rémy Garcia on 12/04/2019.
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

void check_it_d(double r, double k, double x, double z, id<ORRational> ez) {
   mpq_t qz, qx, tmp0, tmp1, tmp2;
   double cz = ((r*x)*x) / (1.0 + ((x/k)*(x/k)));
   
   if (cz != z)
      NSLog(@"WRONG: cz = % 24.24e != z = %24.24e\n", cz, z);
   
   mpq_inits(qz, qx, tmp0, tmp1, tmp2, NULL);
   
   // ((r*x)*x)
   mpq_set_d(qx, x);
   mpq_set_d(tmp0, r);
   mpq_mul(tmp1, tmp0, qx);
   mpq_mul(tmp0, tmp1, qx);
   
   // ((x/k)*(x/k))
   mpq_set_d(tmp2, k);
   mpq_div(tmp1, qx, tmp2);
   mpq_mul(tmp2, tmp1, tmp1);
   
   // ((r*x)*x) / (1.0f + ((x/k)*(x/k)))
   mpq_set_d(qz, 1.0);
   mpq_add(tmp1, tmp2, qz);
   mpq_div(qz, tmp0, tmp1);
   
   mpq_set_d(tmp0, cz);
   mpq_sub(tmp1, qz, tmp0);
   // La différence vient de ce que minError retourne un flottant au lieu d'un double !
   if (mpq_cmp(tmp1,ez.rational) != 0){
      NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
      NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
   }
   mpq_clears(qz, qx, tmp0, tmp1, tmp2, NULL);
}

void predatorPrey_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
      id<ORDoubleVar> K = [ORFactory doubleVar:mdl name:@"K"];
      id<ORDoubleVar> x = [ORFactory doubleVar:mdl low:0.1 up:0.3 elow:zero eup:zero name:@"x"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      [zero release];

      [mdl add:[r set: @(4.0)]];
      [mdl add:[K set: @(1.11)]];
      [mdl add:[z set:[[[r mul: x] mul: x] div: [@(1.0) plus: [[x div: K] mul: [x div: K]]]]]];
      
      //[mdl add:[[z error] geq:c]];
      [mdl add: [ezAbs eq: [ez abs]]];
      [mdl maximize:ezAbs];
      
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBBController proto]];
      id<ORDoubleVarArray> vs =  [ORFactory doubleVarArray:mdl range:RANGE(mdl, 0, 0)];//[mdl doubleVars];
      vs[0] = x;
      id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
         if (search)
            [cp branchAndBoundSearchD:vars out:ezAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [cp floatSplit:i withVars:x];
            }];
      }];
   }
}

void check_it_f(float r, float k, float x, float z, id<ORRational> ez) {
   mpq_t qz, qx, tmp0, tmp1, tmp2;
   float cz = ((r*x)*x) / (1.0f + ((x/k)*(x/k)));
   
   if (cz != z)
      printf("WRONG: cz = % 20.20e != z = % 20.20e\n", cz, z);
   
   mpq_inits(qz, qx, tmp0, tmp1, tmp2, NULL);
   
   // ((r*x)*x)
   mpq_set_d(qx, x);
   mpq_set_d(tmp0, r);
   mpq_mul(tmp1, tmp0, qx);
   mpq_mul(tmp0, tmp1, qx);
   
   // ((x/k)*(x/k))
   mpq_set_d(tmp2, k);
   mpq_div(tmp1, qx, tmp2);
   mpq_mul(tmp2, tmp1, tmp1);
   
   // ((r*x)*x) / (1.0f + ((x/k)*(x/k)))
   mpq_set_d(qz, 1.0f);
   mpq_add(tmp1, tmp2, qz);
   mpq_div(qz, tmp0, tmp1);
   
   mpq_set_d(tmp0, cz);
   mpq_sub(tmp1, qz, tmp0);
   // La différence vient de ce que minError retourne un flottant au lieu d'un double !
   if (mpq_cmp(tmp1, ez.rational) != 0){
      NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
      NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
   }
   mpq_clears(qz, qx, tmp0, tmp1, tmp2, NULL);
}

void predatorPrey_f(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0f];
      id<ORFloatVar> r = [ORFactory floatVar:mdl name:@"r"];
      id<ORFloatVar> K = [ORFactory floatVar:mdl name:@"K"];
      id<ORFloatVar> z = [ORFactory floatVar:mdl name:@"z"];
      id<ORFloatVar> x = [ORFactory floatVar:mdl low:0.1f up:0.3f elow:zero eup:zero name:@"x"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      //[zero release];
      
      [mdl add:[r set: @(4.0f)]];
      [mdl add:[K set: @(1.11f)]];
      [mdl add:[z set:[[[r mul: x] mul: x]  div: [@(1.0f) plus: [[x div: K] mul:[x div: K]]]]]];
      
      [mdl add: [ezAbs eq: [ez abs]]];
      //[zero set_d:9.9e-17];
      //[mdl add: [ez geq:zero]];
      [mdl maximize:ezAbs];
      [zero release];
      
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

int main(int argc, const char * argv[]) {
   //   LOO_MEASURE_TIME(@"rigidbody2"){
      //predatorPrey_f(1, argc, argv);
      predatorPrey_d(1, argc, argv);
   //}
   return 0;
}


