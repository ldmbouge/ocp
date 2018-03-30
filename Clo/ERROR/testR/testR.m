//
//  main.m
//  testFloat
//
//  Created by Remy on 01/12/2017.
//
//

#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> mdl = [ORFactory createModel];
       //id<ORFloatRange> r0 = [ORFactory floatRange:mdl low:0.100001f up:0.399434344f];
       //id<ORFloatRange> r1 = [ORFactory floatRange:mdl low:0.2f up:0.4f];
         id<ORFloatVar> x = [ORFactory floatVar:mdl low:0.1f up:0.2f name:@"x"];
       id<ORFloatVar> y = [ORFactory floatVar:mdl low:0.2f up:0.4f name:@"y"];
       id<ORFloatVar> w = [ORFactory floatVar:mdl low:0.6f up:0.9f name:@"w"];
       //id<ORFloatVar> u = [ORFactory floatVar:mdl];
       id<ORFloatVar> z = [ORFactory floatVar:mdl name:@"z"];
       
       //[mdl add:[x set: @(0.2f)]];
       //[mdl add:[y set: @(0.4f)]];
       //[mdl add:[w set: @(0.9f)]];
       //[mdl add:[w set: [x div:y]]];
       //[mdl add:[u set: [x plus: y]]];
       //[mdl add:[z set: [x plus: y]]];
       //[mdl add:[z set: @(5.0e-1)]];
       [mdl add:[z set: [x plus:[y plus: w]]]];
       
       //[mdl add:[y set: @(4.0f)]];
       //[mdl add:[w set: @(1.11f)]];
       //[mdl add:[z set:[[x plus: y] sub: [x div: y]]]];

       NSLog(@"model: %@",mdl);
       //id<ORFloatVarArray> vs = [mdl floatVars];
       id<CPProgram> cp = [args makeProgram:mdl];
       //id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
       
       //[cp setMinError:z minError:7.45e-9f];
       [cp setMinError:y minError:0.0f];
       [cp setMaxError:y maxError:0.0f];
       [cp setMinError:x minError:0.0f];
       [cp setMaxError:x maxError:0.0f];
       [cp setMinError:w minError:0.0f];
       [cp setMaxError:w maxError:0.0f];
       [cp solve:^{
            /*[cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
               [cp floatSplit:i call:s withVars:x];
            }];*/
            NSLog(@"%@",cp);
            //NSLog(@"%@ (%s)",[cp concretize:x],[cp bound:x] ? "YES" : "NO");
            /* format of 8.8e to have the same value displayed as in FLUCTUAT */
            /* Use printRational(ORRational r) to print a rational inside the solver */
            NSLog(@"x : [%8.8e;%8.8e] (%s)",[cp minF:x],[cp maxF:x],[cp bound:x] ? "YES" : "NO");
            NSLog(@"ex: [%8.8e;%8.8e]",[cp minError:x],[cp maxError:x]);
            NSLog(@"y : [%8.8e;%8.8e] (%s)",[cp minF:y],[cp maxF:y],[cp bound:y] ? "YES" : "NO");
            NSLog(@"ey: [%8.8e;%8.8e]",[cp minError:y],[cp maxError:y]);
            NSLog(@"w : [%8.8e;%8.8e] (%s)",[cp minF:w],[cp maxF:w],[cp bound:w] ? "YES" : "NO");
            NSLog(@"ew: [%8.8e;%8.8e]",[cp minError:w],[cp maxError:w]);
           //NSLog(@"u : [%8.8e;%8.8e] (%s)",[cp minF:u],[cp maxF:u],[cp bound:u] ? "YES" : "NO");
           //NSLog(@"eu: [%8.8e;%8.8e]",[cp minError:u],[cp maxError:u]);
            NSLog(@"z : [%8.8e;%8.8e] (%s)",[cp minF:z],[cp maxF:z],[cp bound:z] ? "YES" : "NO");
            NSLog(@"ez: [%8.8e;%8.8e]",[cp minError:z],[cp maxError:z]);
        }];
         struct ORResult r = REPORT(0, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
      
   }
   return 0;
}
