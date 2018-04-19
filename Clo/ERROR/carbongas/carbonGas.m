//
//  carbonGas.m
//
//  Created by Remy Garcia on 06/03/2018.
//
#import <ORProgram/ORProgram.h>
#include "gmp.h"

#define printFvar(name, var) NSLog(@""name" : [% 20.20e, % 20.20e]f (%s)",[(id<CPFloatVar>)[cp concretize:var] min],[(id<CPFloatVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 20.20e, % 20.20e]q",[(id<CPFloatVar>)[cp concretize:var] minErrF],[(id<CPFloatVar>)[cp concretize:var] maxErrF]);
#define getFmin(var) [(id<CPFloatVar>)[cp concretize:var] min]
#define getFminErr(var) *[(id<CPFloatVar>)[cp concretize:var] minErr]

#define printDvar(name, var) NSLog(@""name" : [% 24.24e, % 24.24e]d (%s)",[(id<CPDoubleVar>)[cp concretize:var] min],[(id<CPDoubleVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 24.24e, % 24.24e]q",[(id<CPDoubleVar>)[cp concretize:var] minErrF],[(id<CPDoubleVar>)[cp concretize:var] maxErrF]);
#define getDmin(var) [(id<CPDoubleVar>)[cp concretize:var] min]
#define getDminErr(var) *[(id<CPDoubleVar>)[cp concretize:var] minErr]

void check_it_d(double p, double a, double b, double t, double n, double k, double v, double r, mpq_t er) {
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
    if (mpq_cmp(tmp1, er) != 0)
        printf("WRONG: er = % 20.20e while cer = % 20.20e\n", mpq_get_d(er), mpq_get_d(tmp1));
    mpq_clears(pq, aq, bq, tq, nq, kq, vq, rq, tmp0, tmp1, NULL);
}

void carbonGas_d(int search, int argc, const char * argv[]) {
    @autoreleasepool {
        id<ORModel> mdl = [ORFactory createModel];
        id<ORDoubleVar> p = [ORFactory doubleVar:mdl];
        id<ORDoubleVar> a = [ORFactory doubleVar:mdl];
        id<ORDoubleVar> b = [ORFactory doubleVar:mdl];
        id<ORDoubleVar> t = [ORFactory doubleVar:mdl];
        
        id<ORDoubleVar> n = [ORFactory doubleVar:mdl];
        id<ORDoubleVar> k = [ORFactory doubleVar:mdl];
        id<ORDoubleVar> v = [ORFactory doubleVar:mdl  low:0.1 up:0.5];
        id<ORDoubleVar> r = [ORFactory doubleVar:mdl];
        
        //[mdl add:[v set: @(0.5)]];
        [mdl add:[p set: @(3.5e7)]];
        [mdl add:[a set: @(0.401)]];
        [mdl add:[b set: @(42.7e-6)]];
        [mdl add:[t set: @(300.0)]];
        [mdl add:[n set: @(1000.0)]];
        [mdl add:[k set: @(1.3806503e-23)]];
        
        /*[mdl add:[t1 set:[n div: v]]];
         [mdl add:[t2 set:[a mul: t1]]];
         [mdl add:[t3 set:[t2 mul: t1]]];
         [mdl add:[t4 set:[p plus: t3]]];
         [mdl add:[t5 set:[n mul: b]]];
         [mdl add:[t6 set:[v sub: t5]]];
         [mdl add:[t7 set:[t4 mul: t6]]];
         [mdl add:[t8 set:[k mul: n]]];
         [mdl add:[t9 set:[t8 mul: t]]];
         [mdl add: [r set:[t7 sub: t9]]];*/
        
        [mdl add:[r set: [[[p plus: [[a mul: [n div: v]] mul: [n div: v]]] mul: [v sub: [n mul: b]]] sub: [[k mul: n] mul: t]]]];
        
        NSLog(@"model: %@",mdl);
        id<CPProgram> cp = [ORFactory createCPProgram:mdl];
        id<ORDoubleVarArray> vs = [mdl doubleVars];
        id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
        
        [cp setMinErrorDD:v minErrorF:0.0];
        [cp setMaxErrorDD:v maxErrorF:0.0];
        //[cp setMinErrorDD:r minErrorF:0.0];
        //[cp setMaxErrorDD:r maxErrorF:0.0];
        [cp solve:^{
            if (search)
                [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
                    [cp floatSplitD:i call:s withVars:x];
                }];
            NSLog(@"%@",cp);
            /* format of 8.8e to have the same value displayed as in FLUCTUAT */
            /* Use printRational(ORRational r) to print a rational inside the solver */
            printDvar("p", p);
            printDvar("a", a);
            printDvar("b", b);
            printDvar("t", t);
            printDvar("n", n);
            printDvar("k", k);
            printDvar("v", v);
            printDvar("r", r);
            if (search)
                check_it_d(getDmin(p), getDmin(a), getDmin(b), getDmin(t), getDmin(n), getDmin(k), getDmin(v), getDmin(r), getDminErr(r));
        }];
    }
}

