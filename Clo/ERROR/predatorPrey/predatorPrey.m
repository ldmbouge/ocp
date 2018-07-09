//
//  predatorPrey.m
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

void check_it_d(double r, double k, double x, double z, ORRational ez) {
    mpq_t qz, qx, tmp0, tmp1, tmp2;
    double cz = ((r*x)*x) / (1.0 + ((x/k)*(x/k)));
    
    if (cz != z)
        printf("WRONG: cz = % 24.24e != z = % 24.24e\n", cz, z);
    
    mpq_inits(qz, qx, tmp0, tmp1, tmp2, NULL);
    
    // ((r*x)*x)
    mpq_set_d(qx, x);
    mpq_set_d(tmp0, r);
    mpq_mul(tmp1, tmp0, qx);
    mpq_mul(tmp0, tmp1, qx);
    
    // ((x/k)*(x/k))
    mpq_set_d(tmp2, k);
    mpq_div(tmp1, qx, tmp2);
    mpq_mul(tmp2, tmp1, tmp1);
    
    // ((r*x)*x) / (1.0f + ((x/k)*(x/k)))
    mpq_set_d(qz, 1.0);
    mpq_add(tmp1, tmp2, qz);
    mpq_div(qz, tmp0, tmp1);
    
    mpq_set_d(tmp0, cz);
    mpq_sub(tmp1, qz, tmp0);
    // La différence vient de ce que minError retourne un flottant au lieu d'un double !
    if (mpq_cmp(tmp1,ez) != 0)
        printf("WRONG: Err found = % 24.24e\n         != % 24.24e\n", mpq_get_d(tmp1), mpq_get_d(ez));
    mpq_clears(qz, qx, tmp0, tmp1, tmp2, NULL);
}

void predatorPrey_d(int search, int argc, const char * argv[]) {
    @autoreleasepool {
        id<ORModel> mdl = [ORFactory createModel];
        id<ORDoubleVar> r = [ORFactory doubleVar:mdl];
        id<ORDoubleVar> K = [ORFactory doubleVar:mdl];
        id<ORDoubleVar> z = [ORFactory doubleVar:mdl];
        id<ORDoubleVar> x = [ORFactory doubleVar:mdl low:0.1 up:0.3];
        
        [mdl add:[r set: @(4.0)]];
        [mdl add:[K set: @(1.11)]];
        [mdl add:[z set:[[[r mul: x] mul: x]  div: [@(1.0) plus: [[x div: K] mul:[x div: K]]]]]];
        NSLog(@"model: %@",mdl);
        id<ORDoubleVarArray> vs = [mdl doubleVars];
        id<CPProgram> cp = [ORFactory createCPProgram:mdl];
        id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
        
        [cp setMinErrorDD:x minErrorF:0.0];
        [cp setMaxErrorDD:x maxErrorF:0.0];
       [cp setMinErrorDD:z minErrorF:nextafter(0.0f, +INFINITY)];
        //[cp setMinErrorDD:z minErrorF:0.0];
        //[cp setMaxErrorDD:z maxErrorF:0.0];
        [cp solve:^{
            if (search)
                [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
                    [cp floatSplitD:i call:s withVars:x];
                }];
            NSLog(@"%@",cp);
            /* format of 8.8e to have the same value displayed as in FLUCTUAT */
            /* Use printRational(ORRational r) to print a rational inside the solver */
            printDvar("x", x);
            printDvar("r", r);
            printDvar("K", K);
            printDvar("z", z);
            if (search) check_it_d(getDmin(r),getDmin(K),getDmin(x),getDmin(z),getDminErr(z));
        }];
    }
}

void check_it_f(float r, float k, float x, float z, ORRational ez) {
    mpq_t qz, qx, tmp0, tmp1, tmp2;
    float cz = ((r*x)*x) / (1.0f + ((x/k)*(x/k)));
    
    if (cz != z)
        printf("WRONG: cz = % 20.20e != z = % 20.20e\n", cz, z);
    
    mpq_inits(qz, qx, tmp0, tmp1, tmp2, NULL);
    
    // ((r*x)*x)
    mpq_set_d(qx, x);
    mpq_set_d(tmp0, r);
    mpq_mul(tmp1, tmp0, qx);
    mpq_mul(tmp0, tmp1, qx);
    
    // ((x/k)*(x/k))
    mpq_set_d(tmp2, k);
    mpq_div(tmp1, qx, tmp2);
    mpq_mul(tmp2, tmp1, tmp1);
    
    // ((r*x)*x) / (1.0f + ((x/k)*(x/k)))
    mpq_set_d(qz, 1.0f);
    mpq_add(tmp1, tmp2, qz);
    mpq_div(qz, tmp0, tmp1);
    
    mpq_set_d(tmp0, cz);
    mpq_sub(tmp1, qz, tmp0);
    // La différence vient de ce que minError retourne un flottant au lieu d'un double !
    if (mpq_cmp(tmp1,ez) != 0)
        printf("WRONG: Err found = % 20.20e\n         != % 20.20e\n", mpq_get_d(tmp1), mpq_get_d(ez));
    mpq_clears(qz, qx, tmp0, tmp1, tmp2, NULL);
}

void predatorPrey_f(int search, int argc, const char * argv[]) {
    @autoreleasepool {
        id<ORModel> mdl = [ORFactory createModel];
        id<ORFloatVar> r = [ORFactory floatVar:mdl name:@"r"];
        id<ORFloatVar> K = [ORFactory floatVar:mdl];
        id<ORFloatVar> z = [ORFactory floatVar:mdl];
        id<ORFloatVar> x = [ORFactory floatVar:mdl low:0.1f up:0.3f name:@"x"];
        
        [mdl add:[r set: @(4.0f)]];
        [mdl add:[K set: @(1.11f)]];
        [mdl add:[z set:[[[r mul: x] mul: x]  div: [@(1.0f) plus: [[x div: K] mul:[x div: K]]]]]];
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
            /* format of 8.8e to have the same value displayed as in FLUCTUAT */
            /* Use printRational(ORRational r) to print a rational inside the solver */
            printFvar("x", x);
            printFvar("r", r);
            printFvar("K", K);
            printFvar("z", z);
            if (search) check_it_f(getFmin(r),getFmin(K),getFmin(x),getFmin(z),getFminErr(z));
        }];
    }
}

int main(int argc, const char * argv[]) {
   LOO_MEASURE_TIME(@"d"){
    //predatorPrey_f(1, argc, argv);
    predatorPrey_d(1, argc, argv);
   }
    return 0;
}


