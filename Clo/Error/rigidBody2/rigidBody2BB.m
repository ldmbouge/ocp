//
//  rigidBody2.m
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

void check_it_rigidBody2_d(double x1, double x2, double x3, double z, id<ORRational> ez) {
   double cz = (((((((2.0 * x1) * x2) * x3) + ((3.0 * x3) * x3)) - (((x2 * x1) * x2) * x3)) + ((3.0 * x3) * x3)) - x2);
   
   if (cz != z)
      printf("WRONG: z  = % 24.24e while cz  = % 24.24e\n", z, cz);
   
   {
      mpq_t x1q, x2q, x3q, zq, tmp0, tmp1, tmp2;
      
      mpq_inits(x1q, x2q, x3q, zq, tmp0, tmp1, tmp2, NULL);
      mpq_set_d(x1q, x1);
      mpq_set_d(x2q, x2);
      mpq_set_d(x3q, x3);
      mpq_set_d(tmp0, 2.0);
      mpq_mul(tmp2, tmp0, x1q);
      mpq_mul(tmp0, tmp2, x2q);
      mpq_mul(tmp2, tmp0, x3q);
      mpq_set_d(tmp0, 3.0);
      mpq_mul(tmp1, tmp0, x3q);
      mpq_mul(tmp0, tmp1, x3q);
      mpq_add(tmp1, tmp2, tmp0);
      mpq_mul(tmp0, x2q, x1q);
      mpq_mul(tmp2, tmp0, x2q);
      mpq_mul(tmp0, tmp2, x3q);
      mpq_sub(tmp2, tmp1, tmp0);
      mpq_set_d(tmp0, 3.0);
      mpq_mul(tmp1, tmp0, x3q);
      mpq_mul(tmp0, tmp1, x3q);
      mpq_add(tmp1, tmp2, tmp0);
      mpq_sub(zq, tmp1, x2q);
      
      mpq_set_d(tmp0, z);
      mpq_sub(tmp1, zq, tmp0);
      if (mpq_cmp(tmp1, ez.rational) != 0){
         NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
         NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
      }
      mpq_clears(x1q, x2q, x3q, zq, tmp0, tmp1, tmp2, NULL);
   }
   
}

void rigidBody2_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> x1 = [ORFactory doubleInputVar:mdl low:-15.0 up:15.0 elow:zero eup:zero name:@"x1"];
      id<ORDoubleVar> x2 = [ORFactory doubleInputVar:mdl low:-15.0 up:15.0 elow:zero eup:zero name:@"x2"];
      id<ORDoubleVar> x3 = [ORFactory doubleInputVar:mdl low:-15.0 up:15.0 elow:zero eup:zero name:@"x3"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      [zero release];
      
      // Plante dans le calcul d'un produit sur le calcul de ex pour lequel il faut faire une division par 0 (y + ey) ...
      [mdl add:[z set: [[[[[[[@(2.0) mul: x1] mul: x2] mul: x3] plus: [[@(3.0) mul: x3] mul: x3]] sub: [[[x2 mul: x1] mul: x2] mul: x3]] plus: [[@(3.0) mul: x3] mul: x3]] sub: x2]]];
      
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
                
                id<ORRational> two = [[ORRational alloc] init];
                id<ORRational> three = [[ORRational alloc] init];
                id<ORRational> x1Q = [[ORRational alloc] init];
                id<ORRational> x2Q = [[ORRational alloc] init];
                id<ORRational> x3Q = [[ORRational alloc] init];
                id<ORRational> zQ = [[ORRational alloc] init];
                id<ORRational> zF = [[ORRational alloc] init];
                id<ORRational> ez = [[[ORRational alloc] init] autorelease];
                
                [two set_d:2.0];
                [three set_d:3.0];
                [x1Q setInput:x1 with:[arrayError objectAtIndex:0]];
                [x2Q setInput:x2 with:[arrayError objectAtIndex:1]];
                [x3Q setInput:x3 with:[arrayError objectAtIndex:2]];
                
                ORDouble z = (((((((2.0 * x1) * x2) * x3) + ((3.0 * x3) * x3)) - (((x2 * x1) * x2) * x3)) + ((3.0 * x3) * x3)) - x2);
                
                [zF set_d:z];
                
                [zQ set:[[[[[[[two mul: x1Q] mul: x2Q] mul: x3Q] add: [[three mul: x3Q] mul: x3Q]] sub: [[[x2Q mul: x1Q] mul: x2Q] mul: x3Q]] add: [[three mul: x3Q] mul: x3Q]] sub: x2Q]];
                
                [ez set: [zQ sub: zF]];
                
                [two release];
                [three release];
                [x1Q release];
                [x2Q release];
                [x3Q release];
                [zQ release];
                [zF release];
                return ez;
            }];
      }];
   }
}

void rigidBody2_d_c(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of model variables */
      id<ORDoubleVar> x1 = [ORFactory doubleInputVar:mdl low:-15.0 up:15.0 name:@"x1"];
      id<ORDoubleVar> x2 = [ORFactory doubleInputVar:mdl low:-15.0 up:15.0 name:@"x2"];
      id<ORDoubleVar> x3 = [ORFactory doubleInputVar:mdl low:-15.0 up:15.0 name:@"x3"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      
      /* Declaration of constraints */
      [mdl add:[z set: [[[[[[[@(2.0) mul: x1] mul: x2] mul: x3] plus: [[@(3.0) mul: x3] mul: x3]] sub: [[[x2 mul: x1] mul: x2] mul: x3]] plus: [[@(3.0) mul: x3] mul: x3]] sub: x2]]];
      
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
                
                id<ORRational> two = [[ORRational alloc] init];
                id<ORRational> three = [[ORRational alloc] init];
                id<ORRational> x1Q = [[ORRational alloc] init];
                id<ORRational> x2Q = [[ORRational alloc] init];
                id<ORRational> x3Q = [[ORRational alloc] init];
                id<ORRational> zQ = [[ORRational alloc] init];
                id<ORRational> zF = [[ORRational alloc] init];
                id<ORRational> ez = [[[ORRational alloc] init] autorelease];
                
                [two set_d:2.0];
                [three set_d:3.0];
                [x1Q setInput:x1 with:[arrayError objectAtIndex:0]];
                [x2Q setInput:x2 with:[arrayError objectAtIndex:1]];
                [x3Q setInput:x3 with:[arrayError objectAtIndex:2]];
                
                ORDouble z = (((((((2.0 * x1) * x2) * x3) + ((3.0 * x3) * x3)) - (((x2 * x1) * x2) * x3)) + ((3.0 * x3) * x3)) - x2);
                
                [zF set_d:z];
                
                [zQ set:[[[[[[[two mul: x1Q] mul: x2Q] mul: x3Q] add: [[three mul: x3Q] mul: x3Q]] sub: [[[x2Q mul: x1Q] mul: x2Q] mul: x3Q]] add: [[three mul: x3Q] mul: x3Q]] sub: x2Q]];
                
                [ez set: [zQ sub: zF]];
                
                [two release];
                [three release];
                [x1Q release];
                [x2Q release];
                [x3Q release];
                [zQ release];
                [zF release];
                return ez;
             }];
      }];
   }
}

int main(int argc, const char * argv[]) {
   rigidBody2_d(1, argc, argv);
   //rigidBody2_d_c(1, argc, argv);
   return 0;
}
