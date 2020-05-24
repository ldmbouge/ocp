//
//  carbonGas.m
//
//  Created by Rémy Garcia on 12/04/2019.
//
#import <ORProgram/ORProgram.h>
#include "gmp.h"
#include <signal.h>
#include <stdlib.h>

id<ORRational> (^carbonGasError)(NSMutableArray* arrayValue, NSMutableArray* arrayError) = ^(NSMutableArray* arrayValue, NSMutableArray* arrayError){
   ORDouble v = [[arrayValue objectAtIndex:0] doubleValue];
   ORDouble p = 3.5e7;
   ORDouble a = 0.401;
   ORDouble b = 42.7e-6;
   ORDouble t = 300.0;
   ORDouble n = 1000.0;
   ORDouble k = 1.3806503e-23;
   
   id<ORRational> vQ = [[ORRational alloc] init];
   id<ORRational> pQ = [[ORRational alloc] init];
   id<ORRational> aQ = [[ORRational alloc] init];
   id<ORRational> bQ = [[ORRational alloc] init];
   id<ORRational> tQ = [[ORRational alloc] init];
   id<ORRational> nQ = [[ORRational alloc] init];
   id<ORRational> kQ = [[ORRational alloc] init];
   id<ORRational> zQ = [[ORRational alloc] init];
   id<ORRational> zF = [[ORRational alloc] init];
   id<ORRational> ez = [[[ORRational alloc] init] autorelease];
   
   [vQ setInput:v with:[arrayError objectAtIndex:0]];
   [pQ set_d:p];
   [aQ set_str:"401/1000"];
   [bQ set_str:"427/10000000"];
   [tQ set_d:t];
   [nQ set_d:n];
   [kQ set_str:"13806503/1000000000000000000000000000000"];

   ORDouble z = (((p + ((a * (n/v)) * (n/v))) * (v - (n * b))) - ((k * n) * t));
   [zF set_d:z];
   
   [zQ set: [[[pQ add: [[aQ mul: [nQ div: vQ]] mul: [nQ div: vQ]]] mul: [vQ sub: [nQ mul: bQ]]] sub: [[kQ mul: nQ] mul: tQ]]];
   
   [ez set: [zQ sub: zF]];
   
   [vQ release];
   [pQ release];
   [aQ release];
   [bQ release];
   [tQ release];
   [nQ release];
   [kQ release];
   [zQ release];
   [zF release];
   
   [arrayValue addObject:[NSNumber numberWithDouble:z]];
   [arrayError addObject:ez];
   
   return ez;
};

void carbonGas_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> v = [ORFactory doubleInputVar:mdl low:0.1 up:0.5 elow:zero eup:zero name:@"v"];
      id<ORDoubleVar> p = [ORFactory doubleVar:mdl name:@"p"];
      id<ORDoubleVar> a = [ORFactory doubleVar:mdl name:@"a"];
      id<ORDoubleVar> b = [ORFactory doubleVar:mdl name:@"b"];
      id<ORDoubleVar> t = [ORFactory doubleVar:mdl name:@"t"];
      id<ORDoubleVar> n = [ORFactory doubleVar:mdl name:@"n"];
      id<ORDoubleVar> k = [ORFactory doubleVar:mdl name:@"k"];
      id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
      id<ORRationalVar> er = [ORFactory errorVar:mdl of:r];
      id<ORRationalVar> ulp_r = [ORFactory ulpVar:mdl of:r];
      id<ORRationalVar> erAbs = [ORFactory rationalVar:mdl name:@"erAbs"];
      [zero release];
      
      [mdl add:[p set: @(3.5e7)]];
      [mdl add:[a set: @(0.401)]];
      [mdl add:[b set: @(42.7e-6)]];
      [mdl add:[t set: @(300.0)]];
      [mdl add:[n set: @(1000.0)]];
      [mdl add:[k set: @(1.3806503e-23)]];
      
      [mdl add:[r set: [[[p plus: [[a mul: [n div: v]] mul: [n div: v]]] mul: [v sub: [n mul: b]]] sub: [[k mul: n] mul: t]]]];
      
      [mdl add: [er leq: ulp_r]];
      [mdl add: [erAbs eq: [er abs]]];
      [mdl maximize:erAbs];
      
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBBController proto]];
      id<ORDoubleVarArray> vs = [mdl doubleVars];
      id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
         if (search)
            [cp branchAndBoundSearchD:vars out:erAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [cp floatSplit:i withVars:x];
            }
                              compute:carbonGasError];
      }];
   }
}

