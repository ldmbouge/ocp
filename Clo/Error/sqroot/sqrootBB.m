//
//  sqroot.m
//  Clo
//
//  Created by Rémy Garcia on 12/04/2019.
//

#import <ORProgram/ORProgram.h>
#include "gmp.h"
#import "ORCmdLineArgs.h"
#include <signal.h>
#include <stdlib.h>
#include <time.h>

#define LOO_MEASURE_TIME(__message) \
for (CFAbsoluteTime startTime##__LINE__ = CFAbsoluteTimeGetCurrent(), endTime##__LINE__ = 0.0; endTime##__LINE__ == 0.0; \
NSLog(@"'%@' took %.3fs", (__message), (endTime##__LINE__ = CFAbsoluteTimeGetCurrent()) - startTime##__LINE__))

#define printFvar(name, var) NSLog(@""name" : [% 20.20e, % 20.20e]f (%s)",[(id<CPFloatVar>)[cp concretize:var] min],[(id<CPFloatVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 20.20e, % 20.20e]q",[(id<CPFloatVar>)[cp concretize:var] minErrF],[(id<CPFloatVar>)[cp concretize:var] maxErrF]);
#define getFmin(var) [(id<CPFloatVar>)[cp concretize:var] min]
#define getFminErr(var) *[(id<CPFloatVar>)[cp concretize:var] minErr]

#define printDvar(name, var) NSLog(@""name" : [% 24.24e, % 24.24e]d (%s)",[(id<CPDoubleVar>)[cp concretize:var] min],[(id<CPDoubleVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 1.2e, % 1.2e]q",[(id<CPDoubleVar>)[cp concretize:var] minErrF],[(id<CPDoubleVar>)[cp concretize:var] maxErrF]);
#define getDmin(var) [(id<CPDoubleVar>)[cp concretize:var] min]
#define getDminErr(var) *[(id<CPDoubleVar>)[cp concretize:var] minErr]

void check_it_sqroot_d(double x, double z, id<ORRational> ez) {
   double cz = ((((1.0 + (0.5 * x)) - ((0.125 * x) * x)) + (((0.0625 * x) * x) * x)) - ((((0.0390625 * x) * x) * x) * x));
   
   if (cz != z)
      printf("WRONG: z  = % 24.24e while cz  = % 24.24e\n", z, cz);
   
   {
      mpq_t xq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19;
      
      mpq_inits(xq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19, NULL);
      
      mpq_set_d(xq, x);
      
      mpq_set_d(tmp1, 1.0);
      mpq_set_d(tmp2, 0.5);
      mpq_mul(tmp3, tmp2, xq);
      mpq_add(tmp4, tmp1, tmp3);
      mpq_set_d(tmp5, 0.125);
      mpq_mul(tmp6, tmp5, xq);
      mpq_mul(tmp7, tmp6, xq);
      mpq_sub(tmp8, tmp4, tmp7);
      mpq_set_d(tmp9, 0.0625);
      mpq_mul(tmp10, tmp9, xq);
      mpq_mul(tmp11, tmp10, xq);
      mpq_mul(tmp12, tmp11, xq);
      mpq_add(tmp13, tmp8, tmp12);
      mpq_set_d(tmp14, 0.0390625);
      mpq_mul(tmp15, tmp14, xq);
      mpq_mul(tmp16, tmp15, xq);
      mpq_mul(tmp17, tmp16, xq);
      mpq_mul(tmp18, tmp17, xq);
      mpq_sub(tmp19, tmp13, tmp18);
      mpq_set(zq, tmp19);
      
      mpq_set_d(tmp0, z);
      mpq_sub(tmp1, zq, tmp0);
      if (mpq_cmp(tmp1, ez.rational) != 0){
         NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
         NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
      }
      mpq_clears(xq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19, NULL);
   }
   
}

void sqroot_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> x = [ORFactory doubleVar:mdl low:0.0 up:1.0 elow:zero eup:zero name:@"x"];
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
   
   void sqroot_d_c(int search, int argc, const char * argv[]) {
      @autoreleasepool {
         ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
         [args measure:^struct ORResult(){
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
            struct ORResult r = REPORT(0, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
            return r;
         }];
      }
   }
   
   void sqroot_f(int search, int argc, const char * argv[]) {
      @autoreleasepool {
         //srand(time(NULL));
         ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
         [args measure:^struct ORResult(){
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
                     [cp float3WaySplit:i withVars:x];
                  }];
            }];
            struct ORResult result = REPORT(0, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
            return result;
         }];
      }
   }
   
   int main(int argc, const char * argv[]) {
      sqroot_d(1, argc, argv);
      //sqroot_d_c(1, argc, argv);
      //sqroot_f(1, argc, argv);
      return 0;
   }
