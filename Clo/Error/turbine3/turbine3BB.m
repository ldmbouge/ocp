//
//  turbine3.m
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

void turbine3_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> v = [ORFactory doubleInputVar:mdl low:-4.5 up:-0.3 elow:zero eup:zero name:@"v"];
      id<ORDoubleVar> w = [ORFactory doubleInputVar:mdl low:0.4 up:0.9 elow:zero eup:zero name:@"w"];
      id<ORDoubleVar> r = [ORFactory doubleInputVar:mdl low:3.8 up:7.8 elow:zero eup:zero name:@"r"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      [zero release];
      
      [mdl add:[z set: [[[@(3.0) sub: [@(2.0) div: [r mul: r]]] sub: [[[@(0.125) mul: [@(1.0) plus: [@(2.0) mul: v]]] mul: [[[w mul: w] mul: r] mul: r]] div: [@(1.0) sub: v]]] sub: @(0.5)]]];
      
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
               ORDouble v = [[arrayValue objectAtIndex:0] doubleValue];
               ORDouble w = [[arrayValue objectAtIndex:1] doubleValue];
               ORDouble r = [[arrayValue objectAtIndex:2] doubleValue];
               ORDouble a = 0.125;
               ORDouble b = 0.5;
               
               id<ORRational> one = [[ORRational alloc] init];
               id<ORRational> two = [[ORRational alloc] init];
               id<ORRational> three = [[ORRational alloc] init];
               id<ORRational> vQ = [[ORRational alloc] init];
               id<ORRational> wQ = [[ORRational alloc] init];
               id<ORRational> rQ = [[ORRational alloc] init];
               id<ORRational> aQ = [[ORRational alloc] init];
               id<ORRational> bQ = [[ORRational alloc] init];
               id<ORRational> zQ = [[ORRational alloc] init];
               id<ORRational> zF = [[ORRational alloc] init];
               id<ORRational> ez = [[[ORRational alloc] init] autorelease];
               
               [one setOne];
               [two set_d:2.0];
               [three set_d:3.0];
               [vQ setInput:v with:[arrayError objectAtIndex:0]];
               [wQ setInput:w with:[arrayError objectAtIndex:1]];
               [rQ setInput:r with:[arrayError objectAtIndex:2]];
               [aQ set_d:a];
               [bQ set_d:b];
               
               ORDouble z = 3 - 2/(r*r) - a * (1+2*v) * (w*w*r*r) / (1-v) - b;
               
               [zF set_d:z];
               
               [zQ set:[[[three sub: [two div: [rQ mul: rQ]]] sub: [[[aQ mul: [one add: [two mul: vQ]]] mul: [[[wQ mul: wQ] mul: rQ] mul: rQ]] div: [one sub: vQ]]] sub: bQ]];
               
               [ez set: [zQ sub: zF]];
               
               [one release];
               [two release];
               [three release];
               [vQ release];
               [wQ release];
               [rQ release];
               [aQ release];
               [bQ release];
               [zQ release];
               [zF release];
               return ez;
            }];
         
      }];
   }
}

void turbine3_d_c(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of model variables */
      id<ORDoubleVar> v = [ORFactory doubleInputVar:mdl low:-4.5 up:-0.3 name:@"v"];
      id<ORDoubleVar> w = [ORFactory doubleInputVar:mdl low:0.4 up:0.9 name:@"w"];
      id<ORDoubleVar> r = [ORFactory doubleInputVar:mdl low:3.8 up:7.8 name:@"r"];
      id<ORDoubleVar> a = [ORFactory doubleConstantVar:mdl value:0.125 string:@"1/8" name:@"a"];
      id<ORDoubleVar> b = [ORFactory doubleConstantVar:mdl value:0.5 string:@"1/2" name:@"b"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      
      /* Declaration of constraints */
      [mdl add:[z set: [[[@(3.0) sub: [@(2.0) div: [r mul: r]]] sub: [[[a mul: [@(1.0) plus: [@(2.0) mul: v]]] mul: [[[w mul: w] mul: r] mul: r]] div: [@(1.0) sub: v]]] sub: b]]];
      
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
            ORDouble v = [[arrayValue objectAtIndex:0] doubleValue];
            ORDouble w = [[arrayValue objectAtIndex:1] doubleValue];
            ORDouble r = [[arrayValue objectAtIndex:2] doubleValue];
            ORDouble a = 0.125;
            ORDouble b = 0.5;
            
            id<ORRational> one = [[ORRational alloc] init];
            id<ORRational> two = [[ORRational alloc] init];
            id<ORRational> three = [[ORRational alloc] init];
            id<ORRational> vQ = [[ORRational alloc] init];
            id<ORRational> wQ = [[ORRational alloc] init];
            id<ORRational> rQ = [[ORRational alloc] init];
            id<ORRational> aQ = [[ORRational alloc] init];
            id<ORRational> bQ = [[ORRational alloc] init];
            id<ORRational> zQ = [[ORRational alloc] init];
            id<ORRational> zF = [[ORRational alloc] init];
            id<ORRational> ez = [[[ORRational alloc] init] autorelease];
            
            [one setOne];
            [two set_d:2.0];
            [three set_d:3.0];
            [vQ setInput:v with:[arrayError objectAtIndex:0]];
            [wQ setInput:w with:[arrayError objectAtIndex:1]];
            [rQ setInput:r with:[arrayError objectAtIndex:2]];
            [aQ setConstant:a and:"1/8"];
            [bQ setConstant:b and:"1/2"];
            
            ORDouble z = 3 - 2/(r*r) - a * (1+2*v) * (w*w*r*r) / (1-v) - b;
            
            [zF set_d:z];
            
            [zQ set:[[[three sub: [two div: [rQ mul: rQ]]] sub: [[[aQ mul: [one add: [two mul: vQ]]] mul: [[[wQ mul: wQ] mul: rQ] mul: rQ]] div: [one sub: vQ]]] sub: bQ]];
            
            [ez set: [zQ sub: zF]];
            
            [one release];
            [two release];
            [three release];
            [vQ release];
            [wQ release];
            [rQ release];
            [aQ release];
            [bQ release];
            [zQ release];
            [zF release];
            return ez;
         }];
      }];
   }
}

int main(int argc, const char * argv[]) {
   turbine3_d(1, argc, argv);
   //turbine3_d_c(1, argc, argv);
   return 0;
}