void carbonGas_d_c(bool continuous, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of rational numbers */
      id<ORRational> zero = [[ORRational alloc] init];
      
      /* Initialization of rational numbers */
      [zero setZero];
      
      /* Declaration of model variables */
      id<ORDoubleVar> v = [ORFactory doubleInputVar:mdl low:0.1 up:0.5 name:@"v"];
      id<ORDoubleVar> p = [ORFactory doubleVar:mdl name:@"p"];
      id<ORDoubleVar> a = [ORFactory doubleConstantVar:mdl value:0.401 string:@"401/1000" name:@"a"];
      id<ORDoubleVar> b = [ORFactory doubleConstantVar:mdl value:42.7e-6 string:@"427/10000000" name:@"b"];
      id<ORDoubleVar> t = [ORFactory doubleVar:mdl name:@"t"];
      id<ORDoubleVar> n = [ORFactory doubleVar:mdl name:@"n"];
      id<ORDoubleVar> k = [ORFactory doubleConstantVar:mdl value:1.3806503e-23 string:@"13806503/1000000000000000000000000000000" name:@"k"];
      id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
      id<ORRationalVar> er = [ORFactory errorVar:mdl of:r];
      id<ORRationalVar> erAbs = [ORFactory rationalVar:mdl name:@"erAbs"];
      
      /* Initialization of constants */
      [mdl add:[p set: @(3.5e7)]];
      [mdl add:[t set: @(300.0)]];
      [mdl add:[n set: @(1000.0)]];
      
      /* Declaration of constraints */
      [mdl add:[r set: [[[p plus: [[a mul: [n div: v]] mul: [n div: v]]] mul: [v sub: [n mul: b]]] sub: [[k mul: n] mul: t]]]];
      
      /* Declaration of constraints over errors */
      [mdl add: [erAbs eq: [er abs]]];
      [mdl maximize:erAbs];
      
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
         [cp branchAndBoundSearchD:vars out:erAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
            /* Split strategy */
            [cp floatSplit:i withVars:x];
         }
                           compute:carbonGasError];
      }];
   }
}

void motivating_example_d_c(bool continuous, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of rational numbers */
      id<ORRational> zero = [[ORRational alloc] init];
      
      /* Initialization of rational numbers */
      [zero setZero];
      
      /* Declaration of model variables */
//      id<ORDoubleVar> x = [ORFactory doubleInputVar:mdl low:0.0 up:100.0 elow:zero eup:zero name:@"x"];
      id<ORDoubleVar> x = [ORFactory doubleInputVar:mdl low:7.0 up:9.0 name:@"x"];
      id<ORDoubleVar> y = [ORFactory doubleInputVar:mdl low:3.0 up:5.0 name:@"y"];
      id<ORDoubleVar> w = [ORFactory doubleInputVar:mdl low:2.0 up:4.0 name:@"w"];
      id<ORDoubleVar> p = [ORFactory doubleVar:mdl name:@"p"];
      //id<ORDoubleVar> k = [ORFactory doubleConstantVar:mdl value:1.11 string:@"111/100" name:@"k"];
      id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
      id<ORRationalVar> er = [ORFactory errorVar:mdl of:r];
      id<ORRationalVar> erAbs = [ORFactory rationalVar:mdl name:@"erAbs"];
      
      /* Initialization of constants */
      [mdl add:[p set: @(3.0)]];
      
      /* Declaration of constraints */
      [mdl add:[r set:[[[x mul: p] plus: y] div: w]]];
      [mdl add:[r leq:@(10.0)]];
      
//      [mdl add:[r set:[[x mul: x] plus: x]]];
//      [mdl add:[r leq:@(1.0)]];
      
      /* Declaration of constraints over errors */
      [mdl add: [erAbs eq: [er abs]]];
      [mdl maximize:erAbs];
      
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
         [cp branchAndBoundSearchD:vars out:erAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
            /* Split strategy */
            [cp floatSplit:i withVars:x];
         }
                           compute:^(NSMutableArray* arrayValue, NSMutableArray* arrayError){
            ORDouble x = [[arrayValue objectAtIndex:0] doubleValue];
            ORDouble y = [[arrayValue objectAtIndex:1] doubleValue];
            ORDouble w = [[arrayValue objectAtIndex:2] doubleValue];
            ORDouble p = 3.0;
            
            id<ORRational> xQ = [[ORRational alloc] init];
            id<ORRational> yQ = [[ORRational alloc] init];
            id<ORRational> wQ = [[ORRational alloc] init];
            id<ORRational> pQ = [[ORRational alloc] init];
            id<ORRational> zQ = [[ORRational alloc] init];
            id<ORRational> zF = [[ORRational alloc] init];
            id<ORRational> ez = [[[ORRational alloc] init] autorelease];
            
            [pQ set_d:p];
            //[kQ set_str:"111/100"];
            [xQ setInput:x with:[arrayError objectAtIndex:0]];
            [yQ setInput:y with:[arrayError objectAtIndex:1]];
            [wQ setInput:w with:[arrayError objectAtIndex:2]];

            ORDouble z = ((x*p)+y)/w;
//            ORDouble z = ((x*x)+x);
            [zF set_d:z];
            
            [zQ set: [[[xQ mul: pQ] add: yQ] div: wQ]];
            //[zQ set: [[xQ mul: xQ] add: xQ]];

            if(z <= 10.0){
            [ez set: [zQ sub: zF]];
            } else {
               [ez setZero];
            }
            
            [xQ release];
            [yQ release];
            [pQ release];
            [wQ release];
            [zQ release];
            [zF release];
            
            [arrayValue addObject:[NSNumber numberWithDouble:z]];
            [arrayError addObject:ez];
            
            return ez;
         }];
      }];
   }
}


