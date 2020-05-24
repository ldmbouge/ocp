//
//  rigidBody1.m
//  Clo
//
//  Created by Rémy Garcia on 12/04/2019.
//
#import <ORProgram/ORProgram.h>
#include "gmp.h"
#include <signal.h>
#include <stdlib.h>

id<ORRational> (^rigidBody1Error)(NSMutableArray* arrayValue, NSMutableArray* arrayError) = ^(NSMutableArray* arrayValue, NSMutableArray* arrayError){
   ORDouble x1 = [[arrayValue objectAtIndex:0] doubleValue];
   ORDouble x2 = [[arrayValue objectAtIndex:1] doubleValue];
   ORDouble x3 = [[arrayValue objectAtIndex:2] doubleValue];
   
   id<ORRational> two = [[ORRational alloc] init];
   id<ORRational> x1Q = [[ORRational alloc] init];
   id<ORRational> x2Q = [[ORRational alloc] init];
   id<ORRational> x3Q = [[ORRational alloc] init];
   id<ORRational> zQ = [[ORRational alloc] init];
   id<ORRational> zF = [[ORRational alloc] init];
   id<ORRational> ez = [[[ORRational alloc] init] autorelease];
   
   [two set_d:2.0];
   [x1Q setInput:x1 with:[arrayError objectAtIndex:0]];
   [x2Q setInput:x2 with:[arrayError objectAtIndex:1]];
   [x3Q setInput:x3 with:[arrayError objectAtIndex:2]];
   
   ORDouble z = (((-(x1 * x2) - ((2.0 * x2) * x3)) - x1) - x3);
   
   [zF set_d:z];
   
   [zQ set:[[[[[x1Q mul: x2Q] neg] sub: [[two mul: x2Q] mul: x3Q]] sub: x1Q] sub: x3Q]];
   
   [ez set: [zQ sub: zF]];
   
   [two release];
   [x1Q release];
   [x2Q release];
   [x3Q release];
   [zQ release];
   [zF release];
   
   [arrayValue addObject:[NSNumber numberWithDouble:z]];
   [arrayError addObject:ez];
   
   return ez;
};

void rigidBody1_d(int search, int argc, const char * argv[]) {
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
      
      [mdl add:[z set: [[[[[x1 mul: x2] minus] sub: [[@(2.0) mul: x2] mul: x3]] sub: x1] sub: x3]]];
      
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
                              compute:rigidBody1Error];
      }];
   }
}

void rigidBody1_d_c(int search, int argc, const char * argv[]) {
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
      [mdl add:[z set: [[[[[x1 mul: x2] minus] sub: [[@(2.0) mul: x2] mul: x3]] sub: x1] sub: x3]]];
      
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
                           compute:rigidBody1Error];
      }];
   }
}

void rigidBody1_d_c_3B(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of model variables */
      id<ORGroup> g = [ORFactory group:mdl type:Group3B];
      id<ORDoubleVar> x1 = [ORFactory doubleInputVar:mdl low:-15.0 up:15.0 name:@"x1"];
      id<ORDoubleVar> x2 = [ORFactory doubleInputVar:mdl low:-15.0 up:15.0 name:@"x2"];
      id<ORDoubleVar> x3 = [ORFactory doubleInputVar:mdl low:-15.0 up:15.0 name:@"x3"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      
      /* Declaration of constraints */
      [g add:[z set: [[[[[x1 mul: x2] minus] sub: [[@(2.0) mul: x2] mul: x3]] sub: x1] sub: x3]]];
      
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
                           compute:rigidBody1Error];
      }];
   }
}


