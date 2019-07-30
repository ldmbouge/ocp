//
//  doppler1.m
//  Clo
//
//  Created by Remy Garcia on 16/03/2018.
//
#import <ORProgram/ORProgram.h>
#include "gmp.h"

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
        id<ORDoubleVar> t1 = [ORFactory doubleVar:mdl];
        id<ORDoubleVar> z = [ORFactory doubleVar:mdl];
        [zero release];
        
        [mdl add:[t1 set: [@(331.4) plus:[@(0.6) mul: t]]]];
        [mdl add:[z set: [[[@(-1.0) mul: t1] mul: v] div: [[t1 plus: u] mul: [t1 plus: u]]]]];
        
        NSLog(@"model: %@",mdl);
        id<ORDoubleVarArray> vs = [mdl doubleVars];
        id<CPProgram> cp = [ORFactory createCPProgram:mdl];
       id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
       
        [cp solve:^{
            if (search)
               [cp lexicalOrderedSearch:vars do:^(ORUInt i, id<ORDisabledVarArray> x) {
                    [cp floatSplit:i withVars:x];
                }];
            NSLog(@"%@",cp);
           NSLog(@"u : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:u],[cp maxD:u],[cp minDQ:u],[cp maxDQ:u],[cp bound:u] ? "YES" : "NO");
           NSLog(@"v : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:v],[cp maxD:v],[cp minDQ:v],[cp maxDQ:v],[cp bound:v] ? "YES" : "NO");
           NSLog(@"t : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:t],[cp maxD:t],[cp minDQ:t],[cp maxDQ:t],[cp bound:t] ? "YES" : "NO");
           NSLog(@"t1 : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:t1],[cp maxD:t1],[cp minDQ:t1],[cp maxDQ:t1],[cp bound:t1] ? "YES" : "NO");
           NSLog(@"z : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:z],[cp maxD:z],[cp minDQ:z],[cp maxDQ:z],[cp bound:z] ? "YES" : "NO");

            if (search) check_it_d(getDmin(u), getDmin(v), getDmin(t), getDmin(t1), getDmin(z), [cp minErrorDQ:z]);
        }];
    }
}

void doppler1_d_QF(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> u = [ORFactory doubleVar:mdl low:-100.0 up:100.0 elow:zero eup:zero name:@"u"];
      id<ORDoubleVar> v = [ORFactory doubleVar:mdl low:20.0 up:20000.0 elow:zero eup:zero name:@"v"];
      id<ORDoubleVar> t = [ORFactory doubleVar:mdl low:-30.0 up:50.0 elow:zero eup:zero name:@"t"];
      id<ORDoubleVar> t1 = [ORFactory doubleVar:mdl];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl];
      
      id<ORRationalVar> uQ = [ORFactory rationalVar:mdl name:@"uQ"];
      id<ORRationalVar> vQ = [ORFactory rationalVar:mdl name:@"vQ"];
      id<ORRationalVar> tQ = [ORFactory rationalVar:mdl name:@"tQ"];
      id<ORRationalVar> t1Q = [ORFactory rationalVar:mdl name:@"t1Q"];
      id<ORRationalVar> zQ = [ORFactory rationalVar:mdl name:@"zQ"];
      id<ORRationalVar> zq = [ORFactory rationalVar:mdl name:@"zq"];
      id<ORRationalVar> ez = [ORFactory rationalVar:mdl name:@"ez"];
      [zero set_d:331.4];
      id<ORRationalVar> tmp1 = [ORFactory rationalVar:mdl low:zero up:zero name:@"tmp1"];
      [zero set_d:0.6];
      id<ORRationalVar> tmp2 = [ORFactory rationalVar:mdl low:zero up:zero name:@"tmp2"];
      [zero set_d:-1.0];
      id<ORRationalVar> tmp3 = [ORFactory rationalVar:mdl low:zero up:zero name:@"tmp3"];
      
      [zero release];
      
      [mdl add:[ORFactory channel:u with:uQ]];
      [mdl add:[ORFactory channel:v with:vQ]];
      [mdl add:[ORFactory channel:t with:tQ]];
      [mdl add:[ORFactory channel:t1 with:t1Q]];
      [mdl add:[ORFactory channel:z with:zq]];

      
      [mdl add:[t1 set: [@(331.4) plus:[@(0.6) mul: t]]]];
      [mdl add:[z set: [[[@(-1.0) mul: t1] mul: v] div: [[t1 plus: u] mul: [t1 plus: u]]]]];
      
      [mdl add:[t1Q eq: [tmp1 plus:[tmp2 mul: tQ]]]];
      [mdl add:[zQ eq: [[[tmp3 mul: t1Q] mul: vQ] div: [[t1Q plus: uQ] mul: [t1Q plus: uQ]]]]];
      
      [mdl add:[ez eq:[zQ sub: zq]]];
      
      
      
      NSLog(@"model: %@",mdl);
      id<ORDoubleVarArray> vs = [mdl doubleVars];
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
         if (search)
            [cp lexicalOrderedSearch:vars do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [cp floatSplit:i withVars:x];
            }];
         NSLog(@"%@",cp);
         NSLog(@"u : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:u],[cp maxD:u],[cp minDQ:u],[cp maxDQ:u],[cp bound:u] ? "YES" : "NO");
         NSLog(@"v : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:v],[cp maxD:v],[cp minDQ:v],[cp maxDQ:v],[cp bound:v] ? "YES" : "NO");
         NSLog(@"t : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:t],[cp maxD:t],[cp minDQ:t],[cp maxDQ:t],[cp bound:t] ? "YES" : "NO");
         NSLog(@"t1 : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:t1],[cp maxD:t1],[cp minDQ:t1],[cp maxDQ:t1],[cp bound:t1] ? "YES" : "NO");
         NSLog(@"z : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:z],[cp maxD:z],[cp minDQ:z],[cp maxDQ:z],[cp bound:z] ? "YES" : "NO");
         NSLog(@"");
         NSLog(@"uQ: [%@;%@] (%s)",[cp minQ:uQ],[cp maxQ:uQ],[cp bound:uQ] ? "YES" : "NO");
         NSLog(@"vQ: [%@;%@] (%s)",[cp minQ:vQ],[cp maxQ:uQ],[cp bound:vQ] ? "YES" : "NO");
         NSLog(@"tQ: [%@;%@] (%s)",[cp minQ:tQ],[cp maxQ:tQ],[cp bound:tQ] ? "YES" : "NO");
         NSLog(@"t1Q: [%@;%@] (%s)",[cp minQ:t1Q],[cp maxQ:t1Q],[cp bound:t1Q] ? "YES" : "NO");
         NSLog(@"zQ: [%@;%@] (%s)",[cp minQ:zQ],[cp maxQ:zQ],[cp bound:zQ] ? "YES" : "NO");
         NSLog(@"ez: [%@;%@] (%s)",[cp minQ:ez],[cp maxQ:ez],[cp bound:ez] ? "YES" : "NO");


         
         if (search) check_it_d(getDmin(u), getDmin(v), getDmin(t), getDmin(t1), getDmin(z), [cp minErrorDQ:z]);
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
   LOO_MEASURE_TIME(@"u"){
    //doppler1_f(1, argc, argv);
//    doppler1_d(0, argc, argv);
      doppler1_d_QF(0, argc, argv);

   }
    return 0;
}