void carbonGas_d_c_3B(bool continuous, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of rational numbers */
      id<ORRational> zero = [[ORRational alloc] init];
      
      /* Initialization of rational numbers */
      [zero setZero];
      
      /* Declaration of model variables */
      id<ORGroup> g = [ORFactory group:mdl type:Group3B];
      id<ORDoubleVar> v = [ORFactory doubleInputVar:mdl low:0.1 up:0.5 name:@"v"];
      id<ORDoubleVar> p = [ORFactory doubleVar:mdl name:@"p"];
      id<ORDoubleVar> a = [ORFactory doubleConstantVar:mdl value:0.401 string:@"401/1000" name:@"a"];
      id<ORDoubleVar> b = [ORFactory doubleConstantVar:mdl value:42.7e-6 string:@"427/10000000" name:@"b"];
      id<ORDoubleVar> t = [ORFactory doubleVar:mdl name:@"t"];
      id<ORDoubleVar> n = [ORFactory doubleVar:mdl name:@"n"];
      id<ORDoubleVar> k = [ORFactory doubleConstantVar:mdl value:1.3806503e-23 string:@"13806503/1000000000000000000000000000000" name:@"k"];
      id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
      id<ORRationalVar> er = [ORFactory errorVar:mdl of:r];
      id<ORRationalVar> erAbs = [ORFactory rationalVar:mdl name:@"erAbs"];
      
      /* Initialization of constants */
      [g add:[p set: @(3.5e7)]];
      [g add:[t set: @(300.0)]];
      [g add:[n set: @(1000.0)]];
      
      /* Declaration of constraints */
      [g add:[r set: [[[p plus: [[a mul: [n div: v]] mul: [n div: v]]] mul: [v sub: [n mul: b]]] sub: [[k mul: n] mul: t]]]];
      
      /* Declaration of constraints over errors */
      [g add: [erAbs eq: [er abs]]];
      [mdl add:g];
      [mdl maximize:erAbs];
      
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
         [cp branchAndBoundSearchD:vars out:erAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
            /* Split strategy */
            [cp floatSplit:i withVars:x];
         }
                           compute:carbonGasError];
      }];
   }
}

