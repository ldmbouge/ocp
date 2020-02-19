//
//  kepler2BB.m
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

void kepler2_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> x1 = [ORFactory doubleInputVar:mdl low:4 up:159/25 elow:zero eup:zero name:@"x1"];
      id<ORDoubleVar> x2 = [ORFactory doubleInputVar:mdl low:4 up:159/25 elow:zero eup:zero name:@"x2"];
      id<ORDoubleVar> x3 = [ORFactory doubleInputVar:mdl low:4 up:159/25 elow:zero eup:zero name:@"x3"];
      id<ORDoubleVar> x4 = [ORFactory doubleInputVar:mdl low:4 up:159/25 elow:zero eup:zero name:@"x4"];
      id<ORDoubleVar> x5 = [ORFactory doubleInputVar:mdl low:4 up:159/25 elow:zero eup:zero name:@"x5"];
      id<ORDoubleVar> x6 = [ORFactory doubleInputVar:mdl low:4 up:159/25   elow:zero eup:zero name:@"x6"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      
      [zero release];
      
      // x1*x4(-x1+x2+x3-x4+x5+x6) + x2*x5(x1-x2+x3+x4-x5+x6) + x3*x6(x1+x2-x3+x4+x5-x6) - x2*x3*x4 - x1*x3*x5 - x1*x2*x6 - x4*x5*x6
      
      [mdl add:[z set: [[[[[[[[x1 mul: x4] mul: [[[[[[x1 minus] plus: x2] plus: x3] sub: x4] plus: x5] plus: x6] ] plus: [[x2 mul: x5] mul:[[[[[x1 sub: x2] plus: x3] plus: x4] sub: x5] plus: x6]]] plus: [[x3 mul: x6] mul: [[[[[x1 plus: x2] sub: x3] plus: x4] plus: x5] sub: x6]]] sub: [[x2 mul: x3] mul: x4]] sub: [[x1 mul: x3] mul: x5]] sub: [[x1 mul: x2] mul: x6]] sub: [[x4 mul: x5] mul: x6]]]];
      
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
            }
                              compute:^(NSMutableArray* arrayValue, NSMutableArray* arrayError){
               ORDouble x1 = [[arrayValue objectAtIndex:0] doubleValue];
               ORDouble x2 = [[arrayValue objectAtIndex:1] doubleValue];
               ORDouble x3 = [[arrayValue objectAtIndex:2] doubleValue];
               ORDouble x4 = [[arrayValue objectAtIndex:3] doubleValue];
               ORDouble x5 = [[arrayValue objectAtIndex:4] doubleValue];
               ORDouble x6 = [[arrayValue objectAtIndex:5] doubleValue];
               
               id<ORRational> x1Q = [[ORRational alloc] init];
               id<ORRational> x2Q = [[ORRational alloc] init];
               id<ORRational> x3Q = [[ORRational alloc] init];
               id<ORRational> x4Q = [[ORRational alloc] init];
               id<ORRational> x5Q = [[ORRational alloc] init];
               id<ORRational> x6Q = [[ORRational alloc] init];
               id<ORRational> zQ = [[ORRational alloc] init];
               id<ORRational> zF = [[ORRational alloc] init];
               id<ORRational> ez = [[[ORRational alloc] init] autorelease];
               
               [x1Q setInput:x1 with:[arrayError objectAtIndex:0]];
               [x2Q setInput:x2 with:[arrayError objectAtIndex:1]];
               [x3Q setInput:x3 with:[arrayError objectAtIndex:2]];
               [x4Q setInput:x4 with:[arrayError objectAtIndex:3]];
               [x5Q setInput:x5 with:[arrayError objectAtIndex:4]];
               [x6Q setInput:x6 with:[arrayError objectAtIndex:5]];
               
               ORDouble z = x1*x4*(-x1+x2+x3-x4+x5+x6) + x2*x5*(x1-x2+x3+x4-x5+x6) + x3*x6*(x1+x2-x3+x4+x5-x6) - x2*x3*x4 - x1*x3*x5 - x1*x2*x6 - x4*x5*x6;
               [zF set_d:z];
               
               [zQ set: [[[[[[[[x1Q mul: x4Q] mul: [[[[[[x1Q neg] add: x2Q] add: x3Q] sub: x4Q] add: x5Q] add: x6Q] ] add: [[x2Q mul: x5Q] mul:[[[[[x1Q sub: x2Q] add: x3Q] add: x4Q] sub: x5Q] add: x6Q]]] add: [[x3Q mul: x6Q] mul: [[[[[x1Q add: x2Q] sub: x3Q] add: x4Q] add: x5Q] sub: x6Q]]] sub: [[x2Q mul: x3Q] mul: x4Q]] sub: [[x1Q mul: x3Q] mul: x5Q]] sub: [[x1Q mul: x2Q] mul: x6Q]] sub: [[x4Q mul: x5Q] mul: x6Q]]
                ];
               
               [ez set: [zQ sub: zF]];
               
               [x1Q release];
               [x2Q release];
               [x3Q release];
               [x4Q release];
               [x5Q release];
               [x6Q release];
               [zQ release];
               [zF release];
               return ez;
            }];
      }];
   }
}

