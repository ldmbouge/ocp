//
//  main.m
//  testFloat
//
//  Created by Rémy Garcia on 12/04/2019.
//
//

#import <ORProgram/ORProgram.h>
#include "gmp.h"
//#import "ORCmdLineArgs.h"
#include <signal.h>
#include <stdlib.h>

id<ORRational> (^verhulstError)(NSMutableArray* arrayValue, NSMutableArray* arrayError) = ^(NSMutableArray* arrayValue, NSMutableArray* arrayError){
   ORDouble r = 4.0;
   ORDouble k = 1.11;
   ORDouble x = [[arrayValue objectAtIndex:0] doubleValue];
   
   id<ORRational> one = [[ORRational alloc] init];
   id<ORRational> rQ = [[ORRational alloc] init];
   id<ORRational> kQ = [[ORRational alloc] init];
   id<ORRational> xQ = [[ORRational alloc] init];
   id<ORRational> zQ = [[ORRational alloc] init];
   id<ORRational> zF = [[ORRational alloc] init];
   id<ORRational> ez = [[[ORRational alloc] init] autorelease];
   
   [one setOne];
   [rQ set_d:4.0];
   [kQ set_str:"111/100"];
   [xQ setInput:x with:[arrayError objectAtIndex:0]];
   
   ORDouble z = ((r * x) / (1.0 + (x / k)));
   [zF set_d:z];
   
   [zQ set: [[rQ mul: xQ] div: [one add: [xQ div: kQ]]]];
   
   [ez set: [zQ sub: zF]];
   
   [one release];
   [rQ release];
   [kQ release];
   [xQ release];
   [zQ release];
   [zF release];
   
   [arrayValue addObject:[NSNumber numberWithDouble:z]];
   [arrayError addObject:ez];
   return ez;

};

void verhulst_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> x = [ORFactory doubleInputVar:mdl low:0.1 up:0.3 elow:zero eup:zero name:@"x"];
      id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
      id<ORDoubleVar> k = [ORFactory doubleVar:mdl name:@"k"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      [zero release];
      
      [mdl add:[r set: @(4.0)]];
      [mdl add:[k set: @(1.11)]];
      [mdl add:[z set:[[r mul: x] div: [@(1.0) plus: [x div: k]]]]];
      
      [mdl add: [ezAbs eq: [ez abs]]];
      [mdl maximize:ezAbs];
      
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBBController proto]];
      id<ORDoubleVarArray> vs = [mdl doubleVars];
      id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
         [cp branchAndBoundSearchD:vars out:ezAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [cp floatSplit:i withVars:x];
         }
                           compute:verhulstError];
      }];
   }
}

void verhulst_f(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORFloatVar> x = [ORFactory floatVar:mdl low:0.1 up:0.3 elow:zero eup:zero name:@"x"];
      id<ORFloatVar> r = [ORFactory floatVar:mdl name:@"r"];
      id<ORFloatVar> k = [ORFactory floatVar:mdl name:@"k"];
      id<ORFloatVar> z = [ORFactory floatVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      [zero release];
      
      [mdl add:[r set: @(4.0f)]];
      [mdl add:[k set: @(1.11f)]];
      [mdl add:[z set:[[r mul: x] div: [@(1.0f) plus: [x div: k]]]]];
      
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
                             compute:verhulstError];
         
      }];
   }
}

void verhulst_d_c(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      //ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      //[args measure:^struct ORResult(){
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of rational numbers */
      id<ORRational> zero = [[ORRational alloc] init];
      
      /* Initialization of rational numbers */
      [zero set_d: 0];
      
      /* Declaration of model variables */
      id<ORDoubleVar> x = [ORFactory doubleInputVar:mdl low:0.1 up:0.3 name:@"x"];
      id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
      id<ORDoubleVar> k = [ORFactory doubleConstantVar:mdl value:1.11 string:@"111/100" name:@"k"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      
      /* Initialization of constants */
      [mdl add:[r set: @(4.0)]];
      
      /* Declaration of constraints */
      [mdl add:[z set:[[r mul: x] div: [@(1.0) plus: [x div: k]]]]];
      
      /* Declaration of constraints over errors */
      [mdl add: [ezAbs eq: [ez abs]]];
      [mdl maximize:ezAbs];
      
      /* Memory release of rational numbers */
      [zero release];
      
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
                           compute:verhulstError];
      }];
   }
}

void verhulst_d_c_3B(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of rational numbers */
      id<ORRational> zero = [[ORRational alloc] init];
      
      /* Initialization of rational numbers */
      [zero set_d: 0];
      
      /* Declaration of model variables */
      id<ORGroup> g = [ORFactory group:mdl type:Group3B];
      id<ORDoubleVar> x = [ORFactory doubleInputVar:mdl low:0.1 up:0.3 name:@"x"];
      id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
      id<ORDoubleVar> k = [ORFactory doubleConstantVar:mdl value:1.11 string:@"111/100" name:@"k"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      
      /* Initialization of constants */
      [g add:[r set: @(4.0)]];
      
      /* Declaration of constraints */
      [g add:[z set:[[r mul: x] div: [@(1.0) plus: [x div: k]]]]];
      
      /* Declaration of constraints over errors */
      [g add: [ezAbs eq: [ez abs]]];
      [mdl add: g];
      [mdl maximize:ezAbs];
      
      /* Memory release of rational numbers */
      [zero release];
      
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
                           compute:verhulstError];
      }];
   }
}

int main(int argc, const char * argv[]) {
   //verhulst_f(1, argc, argv);
   //verhulst_d(1, argc, argv);
   verhulst_d_c(1, argc, argv);
   //verhulst_d_c_3B(1, argc, argv);
   return 0;
}
