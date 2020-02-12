//
//  doppler1.m
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

void check_it_d(double u, double v, double t, double t1, double z, id<ORRational> ez) {
   double ct1 = 331.4 + (0.6 * t);
   double cz = ((-1.0 * t1) * v) / ((t1 + u) * (t1 + u));
   
   if (ct1 != t1)
      printf("WRONG: t1 = % 24.24e while ct1 = % 24.24e\n", t1, ct1);
   
   if (cz != z)
      printf("WRONG: z  = % 24.24e while cz  = % 24.24e\n", z, cz);
   
   {
      mpq_t uq, vq, tq, t1q, zq, tmp0, tmp1, tmp2;
      
      mpq_inits(uq, vq, tq, t1q, zq, tmp0, tmp1, tmp2, NULL);
      mpq_set_d(uq, u);
      mpq_set_d(vq, v);
      mpq_set_d(tq, t);
      mpq_set_d(tmp0, 0.6);
      mpq_mul(tmp1, tq, tmp0);
      mpq_set_d(tmp0, 331.4);
      mpq_add(t1q, tmp0, tmp1);
      mpq_set_d(tmp0, -1.0);
      mpq_mul(tmp1, tmp0, t1q);
      mpq_mul(tmp0, tmp1, vq);
      mpq_add(zq, t1q, uq);
      mpq_mul(tmp1, zq, zq);
      mpq_div(zq, tmp0, tmp1);
      mpq_set_d(tmp0, z);
      mpq_sub(tmp1, zq, tmp0);
      if (mpq_cmp(tmp1, ez.rational) != 0){
         NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
         NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
      }
      mpq_clears(uq, vq, tq, t1q, zq, tmp0, tmp1, tmp2, NULL);
   }
   
}

void doppler1_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> u = [ORFactory doubleVar:mdl low:-100.0 up:100.0 elow:zero eup:zero name:@"u"];
      id<ORDoubleVar> v = [ORFactory doubleVar:mdl low:20.0 up:20000.0 elow:zero eup:zero name:@"v"];
      id<ORDoubleVar> t = [ORFactory doubleVar:mdl low:-30.0 up:50.0 elow:zero eup:zero name:@"t"];
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
            }];
      }];
   }
}

void doppler1_d_c(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];

      /* Declaration of model variables */
      id<ORDoubleVar> u = [ORFactory doubleInputVar:mdl low:-100.0 up:100.0 name:@"u"];
      id<ORDoubleVar> v = [ORFactory doubleInputVar:mdl low:20.0 up:20000.0 name:@"v"];
      id<ORDoubleVar> t = [ORFactory doubleInputVar:mdl low:-30.0 up:50.0 name:@"t"];
      id<ORDoubleVar> a = [ORFactory doubleConstantVar:mdl value:331.4 string:@"1657/5" name:@"a"];
      id<ORDoubleVar> b = [ORFactory doubleConstantVar:mdl value:0.6 string:@"3/5" name:@"b"];
      id<ORDoubleVar> t1 = [ORFactory doubleVar:mdl name:@"t1"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];
      [zero release];
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
                           compute:^(NSMutableArray* arrayValue, NSMutableArray* arrayError){
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
            [aQ setConstant:a and:"1657/5"];
            [bQ setConstant:b and:"3/5"];
            
            ORDouble t1 = 331.4 + (0.6 * t);
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
            return ez;
         }];
      }];
   }
}


void check_it_f(float u, float v, float t, float t1, float z, id<ORRational> ez) {
   float ct1 = 331.4f + (0.6f * t);
   float cz = ((-1.0f * t1) * v) / ((t1 + u) * (t1 + u));
   
   if (ct1 != t1)
      printf("WRONG: t1 = % 20.20e while ct1 = % 20.20e\n", t1, ct1);
   
   if (cz != z)
      printf("WRONG: z  = % 20.20e while cz  = % 20.20e\n", z, cz);
   
   {
      mpq_t uq, vq, tq, t1q, zq, tmp0, tmp1, tmp2;
      
      mpq_inits(uq, vq, tq, t1q, zq, tmp0, tmp1, tmp2, NULL);
      mpq_set_d(uq, u);
      mpq_set_d(vq, v);
      mpq_set_d(tq, t);
      mpq_set_d(tmp0, 0.6f);
      mpq_mul(tmp1, tq, tmp0);
      mpq_set_d(tmp0, 331.4f);
      mpq_add(t1q, tmp0, tmp1);
      mpq_set_d(tmp0, -1.0f);
      mpq_mul(tmp1, tmp0, t1q);
      mpq_mul(tmp0, tmp1, vq);
      mpq_add(zq, t1q, uq);
      mpq_mul(tmp1, zq, zq);
      mpq_div(zq, tmp0, tmp1);
      mpq_set_d(tmp0, z);
      mpq_sub(tmp1, zq, tmp0);
      if (mpq_cmp(tmp1, ez.rational) != 0){
         NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
         NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
      }
      mpq_clears(uq, vq, tq, t1q, zq, tmp0, tmp1, tmp2, NULL);
   }
   
}

void doppler1_f(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0f];
      id<ORFloatVar> u = [ORFactory floatVar:mdl low:-100.0f up:100.0f elow:zero eup:zero name:@"u"];
      id<ORFloatVar> v = [ORFactory floatVar:mdl low:20.0f up:20000.0f elow:zero eup:zero name:@"v"];
      id<ORFloatVar> t = [ORFactory floatVar:mdl low:-30.0f up:50.0f elow:zero eup:zero name:@"t"];
      id<ORFloatVar> t1 = [ORFactory floatVar:mdl];
      id<ORFloatVar> z = [ORFactory floatVar:mdl];
      [zero release];
      
      [mdl add:[t1 set: [@(331.4f) plus:[@(0.6f) mul: t]]]];
      [mdl add:[z set: [[[@(-1.0f) mul: t1] mul: v] div: [[t1 plus: u] mul: [t1 plus: u]]]]];
      
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<ORFloatVarArray> vs = [mdl floatVars];
      id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
         if (search)
            [cp lexicalOrderedSearch:vars do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [cp floatSplit:i withVars:x];
            }];
         NSLog(@"%@",cp);
         NSLog(@"u : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minF:u],[cp maxF:u],[cp minFQ:u],[cp maxFQ:u],[cp bound:u] ? "YES" : "NO");
         NSLog(@"v : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minF:v],[cp maxF:v],[cp minFQ:v],[cp maxFQ:v],[cp bound:v] ? "YES" : "NO");
         NSLog(@"t : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minF:t],[cp maxF:t],[cp minFQ:t],[cp maxFQ:t],[cp bound:t] ? "YES" : "NO");
         NSLog(@"t1 : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minF:t1],[cp maxF:t1],[cp minFQ:t1],[cp maxFQ:t1],[cp bound:t1] ? "YES" : "NO");
         NSLog(@"z : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minF:z],[cp maxF:z],[cp minFQ:z],[cp maxFQ:z],[cp bound:z] ? "YES" : "NO");
         if (search) check_it_f(getFmin(u), getFmin(v), getFmin(t), getFmin(t1), getFmin(z), [cp minErrorFQ:z]);
      }];
   }
}

int main(int argc, const char * argv[]) {
   //doppler1_f(1, argc, argv);
   //doppler1_d(1, argc, argv);
   doppler1_d_c(1, argc, argv);
   return 0;
}
