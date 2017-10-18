#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"

#define eps 1.0e-5f

float check_solution(float a, float b, float c, float c_aire) {
    float aire = 0.0;
    unsigned int* aptr, * bptr, *cptr, *sqptr;
    
    aptr = (unsigned int *)&a;
    bptr = (unsigned int *)&b;
    cptr = (unsigned int *)&c;
    sqptr = (unsigned int *)&c_aire;
    printf("Hexa values \na = %20.20e [%4X]\nb =  %20.20e [%4X]\nc =  %20.20e [%4X]\nsquared_area = %20.20e [%4X]\n", a, *aptr, b , *bptr, c, *cptr, c_aire, *sqptr);
    
    
    if ((a < 5.0f) || (10.0f < a)) {
        printf("a is out of bounds:  %16.16e  %16.16e  %16.16e  %16.16e\n", a, b, c, c_aire);
        exit(0);
    }
    if ((b < 0.0f) || (5.0f < b)) {
        printf("b is out of bounds: %16.16e\n", b);
        exit(0);
    }
    if ((c < 0.0f) || (5.0f < c)) {
        printf("c is out of bounds: %16.16e\n", c);
        exit(0);
    }
    if (a <= 0)  {
        printf("assume a > 0 not fulfilled.\n");
        exit(0);
    }
    if (b <= 0) {
        printf("assume b > 0 not fulfilled.\n");
        exit(0);
    }
    if (c <= 0)  {
        printf("assume c > 0 not fulfilled.\n");
        exit(0);
    }
    if (b >= a+c)  {
        printf("assume a+c > b not fulfilled.\n");
        exit(0);
    }
    if (c >= a+b)  {
        printf("assume a+b > c not fulfilled.\n");
        exit(0);
    }
    if (a >= b+c)   {
        printf("assume b+c > a not fulfilled.\n");
        exit(0);
    }
    
    if (b > a)   {
        printf("assume a > b not fulfilled.\n");
        exit(0);
    }
    if (c > b)   {
        printf("assume b > c not fulfilled.\n");
        exit(0);
    }
    
    aire = (((a+(b+c))*(c-(a-b))*(c+(a-b))*(a+(b-c)))/16.0f);
    
    if (aire != c_aire) printf("aire not correct: got %16.16e, computed %16.16e\n", c_aire, aire); else printf("aire correct.\n");
    if (aire > eps) printf("aire is not < %e.\n", eps);
    
    return aire;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
        id<ORModel> model = [ORFactory createModel];
        id<ORFloatVar> a = [ORFactory floatVar:model low:5.0f up:10.0f];
        id<ORFloatVar> b = [ORFactory floatVar:model low:0.0f up:5.0f];
        id<ORFloatVar> c = [ORFactory floatVar:model low:0.0f up:5.0f];
        id<ORFloatVar> squared_area = [ORFactory floatVar:model];
        
        [model add:[a gt:@(0.0f)]];
        [model add:[b gt:@(0.0f)]];
        [model add:[c gt:@(0.0f)]];
        
        [model add:[[a plus:c] gt:b]];
        [model add:[[a plus:b] gt:c]];
        [model add:[[b plus:c] gt:a]];
        
        
        [model add:[a gt:b]];
        [model add:[b gt:c]];
        
        //squared_area = (((a+(b+c))*(c-(a-b))*(c+(a-b))*(a+(b-c)))/16.0f)
        [model add:[squared_area eq:[[
                                      [[
                                        [a plus:[b plus:c]]
                                        mul:[c sub:[a sub:b]]]
                                       mul:[c plus:[a sub:b]]]
                                      mul:[a plus:[b sub:c]]]
                                     div:@(16.0f)]
                    ]];
        
        [model add:[squared_area lt:@(1e-5f)]]; /* */
        
        
        id<ORFloatVarArray> vars = [model floatVars];
        id<CPProgram> cp = [args makeProgram:model];
        __block bool found = false;
            __block bool has_found = false;
            
            [cp solveOn:^(id<CPCommonProgram> p) {
             [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
                has_found = YES;
                for(id<ORFloatVar> v in vars){
                    found &= [p bound: v];
                    NSLog(@"%@ : %f (%s)",v,[p floatValue:v],[p bound:v] ? "YES" : "NO");
                }
                
                check_solution([p floatValue:a], [p floatValue:b], [p floatValue:c], [p floatValue:squared_area]);
                /*  if(found){
                          NSLog(@"\n");
                 NSLog(@"Verification solutions : \n");
                 check_solution([p floatValue:a], [p floatValue:b], [p floatValue:c], [p floatValue:squared_area]);
             }*/
            }  withTimeLimit:[args timeOut]];
            struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
            return r;
        }];
    }
    return 0;
}