void rigidBody1_f_c(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of model variables */
      id<ORFloatVar> x1 = [ORFactory floatInputVar:mdl low:-15.0f up:15.0f name:@"x1"];
      id<ORFloatVar> x2 = [ORFactory floatInputVar:mdl low:-15.0f up:15.0f name:@"x2"];
      id<ORFloatVar> x3 = [ORFactory floatInputVar:mdl low:-15.0f up:15.0f name:@"x3"];
      id<ORFloatVar> z = [ORFactory floatVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      
      /* Declaration of constraints */
      [mdl add:[z set: [[[[[x1 mul: x2] minus] sub: [[@(2.0f) mul: x2] mul: x3]] sub: x1] sub: x3]]];
      
      /* Declaration of constraints over errors */
      [mdl add: [ezAbs eq: [ez abs]]];
      [mdl maximize:ezAbs];
      
      /* Display model */
      NSLog(@"model: %@",mdl);
      
      /* Construction of solver */
      id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBBController proto]];
      id<ORFloatVarArray> vs = [mdl floatVars];
      id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      /* Solving */
      [cp solve:^{
         /* Branch-and-bound search strategy to maximize ezAbs, the error in absolute value of z */
         [cp branchAndBoundSearch:vars out:ezAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
            /* Split strategy */
            [cp floatSplit:i withVars:x];
         }
                          compute:^(NSMutableArray* arrayValue, NSMutableArray* arrayError){
            ORFloat x1 = [[arrayValue objectAtIndex:0] doubleValue];
            ORFloat x2 = [[arrayValue objectAtIndex:1] doubleValue];
            ORFloat x3 = [[arrayValue objectAtIndex:2] doubleValue];
            
            id<ORRational> two = [[ORRational alloc] init];
            id<ORRational> x1Q = [[ORRational alloc] init];
            id<ORRational> x2Q = [[ORRational alloc] init];
            id<ORRational> x3Q = [[ORRational alloc] init];
            id<ORRational> zQ = [[ORRational alloc] init];
            id<ORRational> zF = [[ORRational alloc] init];
            id<ORRational> ez = [[[ORRational alloc] init] autorelease];
            
            [two set_d:2.0];
            [x1Q setInput:x1 with:[arrayError objectAtIndex:0]];
            [x2Q setInput:x2 with:[arrayError objectAtIndex:1]];
            [x3Q setInput:x3 with:[arrayError objectAtIndex:2]];
            
            ORFloat z = (((-(x1 * x2) - ((2.0 * x2) * x3)) - x1) - x3);
            
            [zF set_d:z];
            
            [zQ set:[[[[[x1Q mul: x2Q] neg] sub: [[two mul: x2Q] mul: x3Q]] sub: x1Q] sub: x3Q]];
            
            [ez set: [zQ sub: zF]];
            
            [two release];
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


void rigidBody1_f(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0f];
      id<ORFloatVar> x1 = [ORFactory floatVar:mdl low:-15.0f up:15.0f elow:zero eup:zero name:@"x1"];
      id<ORFloatVar> x2 = [ORFactory floatVar:mdl low:-15.0f up:15.0f elow:zero eup:zero name:@"x2"];
      id<ORFloatVar> x3 = [ORFactory floatVar:mdl low:-15.0f up:15.0f elow:zero eup:zero name:@"x3"];
      id<ORFloatVar> z = [ORFactory floatVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      [zero release];
      
      //[mdl add:[z set: [[[[@(0.0) sub: [x1 mul: x2]] sub: [[@(2.0) mul: x2] mul: x3]] sub: x1] sub: x3]]];
      
      [mdl add:[z set: [[[[[x1 mul: x2] minus] sub: [[@(2.0f) mul: x2] mul: x3]] sub: x1] sub: x3]]];
      
      
      [mdl add: [ezAbs eq: [ez abs]]];
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
               ORFloat x1 = [[arrayValue objectAtIndex:0] doubleValue];
               ORFloat x2 = [[arrayValue objectAtIndex:1] doubleValue];
               ORFloat x3 = [[arrayValue objectAtIndex:2] doubleValue];
               
               id<ORRational> two = [[ORRational alloc] init];
               id<ORRational> x1Q = [[ORRational alloc] init];
               id<ORRational> x2Q = [[ORRational alloc] init];
               id<ORRational> x3Q = [[ORRational alloc] init];
               id<ORRational> zQ = [[ORRational alloc] init];
               id<ORRational> zF = [[ORRational alloc] init];
               id<ORRational> ez = [[[ORRational alloc] init] autorelease];
               
               [two set_d:2.0];
               [x1Q setInput:x1 with:[arrayError objectAtIndex:0]];
               [x2Q setInput:x2 with:[arrayError objectAtIndex:1]];
               [x3Q setInput:x3 with:[arrayError objectAtIndex:2]];
               
               ORFloat z = (((-(x1 * x2) - ((2.0 * x2) * x3)) - x1) - x3);
               
               [zF set_d:z];
               
               [zQ set:[[[[[x1Q mul: x2Q] neg] sub: [[two mul: x2Q] mul: x3Q]] sub: x1Q] sub: x3Q]];
               
               [ez set: [zQ sub: zF]];
               
               [two release];
               [x1Q release];
               [x2Q release];
               [x3Q release];
               [zQ release];
               [zF release];
               
               [arrayValue addObject:[NSNumber numberWithDouble:z]];
               [arrayError addObject:ez];

               return ez;
            }];
      }];
   }
}

int main(int argc, const char * argv[]) {
   //rigidBody1_d(1, argc, argv);
   rigidBody1_d_c(1, argc, argv);
   //rigidBody1_d_c_3B(1, argc, argv);
   //rigidBody1_f_c(1, argc, argv);
   //rigidBody1_f(1, argc, argv);
   return 0;
}