void kepler2_d_c(int search, int argc, const char * argv[]) {
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
      // x1*x4(-x1+x2+x3-x4+x5+x6) + x2*x5(x1-x2+x3+x4-x5+x6) + x3*x6(x1+x2-x3+x4+x5-x6) - x2*x3*x4 - x1*x3*x5 - x1*x2*x6 - x4*x5*x6
      [mdl add:[z set: [[[[[[[[x1 mul: x4] mul: [[[[[[x1 minus] plus: x2] plus: x3] sub: x4] plus: x5] plus: x6] ] plus: [[x2 mul: x5] mul:[[[[[x1 sub: x2] plus: x3] plus: x4] sub: x5] plus: x6]]] plus: [[x3 mul: x6] mul: [[[[[x1 plus: x2] sub: x3] plus: x4] plus: x5] sub: x6]]] sub: [[x2 mul: x3] mul: x4]] sub: [[x1 mul: x3] mul: x5]] sub: [[x1 mul: x2] mul: x6]] sub: [[x4 mul: x5] mul: x6]]]];
      
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
         }
                           compute:^(NSMutableArray* arrayValue, NSMutableArray* arrayError){
            ORDouble x1 = [[arrayValue objectAtIndex:0] doubleValue];
            ORDouble x2 = [[arrayValue objectAtIndex:1] doubleValue];
            ORDouble x3 = [[arrayValue objectAtIndex:2] doubleValue];
            ORDouble x4 = [[arrayValue objectAtIndex:3] doubleValue];
            ORDouble x5 = [[arrayValue objectAtIndex:4] doubleValue];
            ORDouble x6 = [[arrayValue objectAtIndex:5] doubleValue];
            
            id<ORRational> x1Q = [[ORRational alloc] init];
            id<ORRational> x2Q = [[ORRational alloc] init];
            id<ORRational> x3Q = [[ORRational alloc] init];
            id<ORRational> x4Q = [[ORRational alloc] init];
            id<ORRational> x5Q = [[ORRational alloc] init];
            id<ORRational> x6Q = [[ORRational alloc] init];
            id<ORRational> zQ = [[ORRational alloc] init];
            id<ORRational> zF = [[ORRational alloc] init];
            id<ORRational> ez = [[[ORRational alloc] init] autorelease];
            
            [x1Q setInput:x1 with:[arrayError objectAtIndex:0]];
            [x2Q setInput:x2 with:[arrayError objectAtIndex:1]];
            [x3Q setInput:x3 with:[arrayError objectAtIndex:2]];
            [x4Q setInput:x4 with:[arrayError objectAtIndex:3]];
            [x5Q setInput:x5 with:[arrayError objectAtIndex:4]];
            [x6Q setInput:x6 with:[arrayError objectAtIndex:5]];
            
            ORDouble z = x1*x4*(-x1+x2+x3-x4+x5+x6) + x2*x5*(x1-x2+x3+x4-x5+x6) + x3*x6*(x1+x2-x3+x4+x5-x6) - x2*x3*x4 - x1*x3*x5 - x1*x2*x6 - x4*x5*x6;
            [zF set_d:z];
            
            [zQ set: [[[[[[[[x1Q mul: x4Q] mul: [[[[[[x1Q neg] add: x2Q] add: x3Q] sub: x4Q] add: x5Q] add: x6Q] ] add: [[x2Q mul: x5Q] mul:[[[[[x1Q sub: x2Q] add: x3Q] add: x4Q] sub: x5Q] add: x6Q]]] add: [[x3Q mul: x6Q] mul: [[[[[x1Q add: x2Q] sub: x3Q] add: x4Q] add: x5Q] sub: x6Q]]] sub: [[x2Q mul: x3Q] mul: x4Q]] sub: [[x1Q mul: x3Q] mul: x5Q]] sub: [[x1Q mul: x2Q] mul: x6Q]] sub: [[x4Q mul: x5Q] mul: x6Q]]
             ];
            
            [ez set: [zQ sub: zF]];
            
            [x1Q release];
            [x2Q release];
            [x3Q release];
            [x4Q release];
            [x5Q release];
            [x6Q release];
            [zQ release];
            [zF release];
            return ez;
         }];
      }];
   }
}


int main(int argc, const char * argv[]) {
   kepler2_d(1, argc, argv);
   //kepler2_d_c(1, argc, argv);
   return 0;
}
