//
//  carbonGas.m
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

void check_it_d(double p, double a, double b, double t, double n, double k, double v, double r, id<ORRational> er) {
   double cr = (((p + ((a * (n/v)) * (n/v))) * (v - (n * b))) - ((k * n) * t));
   mpq_t pq, aq, bq, tq, nq, kq, vq, rq, tmp0, tmp1;
   
   if (cr != r)
      printf("WRONG: r = % 24.24e while cr = % 24.24e\n", r, cr);
   
   mpq_inits(pq, aq, bq, tq, nq, kq, vq, rq, tmp0, tmp1, NULL);
   mpq_set_d(pq, p);
   mpq_set_d(aq, a);
   mpq_set_d(bq, b);
   mpq_set_d(tq, t);
   mpq_set_d(nq, n);
   mpq_set_d(kq, k);
   mpq_set_d(vq, v);
   mpq_div(tmp0, nq, vq);
   mpq_mul(tmp1, tmp0, tmp0);
   mpq_mul(rq, tmp1, aq);
   mpq_add(rq, rq, pq);
   mpq_mul(tmp0, nq, bq);
   mpq_sub(tmp1, vq, tmp0);
   mpq_mul(rq, rq, tmp1);
   mpq_mul(tmp0, kq, nq);
   mpq_mul(tmp1, tmp0, tq);
   mpq_sub(rq, rq, tmp1);
   mpq_set_d(tmp0, r);
   mpq_sub(tmp1, rq, tmp0);
   if (mpq_cmp(tmp1, er.rational) != 0)
      printf("WRONG: er = % 20.20e while cer = % 20.20e\n", mpq_get_d(er.rational), mpq_get_d(tmp1));
   mpq_clears(pq, aq, bq, tq, nq, kq, vq, rq, tmp0, tmp1, NULL);
}

void carbonGas_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> p = [ORFactory doubleVar:mdl name:@"p"];
      id<ORDoubleVar> a = [ORFactory doubleVar:mdl name:@"a"];
      id<ORDoubleVar> b = [ORFactory doubleVar:mdl name:@"b"];
      id<ORDoubleVar> t = [ORFactory doubleVar:mdl name:@"t"];
      id<ORDoubleVar> n = [ORFactory doubleVar:mdl name:@"n"];
      id<ORDoubleVar> k = [ORFactory doubleVar:mdl name:@"k"];
      id<ORDoubleVar> v = [ORFactory doubleVar:mdl low:0.1 up:0.5 elow:zero eup:zero name:@"v"];
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
            }];
         //NSLog(@"%@",cp);
      }];
   }
}

void carbonGas_d_c(int search, int argc, const char * argv[]) {
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
            }];
      }];
   }
}

void check_it_f(float p, float a, float b, float t, float n, float k, float v, float r, id<ORRational> er) {
   float cr = (((p + ((a * (n/v)) * (n/v))) * (v - (n * b))) - ((k * n) * t));
   mpq_t pq, aq, bq, tq, nq, kq, vq, rq, tmp0, tmp1;
   
   if (cr != r)
      printf("WRONG: r = % 20.20e while cr = % 20.20e\n", r, cr);
   
   mpq_inits(pq, aq, bq, tq, nq, kq, vq, rq, tmp0, tmp1, NULL);
   mpq_set_d(pq, p);
   mpq_set_d(aq, a);
   mpq_set_d(bq, b);
   mpq_set_d(tq, t);
   mpq_set_d(nq, n);
   mpq_set_d(kq, k);
   mpq_set_d(vq, v);
   mpq_div(tmp0, nq, vq);
   mpq_mul(tmp1, tmp0, tmp0);
   mpq_mul(rq, tmp1, aq);
   mpq_add(rq, rq, pq);
   mpq_mul(tmp0, nq, bq);
   mpq_sub(tmp1, vq, tmp0);
   mpq_mul(rq, rq, tmp1);
   mpq_mul(tmp0, kq, nq);
   mpq_mul(tmp1, tmp0, tq);
   mpq_sub(rq, rq, tmp1);
   mpq_set_d(tmp0, r);
   mpq_sub(tmp1, rq, tmp0);
   if (mpq_cmp(tmp1, er.rational) != 0)
      printf("WRONG: er = % 20.20e while cer = % 20.20e\n", mpq_get_d(er.rational), mpq_get_d(tmp1));
   mpq_clears(pq, aq, bq, tq, nq, kq, vq, rq, tmp0, tmp1, NULL);
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
            }];
         NSLog(@"%@",cp);
      }];
   }
}


void testMemory_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> p = [ORFactory doubleVar:mdl name:@"p"];
      id<ORDoubleVar> v = [ORFactory doubleVar:mdl low:0.1 up:0.5 elow:zero eup:zero name:@"v"];
      id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
      id<ORRationalVar> er = [ORFactory errorVar:mdl of:r];
      id<ORRationalVar> erAbs = [ORFactory rationalVar:mdl name:@"erAbs"];
      [zero release];
      
      [mdl add:[p set: @(3.5e7)]];
      
      [mdl add:[r set: [[v plus: p] sub: p]]];
      
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
            }];
         NSLog(@"%@",cp);
         //if (search)
            //check_it_d(getDmin(p), getDmin(a), getDmin(b), getDmin(t), getDmin(n), getDmin(k), getDmin(v), getDmin(r), [cp minErrorDQ:r]);
      }];
   }
}


int main(int argc, const char * argv[]) {
   //carbonGas_f(1, argc, argv);
   //carbonGas_d(1, argc, argv);
   carbonGas_d_c(1, argc, argv);
   //testMemory_d(1,argc,argv)
   return 0;
}
