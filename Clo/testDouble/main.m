#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#include <fenv.h>

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         fesetround(FE_TONEAREST);
         id<ORModel> model = [ORFactory createModel];
         id<ORDoubleVar> c_0 = [ORFactory doubleVar:model name:@"c"];
         id<ORDoubleVar> r_0 = [ORFactory doubleVar:model name:@"r"];
         id<ORDoubleVar> a_0 = [ORFactory doubleVar:model name:@"a"];
         id<ORDoubleVar> Q_0 = [ORFactory doubleVar:model name:@"Q"];
         id<ORDoubleVar> R2_0 = [ORFactory doubleVar:model name:@"R2"];
         id<ORDoubleVar> CR2_0 = [ORFactory doubleVar:model name:@"CR2"];
         id<ORDoubleVar> CQ3_0 = [ORFactory doubleVar:model name:@"CQ3"];
         id<ORDoubleVar> Q3_0 = [ORFactory doubleVar:model name:@"Q3"];
         id<ORDoubleVar> R_0 = [ORFactory doubleVar:model name:@"R"];
         id<ORDoubleVar> q_0 = [ORFactory doubleVar:model name:@"q"];
         id<ORDoubleVar> b_0 = [ORFactory doubleVar:model name:@"b"];
         id<ORGroup> g = [args makeGroup:model];
         [g add:[q_0 eq: [[a_0 mul: a_0] sub: [b_0 mul:@(3.)]]]];
         
         [g add:[r_0 eq: [[[[[a_0 mul:@(2.)] mul: a_0] mul: a_0] sub: [[a_0 mul:@(9.)] mul: b_0]] plus: [c_0 mul:@(27.)]]]];
         
         
         [g add:[Q_0 eq: [q_0 div:@(9.)]]];
         
         [g add:[R_0 eq: [r_0 div:@(54.)]]];
         
         
         [g add:[Q3_0 eq: [[Q_0 mul:Q_0] mul:Q_0]]];
         
         [g add:[R2_0 eq: [R_0 mul:R_0]]];
         
         
         [g add:[CR2_0 eq: [[r_0 mul:@(729.)] mul: r_0]]];
         
         [g add:[CQ3_0 eq: [[[q_0 mul:@(2916.)] mul: q_0] mul: q_0]]];
         
         //assert(!(R == 0 && Q == 0));
         [g add:[R_0 eq:@(0.0)]];
         [g add:[Q_0 eq:@(0.0)]];
//         [g add:[a_0 eq:@(15.0)]];
         
         [model add:g];
         id<CPProgram> cp = [args makeProgram:model];
         NSLog(@"%@",g);
         id<ORDoubleVarArray> dv = [model doubleVars];
         id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:dv engine:[cp engine]];
         __block bool found = false;
         [cp solveOn:^(id<CPCommonProgram> p) {
            NSLog(@"Valeurs solutions : \n");
            [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> d) {
               [cp floatSplitD:i call:s withVars:d];
            }];
            found=true;
            for(id<ORVar> v in vars){
               found &= [p bound: v];
               NSLog(@"%@ : %20.20e (%s) %@",v,[p doubleValue:v],[p bound:v] ? "YES" : "NO",[p concretize:v]);
            }
            
         } withTimeLimit:[args timeOut]];
         
         struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
      
   }
   return 0;
}

