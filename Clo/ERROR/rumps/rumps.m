//
//  rumps.m
//  Clo
//
//  Created by Remy Garcia on 11/03/2018.
//
#import <ORProgram/ORProgram.h>
#include "gmp.h"

#define printFvar(name, var) NSLog(@""name" : [% 20.20e, % 20.20e]f (%s)",[(id<CPFloatVar>)[cp concretize:var] min],[(id<CPFloatVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 20.20e, % 20.20e]q",[(id<CPFloatVar>)[cp concretize:var] minErrF],[(id<CPFloatVar>)[cp concretize:var] maxErrF]);
#define getFmin(var) [(id<CPFloatVar>)[cp concretize:var] min]
#define getFminErr(var) *[(id<CPFloatVar>)[cp concretize:var] minErr]

#define printDvar(name, var) NSLog(@""name" : [% 24.24e, % 24.24e]d (%s)",[(id<CPDoubleVar>)[cp concretize:var] min],[(id<CPDoubleVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 24.24e, % 24.24e]q",[(id<CPDoubleVar>)[cp concretize:var] minErrF],[(id<CPDoubleVar>)[cp concretize:var] maxErrF]);
#define getDmin(var) [(id<CPDoubleVar>)[cp concretize:var] min]
#define getDminErr(var) *[(id<CPDoubleVar>)[cp concretize:var] minErr]

void check_it_d(double x, double y, double z, id<ORRational> ez) {
    // 333.75 b^6 + a^2 (11 a^2 b^2 - b^6 - 121 b^4 - 2 ) + 5.5 b^8 + a / (2b)
    mpq_t xq, yq, zq, y2q, y4q, y6q, y8q, x2q, tmp0, tmp1;
    double cz = 333.75*y*y*y*y*y*y + x*x*(11.0*x*x*y*y - y*y*y*y*y*y - 121.0*y*y*y*y - 2.0) + 5.5*y*y*y*y*y*y*y*y + x/(2.0*y);
    
    if (cz != z)
        printf("WRONG: z   = % 24.24e while cz = % 24.24e\n", z, cz);
    
    mpq_inits(xq, yq, zq, y2q, y4q, y6q, y8q, x2q, tmp0, tmp1, NULL);
    mpq_set_d(xq, x);
    mpq_set_d(yq, y);
    mpq_mul(x2q, xq, xq);
    mpq_mul(y2q, yq, yq);
    mpq_mul(y4q, y2q, y2q);
    mpq_mul(y6q, y4q, y2q);
    mpq_mul(y8q, y4q, y4q);
    mpq_set_d(tmp0, 11.0);
    mpq_mul(tmp1, tmp0, x2q);
    mpq_mul(tmp0, tmp1, y2q);
    mpq_sub(zq, tmp0, y6q);
    mpq_set_d(tmp0, 121.0);
    mpq_mul(tmp1, tmp0, y4q);
    mpq_sub(tmp0, zq, tmp1);
    mpq_set_d(tmp1, 2.0);
    mpq_sub(zq, tmp0, tmp1);
    mpq_mul(zq, zq, x2q);
    mpq_set_d(tmp0, 333.75);
    mpq_mul(tmp1, tmp0, y6q);
    mpq_add(tmp0, zq, tmp1);
    mpq_set_d(zq, 5.5);
    mpq_mul(tmp1, zq, y8q);
    mpq_add(zq, tmp1, tmp0);
    mpq_set_d(tmp1, 2.0);
    mpq_mul(tmp0, tmp1, yq);
    mpq_div(tmp1, xq, tmp0);
    mpq_add(zq, zq, tmp1);
    mpq_set_d(tmp0, z);
    mpq_sub(tmp1, zq, tmp0);
   if (mpq_cmp(tmp1, ez.rational) != 0){
       NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
       NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
}
    mpq_clears(xq, yq, zq, y2q, y4q, y6q, y8q, x2q, tmp0, tmp1, NULL);
}

