//
//  predatorPrey.m
//  Clo
//
//  Created by Rémy Garcia on 12/04/2019.
//

#import <ORProgram/ORProgram.h>
#include "gmp.h"
#include <signal.h>
#include <stdlib.h>

id<ORRational> (^predatorPreyError)(NSMutableArray* arrayValue, NSMutableArray* arrayError) = ^(NSMutableArray* arrayValue, NSMutableArray* arrayError){
   ORDouble r = 4.0;
   ORDouble k = 1.11;
   ORDouble x = [[arrayValue objectAtIndex:0] doubleValue];
   
   id<ORRational> oneQ = [[ORRational alloc] init];
   id<ORRational> rQ = [[ORRational alloc] init];
   id<ORRational> kQ = [[ORRational alloc] init];
   id<ORRational> xQ = [[ORRational alloc] init];
   id<ORRational> zQ = [[ORRational alloc] init];
   id<ORRational> zF = [[ORRational alloc] init];
   id<ORRational> ez = [[[ORRational alloc] init] autorelease];
   
   [oneQ setOne];
   [rQ set_d:4.0];
   [kQ set_str:"111/100"];
   [xQ setInput:x with:[arrayError objectAtIndex:0]];
   
   ORDouble z = ((r*x)*x) / (1.0 + ((x/k)*(x/k)));
   
   [zF set_d:z];
   
   [zQ set:[[[rQ mul: xQ] mul: xQ] div: [oneQ add: [[xQ div: kQ] mul: [xQ div: kQ]]]]];
   
   [ez set: [zQ sub: zF]];
   
   [oneQ release];
   [rQ release];
   [kQ release];
   [xQ release];
   [zQ release];
   [zF release];
   
   [arrayValue addObject:[NSNumber numberWithDouble:z]];
   [arrayError addObject:ez];

   return ez;
};

void predatorPrey_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> x = [ORFactory doubleInputVar:mdl low:0.1 up:0.3 elow:zero eup:zero name:@"x"];
      id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
      id<ORDoubleVar> K = [ORFactory doubleVar:mdl name:@"K"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      [zero release];
      
      [mdl add:[r set: @(4.0)]];
      [mdl add:[K set: @(1.11)]];
      [mdl add:[z set:[[[r mul: x] mul: x] div: [@(1.0) plus: [[x div: K] mul: [x div: K]]]]]];
      
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
                              compute:predatorPreyError];
      }];
   }
}

void predatorPrey_d_c(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of rational numbers */
      id<ORRational> zero = [[ORRational alloc] init];
      
      /* Initialization of rational numbers */
      [zero setZero];
      
      /* Declaration of model variables */
      id<ORDoubleVar> x = [ORFactory doubleInputVar:mdl low:0.1 up:0.3 name:@"x"];
      id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
      id<ORDoubleVar> K = [ORFactory doubleConstantVar:mdl value:1.11 string:@"111/100" name:@"K"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      
      /* Initialization of constants */
      [mdl add:[r set: @(4.0)]];
      
      /* Declaration of constraints */
      [mdl add:[z set:[[[r mul: x] mul: x] div: [@(1.0) plus: [[x div: K] mul: [x div: K]]]]]];
      
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
                           compute:predatorPreyError];
      }];
   }
}

void predatorPrey_f(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0f];
      id<ORFloatVar> r = [ORFactory floatVar:mdl name:@"r"];
      id<ORFloatVar> K = [ORFactory floatVar:mdl name:@"K"];
      id<ORFloatVar> z = [ORFactory floatVar:mdl name:@"z"];
      id<ORFloatVar> x = [ORFactory floatVar:mdl low:0.1f up:0.3f elow:zero eup:zero name:@"x"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      //[zero release];
      
      [mdl add:[r set: @(4.0f)]];
      [mdl add:[K set: @(1.11f)]];
      [mdl add:[z set:[[[r mul: x] mul: x]  div: [@(1.0f) plus: [[x div: K] mul:[x div: K]]]]]];
      
      [mdl add: [ezAbs eq: [ez abs]]];
      //[zero set_d:9.9e-17];
      //[mdl add: [ez geq:zero]];
      [mdl maximize:ezAbs];
      [zero release];
      
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
               return [[ORRational alloc] init];
            }];
      }];
   }
}

void predatorPrey_d_c_3B(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of rational numbers */
      id<ORRational> zero = [[ORRational alloc] init];
      
      /* Initialization of rational numbers */
      [zero setZero];
      
      /* Declaration of model variables */
      id<ORGroup> g = [ORFactory group:mdl type:Group3B];
      id<ORDoubleVar> x = [ORFactory doubleInputVar:mdl low:0.1 up:0.3 name:@"x"];
      id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
      id<ORDoubleVar> K = [ORFactory doubleConstantVar:mdl value:1.11 string:@"111/100" name:@"K"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      
      /* Initialization of constants */
      [g add:[r set: @(4.0)]];
      
      /* Declaration of constraints */
      [g add:[z set:[[[r mul: x] mul: x] div: [@(1.0) plus: [[x div: K] mul: [x div: K]]]]]];
      
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
                           compute:predatorPreyError];
      }];
   }
}

int main(int argc, const char * argv[]) {
   //predatorPrey_f(1, argc, argv);
   //predatorPrey_d(1, argc, argv);
   predatorPrey_d_c(1, argc, argv);
   //predatorPrey_d_c_3B(1, argc, argv);
   return 0;
}


