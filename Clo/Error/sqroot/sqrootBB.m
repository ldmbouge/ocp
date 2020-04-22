//
//  sqroot.m
//  Clo
//
//  Created by Rémy Garcia on 12/04/2019.
//

#import <ORProgram/ORProgram.h>
#include "gmp.h"
//#import "ORCmdLineArgs.h"
#include <signal.h>
#include <stdlib.h>
#include <time.h>

id<ORRational> (^sqrootError)(NSMutableArray* arrayValue, NSMutableArray* arrayError) = ^(NSMutableArray* arrayValue, NSMutableArray* arrayError){
   ORDouble x = [[arrayValue objectAtIndex:0] doubleValue];
   ORDouble a = 0.5;
   ORDouble b = 0.125;
   ORDouble c = 0.0625;
   ORDouble d = 0.0390625;
   
   id<ORRational> one = [[ORRational alloc] init];
   id<ORRational> xQ = [[ORRational alloc] init];
   id<ORRational> aQ = [[ORRational alloc] init];
   id<ORRational> bQ = [[ORRational alloc] init];
   id<ORRational> cQ = [[ORRational alloc] init];
   id<ORRational> dQ = [[ORRational alloc] init];
   id<ORRational> zQ = [[ORRational alloc] init];
   id<ORRational> zF = [[ORRational alloc] init];
   id<ORRational> ez = [[[ORRational alloc] init] autorelease];
   
   [one setOne];
   [xQ setInput:x with:[arrayError objectAtIndex:0]];
   [aQ setConstant:a and:"1/2"];
   [bQ setConstant:b and:"1/8"];
   [cQ setConstant:c and:"1/16"];
   [dQ setConstant:d and:"5/128"];
   
   ORDouble z = ((((1.0 + (a * x)) - ((b * x) * x)) + (((c * x) * x) * x)) - ((((d * x) * x) * x) * x));
   
   [zF set_d:z];
   
   [zQ set:[[[[one add: [aQ mul: xQ]] sub: [[bQ mul: xQ] mul: xQ]] add: [[[cQ mul: xQ] mul: xQ] mul: xQ]] sub: [[[[dQ mul: xQ] mul: xQ] mul: xQ] mul: xQ]]];
   
   [ez set: [zQ sub: zF]];
   
   [one release];
   [xQ release];
   [aQ release];
   [bQ release];
   [cQ release];
   [dQ release];
   [zQ release];
   [zF release];
   
   [arrayValue addObject:[NSNumber numberWithDouble:z]];
   [arrayError addObject:ez];
   
   return ez;
   
};

void sqroot_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> x = [ORFactory doubleInputVar:mdl low:0.0 up:1.0 elow:zero eup:zero name:@"x"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      id<ORGroup> g = [ORFactory group:mdl type:DefaultGroup];
      [zero release];
      
      //((((1.0 + (0.5 * x)) - ((0.125 * x) * x)) + (((0.0625 * x) * x) * x)) - ((((0.0390625 * x) * x) * x) * x));
      [g add:[z set: [[[[@(1.0) plus: [@(0.5) mul: x]] sub: [[@(0.125) mul: x] mul: x]] plus: [[[@(0.0625) mul: x] mul: x] mul: x]] sub: [[[[@(0.0390625) mul: x] mul: x] mul: x] mul: x]]]];
      
      [g add: [ezAbs eq: [ez abs]]];
      [mdl add:g];
      [mdl maximize:ezAbs];
      
      //[zero release];
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBBController proto]];
      id<ORDoubleVarArray> vs = [mdl doubleVars];
      id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
         if (search)
            [cp branchAndBoundSearchD:vars out:ezAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [cp floatSplit:i withVars:x];
            }
                              compute:sqrootError];
      }];
   }
}

void sqroot_d_c(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of model variables */
      id<ORDoubleVar> x = [ORFactory doubleInputVar:mdl low:0.0 up:1.0 name:@"x"];
      id<ORDoubleVar> a = [ORFactory doubleConstantVar:mdl value:0.5 string:@"1/2" name:@"a"];
      id<ORDoubleVar> b = [ORFactory doubleConstantVar:mdl value:0.125 string:@"1/8" name:@"b"];
      id<ORDoubleVar> c = [ORFactory doubleConstantVar:mdl value:0.0625 string:@"1/16" name:@"c"];
      id<ORDoubleVar> d = [ORFactory doubleConstantVar:mdl value:0.0390625 string:@"5/128" name:@"d"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      
      /* Declaration of constraints */
      //((((1.0 + (0.5 * x)) - ((0.125 * x) * x)) + (((0.0625 * x) * x) * x)) - ((((0.0390625 * x) * x) * x) * x));
      [mdl add:[z set: [[[[@(1.0) plus: [a mul: x]] sub: [[b mul: x] mul: x]] plus: [[[c mul: x] mul: x] mul: x]] sub: [[[[d mul: x] mul: x] mul: x] mul: x]]]];
      
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
                           compute:sqrootError];
      }];
   }
}

