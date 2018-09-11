//
//  main.m
//  testFloat
//
//  Created by Remy on 01/12/2017.
//
//

#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

#define printFvar(name, var) NSLog(@""name" : [%20.20e, %20.20e]f (%s)",[(id<CPFloatVar>)[cp concretize:var] min],[(id<CPFloatVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [%20.20e, %20.20e]q",[(id<CPFloatVar>)[cp concretize:var] minErrF],[(id<CPFloatVar>)[cp concretize:var] maxErrF]);
#define getFmin(var) [(id<CPFloatVar>)[cp concretize:var] min]
#define getFminErr(var) *[(id<CPFloatVar>)[cp concretize:var] minErr]

#define printDvar(name, var) NSLog(@""name" : [% 24.24e, % 24.24e]d (%s)",[(id<CPDoubleVar>)[cp concretize:var] min],[(id<CPDoubleVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 24.24e, % 24.24e]q",[(id<CPDoubleVar>)[cp concretize:var] minErrF],[(id<CPDoubleVar>)[cp concretize:var] maxErrF]);
#define getDmin(var) [(id<CPDoubleVar>)[cp concretize:var] min]
#define getDminErr(var) *[(id<CPDoubleVar>)[cp concretize:var] minErr]

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      ORRational * zero = [[[ORRational alloc] init] setZero];
      id<ORFloatVar> x = [ORFactory floatVar:mdl name:@"x"];
      id<ORFloatVar> y = [ORFactory floatVar:mdl low:1.3f up:3.4f elow:zero eup:zero name:@"y"];
      id<ORFloatVar> o = [ORFactory floatVar:mdl name:@"o"];
      id<ORFloatVar> k = [ORFactory floatVar:mdl low:2.0f up:3.0f elow:zero eup:zero name:@"k"];
      id<ORFloatVar> w = [ORFactory floatVar:mdl name:@"w"];
      //id<ORRationalVar> ew = [ORFactory errorVar:mdl of:w name:@"ew"];
      id<ORFloatVar> u = [ORFactory floatVar:mdl name:@"u"];
      id<ORFloatVar> z = [ORFactory floatVar:mdl name:@"z"];
      [zero release];

      [mdl add:[x set: @(11.34f)]];
      [mdl add:[o set: @(2.43f)]];
      [mdl add:[[x error] leq: [z error]]];
      
      //[mdl add:[[[x channel] plus: [x error]] geq: [z error]]];

      [mdl add:[w set: [x plus: y]]];
      [mdl add:[u set: [o plus: k]]];
      [mdl add:[z set: [w sub: u]]];
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<ORFloatVarArray> vs = [mdl floatVars];
      id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
        [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
            [cp floatSplit:i call:s withVars:x];
         }];
         NSLog(@"x : [%16.16e;%16.16e] (%s)",[cp minF:x],[cp maxF:x],[cp bound:x] ? "YES" : "NO");
         NSLog(@"ex: [%@;%@]",[cp minFQ:x],[cp maxFQ:x]);
         NSLog(@"y : [%16.16e;%16.16e] (%s)",[cp minF:y],[cp maxF:y],[cp bound:y] ? "YES" : "NO");
         NSLog(@"ey: [%@;%@]",[cp minFQ:y],[cp maxFQ:y]);
         NSLog(@"o : [%8.8e;%8.8e] (%s)",[cp minF:o],[cp maxF:o],[cp bound:o] ? "YES" : "NO");
         NSLog(@"eo: [%@;%@]",[cp minFQ:o],[cp maxFQ:o]);
         NSLog(@"k : [%8.8e;%8.8e] (%s)",[cp minF:k],[cp maxF:k],[cp bound:k] ? "YES" : "NO");
         NSLog(@"ek: [%@;%@]",[cp minFQ:k],[cp maxFQ:k]);
         NSLog(@"w : [%16.16e;%16.16e] (%s)",[cp minF:w],[cp maxF:w],[cp bound:w] ? "YES" : "NO");
         NSLog(@"ew: [%@;%@]",[cp minFQ:w],[cp maxFQ:w]);
         NSLog(@"u : [%8.8e;%8.8e] (%s)",[cp minF:u],[cp maxF:u],[cp bound:u] ? "YES" : "NO");
         NSLog(@"eu: [%@;%@]",[cp minFQ:u],[cp maxFQ:u]);
         NSLog(@"z : [%8.8e;%8.8e] (%s)",[cp minF:z],[cp maxF:z],[cp bound:z] ? "YES" : "NO");
         NSLog(@"ez: [%@;%@]",[cp minFQ:z],[cp  maxFQ:z]);
        }];
        NSLog(@"%@",cp);
      //struct ORResult r = REPORT(0, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
      //return r;
   //}];
   }
   return 0;
}
