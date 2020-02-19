//
//  turbine1.m
//  Clo
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

#define printFvar(name, var) NSLog(@""name" : [% 20.20e, % 20.20e]f (%s)",[(id<CPFloatVar>)[cp concretize:var] min],[(id<CPFloatVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 20.20e, % 20.20e]q",[(id<CPFloatVar>)[cp concretize:var] minErrF],[(id<CPFloatVar>)[cp concretize:var] maxErrF]);
#define getFmin(var) [(id<CPFloatVar>)[cp concretize:var] min]
#define getFminErr(var) *[(id<CPFloatVar>)[cp concretize:var] minErr]

#define printDvar(name, var) NSLog(@""name" : [% 24.24e, % 24.24e]d (%s)",[(id<CPDoubleVar>)[cp concretize:var] min],[(id<CPDoubleVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 1.2e, % 1.2e]q",[(id<CPDoubleVar>)[cp concretize:var] minErrF],[(id<CPDoubleVar>)[cp concretize:var] maxErrF]);
#define getDmin(var) [(id<CPDoubleVar>)[cp concretize:var] min]
#define getDminErr(var) *[(id<CPDoubleVar>)[cp concretize:var] minErr]

void check_it_turbine1_d(double v, double w, double r, double z, id<ORRational> ez) {
   double cz = (((3.0 + (2.0 / (r * r))) - (((0.125 * (3.0 - (2.0 * v))) * (((w * w) * r) * r)) / (1.0 - v))) - 4.5);;
   
   if (cz != z)
      printf("WRONG: z  = % 24.24e while cz  = % 24.24e\n", z, cz);
   
   {
      mpq_t vq, wq, rq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19, tmp20, tmp21;
      
      mpq_inits(vq, wq, rq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19, tmp20, tmp21, NULL);
      mpq_set_d(vq, v);
      mpq_set_d(wq, w);
      mpq_set_d(rq, r);
      
      mpq_set_d(tmp1, 3.0);
      mpq_set_d(tmp2, 2.0);
      mpq_mul(tmp3, rq, rq);
      mpq_div(tmp4, tmp2, tmp3);
      mpq_add(tmp5, tmp1, tmp4);
      mpq_set_d(tmp6, 0.125);
      mpq_set_d(tmp7, 3.0);
      mpq_set_d(tmp8, 2.0);
      mpq_mul(tmp9, tmp8, vq);
      mpq_sub(tmp10, tmp7, tmp9);
      mpq_mul(tmp11, tmp6, tmp10);
      mpq_mul(tmp12, wq, wq);
      mpq_mul(tmp13, tmp12, rq);
      mpq_mul(tmp14, tmp13, rq);
      mpq_mul(tmp15, tmp11, tmp14);
      mpq_set_d(tmp16, 1.0);
      mpq_sub(tmp17, tmp16, vq);
      mpq_div(tmp18, tmp15, tmp17);
      mpq_sub(tmp19, tmp5, tmp18);
      mpq_set_d(tmp20, 4.5);
      mpq_sub(tmp21, tmp19, tmp20);
      mpq_set(zq, tmp21);
      
      
      mpq_set_d(tmp0, z);
      mpq_sub(tmp1, zq, tmp0);
      if (mpq_cmp(tmp1, ez.rational) != 0){
         NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
         NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
      }
      mpq_clears(vq, wq, rq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19, tmp20, tmp21, NULL);
   }
   
}

void turbine1_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> v = [ORFactory doubleInputVar:mdl low:-4.5 up:-0.3 elow:zero eup:zero name:@"v"];
      id<ORDoubleVar> w = [ORFactory doubleInputVar:mdl low:0.4 up:0.9 elow:zero eup:zero name:@"w"];
      id<ORDoubleVar> r = [ORFactory doubleInputVar:mdl low:3.8 up:7.8 elow:zero eup:zero name:@"r"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      [zero release];
      
      [mdl add:[z set: [[[@(3.0) plus: [@(2.0) div: [r mul: r]]] sub: [[[@(0.125) mul: [@(3.0) sub: [@(2.0) mul: v]]] mul: [[[w mul: w] mul: r] mul: r]] div: [@(1.0) sub: v]]] sub: @(4.5)]]];
      
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
                              compute:^(NSMutableArray* arrayValue, NSMutableArray* arrayError){
               ORDouble v = [[arrayValue objectAtIndex:0] doubleValue];
               ORDouble w = [[arrayValue objectAtIndex:1] doubleValue];
               ORDouble r = [[arrayValue objectAtIndex:2] doubleValue];
               ORDouble a = 0.125;
               ORDouble b = 4.5;
               
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
               [aQ set_d:a];
               [bQ set_d:b];
               
               ORDouble z = (((3.0 + (2.0 / (r * r))) - (((a * (3.0 - (2.0 * v))) * (((w * w) * r) * r)) / (1.0 - v))) - b);
               [zF set_d:z];
               
               [zQ set:[[[three add: [two div: [rQ mul: rQ]]] sub: [[[aQ mul: [three sub: [two mul: vQ]]] mul: [[[wQ mul: wQ] mul: rQ] mul: rQ]] div: [one sub: vQ]]] sub: bQ]];
               
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

void turbine1_d_c(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of model variables */
      id<ORDoubleVar> v = [ORFactory doubleInputVar:mdl low:-4.5 up:-0.3 name:@"v"];
      id<ORDoubleVar> w = [ORFactory doubleInputVar:mdl low:0.4 up:0.9 name:@"w"];
      id<ORDoubleVar> r = [ORFactory doubleInputVar:mdl low:3.8 up:7.8 name:@"r"];
      id<ORDoubleVar> a = [ORFactory doubleConstantVar:mdl value:0.125 string:@"1/8" name:@"a"];
      id<ORDoubleVar> b = [ORFactory doubleConstantVar:mdl value:4.5 string:@"9/2" name:@"b"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      
      /* Declaration of constraints */
      [mdl add:[z set: [[[@(3.0) plus: [@(2.0) div: [r mul: r]]] sub: [[[a mul: [@(3.0) sub: [@(2.0) mul: v]]] mul: [[[w mul: w] mul: r] mul: r]] div: [@(1.0) sub: v]]] sub: b]]];
      
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
            ORDouble v = [[arrayValue objectAtIndex:0] doubleValue];
            ORDouble w = [[arrayValue objectAtIndex:1] doubleValue];
            ORDouble r = [[arrayValue objectAtIndex:2] doubleValue];
            ORDouble a = 0.125;
            ORDouble b = 4.5;
            
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
            [bQ setConstant:b and:"9/2"];
            
            ORDouble z = (((3.0 + (2.0 / (r * r))) - (((a * (3.0 - (2.0 * v))) * (((w * w) * r) * r)) / (1.0 - v))) - b);
            [zF set_d:z];
            
            [zQ set:[[[three add: [two div: [rQ mul: rQ]]] sub: [[[aQ mul: [three sub: [two mul: vQ]]] mul: [[[wQ mul: wQ] mul: rQ] mul: rQ]] div: [one sub: vQ]]] sub: bQ]];
            
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


int main(int argc, const char * argv[]) {
   turbine1_d(1, argc, argv);
   //turbine1_d_c(1, argc, argv);
   return 0;
}
