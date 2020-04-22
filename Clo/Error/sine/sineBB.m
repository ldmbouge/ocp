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

id<ORRational> (^sineError)(NSMutableArray* arrayValue, NSMutableArray* arrayError) = ^(NSMutableArray* arrayValue, NSMutableArray* arrayError){
   ORDouble x = [[arrayValue objectAtIndex:0] doubleValue];
   ORDouble a = 6.0;
   ORDouble b = 120.0;
   ORDouble c = 5040.0;
   
   id<ORRational> xQ = [[ORRational alloc] init];
   id<ORRational> aQ = [[ORRational alloc] init];
   id<ORRational> bQ = [[ORRational alloc] init];
   id<ORRational> cQ = [[ORRational alloc] init];
   id<ORRational> zQ = [[ORRational alloc] init];
   id<ORRational> zF = [[ORRational alloc] init];
   id<ORRational> ez = [[[ORRational alloc] init] autorelease];
   
   [xQ setInput:x with:[arrayError objectAtIndex:0]];
   [aQ set_d:a];
   [bQ set_d:b];
   [cQ set_d:c];
   
   ORDouble z = x - (x*x*x)/a + (x*x*x*x*x)/b - (x*x*x*x*x*x*x)/c;
   
   [zF set_d:z];
   
   [zQ set:[[[xQ sub: [ [[xQ mul: xQ] mul: xQ] div: aQ]] add: [[[[[xQ mul: xQ] mul: xQ] mul: xQ] mul: xQ] div: bQ]] sub: [[[[[[[xQ mul: xQ] mul: xQ] mul: xQ] mul: xQ] mul: xQ] mul: xQ] div: cQ]]];
   
   [ez set: [zQ sub: zF]];
   
   [xQ release];
   [aQ release];
   [bQ release];
   [cQ release];
   [zQ release];
   [zF release];
   
   [arrayValue addObject:[NSNumber numberWithDouble:z]];
   [arrayError addObject:ez];
   
   return ez;
};

void sine_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> x = [ORFactory doubleInputVar:mdl low:-1.57079632679 up:1.57079632679 elow:zero eup:zero name:@"x"];
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
            }
                              compute:sineError];
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
         }
                           compute:sineError];
      }];
      
   }
}

void sine_d_c_3B(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of model variables */
      id<ORGroup> g = [ORFactory group:mdl type:Group3B];
      id<ORDoubleVar> x = [ORFactory doubleInputVar:mdl low:-1.57079632679 up:1.57079632679 name:@"x"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      
      /* Declaration of constraints */
      [g add:[z set: [[[x sub: [ [[x mul: x] mul: x] div: @(6.0)]] plus: [[[[[x mul: x] mul: x] mul: x] mul: x] div: @(120.0)]] sub: [[[[[[[x mul: x] mul: x] mul: x] mul: x] mul: x] mul: x] div: @(5040.0)]]]];
      
      [g add:[z lt: @(1.0)]];
      [g add:[z gt: @(-1.0)]];
      
      /* Declaration of constraints over errors */
      [g add: [ezAbs eq: [ez abs]]];
      [mdl add: g];
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
                           compute:sineError];
      }];
      
   }
}

int main(int argc, const char * argv[]) {
   //sine_d(1, argc, argv);
   //sine_d_c(1, argc, argv);
   sine_d_c_3B(1, argc, argv);
   return 0;
}
