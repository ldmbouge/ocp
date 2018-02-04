#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         fesetround(FE_TONEAREST);
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVar> c_0 = [ORFactory floatVar:model name:@"c"];
         id<ORFloatVar> r_0 = [ORFactory floatVar:model name:@"r"];
         id<ORFloatVar> a_0 = [ORFactory floatVar:model name:@"a"];
         id<ORFloatVar> Q_0 = [ORFactory floatVar:model name:@"Q"];
         id<ORFloatVar> R2_0 = [ORFactory floatVar:model name:@"R2"];
         id<ORFloatVar> CR2_0 = [ORFactory floatVar:model name:@"CR2"];
         id<ORFloatVar> CQ3_0 = [ORFactory floatVar:model name:@"CQ3"];
         id<ORFloatVar> Q3_0 = [ORFactory floatVar:model name:@"Q3"];
         id<ORFloatVar> R_0 = [ORFactory floatVar:model name:@"R"];
         id<ORFloatVar> q_0 = [ORFactory floatVar:model name:@"q"];
         id<ORFloatVar> b_0 = [ORFactory floatVar:model name:@"b"];
         id<ORGroup> g = [args makeGroup:model];
         [g add:[q_0 eq: [[a_0 mul: a_0] sub: [b_0 mul:@(3.f)]]]];
         
         [g add:[r_0 eq: [[[[[a_0 mul:@(2.f)] mul: a_0] mul: a_0] sub: [[a_0 mul:@(9.f)] mul: b_0]] plus: [c_0 mul:@(27.f)]]]];
         
         
         [g add:[Q_0 eq: [q_0 div:@(9.f)]]];
         
         [g add:[R_0 eq: [r_0 div:@(54.f)]]];
         
         
         [g add:[Q3_0 eq: [[Q_0 mul:Q_0] mul:Q_0]]];
         
         [g add:[R2_0 eq: [R_0 mul:R_0]]];
         
         
         [g add:[CR2_0 eq: [[r_0 mul:@(729.f)] mul: r_0]]];
         
         [g add:[CQ3_0 eq: [[[q_0 mul:@(2916.f)] mul: q_0] mul: q_0]]];
         
         //assert(!(R == 0 && Q == 0));
         [g add:[R_0 eq:@(0.0f)]];
         [g add:[Q_0 eq:@(0.0f)]];
         [g add:[a_0 eq:@(15.0f)]];

         [model add:g];
         id<CPProgram> cp = [ORFactory createCPProgram:model];
         
         id<ORFloatVarArray> vars = [model floatVars];
         NSLog(@"%@",model);
//         id<CPProgram> cp = [args makeProgram:model];
         __block bool found = false;
         [cp solveOn:^(id<CPCommonProgram> p) {
//            NSLog(@"%@",p);
            
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            NSLog(@"Valeurs solutions : \n");
            found=true;
            for(id<ORFloatVar> v in vars){
               found &= [p bound: v];
               NSLog(@"%@ : %20.20e (%s) %@",v,[p floatValue:v],[p bound:v] ? "YES" : "NO",[p concretize:v]);
            }
         } withTimeLimit:[args timeOut]];
         
         struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
      
   }
   return 0;
}
