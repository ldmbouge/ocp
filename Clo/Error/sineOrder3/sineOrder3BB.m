//
//  sineOrder3.m
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

void check_it_sineOrder3_d(double x, double z, id<ORRational> ez) {
   double cz = ((0.954929658551372 * x) - (0.12900613773279798 * ((x * x) * x)));
   
   if (cz != z)
      printf("WRONG: z  = % 24.24e while cz  = % 24.24e\n", z, cz);
   
   {
      mpq_t xq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7;
      
      mpq_inits(xq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, NULL);
      mpq_set_d(xq, x);
      
      mpq_set_d(tmp1, 0.954929658551372);
      mpq_mul(tmp2, tmp1, xq);
      mpq_set_d(tmp3, 0.12900613773279798);
      mpq_mul(tmp4, xq, xq);
      mpq_mul(tmp5, tmp4, xq);
      mpq_mul(tmp6, tmp3, tmp5);
      mpq_sub(tmp7, tmp2, tmp6);
      mpq_set(zq, tmp7);
      
      mpq_set_d(tmp0, z);
      mpq_sub(tmp1, zq, tmp0);
      if (mpq_cmp(tmp1, ez.rational) != 0){
         NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
         NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
      }
      mpq_clears(xq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, NULL);
   }
   
}

void sineOrder3_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> x = [ORFactory doubleInputVar:mdl low:-2 up:2 elow:zero eup:zero name:@"x"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      [zero release];
      
      [mdl add:[z set: [[@(0.954929658551372) mul: x] sub: [@(0.12900613773279798) mul: [[x mul: x] mul: x]]]]];
      
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
                              compute:^(NSMutableArray* arrayValue, NSMutableArray* arrayError){
               ORDouble x = [[arrayValue objectAtIndex:0] doubleValue];
               ORDouble a = 0.954929658551372;
               ORDouble b = 0.12900613773279798;
               
               id<ORRational> xQ = [[ORRational alloc] init];
               id<ORRational> aQ = [[ORRational alloc] init];
               id<ORRational> bQ = [[ORRational alloc] init];
               id<ORRational> zQ = [[ORRational alloc] init];
               id<ORRational> zF = [[ORRational alloc] init];
               id<ORRational> ez = [[[ORRational alloc] init] autorelease];
               
               [xQ setInput:x with:[arrayError objectAtIndex:0]];
               [aQ set_d:a];
               [bQ set_d:b];
               
               ORDouble z = a * x - b*(x*x*x);
               
               [zF set_d:z];
               
               [zQ set:[[aQ mul: xQ] sub: [bQ mul: [[xQ mul: xQ] mul: xQ]]]];
               
               [ez set: [zQ sub: zF]];
               
               [xQ release];
               [aQ release];
               [bQ release];
               [zQ release];
               [zF release];
               return ez;
            }];
      }];
   }
}

void sineOrder3_d_c(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of model variables */
      id<ORDoubleVar> x = [ORFactory doubleInputVar:mdl low:-2 up:2 name:@"x"];
      id<ORDoubleVar> a = [ORFactory doubleConstantVar:mdl value:0.954929658551372 string:@"238732414637843/250000000000000" name:@"a"];
      id<ORDoubleVar> b = [ORFactory doubleConstantVar:mdl value:0.12900613773279798 string:@"6450306886639899/50000000000000000" name:@"b"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      
      /* Declaration of constraints */
      [mdl add:[z set: [[a mul: x] sub: [b mul: [[x mul: x] mul: x]]]]];
      
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
                           compute:^(NSMutableArray* arrayValue, NSMutableArray* arrayError){
            ORDouble x = [[arrayValue objectAtIndex:0] doubleValue];
            ORDouble a = 0.954929658551372;
            ORDouble b = 0.12900613773279798;
            
            id<ORRational> xQ = [[ORRational alloc] init];
            id<ORRational> aQ = [[ORRational alloc] init];
            id<ORRational> bQ = [[ORRational alloc] init];
            id<ORRational> zQ = [[ORRational alloc] init];
            id<ORRational> zF = [[ORRational alloc] init];
            id<ORRational> ez = [[[ORRational alloc] init] autorelease];
            
            [xQ setInput:x with:[arrayError objectAtIndex:0]];
            [aQ setConstant:a and:"238732414637843/250000000000000"];
            [bQ setConstant:b and:"6450306886639899/50000000000000000"];
            
            ORDouble z = a * x - b*(x*x*x);
            
            [zF set_d:z];
            
            [zQ set:[[aQ mul: xQ] sub: [bQ mul: [[xQ mul: xQ] mul: xQ]]]];
            
            [ez set: [zQ sub: zF]];
            
            [xQ release];
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
   //sineOrder3_d(1, argc, argv);
   sineOrder3_d_c(1, argc, argv);
   return 0;
}