void rump_d(int search, int argc, const char * argv[]) {
    @autoreleasepool {
        id<ORModel> mdl = [ORFactory createModel];
        id<ORDoubleVar> x_0 = [ORFactory doubleVar:mdl name:@"x"];
        id<ORDoubleVar> y_0 = [ORFactory doubleVar:mdl name:@"y"];
        id<ORDoubleVar> r_0 = [ORFactory doubleVar:mdl];
       
        [mdl add:[x_0 set: @(77617.0)]];
        [mdl add:[y_0 set: @(33096.0)]];
        [mdl add:[r_0 set: [[[[[[[[[y_0 mul: @(333.75)] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0] plus: [[x_0 mul: x_0] mul: [[[[[[[x_0 mul: @(11.0)] mul: x_0] mul: y_0] mul: y_0] sub: [[[[[y_0 mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0]] sub: [[[[y_0 mul: @(121.0)] mul: y_0] mul: y_0] mul: y_0]] sub: @(2.0)]]] plus: [[[[[[[[y_0 mul: @(5.5)] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0]] plus: [x_0 div: [y_0 mul: @(2.0)]]]]];
        //assert((r_0 >= 0));
        //[mdl add:[r_0 set:[x_0 plus: y_0]]];
        //[mdl add:[r_0 geq:@(0.0f)]];
        //[model add:[[r_0 lt:@(0.0f)] lor:[r_0 gt:@(0.0f)]]];
        
        NSLog(@"model: %@",mdl);
        id<CPProgram> cp = [ORFactory createCPProgram:mdl];
        id<ORDoubleVarArray> vs = [mdl doubleVars];
        id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
       
        [cp solve:^{
           if (search)
              [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
                 [cp floatSplitD:i call:s withVars:x];
              }];
            NSLog(@"%@",cp);
           NSLog(@"x : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:x_0],[cp maxD:x_0],[cp minDQ:x_0],[cp maxDQ:x_0],[cp bound:x_0] ? "YES" : "NO");
           NSLog(@"y : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:y_0],[cp maxD:y_0],[cp minDQ:y_0],[cp maxDQ:y_0],[cp bound:y_0] ? "YES" : "NO");
           NSLog(@"r : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:r_0],[cp maxD:r_0],[cp minDQ:r_0],[cp maxDQ:r_0],[cp bound:r_0] ? "YES" : "NO");
            check_it_d(getDmin(x_0), getDmin(y_0), getDmin(r_0), [cp minErrorDQ:r_0]);
        }];
    }
}

void check_it_f(float x, float y, float z, id<ORRational> ez) {
    // 333.75 b^6 + a^2 (11 a^2 b^2 - b^6 - 121 b^4 - 2 ) + 5.5 b^8 + a / (2b)
    mpq_t xq, yq, zq, y2q, y4q, y6q, y8q, x2q, tmp0, tmp1;
    float cz = 333.75f*y*y*y*y*y*y + x*x*(11.0f*x*x*y*y - y*y*y*y*y*y - 121.0f*y*y*y*y - 2.0f) + 5.5f*y*y*y*y*y*y*y*y + x/(2.0f*y);
    
    if (cz != z)
        printf("WRONG: z   = % 20.20e while cz = % 20.20e\n", z, cz);
    
    mpq_inits(xq, yq, zq, y2q, y4q, y6q, y8q, x2q, tmp0, tmp1, NULL);
    mpq_set_d(xq, x);
    mpq_set_d(yq, y);
    mpq_mul(x2q, xq, xq);
    mpq_mul(y2q, yq, yq);
    mpq_mul(y4q, y2q, y2q);
    mpq_mul(y6q, y4q, y2q);
    mpq_mul(y8q, y4q, y4q);
    mpq_set_d(tmp0, 11.0f);
    mpq_mul(tmp1, tmp0, x2q);
    mpq_mul(tmp0, tmp1, y2q);
    mpq_sub(zq, tmp0, y6q);
    mpq_set_d(tmp0, 121.0f);
    mpq_mul(tmp1, tmp0, y4q);
    mpq_sub(tmp0, zq, tmp1);
    mpq_set_d(tmp1, 2.0f);
    mpq_sub(zq, tmp0, tmp1);
    mpq_mul(zq, zq, x2q);
    mpq_set_d(tmp0, 333.75f);
    mpq_mul(tmp1, tmp0, y6q);
    mpq_add(tmp0, zq, tmp1);
    mpq_set_d(zq, 5.5f);
    mpq_mul(tmp1, zq, y8q);
    mpq_add(zq, tmp1, tmp0);
    mpq_set_d(tmp1, 2.0f);
    mpq_mul(tmp0, tmp1, yq);
    mpq_div(tmp1, xq, tmp0);
    mpq_add(zq, zq, tmp1);
    mpq_set_d(tmp0, z);
    mpq_sub(tmp1, zq, tmp0);
   if (mpq_cmp(tmp1, ez.rational) != 0){
       NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
       NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
   }
    mpq_clears(xq, yq, zq, y2q, y4q, y6q, y8q, x2q, tmp0, tmp1, NULL);
}

void rump_f(int search, int argc, const char * argv[]) {
    @autoreleasepool {
        id<ORModel> mdl = [ORFactory createModel];
        id<ORFloatVar> x_0 = [ORFactory floatVar:mdl name:@"x_0"];
        id<ORFloatVar> y_0 = [ORFactory floatVar:mdl name:@"y_0"];
        id<ORFloatVar> r_0 = [ORFactory floatVar:mdl name:@"r_0"];
        
        
        [mdl add:[x_0 set: @(77617.f)]];
        [mdl add:[y_0 set: @(33096.f)]];
        //[mdl add:[r_0 set: [[[[[[[[[y_0 mul: @(333.75f)] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0] plus: [[x_0 mul: x_0] mul: [[[[[[[x_0 mul: @(11.0f)] mul: x_0] mul: y_0] mul: y_0] sub: [[[[[y_0 mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0]] sub: [[[[y_0 mul: @(121.0f)] mul: y_0] mul: y_0] mul: y_0]] sub: @(2.0f)]]] plus: [[[[[[[[y_0 mul: @(5.5f)] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0]] plus: [x_0 div: [y_0 mul: @(2.f)]]]]];
        //assert((r_0 >= 0));
        [mdl add:[r_0 set:[x_0 plus: y_0]]];
        //[mdl add:[r_0 geq:@(0.0f)]];
        //[model add:[[r_0 lt:@(0.0f)] lor:[r_0 gt:@(0.0f)]]];
        
        NSLog(@"model: %@",mdl);
        id<CPProgram> cp = [ORFactory createCPProgram:mdl];
        id<ORFloatVarArray> vs = [mdl floatVars];
        id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];

        [cp solve:^{
           if (search)
              [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
                 [cp floatSplitD:i call:s withVars:x];
              }];
            NSLog(@"%@",cp);
           NSLog(@"x : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minF:x_0],[cp maxF:x_0],[cp minFQ:x_0],[cp maxFQ:x_0],[cp bound:x_0] ? "YES" : "NO");
           NSLog(@"y : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minF:y_0],[cp maxF:y_0],[cp minFQ:y_0],[cp maxFQ:y_0],[cp bound:y_0] ? "YES" : "NO");
           NSLog(@"r : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minF:r_0],[cp maxF:r_0],[cp minFQ:r_0],[cp maxFQ:r_0],[cp bound:r_0] ? "YES" : "NO");
           check_it_f(getFmin(x_0), getFmin(y_0), getFmin(r_0), [cp minErrorFQ:r_0]);
        }];
    }
}

int main(int argc, const char * argv[]) {

    rump_f(1, argc, argv);
    //rump_d(1, argc, argv);
    NSLog(@"%16.16e", FLT_MAX);
    return 0;
}

