//
//  sine.m
//  ORUtilities
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

void sine_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> x = [ORFactory doubleVar:mdl low:-1.57079632679 up:1.57079632679 elow:zero eup:zero name:@"x"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      [zero release];

      
      [mdl add:[z set: [[[x sub: [ [[x mul: x] mul: x] div: @(6.0)]] plus: [[[[[x mul: x] mul: x] mul: x] mul: x] div: @(120.0)]] sub: [[[[[[[x mul: x] mul: x] mul: x] mul: x] mul: x] mul: x] div: @(5040.0)]]]];
      
      [mdl add:[z lt: @(1.0)]];
      [mdl add:[z gt: @(-1.0)]];
      
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

void sine_d_c(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of model variables */
      id<ORDoubleVar> x = [ORFactory doubleInputVar:mdl low:-1.57079632679 up:1.57079632679 name:@"x"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      
      /* Declaration of constraints */
      [mdl add:[z set: [[[x sub: [ [[x mul: x] mul: x] div: @(6.0)]] plus: [[[[[x mul: x] mul: x] mul: x] mul: x] div: @(120.0)]] sub: [[[[[[[x mul: x] mul: x] mul: x] mul: x] mul: x] mul: x] div: @(5040.0)]]]];
      
      [mdl add:[z lt: @(1.0)]];
      [mdl add:[z gt: @(-1.0)]];
      
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

void sine_f(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0f];
      id<ORFloatVar> x = [ORFactory floatVar:mdl low:-1.57079632679f up:1.57079632679f elow:zero eup:zero name:@"x"];
      id<ORFloatVar> z = [ORFactory floatVar:mdl name:@"z"];
      id<ORFloatVar> mul1 = [ORFactory floatVar:mdl name:@"mul1"];
      
      //[mdl add:[x set:  @(1.57079632679000003037) ]];
      [mdl add:[mul1 set: x]];
      [mdl add:[z set: [[[x sub: [ [[x mul: x] mul: x] div: @(6.0f)]] plus: [[[[[x mul: x] mul: x] mul: x] mul: x] div: @(120.0f)]] sub: [[[[[[[x mul: x] mul: x] mul: x] mul: x] mul: x] mul: x] div: @(5040.0f)]]]];
      //[mdl add: [z set: [[x sub: [ [[x mul: x] mul: x] div: @(6.0)]] plus: [[[[[x mul: x] mul: x] mul: x] mul: x] div: @(120.0)]]]];
      
      [mdl add:[z lt: @(1.0f)]];
      [mdl add:[z gt: @(-1.0f)]];
      
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
         NSLog(@"x : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minF:x],[cp maxF:x],[cp minFQ:x],[cp maxFQ:x],[cp bound:x] ? "YES" : "NO");
         NSLog(@"mul1 : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minF:mul1],[cp maxF:mul1],[cp minFQ:mul1],[cp maxFQ:mul1],[cp bound:mul1] ? "YES" : "NO");
         NSLog(@"z : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minF:z],[cp maxF:z],[cp minFQ:z],[cp maxFQ:z],[cp bound:z] ? "YES" : "NO");
      }];
   }
}

int main(int argc, const char * argv[]) {
   //sine_d(1, argc, argv);
   sine_d_c(1, argc, argv);
   return 0;
}