void carbonGas_f(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORFloatVar> p = [ORFactory floatVar:mdl name:@"p"];
      id<ORFloatVar> a = [ORFactory floatVar:mdl name:@"a"];
      id<ORFloatVar> b = [ORFactory floatVar:mdl name:@"b"];
      id<ORFloatVar> t = [ORFactory floatVar:mdl name:@"t"];
      id<ORFloatVar> n = [ORFactory floatVar:mdl name:@"n"];
      id<ORFloatVar> k = [ORFactory floatVar:mdl name:@"k"];
      id<ORFloatVar> v = [ORFactory floatVar:mdl  low:0.1f up:0.5f elow:zero eup:zero name:@"v"];
      id<ORFloatVar> r = [ORFactory floatVar:mdl name:@"r"];
      id<ORRationalVar> er = [ORFactory errorVar:mdl of:r];
      id<ORRationalVar> erAbs = [ORFactory rationalVar:mdl name:@"erAbs"];
      [zero release];
      
      //[mdl add:[v set: @(0.5f)]];
      [mdl add:[p set: @(35000000.0f)]];
      [mdl add:[a set: @(0.401f)]];
      [mdl add:[b set: @(4.27e-05f)]];
      [mdl add:[t set: @(300.0f)]];
      [mdl add:[n set: @(1000.0f)]];
      [mdl add:[k set: @(1.3806503e-23f)]];
      
      [mdl add:[r set: [[[p plus: [[a mul: [n div: v]] mul: [n div: v]]] mul: [v sub: [n mul: b]]] sub: [[k mul: n] mul: t]]]];
      
      [mdl add: [erAbs eq: [er abs]]];
      [mdl maximize:erAbs];
      
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBBController proto]];
      id<ORFloatVarArray> vs = [mdl floatVars];
      id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
         if (search)
            [cp branchAndBoundSearch:vars out:erAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [cp floatSplit:i withVars:x];
            }
                             compute:^(NSMutableArray* arrayValue, NSMutableArray* arrayError){
               ORDouble v = [[arrayValue objectAtIndex:0] doubleValue];
               ORDouble p = 3.5e7;
               ORDouble a = 0.401;
               ORDouble b = 42.7e-6;
               ORDouble t = 300.0;
               ORDouble n = 1000.0;
               ORDouble k = 1.3806503e-23;
               
               id<ORRational> vQ = [[ORRational alloc] init];
               id<ORRational> pQ = [[ORRational alloc] init];
               id<ORRational> aQ = [[ORRational alloc] init];
               id<ORRational> bQ = [[ORRational alloc] init];
               id<ORRational> tQ = [[ORRational alloc] init];
               id<ORRational> nQ = [[ORRational alloc] init];
               id<ORRational> kQ = [[ORRational alloc] init];
               id<ORRational> zQ = [[ORRational alloc] init];
               id<ORRational> zF = [[ORRational alloc] init];
               id<ORRational> ez = [[[ORRational alloc] init] autorelease];
               
               [vQ setInput:v with:[arrayError objectAtIndex:0]];
               [pQ set_d:3.5e7];
               [aQ set_str:"401/1000"];
               [bQ set_str:"427/10000000"];
               [tQ set_d:300.0];
               [nQ set_d:1000.0];
               [kQ set_str:"13806503/1000000000000000000000000000000"];
               
               ORDouble z = (((p + ((a * (n/v)) * (n/v))) * (v - (n * b))) - ((k * n) * t));
               [zF set_d:z];
               
               [zQ set: [[[pQ add: [[aQ mul: [nQ div: vQ]] mul: [nQ div: vQ]]] mul: [vQ sub: [nQ mul: bQ]]] sub: [[kQ mul: nQ] mul: tQ]]];
               
               [ez set: [zQ sub: zF]];
               
               [vQ release];
               [pQ release];
               [aQ release];
               [bQ release];
               [tQ release];
               [nQ release];
               [kQ release];
               [zQ release];
               [zF release];
               return ez;
            }];
         NSLog(@"%@",cp);
      }];
   }
}

