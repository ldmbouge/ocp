#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#include <fenv.h>

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
      id<ORDoubleVar> K = [ORFactory doubleVar:mdl name:@"K"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORDoubleVar> x = [ORFactory doubleVar:mdl low:0.1 up:0.3 name:@"x"];
      
      [mdl add:[r set: @(4.0)]];
      [mdl add:[K set: @(1.11)]];
      [mdl add:[z set:[[[r mul: x] mul: x]  div: [@(1.0) plus: [[x div: K] mul:[x div: K]]]]]];
      NSLog(@"model: %@",mdl);
      id<ORDoubleVarArray> vs = [mdl doubleVars];
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
//      [cp setMinErrorF:x minErrorF:0.0];
//      [cp setMaxErrorF:x maxErrorF:0.0];
      [cp solve:^{
            [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
               [cp floatSplitD:i call:s withVars:x];
            }];
         NSLog(@"%@",cp);
         for(id<ORVar> v in vars){
//            found &= [p bound: v];
            NSLog(@"%@ : %20.20e (%s) %@",v,[cp doubleValue:v],[cp bound:v] ? "YES" : "NO",[cp concretize:v]);
         }
         
         /* format of 8.8e to have the same value displayed as in FLUCTUAT */
         /* Use printRational(ORRational r) to print a rational inside the solver */
//         NSLog(@"x : [% 24.24e,% 24.24e] (%s)",[cp minF:x],[cp maxF:x],[cp bound:x] ? "YES" : "NO");
//         NSLog(@"ex: [% 24.24e,% 24.24e]",[cp minErrorF:x],[cp maxErrorF:x]);
//         NSLog(@"r : [% 24.24e,% 24.24e] (%s)",[cp minF:r],[cp maxF:r],[cp bound:r] ? "YES" : "NO");
//         NSLog(@"er: [% 24.24e,% 24.24e]",[cp minErrorF:r],[cp maxErrorF:r]);
//         NSLog(@"k : [% 24.24e,% 24.24e] (%s)",[cp minF:K],[cp maxF:K],[cp bound:K] ? "YES" : "NO");
//         NSLog(@"ek: [% 24.24e,% 24.24e]",[cp minErrorF:K],[cp maxErrorF:K]);
//         NSLog(@"z : [% 24.24e,% 24.24e] (%s)",[cp minF:z],[cp maxF:z],[cp bound:z] ? "YES" : "NO");
//         NSLog(@"ez: [% 24.24e,% 24.24e]",[cp minErrorF:z],[cp maxErrorF:z]);
//         if (search) check_it_d([cp minF:r],[cp minF:K],[cp minF:x],[cp minF:z],*[cp minError:z]);
      }];
   }
}
