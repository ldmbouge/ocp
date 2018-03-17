//
//  main.m
//  testFloat
//
//  Created by Remy on 01/12/2017.
//
//

#import <ORProgram/ORProgram.h>

int main(int argc, const char * argv[]) {
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
      
      [cp solve:^{
         [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
            [cp floatSplit:i call:s withVars:x];
         }];
         NSLog(@"%@",cp);
         //NSLog(@"%@ (%s)",[cp concretize:x],[cp bound:x] ? "YES" : "NO");
         /* format of 8.8e to have the same value displayed as in FLUCTUAT */
         /* Use printRational(ORRational r) to print a rational inside the solver */
         NSLog(@"x : [%8.8e;%8.8e] (%s)",[cp minF:x],[cp maxF:x],[cp bound:x] ? "YES" : "NO");
         NSLog(@"ex: [%8.8e;%8.8e]",[cp minError:x],[cp maxError:x]);
         NSLog(@"r : [%8.8e;%8.8e] (%s)",[cp minF:r],[cp maxF:r],[cp bound:r] ? "YES" : "NO");
         NSLog(@"er: [%8.8e;%8.8e]",[cp minError:r],[cp maxError:r]);
         NSLog(@"k : [%8.8e;%8.8e] (%s)",[cp minF:k],[cp maxF:k],[cp bound:k] ? "YES" : "NO");
         NSLog(@"ek: [%8.8e;%8.8e]",[cp minError:k],[cp maxError:k]);
         NSLog(@"z : [%8.8e;%8.8e] (%s)",[cp minF:z],[cp maxF:z],[cp bound:z] ? "YES" : "NO");
         NSLog(@"ez: [%8.8e;%8.8e]",[cp minError:z],[cp maxError:z]);
      }];
   }
   return 0;
}