void test_d_c_3B(bool continuous, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of rational numbers */
      id<ORRational> zero = [[ORRational alloc] init];
      
      /* Initialization of rational numbers */
      [zero setZero];
      
      /* Declaration of model variables */
      id<ORGroup> g = [ORFactory group:mdl type:Group3B];
      id<ORDoubleVar> x = [ORFactory doubleInputVar:mdl low:1 up:2 name:@"x"];
      //id<ORDoubleVar> y = [ORFactory doubleInputVar:mdl low:3 up:4 name:@"y"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      
      /* Initialization of constants */
      
      /* Declaration of constraints */
      [g add:[z set:[x mul:x]]];
      
      /* Declaration of constraints over errors */
      [g add: [ezAbs eq: [ez abs]]];
      [mdl add:g];
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
                           compute:^(NSMutableArray* arrayValue, NSMutableArray* arrayError){
            ORDouble x = [[arrayValue objectAtIndex:0] doubleValue];
            //ORDouble y = [[arrayValue objectAtIndex:1] doubleValue];
            
            id<ORRational> xQ = [[ORRational alloc] init];
            //id<ORRational> yQ = [[ORRational alloc] init];
            id<ORRational> zQ = [[ORRational alloc] init];
            id<ORRational> zF = [[ORRational alloc] init];
            id<ORRational> four = [[[ORRational alloc] init] set_d:4.0];
            id<ORRational> ez = [[[ORRational alloc] init] autorelease];
            
            [xQ setInput:x with:[arrayError objectAtIndex:0]];
            //[yQ setInput:y with:[arrayError objectAtIndex:1]];
            
            ORDouble z = (x * x);
            [zF set_d:z];
            
            [zQ set: [xQ mul: xQ]];
            
            [ez set: [zQ sub: zF]];
            
            [xQ release];
            //[yQ release];
            [zQ release];
            [zF release];
            [four release];
            
            [arrayValue addObject:[NSNumber numberWithDouble:z]];
            [arrayError addObject:ez];
            
            return ez;
         }];
      }];
   }
}

void test_Q_3B(bool continuous, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of rational numbers */
      id<ORRational> zero = [[ORRational alloc] init];
      id<ORRational> one = [[ORRational alloc] init];
      id<ORRational> two = [[ORRational alloc] init];
      id<ORRational> three = [[ORRational alloc] init];
      id<ORRational> four = [[ORRational alloc] init];
      
      /* Initialization of rational numbers */
      [zero setZero];
      [one set_d:1];
      [two set_d:2];
      [three set_d:3.0];
      [four set_d:4.0];
      
      /* Declaration of model variables */
      id<ORGroup> g = [ORFactory group:mdl type:DefaultGroup];
      id<ORRationalVar> x = [ORFactory rationalVar:mdl low:one up:two name:@"x"];
      //id<ORRationalVar> y = [ORFactory rationalVar:mdl low:three up:four name:@"y"];
      id<ORRationalVar> z = [ORFactory rationalVar:mdl name:@"z"];
      
      /* Initialization of constants */
      
      /* Declaration of constraints */
      [g add:[z set:[x mul:x]]];
      
      /* Declaration of constraints over errors */
      [mdl add:g];
      
      /* Memory release of rational numbers */
      [zero release];
      [one release];
      [two release];
      [three release];
      [four release];
      
      
      /* Display model */
      NSLog(@"model: %@",mdl);
      
      /* Construction of solver */
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      
      /* Solving */
      [cp solve:^{
         [cp labelRational:x];
         NSLog(@"x : [%@;%@] (%s)",[cp minQ:x],[cp maxQ:x],[cp bound:x] ? "YES" : "NO");
         //NSLog(@"y : [%@;%@] (%s)",[cp minQ:y],[cp maxQ:y],[cp bound:y] ? "YES" : "NO");
         NSLog(@"z : [%@;%@] (%s)",[cp minQ:z],[cp maxQ:z],[cp bound:z] ? "YES" : "NO");
      }];
   }
}

