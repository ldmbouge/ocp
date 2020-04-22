//
//  turbine2.m
//  Clo
//
//  Created by Rémy Garcia on 12/04/2019.
//
#import <ORProgram/ORProgram.h>
#include "gmp.h"
#include <signal.h>
#include <stdlib.h>

id<ORRational> (^turbine2Error)(NSMutableArray* arrayValue, NSMutableArray* arrayError) = ^(NSMutableArray* arrayValue, NSMutableArray* arrayError){
   ORDouble v = [[arrayValue objectAtIndex:0] doubleValue];
   ORDouble w = [[arrayValue objectAtIndex:1] doubleValue];
   ORDouble r = [[arrayValue objectAtIndex:2] doubleValue];
   ORDouble a = 0.5;
   
   id<ORRational> one = [[ORRational alloc] init];
   id<ORRational> six = [[ORRational alloc] init];
   id<ORRational> twoAndAHalf = [[ORRational alloc] init];
   id<ORRational> vQ = [[ORRational alloc] init];
   id<ORRational> wQ = [[ORRational alloc] init];
   id<ORRational> rQ = [[ORRational alloc] init];
   id<ORRational> aQ = [[ORRational alloc] init];
   id<ORRational> zQ = [[ORRational alloc] init];
   id<ORRational> zF = [[ORRational alloc] init];
   id<ORRational> ez = [[[ORRational alloc] init] autorelease];
   
   [one setOne];
   [six set_d:6.0];
   [twoAndAHalf set_d:2.5];
   [vQ setInput:v with:[arrayError objectAtIndex:0]];
   [wQ setInput:w with:[arrayError objectAtIndex:1]];
   [rQ setInput:r with:[arrayError objectAtIndex:2]];
   [aQ setConstant:a and:"1/2"];
   
   ORDouble z = (((6.0 * v) - (((a * v) * (((w * w) * r) * r)) / (1.0 - v))) - 2.5);
   [zF set_d:z];
   
   [zQ set:[[[six mul: vQ] sub: [[[aQ mul: vQ] mul: [[[wQ mul: wQ] mul: rQ] mul: rQ]] div: [one sub: vQ]]] sub: twoAndAHalf]];
   
   [ez set: [zQ sub: zF]];
   
   [one release];
   [six release];
   [twoAndAHalf release];
   [vQ release];
   [wQ release];
   [rQ release];
   [aQ release];
   [zQ release];
   [zF release];
   
   [arrayValue addObject:[NSNumber numberWithDouble:z]];
   [arrayError addObject:ez];

   return ez;
};

void turbine2_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> v = [ORFactory doubleInputVar:mdl low:-4.5 up:-0.3 elow:zero eup:zero name:@"v"];
      id<ORDoubleVar> w = [ORFactory doubleInputVar:mdl low:0.4 up:0.9 elow:zero eup:zero name:@"w"];
      id<ORDoubleVar> r = [ORFactory doubleInputVar:mdl low:3.8 up:7.8 elow:zero eup:zero name:@"r"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      [zero release];
      
      [mdl add:[z set: [[[@(6.0) mul: v] sub: [[[@(0.5) mul: v] mul: [[[w mul: w] mul: r] mul: r]] div: [@(1.0) sub: v]]] sub: @(2.5)]]];
      
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
                              compute:turbine2Error];
      }];
   }
}

void turbine2_d_c(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of model variables */
      id<ORDoubleVar> v = [ORFactory doubleInputVar:mdl low:-4.5 up:-0.3 name:@"v"];
      id<ORDoubleVar> w = [ORFactory doubleInputVar:mdl low:0.4 up:0.9 name:@"w"];
      id<ORDoubleVar> r = [ORFactory doubleInputVar:mdl low:3.8 up:7.8 name:@"r"];
      id<ORDoubleVar> a = [ORFactory doubleConstantVar:mdl value:0.5 string:@"1/2" name:@"a"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      
      /* Declaration of constraints */
      [mdl add:[z set: [[[@(6.0) mul: v] sub: [[[a mul: v] mul: [[[w mul: w] mul: r] mul: r]] div: [@(1.0) sub: v]]] sub: @(2.5)]]];
      
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
                           compute:turbine2Error];
      }];
   }
}

void turbine2_d_c_3B(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of model variables */
      id<ORGroup> g = [ORFactory group:mdl type:Group3B];
      id<ORDoubleVar> v = [ORFactory doubleInputVar:mdl low:-4.5 up:-0.3 name:@"v"];
      id<ORDoubleVar> w = [ORFactory doubleInputVar:mdl low:0.4 up:0.9 name:@"w"];
      id<ORDoubleVar> r = [ORFactory doubleInputVar:mdl low:3.8 up:7.8 name:@"r"];
      id<ORDoubleVar> a = [ORFactory doubleConstantVar:mdl value:0.5 string:@"1/2" name:@"a"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      
      /* Declaration of constraints */
      [g add:[z set: [[[@(6.0) mul: v] sub: [[[a mul: v] mul: [[[w mul: w] mul: r] mul: r]] div: [@(1.0) sub: v]]] sub: @(2.5)]]];
      
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
                           compute:turbine2Error];
      }];
   }
}

int main(int argc, const char * argv[]) {
   //turbine2_d(1, argc, argv);
   //turbine2_d_c(1, argc, argv);
   turbine2_d_c_3B(1, argc, argv);
   return 0;
}
