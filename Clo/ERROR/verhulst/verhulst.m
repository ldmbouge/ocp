//
//  main.m
//  testFloat
//
//  Created by Remy on 01/12/2017.
//
//

#import <ORProgram/ORProgram.h>
#include "gmp.h"

#define printFvar(name, var) NSLog(@""name" : [% 20.20e, % 20.20e]f (%s)",[(id<CPFloatVar>)[cp concretize:var] min],[(id<CPFloatVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 20.20e, % 20.20e]q",[(id<CPFloatVar>)[cp concretize:var] minErrF],[(id<CPFloatVar>)[cp concretize:var] maxErrF]);
#define getFmin(var) [(id<CPFloatVar>)[cp concretize:var] min]
#define getFminErr(var) *[(id<CPFloatVar>)[cp concretize:var] minErr]

#define printDvar(name, var) NSLog(@""name" : [% 24.24e, % 24.24e]d (%s)",[(id<CPDoubleVar>)[cp concretize:var] min],[(id<CPDoubleVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 24.24e, % 24.24e]q",[(id<CPDoubleVar>)[cp concretize:var] minErrF],[(id<CPDoubleVar>)[cp concretize:var] maxErrF]);
#define getDmin(var) [(id<CPDoubleVar>)[cp concretize:var] min]
#define getDminErr(var) *[(id<CPDoubleVar>)[cp concretize:var] minErr]

void check_it_d(double x, double r, double k, double z, mpq_t ez) {
    double cz = (r*x)/(1+x/k);
    mpq_t xq, rq, kq, zq, errq, tmp0, tmp1;
    
    if (cz != z)
        printf("WRONG: z = % 20.20e while cz = % 20.20e\n", z, cz);
    
    mpq_inits(xq, rq, kq, zq, errq, tmp0, tmp1, NULL);
    mpq_set_d(xq, x);
    mpq_set_d(rq, r);
    mpq_set_d(kq, k);
    mpq_div(errq, xq, kq);
    mpq_set_d(tmp1, 1.0f);
    mpq_add(tmp0, errq, tmp1);
    mpq_mul(tmp1, rq, xq);
    mpq_div(zq, tmp1, tmp0);
    mpq_set_d(tmp0, cz);
    mpq_sub(errq, zq, tmp0);
    if (mpq_cmp(errq, ez) != 0)
        printf("WRONG: ez = % 20.20e while errq = % 20.20e\n", mpq_get_d(ez), mpq_get_d(errq));
    mpq_clears(xq, rq, kq, zq, errq, tmp0, tmp1, NULL);
}

void verhulst_d(int search, int argc, const char * argv[]) {
    @autoreleasepool {
        id<ORModel> mdl = [ORFactory createModel];
        id<ORDoubleRange> r0 = [ORFactory doubleRange:mdl low:0.1 up:0.3];
        id<ORDoubleVar> x = [ORFactory doubleVar:mdl domain:r0];
        id<ORDoubleVar> r = [ORFactory doubleVar:mdl];
        id<ORDoubleVar> k = [ORFactory doubleVar:mdl];
        id<ORDoubleVar> z = [ORFactory doubleVar:mdl];
        
        [mdl add:[r set: @(4.0)]];
        [mdl add:[k set: @(1.11)]];
        [mdl add:[z set:[[r mul: x] div: [@(1.0) plus: [x div: k]]]]];
        
        NSLog(@"model: %@",mdl);
        id<ORDoubleVarArray> vs = [mdl doubleVars];
        id<CPProgram> cp = [ORFactory createCPProgram:mdl];
        id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
        
        [cp setMinErrorDD:x minErrorF:0.0];
        [cp setMaxErrorDD:x maxErrorF:0.0];
        //[cp setMinErrorDD:z minErrorF:0.0];
        //[cp setMaxErrorDD:z maxErrorF:0.0];
        
        [cp solve:^{
            if (search)
                [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
                    [cp floatSplitD:i call:s withVars:x];
                }];
            NSLog(@"%@",cp);
            printDvar("x", x);
            printDvar("r", r);
            printDvar("k", k);
            printDvar("z", z);
            if (search) check_it_d(getDmin(x),getDmin(r),getDmin(k),getDmin(z),getDminErr(z));
        }];
    }
}

void check_it_f(float x, float r, float k, float z, mpq_t ez) {
    float cz = (r*x)/(1+x/k);
    mpq_t xq, rq, kq, zq, errq, tmp0, tmp1;
    
    if (cz != z)
        printf("WRONG: z = % 20.20e while cz = % 20.20e\n", z, cz);
    
    mpq_inits(xq, rq, kq, zq, errq, tmp0, tmp1, NULL);
    mpq_set_d(xq, x);
    mpq_set_d(rq, r);
    mpq_set_d(kq, k);
    mpq_div(errq, xq, kq);
    mpq_set_d(tmp1, 1.0f);
    mpq_add(tmp0, errq, tmp1);
    mpq_mul(tmp1, rq, xq);
    mpq_div(zq, tmp1, tmp0);
    mpq_set_d(tmp0, cz);
    mpq_sub(errq, zq, tmp0);
    if (mpq_cmp(errq, ez) != 0)
        printf("WRONG: ez = % 20.20e while errq = % 20.20e\n", mpq_get_d(ez), mpq_get_d(errq));
    mpq_clears(xq, rq, kq, zq, errq, tmp0, tmp1, NULL);
}

void verhulst_f(int search, int argc, const char * argv[]) {
    @autoreleasepool {
        id<ORModel> mdl = [ORFactory createModel];
        id<ORFloatRange> r0 = [ORFactory floatRange:mdl low:0.1f up:0.3f];
        id<ORFloatVar> x = [ORFactory floatVar:mdl domain:r0];
        id<ORFloatVar> r = [ORFactory floatVar:mdl];
        id<ORFloatVar> k = [ORFactory floatVar:mdl];
        id<ORFloatVar> z = [ORFactory floatVar:mdl];
        
        [mdl add:[r set: @(4.0f)]];
        [mdl add:[k set: @(1.11f)]];
        [mdl add:[z set:[[r mul: x] div: [@(1.0f) plus: [x div: k]]]]];
        
        NSLog(@"model: %@",mdl);
        id<ORFloatVarArray> vs = [mdl floatVars];
        id<CPProgram> cp = [ORFactory createCPProgram:mdl];
        id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
        
        [cp setMinErrorFD:x minErrorF:0.0f];
        [cp setMaxErrorFD:x maxErrorF:0.0f];
                
        [cp solve:^{
            if (search)
                [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
                    [cp floatSplit:i call:s withVars:x];
                }];
            NSLog(@"%@",cp);
            printFvar("x", x);
            printFvar("r", r);
            printFvar("k", k);
            printFvar("z", z);
            if (search) check_it_f(getFmin(x),getFmin(r),getFmin(k),getFmin(z),getFminErr(z));
        }];
    }
}

int main(int argc, const char * argv[]) {
 //   verhulst_f(0, argc, argv);
   verhulst_d(1, argc, argv);
    return 0;
}
