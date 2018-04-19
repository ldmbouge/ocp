//
//  main.m
//  testFloat
//
//  Created by Remy on 01/12/2017.
//
//

#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

#define printFvar(name, var) NSLog(@""name" : [% 20.20e, % 20.20e]f (%s)",[(id<CPFloatVar>)[cp concretize:var] min],[(id<CPFloatVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 20.20e, % 20.20e]q",[(id<CPFloatVar>)[cp concretize:var] minErrF],[(id<CPFloatVar>)[cp concretize:var] maxErrF]);
#define getFmin(var) [(id<CPFloatVar>)[cp concretize:var] min]
#define getFminErr(var) *[(id<CPFloatVar>)[cp concretize:var] minErr]

#define printDvar(name, var) NSLog(@""name" : [% 24.24e, % 24.24e]d (%s)",[(id<CPDoubleVar>)[cp concretize:var] min],[(id<CPDoubleVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 24.24e, % 24.24e]q",[(id<CPDoubleVar>)[cp concretize:var] minErrF],[(id<CPDoubleVar>)[cp concretize:var] maxErrF]);
#define getDmin(var) [(id<CPDoubleVar>)[cp concretize:var] min]
#define getDminErr(var) *[(id<CPDoubleVar>)[cp concretize:var] minErr]

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      //ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      //[args measure:^struct ORResult(){
         id<ORModel> mdl = [ORFactory createModel];
       //id<ORFloatRange> r0 = [ORFactory floatRange:mdl low:0.100001f up:0.399434344f];
       //id<ORFloatRange> r1 = [ORFactory floatRange:mdl low:0.2f up:0.4f];
       id<ORFloatVar> x = [ORFactory floatVar:mdl name:@"x"];
       id<ORFloatVar> y = [ORFactory floatVar:mdl low:1.3f up:3.4f name:@"y"];
       id<ORFloatVar> o = [ORFactory floatVar:mdl name:@"o"];
       id<ORFloatVar> k = [ORFactory floatVar:mdl low:2.0f up:3.0f name:@"o"];
       id<ORFloatVar> w = [ORFactory floatVar:mdl name:@"w"];
       id<ORFloatVar> u = [ORFactory floatVar:mdl name:@"u"];
       id<ORFloatVar> z = [ORFactory floatVar:mdl name:@"z"];
       
       [mdl add:[x set: @(11.34f)]];
       [mdl add:[o set: @(2.43f)]];
       //[mdl add:[w set: @(0.9f)]];
       [mdl add:[w set: [x plus :y]]];
       [mdl add:[u set: [o plus: k]]];
       [mdl add:[z set: [w sub: u]]];
       //[mdl add:[z set: @(5.0e-1)]];
       //[mdl add:[z set: [x plus:[y plus: w]]]];
       //[mdl add:[y set: @(4.0f)]];
       //[mdl add:[w set: @(1.11f)]];
       //[mdl add:[z set:[[x plus: y] sub: [x div: y]]]];

      //[mdl add:[z set:[[x mul: x] sub: x]]];
      //[mdl add:[z geq:@(0.0f)]];
      //(if (>= (- (* x x) x) 0)
      // 8./3 - 5./3 - 1
      //[mdl add:[x set: @(3.0f)]];
      //[mdl add:[z set: [[[@(7.0f) div: x] sub: [@(4.0f) div: x]] sub: @(1.0f)]]];
       
       NSLog(@"model: %@",mdl);
       //id<CPProgram> cp = [args makeProgram:mdl];
       id<CPProgram> cp = [ORFactory createCPProgram:mdl];
       id<ORFloatVarArray> vs = [mdl floatVars];
       id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]]; 
       
       //[cp setMinError:z minError:7.45e-9f];
       [cp setMinErrorFD:y minErrorF:0.0f];
       [cp setMaxErrorFD:y maxErrorF:0.0f];
       [cp setMinErrorFD:k minErrorF:0.0f];
       [cp setMaxErrorFD:k maxErrorF:0.0f];
       //[cp setMinErrorFD:x minErrorF:0.0f];
       //[cp setMaxErrorFD:x maxErrorF:0.0f];
       //[cp setMinErrorFD:z minErrorF:0.0f];
       //[cp setMaxErrorFD:z maxErrorF:0.0f];
       [cp solve:^{
            [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
               [cp floatSplit:i call:s withVars:x];
            }];
            NSLog(@"%@",cp);
            //NSLog(@"%@ (%s)",[cp concretize:x],[cp bound:x] ? "YES" : "NO");
            /* format of 8.8e to have the same value displayed as in FLUCTUAT */
            /* Use printRational(ORRational r) to print a rational inside the solver */
            /*NSLog(@"x : [%8.8e;%8.8e] (%s)",[cp minF:x],[cp maxF:x],[cp bound:x] ? "YES" : "NO");
            NSLog(@"ex: [%8.8e;%8.8e]",[cp minError:x],[cp maxError:x]);
            NSLog(@"y : [%8.8e;%8.8e] (%s)",[cp minF:y],[cp maxF:y],[cp bound:y] ? "YES" : "NO");
            NSLog(@"ey: [%8.8e;%8.8e]",[cp minError:y],[cp maxError:y]);
            NSLog(@"w : [%8.8e;%8.8e] (%s)",[cp minF:w],[cp maxF:w],[cp bound:w] ? "YES" : "NO");
            NSLog(@"ew: [%8.8e;%8.8e]",[cp minError:w],[cp maxError:w]);
           //NSLog(@"u : [%8.8e;%8.8e] (%s)",[cp minF:u],[cp maxF:u],[cp bound:u] ? "YES" : "NO");
           //NSLog(@"eu: [%8.8e;%8.8e]",[cp minError:u],[cp maxError:u]);
            NSLog(@"z : [%8.8e;%8.8e] (%s)",[cp minF:z],[cp maxF:z],[cp bound:z] ? "YES" : "NO");
            NSLog(@"ez: [%8.8e;%8.8e]",[cp minError:z],[cp maxError:z]);*/
          printFvar("x", x);
          printFvar("y", y);
          printFvar("o", o);
          printFvar("k", k);
          printFvar("w", w);
          printFvar("u", u);
          printFvar("z", z);

        }];
         //struct ORResult r = REPORT(0, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         //return r;
      //}];
      
   }
   return 0;
}
