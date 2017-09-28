#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"
/**
 //Precondition: x >= 0.0f and x <= 5.0f and y >= 2.0f and y >= 5.0f and z >= 0.0f and z <= 5.0f
 //Condition: z < 1.0f
 float bench1(float x, float y, float z) {
 if(x < y - z && x > 2z) {
 if(z < 1.0) return true;
 }
 }**/
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
            id<ORModel> model = [ORFactory createModel];
            id<ORFloatVar> x = [ORFactory floatVar:model low:0.0f up:5.f];
            id<ORFloatVar> y = [ORFactory floatVar:model low:1000.0f up:1020.0f];
            id<ORFloatVar> z = [ORFactory floatVar:model];
            
            [model add:[z eq: [x plus:y]]];
            
            [model add:[z gt:@(1024.999f)]];
            
            
            id<ORFloatVarArray> vars = [model floatVars];
            id<CPProgram> cp = [args makeProgram:model];
            __block float min = 10.f;
            __block float max = -1.f;
            __block float min2 = 10.f;
            __block float max2 = -1.f;
            __block NSMutableSet *set =  [[NSMutableSet alloc] initWithCapacity:32];
            __block NSMutableSet *set2 =  [[NSMutableSet alloc] initWithCapacity:32];
            __block int nb =0;
            //__block bool found = false;
            [cp solveAll:^{
                [args launchHeuristic:((id<CPProgram>)cp) restricted:vars];
                NSLog(@"Valeurs solutions : \n");
                nb++;
                for(id<ORFloatVar> v in vars){
                    if([v getId] == 0){
                        [set addObject:@([cp floatValue:v])];
                        min = ([cp bound: v] && [cp floatValue:v] < min) ? [cp floatValue:v]:min;
                        max = ([cp bound: v] && [cp floatValue:v] > max) ? [cp floatValue:v]:max;
                    }
                    if([v getId] == 1){
                        [set2 addObject:@([cp floatValue:v])];
                        min2 = ([cp bound: v] && [cp floatValue:v] < min2) ? [cp floatValue:v]:min2;
                        max2 = ([cp bound: v] && [cp floatValue:v] > max2) ? [cp floatValue:v]:max2;
                    }
                 //   found &= [p bound: v];
                    NSLog(@"%@ : %20.20e (%s) %@",v,[cp floatValue:v],[cp bound:v] ? "YES" : "NO",[cp concretize:v]);
                }
            }];
            NSLog(@"min max : %20.20e %20.20e ",min,max);
            NSLog(@"min max : %20.20e %20.20e ",min2,max2);
            NSLog(@"nb : %d [%lu , %lu]",nb,(unsigned long)[set count],(unsigned long)[set2 count]);
            /*[cp solveOn:^(id<CPCommonProgram> p) {
                [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
                NSLog(@"Valeurs solutions : \n");
                for(id<ORFloatVar> v in vars){
                    found &= [p bound: v];
                    NSLog(@"%@ : %20.20e (%s) %@",v,[p floatValue:v],[p bound:v] ? "YES" : "NO",[p concretize:v]);
                }
            } withTimeLimit:[args timeOut]];
            */
            struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
            return r;
        }];
    }
    return 0;
}
