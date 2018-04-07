//
//  doppler1.m
//  Clo
//
//  Created by Remy Garcia on 16/03/2018.
//
#import <ORProgram/ORProgram.h>
#include "gmp.h"

#define printFvar(name, var) NSLog(@""name" : [% 20.20e, % 20.20e]f (%s)",[(id<CPFloatVar>)[cp concretize:var] min],[(id<CPFloatVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 20.20e, % 20.20e]q",[(id<CPFloatVar>)[cp concretize:var] minErrF],[(id<CPFloatVar>)[cp concretize:var] maxErrF]);
#define getFmin(var) [(id<CPFloatVar>)[cp concretize:var] min]
#define getFminErr(var) *[(id<CPFloatVar>)[cp concretize:var] minErr]

#define printDvar(name, var) NSLog(@""name" : [% 24.24e, % 24.24e]d (%s)",[(id<CPDoubleVar>)[cp concretize:var] min],[(id<CPDoubleVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 24.24e, % 24.24e]q",[(id<CPDoubleVar>)[cp concretize:var] minErrF],[(id<CPDoubleVar>)[cp concretize:var] maxErrF]);
#define getDmin(var) [(id<CPDoubleVar>)[cp concretize:var] min]
#define getDminErr(var) *[(id<CPDoubleVar>)[cp concretize:var] minErr]

void check_it_d(double u, double v, double t, double t1, double z, ORRational ez) {
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
        if (mpq_cmp(tmp1, ez) != 0)
            printf("WRONG: ez = % 24.24e while cze = % 24.24e\n", mpq_get_d(ez), mpq_get_d(tmp0));
        mpq_clears(uq, vq, tq, t1q, zq, tmp0, tmp1, tmp2, NULL);
    }
    
}

void doppler1_d(int search, int argc, const char * argv[]) {
    @autoreleasepool {
        id<ORModel> mdl = [ORFactory createModel];
        id<ORDoubleRange> r0 = [ORFactory doubleRange:mdl low:-100.0 up:100.0];
        id<ORDoubleRange> r1 = [ORFactory doubleRange:mdl low:20.0 up:20000.0];
        id<ORDoubleRange> r2 = [ORFactory doubleRange:mdl low:-30.0 up:50.0];
        id<ORDoubleVar> u = [ORFactory doubleVar:mdl domain:r0];
        id<ORDoubleVar> v = [ORFactory doubleVar:mdl domain:r1];
        id<ORDoubleVar> t = [ORFactory doubleVar:mdl domain:r2];
        id<ORDoubleVar> t1 = [ORFactory doubleVar:mdl];
        id<ORDoubleVar> z = [ORFactory doubleVar:mdl];
        
        //[mdl add:[t1 set: [@(331.4) plus:[@(0.6) mul: t]]]];
        [mdl add:[t1 set: [@(331.4) plus:[@(0.6) mul: t]]]];
        //[mdl add:[t1 set: @(331.4)]];
        [mdl add:[z set: [[[@(-1.0) mul: t1] mul: v] div: [[t1 plus: u] mul: [t1 plus: u]]]]];
        
        NSLog(@"model: %@",mdl);
        id<ORDoubleVarArray> vs = [mdl doubleVars];
        id<CPProgram> cp = [ORFactory createCPProgram:mdl];
        id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
        
        [cp setMaxErrorDD:u maxErrorF:0.0];
        [cp setMinErrorDD:u minErrorF:0.0];
        [cp setMaxErrorDD:v maxErrorF:0.0];
        [cp setMinErrorDD:v minErrorF:0.0];
        [cp setMaxErrorDD:t maxErrorF:0.0];
        [cp setMinErrorDD:t minErrorF:0.0];
        [cp solve:^{
            if (search)
                [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
                    [cp floatSplitD:i call:s withVars:x];
                }];
            NSLog(@"%@",cp);
            //NSLog(@"%@ (%s)",[p concretize:x],[p bound:x] ? "YES" : "NO");
            /* format of 8.8e to have the same value displayed as in FLUCTUAT */
            /* Use printRational(ORRational r) to print a rational inside the solver */
            printDvar("u", u);
            printDvar("v", v);
            printDvar("t", t);
            printDvar("t1", t1);
            printDvar("z", z);
            if (search) check_it_d(getDmin(u), getDmin(v), getDmin(t), getDmin(t1), getDmin(z), getDminErr(z));
        }];
    }
}

void check_it_f(float u, float v, float t, float t1, float z, ORRational ez) {
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
        if (mpq_cmp(tmp1, ez) != 0)
            printf("WRONG: ez = % 20.20e while cze = % 20.20e\n", mpq_get_d(ez), mpq_get_d(tmp0));
        mpq_clears(uq, vq, tq, t1q, zq, tmp0, tmp1, tmp2, NULL);
    }
    
}

void doppler1_f(int search, int argc, const char * argv[]) {
    @autoreleasepool {
        id<ORModel> mdl = [ORFactory createModel];
        id<ORFloatRange> r0 = [ORFactory floatRange:mdl low:-100.0f up:100.0f];
        id<ORFloatRange> r1 = [ORFactory floatRange:mdl low:20.0f up:20000.0f];
        id<ORFloatRange> r2 = [ORFactory floatRange:mdl low:-30.0f up:50.0f];
        id<ORFloatVar> u = [ORFactory floatVar:mdl domain:r0];
        id<ORFloatVar> v = [ORFactory floatVar:mdl domain:r1];
        id<ORFloatVar> t = [ORFactory floatVar:mdl domain:r2];
        id<ORFloatVar> t1 = [ORFactory floatVar:mdl];
        id<ORFloatVar> z = [ORFactory floatVar:mdl];
        
        [mdl add:[t1 set: [@(331.4f) plus:[@(0.6f) mul: t]]]];
        [mdl add:[z set: [[[@(-1.0f) mul: t1] mul: v] div: [[t1 plus: u] mul: [t1 plus: u]]]]];
        
        NSLog(@"model: %@",mdl);
        id<CPProgram> cp = [ORFactory createCPProgram:mdl];
        id<ORFloatVarArray> vs = [mdl floatVars];
        id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
        
        [cp setMaxErrorFD:u maxErrorF:0.0];
        [cp setMinErrorFD:u minErrorF:0.0];
        [cp setMaxErrorFD:v maxErrorF:0.0];
        [cp setMinErrorFD:v minErrorF:0.0];
        [cp setMaxErrorFD:t maxErrorF:0.0];
        [cp setMinErrorFD:t minErrorF:0.0];
        
        [cp solve:^{
            if (search)
                [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
                    [cp floatSplit:i call:s withVars:x];
                }];
            NSLog(@"%@",cp);
            //NSLog(@"%@ (%s)",[p concretize:x],[p bound:x] ? "YES" : "NO");
            /* format of 8.8e to have the same value displayed as in FLUCTUAT */
            /* Use printRational(ORRational r) to print a rational inside the solver */
            printFvar("u", u);
            printFvar("v", v);
            printFvar("t", t);
            printFvar("t1", t1);
            printFvar("z", z);
            if (search) check_it_f(getFmin(u), getFmin(v), getFmin(t), getFmin(t1), getFmin(z), getFminErr(z));
        }];
    }
}

int main(int argc, const char * argv[]) {
    //doppler1_f(1, argc, argv);
    doppler1_d(1, argc, argv);
    return 0;
}


