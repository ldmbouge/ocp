//
//  main.m
//  poly
//
//  Created by Zitoun on 26/07/2016.
//
//


#import <ORProgram/ORProgram.h>
#include <fpi.h>

#define eps 1.0e-3f

float check_solution(float a, float b, float c, float c_r) {
    float r;
    
    if ((a < 1.0e3f) || (1.0e4f < a)) printf("a is out of bounds.\n");
    if ((b < 0.0f) || (1.0f < b))  printf("b is out of bounds.\n");
    if ((c < 1.0e3f) || (1.0e4f < c))  printf("c is out of bounds.\n");
    
    r = ((a * a + b + 1.0e-5f) * c);
    
    if (r != c_r) printf("r not correct: got %16.16e, computed %16.16e\n", c_r, r); else printf("r correct.\n");
    if (r > 1000000000.00999999046325683594 - eps) printf("aire is not <= 1000000000.00999999046325683594 - %e.\n", eps);
    
    return r;
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        id<ORModel> mdl = [ORFactory createModel];
        id<ORFloatRange> ra = [ORFactory floatRange:mdl low:1e3f up:1e4f];
        id<ORFloatRange> rb = [ORFactory floatRange:mdl low:0.f up:1.f];
        id<ORFloatRange> rc = [ORFactory floatRange:mdl low:1e3f up:1e4f];
        id<ORFloatRange> rres = [ORFactory floatRange:mdl];
        id<ORFloatVar> a = [ORFactory floatVar:mdl domain:ra];
        id<ORFloatVar> b = [ORFactory floatVar:mdl domain:rb];
        id<ORFloatVar> c = [ORFactory floatVar:mdl domain:rc];
        id<ORFloatVar> res = [ORFactory floatVar:mdl domain:rres];
        
        id<ORFloatVarArray> vars = [mdl floatVars];
        
        //model.add(res = (a*a + b + 1e-5f) * c);
        [mdl add:[res eq:[[[[a mul:a] plus:b] plus:@(1e-5f)] mul:c]]];
    
        //model.add(res > 1e9f + 0.0099999904f - 1e-3f);
        float v = 1000000000.00999999046325683594;
        id<ORExpr> fc = [ORFactory float:mdl value:v];
        [mdl add:[res gt:fc]];
        id<CPProgram> p = [ORFactory createCPProgram:mdl];
        [p solveAll:^{
            NSLog(@"hello");
            [p floatSplitArray:vars];
            check_solution([p floatValue:a],[p floatValue:b], [p floatValue:c], [p floatValue:res]);
            NSLog(@"a : %@ (%s)",[p concretize:a],[p bound:a] ? "YES" : "NO");
            NSLog(@"b : %@ (%s)",[p concretize:b],[p bound:b] ? "YES" : "NO");
            NSLog(@"c : %@ (%s)",[p concretize:c],[p bound:c] ? "YES" : "NO");
            NSLog(@"res : %@ (%s)",[p concretize:res],[p bound:res] ? "YES" : "NO");
        }];
    }
    return 0;
}