void check_it_f(float p, float a, float b, float t, float n, float k, float v, float r, mpq_t er) {
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
    if (mpq_cmp(tmp1, er) != 0)
        printf("WRONG: er = % 20.20e while cer = % 20.20e\n", mpq_get_d(er), mpq_get_d(tmp1));
    mpq_clears(pq, aq, bq, tq, nq, kq, vq, rq, tmp0, tmp1, NULL);
}

void carbonGas_f(int search, int argc, const char * argv[]) {
    @autoreleasepool {
        id<ORModel> mdl = [ORFactory createModel];
        id<ORFloatVar> p = [ORFactory floatVar:mdl];
        id<ORFloatVar> a = [ORFactory floatVar:mdl];
        id<ORFloatVar> b = [ORFactory floatVar:mdl];
        id<ORFloatVar> t = [ORFactory floatVar:mdl];
        
        id<ORFloatVar> n = [ORFactory floatVar:mdl];
        id<ORFloatVar> k = [ORFactory floatVar:mdl];
        id<ORFloatVar> v = [ORFactory floatVar:mdl  low:0.1f up:0.5f];
        id<ORFloatVar> r = [ORFactory floatVar:mdl];
        
        //[mdl add:[v set: @(0.5f)]];
        [mdl add:[p set: @(35000000.0f)]];
        [mdl add:[a set: @(0.401f)]];
        [mdl add:[b set: @(4.27e-05f)]];
        [mdl add:[t set: @(300.0f)]];
        [mdl add:[n set: @(1000.0f)]];
        [mdl add:[k set: @(1.3806503e-23f)]];
        
        /*[mdl add:[t1 set:[n div: v]]];
         [mdl add:[t2 set:[a mul: t1]]];
         [mdl add:[t3 set:[t2 mul: t1]]];
         [mdl add:[t4 set:[p plus: t3]]];
         [mdl add:[t5 set:[n mul: b]]];
         [mdl add:[t6 set:[v sub: t5]]];
         [mdl add:[t7 set:[t4 mul: t6]]];
         [mdl add:[t8 set:[k mul: n]]];
         [mdl add:[t9 set:[t8 mul: t]]];
         [mdl add: [r set:[t7 sub: t9]]];*/
        
        [mdl add:[r set: [[[p plus: [[a mul: [n div: v]] mul: [n div: v]]] mul: [v sub: [n mul: b]]] sub: [[k mul: n] mul: t]]]];
        
        NSLog(@"model: %@",mdl);
        id<CPProgram> cp = [ORFactory createCPProgram:mdl];
        id<ORFloatVarArray> vs = [mdl floatVars];
        id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
        
        //[cp setMinErrorFD:r minErrorF:1.37616859e-1f];
        [cp setMinErrorFD:v minErrorF:0.0f];
        [cp setMaxErrorFD:v maxErrorF:0.0f];
        [cp solve:^{
            if (search)
                [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
                    [cp floatSplit:i call:s withVars:x];
                }];
            NSLog(@"%@",cp);
            /* format of 8.8e to have the same value displayed as in FLUCTUAT */
            /* Use printRational(ORRational r) to print a rational inside the solver */
            printFvar("p", p);
            printFvar("a", a);
            printFvar("b", b);
            printFvar("t", t);
            printFvar("n", n);
            printFvar("k", k);
            printFvar("v", v);
            printFvar("r", r);
            if (search)
                check_it_f(getFmin(p), getFmin(a), getFmin(b), getFmin(t), getFmin(n), getFmin(k), getFmin(v), getFmin(r), getFminErr(r));
        }];
    }
}

int main(int argc, const char * argv[]) {
    //carbonGas_f(1, argc, argv);
    carbonGas_d(1, argc, argv);
    return 0;
}
