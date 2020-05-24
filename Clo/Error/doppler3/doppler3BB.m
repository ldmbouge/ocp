//
//  doppler3.m
//  Clo
//
//  Created by Rémy Garcia on 12/04/2019.
//
#import <ORProgram/ORProgram.h>
#include "gmp.h"
#include <signal.h>
#include <stdlib.h>

id<ORRational> (^doppler3Error)(NSMutableArray* arrayValue, NSMutableArray* arrayError) = ^(NSMutableArray* arrayValue, NSMutableArray* arrayError){
   ORDouble u = [[arrayValue objectAtIndex:0] doubleValue];
   ORDouble v = [[arrayValue objectAtIndex:1] doubleValue];
   ORDouble t = [[arrayValue objectAtIndex:2] doubleValue];
   ORDouble a = 331.4;
   ORDouble b = 0.6;
   
   id<ORRational> minusOne = [[ORRational alloc] init];
   id<ORRational> uQ = [[ORRational alloc] init];
   id<ORRational> vQ = [[ORRational alloc] init];
   id<ORRational> tQ = [[ORRational alloc] init];
   id<ORRational> aQ = [[ORRational alloc] init];
   id<ORRational> bQ = [[ORRational alloc] init];
   id<ORRational> t1Q = [[ORRational alloc] init];
   id<ORRational> zQ = [[ORRational alloc] init];
   id<ORRational> zF = [[ORRational alloc] init];
   id<ORRational> ez = [[[ORRational alloc] init] autorelease];
   
   [minusOne setMinusOne];
   [uQ setInput:u with:[arrayError objectAtIndex:0]];
   [vQ setInput:v with:[arrayError objectAtIndex:1]];
   [tQ setInput:t with:[arrayError objectAtIndex:2]];
   [aQ set_str:"1657/5"];
   [bQ set_str:"3/5"];
   
   ORDouble t1 = a + (b * t);
   ORDouble z = ((-1.0 * t1) * v) / ((t1 + u) * (t1 + u));
   [zF set_d:z];
   
   [t1Q set: [aQ add:[bQ mul: tQ]]];
   [zQ set:[[[t1Q neg] mul: vQ] div: [[t1Q add: uQ] mul: [t1Q add: uQ]]]];
   
   [ez set: [zQ sub: zF]];
   
   [minusOne release];
   [uQ release];
   [vQ release];
   [tQ release];
   [aQ release];
   [bQ release];
   [t1Q release];
   [zQ release];
   [zF release];
   
   [arrayValue addObject:[NSNumber numberWithDouble:z]];
   [arrayError addObject:ez];

   return ez;
};
void doppler3_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> u = [ORFactory doubleInputVar:mdl low:-30.0 up:120.0 elow:zero eup:zero name:@"u"];
      id<ORDoubleVar> v = [ORFactory doubleInputVar:mdl low:320.0 up:20300.0 elow:zero eup:zero name:@"u"];
      id<ORDoubleVar> t = [ORFactory doubleInputVar:mdl low:-50.0 up:30.0 elow:zero eup:zero name:@"u"];
      id<ORDoubleVar> t1 = [ORFactory doubleVar:mdl name:@"t1"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      [zero release];
      
      [mdl add:[t1 set: [@(331.4) plus:[@(0.6) mul: t]]]];
      [mdl add:[z set: [[[t1 minus] mul: v] div: [[t1 plus: u] mul: [t1 plus: u]]]]];
      
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
                              compute:doppler3Error];
      }];
   }
}

void doppler3_d_c(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of model variables */
      id<ORDoubleVar> u = [ORFactory doubleInputVar:mdl low:-30.0 up:120.0 name:@"u"];
      id<ORDoubleVar> v = [ORFactory doubleInputVar:mdl low:320.0 up:20300.0 name:@"v"];
      id<ORDoubleVar> t = [ORFactory doubleInputVar:mdl low:-50.0 up:30.0 name:@"t"];
      id<ORDoubleVar> a = [ORFactory doubleConstantVar:mdl value:331.4 string:@"1657/5" name:@"a"];
      id<ORDoubleVar> b = [ORFactory doubleConstantVar:mdl value:0.6 string:@"3/5" name:@"b"];
      id<ORDoubleVar> t1 = [ORFactory doubleVar:mdl name:@"t1"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      
      /* Declaration of constraints */
      [mdl add:[t1 set: [a plus:[b mul: t]]]];
      [mdl add:[z set: [[[t1 minus] mul: v] div: [[t1 plus: u] mul: [t1 plus: u]]]]];
      
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
                           compute:doppler3Error];
      }];
   }
}

void doppler3_d_c_3B(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of model variables */
      id<ORGroup> g = [ORFactory group:mdl type:Group3B];
      id<ORDoubleVar> u = [ORFactory doubleInputVar:mdl low:-30.0 up:120.0 name:@"u"];
      id<ORDoubleVar> v = [ORFactory doubleInputVar:mdl low:320.0 up:20300.0 name:@"u"];
      id<ORDoubleVar> t = [ORFactory doubleInputVar:mdl low:-50.0 up:30.0 name:@"u"];
      id<ORDoubleVar> a = [ORFactory doubleConstantVar:mdl value:331.4 string:@"1657/5" name:@"a"];
      id<ORDoubleVar> b = [ORFactory doubleConstantVar:mdl value:0.6 string:@"3/5" name:@"b"];
      id<ORDoubleVar> t1 = [ORFactory doubleVar:mdl name:@"t1"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      
      /* Declaration of constraints */
      [g add:[t1 set: [a plus:[b mul: t]]]];
      [g add:[z set: [[[t1 minus] mul: v] div: [[t1 plus: u] mul: [t1 plus: u]]]]];
      
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
                           compute:doppler3Error];
      }];
   }
}


int main(int argc, const char * argv[]) {
   //doppler3_d(1, argc, argv);
   doppler3_d_c(1, argc, argv);
   //doppler3_d_c_3B(1, argc, argv);
   return 0;
}
