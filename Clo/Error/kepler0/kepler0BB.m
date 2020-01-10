//
//  kepler0BB.m
//  Clo
//
//  Created by Rémy Garcia on 09/10/2019.
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

void kepler0_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> x1 = [ORFactory doubleVar:mdl low:4 up:159/25 elow:zero eup:zero name:@"x1"];
      id<ORDoubleVar> x2 = [ORFactory doubleVar:mdl low:4 up:159/25 elow:zero eup:zero name:@"x2"];
      id<ORDoubleVar> x3 = [ORFactory doubleVar:mdl low:4 up:159/25 elow:zero eup:zero name:@"x3"];
      id<ORDoubleVar> x4 = [ORFactory doubleVar:mdl low:4 up:159/25 elow:zero eup:zero name:@"x4"];
      id<ORDoubleVar> x5 = [ORFactory doubleVar:mdl low:4 up:159/25 elow:zero eup:zero name:@"x5"];
      id<ORDoubleVar> x6 = [ORFactory doubleVar:mdl low:4 up:159/25   elow:zero eup:zero name:@"x6"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];

      [zero release];
      
      //(x2*x5) + (x3*x6) - (x2*x3) - (x5*x6) + (x1* (-x1+x2+x3-x4+x5+x6))
      
      [mdl add:[z set:  [[[[[x2 mul: x5] plus: [x3 mul: x6]] sub: [x2 mul: x3]] sub: [x5 mul: x6]] plus: [x1 mul: [[[[[[x1 minus] plus: x2] plus: x3] sub: x4] plus: x5] plus: x6]]]]];

      [mdl add: [ezAbs eq: [ez abs]]];
      [mdl maximize:ezAbs];
      
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBBController proto]];
      id<ORDoubleVarArray> vs = [mdl doubleVars];
      id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];

      [cp solve:^{
         if (search)
            [cp branchAndBoundSearchD:vars out:ezAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [cp floatSplit:i withVars:x];
            }];
      }];
   }
}

void kepler0_d_c(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of model variables */
      id<ORDoubleVar> x1 = [ORFactory doubleInputVar:mdl low:4 up:159/25 name:@"x1"];
      id<ORDoubleVar> x2 = [ORFactory doubleInputVar:mdl low:4 up:159/25 name:@"x2"];
      id<ORDoubleVar> x3 = [ORFactory doubleInputVar:mdl low:4 up:159/25 name:@"x3"];
      id<ORDoubleVar> x4 = [ORFactory doubleInputVar:mdl low:4 up:159/25 name:@"x4"];
      id<ORDoubleVar> x5 = [ORFactory doubleInputVar:mdl low:4 up:159/25 name:@"x5"];
      id<ORDoubleVar> x6 = [ORFactory doubleInputVar:mdl low:4 up:159/25 name:@"x6"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];

      /* Declaration of constraints */
      //(x2*x5) + (x3*x6) - (x2*x3) - (x5*x6) + (x1* (-x1+x2+x3-x4+x5+x6))
      [mdl add:[z set:  [[[[[x2 mul: x5] plus: [x3 mul: x6]] sub: [x2 mul: x3]] sub: [x5 mul: x6]] plus: [x1 mul: [[[[[[x1 minus] plus: x2] plus: x3] sub: x4] plus: x5] plus: x6]]]]];

      /* Declaration of constraints over errors */
      [mdl add: [ezAbs eq: [ez abs]]];
      [mdl maximize:ezAbs];

      /* Display model */
      NSLog(@"model: %@",mdl);
      
      /* Construction of solver */
      id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBBController proto]];
      id<ORDoubleVarArray> vs = [mdl doubleVars];
      id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      /* Solving */
      [cp solve:^{
            /* Branch-and-bound search strategy to maximize ezAbs, the error in absolute value of z */
            [cp branchAndBoundSearchD:vars out:ezAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
               /* Split strategy */
               [cp floatSplit:i withVars:x];
            }];
      }];
   }
}


int main(int argc, const char * argv[]) {
   //kepler0_d(1, argc, argv);
   kepler0_d_c(1, argc, argv);
   return 0;
}