void sqroot_d_c_3B(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of model variables */
      id<ORDoubleVar> x = [ORFactory doubleInputVar:mdl low:0.0 up:1.0 name:@"x"];
      id<ORDoubleVar> a = [ORFactory doubleConstantVar:mdl value:0.5 string:@"1/2" name:@"a"];
      id<ORDoubleVar> b = [ORFactory doubleConstantVar:mdl value:0.125 string:@"1/8" name:@"b"];
      id<ORDoubleVar> c = [ORFactory doubleConstantVar:mdl value:0.0625 string:@"1/16" name:@"c"];
      id<ORDoubleVar> d = [ORFactory doubleConstantVar:mdl value:0.0390625 string:@"5/128" name:@"d"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      id<ORGroup> g = [ORFactory group:mdl type:Group3B];
      
      /* Declaration of constraints */
      //((((1.0 + (0.5 * x)) - ((0.125 * x) * x)) + (((0.0625 * x) * x) * x)) - ((((0.0390625 * x) * x) * x) * x));
      [g add:[z set: [[[[@(1.0) plus: [a mul: x]] sub: [[b mul: x] mul: x]] plus: [[[c mul: x] mul: x] mul: x]] sub: [[[[d mul: x] mul: x] mul: x] mul: x]]]];
      
      /* Declaration of constraints over errors */
      [g add: [ezAbs eq: [ez abs]]];
      [mdl add:g];
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
                           compute:sqrootError];
      }];
   }
}


void sqroot_f(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORFloatVar> x = [ORFactory floatVar:mdl low:0.0f up:1.0f elow:zero eup:zero name:@"x"];
      id<ORFloatVar> z = [ORFactory floatVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      id<ORGroup> g = [ORFactory group:mdl type:DefaultGroup];
      [zero release];
      
      //((((1.0 + (0.5 * x)) - ((0.125 * x) * x)) + (((0.0625 * x) * x) * x)) - ((((0.0390625 * x) * x) * x) * x));
      [g add:[z set: [[[[@(1.0f) plus: [@(0.5f) mul: x]] sub: [[@(0.125f) mul: x] mul: x]] plus: [[[@(0.0625f) mul: x] mul: x] mul: x]] sub: [[[[@(0.0390625f) mul: x] mul: x] mul: x] mul: x]]]];
      
      [g add: [ezAbs eq: [ez abs]]];
      [mdl add:g];
      [mdl maximize:ezAbs];
      
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBBController proto]];
      id<ORFloatVarArray> vs = [mdl floatVars];
      id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
         if (search)
            [cp branchAndBoundSearch:vars out:ezAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [cp floatSplit:i withVars:x];
            }
                             compute:^(NSMutableArray* arrayValue, NSMutableArray* arrayError){
               ORDouble x = [[arrayValue objectAtIndex:0] doubleValue];
               ORDouble a = 0.5;
               ORDouble b = 0.125;
               ORDouble c = 0.0625;
               ORDouble d = 0.0390625;
               
               id<ORRational> one = [[ORRational alloc] init];
               id<ORRational> xQ = [[ORRational alloc] init];
               id<ORRational> aQ = [[ORRational alloc] init];
               id<ORRational> bQ = [[ORRational alloc] init];
               id<ORRational> cQ = [[ORRational alloc] init];
               id<ORRational> dQ = [[ORRational alloc] init];
               id<ORRational> zQ = [[ORRational alloc] init];
               id<ORRational> zF = [[ORRational alloc] init];
               id<ORRational> ez = [[[ORRational alloc] init] autorelease];
               
               [one setOne];
               [xQ setInput:x with:[arrayError objectAtIndex:0]];
               [aQ setConstant:a and:"1/2"];
               [bQ setConstant:b and:"1/8"];
               [cQ setConstant:c and:"1/16"];
               [dQ setConstant:d and:"5/128"];
               
               ORDouble z = ((((1.0 + (a * x)) - ((b * x) * x)) + (((c * x) * x) * x)) - ((((d * x) * x) * x) * x));
               
               [zF set_d:z];
               
               [zQ set:[[[[one add: [aQ mul: xQ]] sub: [[bQ mul: xQ] mul: xQ]] add: [[[cQ mul: xQ] mul: xQ] mul: xQ]] sub: [[[[dQ mul: xQ] mul: xQ] mul: xQ] mul: xQ]]];
               
               [ez set: [zQ sub: zF]];
               
               [one release];
               [xQ release];
               [aQ release];
               [bQ release];
               [cQ release];
               [dQ release];
               [zQ release];
               [zF release];
               return ez;
            }];
      }];
   }
}

int main(int argc, const char * argv[]) {
   //sqroot_d(1, argc, argv);
   //sqroot_d_c(1, argc, argv);
   //sqroot_f(1, argc, argv);
   sqroot_d_c_3B(1, argc, argv);
   return 0;
}