id<ORRational> (^test_linear_error2)(NSMutableArray* arrayValue, NSMutableArray* arrayError) = ^(NSMutableArray* arrayValue, NSMutableArray* arrayError){
   ORDouble x = [[arrayValue objectAtIndex:0] doubleValue];
   ORDouble k0 = 2.0;
   ORDouble k1 = 3.0;
   id<ORRational> k0Q = [[ORRational alloc] init];
   id<ORRational> k1Q = [[ORRational alloc] init];
   id<ORRational> xQ = [[ORRational alloc] init];
   id<ORRational> zQ = [[ORRational alloc] init];
   id<ORRational> zF = [[ORRational alloc] init];
   id<ORRational> ez = [[[ORRational alloc] init] autorelease];
   [k0Q set_str:"2/1"];
   [k1Q set_str:"3/1"];
   [xQ setInput:x with:[arrayError objectAtIndex:0]];
   ORDouble z = ((k1*x) + k0);
   [zF set_d:z];
   [zQ set: [[k1Q mul: xQ] add: k0Q]];
   [ez set: [zQ sub: zF]];
   printf("x = %1.17e, zr = %1.17e, zq = %1.17e\n", x, z, [zQ get_d]);
   [k0Q release];
   [k1Q release];
   [xQ release];
   [zQ release];
   [zF release];
   [arrayValue addObject:[NSNumber numberWithDouble:z]];
   [arrayError addObject:ez];
   return ez;
};
void test_linear2(int search, int argc, const char * argv[]) {
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
      id<ORDoubleVar> k0 = [ORFactory doubleConstantVar:mdl value:2.0 string:@"2" name:@"k0"];
      id<ORDoubleVar> k1 = [ORFactory doubleConstantVar:mdl value:3.0 string:@"3" name:@"k1"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      /* Declaration of constraints */
      [g add:[z set:[[k1 mul: x] plus: k0]]];
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
                           compute:test_linear_error2];
      }];
   }
}
id<ORRational> (^test_linear_error3)(NSMutableArray* arrayValue, NSMutableArray* arrayError) = ^(NSMutableArray* arrayValue, NSMutableArray* arrayError){
   ORDouble x1 = [[arrayValue objectAtIndex:0] doubleValue];
   ORDouble x2 = [[arrayValue objectAtIndex:1] doubleValue];
   ORDouble k0 = 2.0;
   ORDouble k1 = 3.0;
   id<ORRational> k0Q = [[ORRational alloc] init];
   id<ORRational> k1Q = [[ORRational alloc] init];
   id<ORRational> x1Q = [[ORRational alloc] init];
   id<ORRational> x2Q = [[ORRational alloc] init];
   id<ORRational> zQ = [[ORRational alloc] init];
   id<ORRational> zF = [[ORRational alloc] init];
   id<ORRational> ez = [[[ORRational alloc] init] autorelease];
   [k0Q set_str:"2/1"];
   [k1Q set_str:"3/1"];
   [x1Q setInput:x1 with:[arrayError objectAtIndex:0]];
   [x2Q setInput:x2 with:[arrayError objectAtIndex:1]];
   ORDouble z = (((k1*x1) + x2) + k0);
   [zF set_d:z];
   [zQ set: [[[k1Q mul: x1Q] add: x2Q] add: k0Q]];
   [ez set: [zQ sub: zF]];
   //printf("x = %1.17e, zr = %1.17e, zq = %1.17e\n", x, z, [zQ get_d]);
   [k0Q release];
   [k1Q release];
   [x1Q release];
   [x2Q release];
   [zQ release];
   [zF release];
   [arrayValue addObject:[NSNumber numberWithDouble:z]];
   [arrayError addObject:ez];
   return ez;
};
void test_linear3(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      /* Declaration of rational numbers */
      id<ORRational> zero = [[ORRational alloc] init];
      /* Initialization of rational numbers */
      [zero set_d: 0];
      /* Declaration of model variables */
      id<ORGroup> g = [ORFactory group:mdl type:Group3B];
      id<ORDoubleVar> x1 = [ORFactory doubleInputVar:mdl low:0.1 up:0.3 name:@"x1"];
      id<ORDoubleVar> x2 = [ORFactory doubleInputVar:mdl low:0.1 up:0.3 name:@"x2"];
      id<ORDoubleVar> k0 = [ORFactory doubleConstantVar:mdl value:2.0 string:@"2" name:@"k0"];
      id<ORDoubleVar> k1 = [ORFactory doubleConstantVar:mdl value:3.0 string:@"3" name:@"k1"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      /* Declaration of constraints */
      [g add:[z set:[[[k1 mul: x1] plus: x2] plus: k0]]];
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
                           compute:test_linear_error3];
      }];
   }
}

int main(int argc, const char * argv[]) {
   //carbonGas_f(1, argc, argv);
   //carbonGas_d(1, argc, argv);
   carbonGas_d_c(1, argc, argv);
   //motivating_example_d_c(1, argc, argv);
   //test_linear2(0,argc,argv);
   //carbonGas_d_c_3B(1, argc, argv);
   //test_d_c_3B(1, argc, argv);
   //test_Q_3B(1, argc, argv);
   return 0;
}
