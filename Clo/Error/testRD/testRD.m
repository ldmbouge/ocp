//
//  testRD.m
//  Clo
//
//  Created by Remy Garcia on 16/04/2018.
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
      id<ORModel> mdl = [ORFactory createModel];
      //id<ORDoubleRange> r0 = [ORFactory doubleRange:mdl low:0.100001f up:0.399434344f];
      //id<ORDoubleRange> r1 = [ORFactory doubleRange:mdl low:0.2f up:0.4f];
      id<ORDoubleVar> x = [ORFactory doubleVar:mdl name:@"x"];
      /* Error with low:0.0 up:400.0 on assert(mid != NAN && mid <= xi.max && mid >= xi.min) */
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> y = [ORFactory doubleVar:mdl low:1.3 up:3.4 elow:zero eup:zero name:@"y"];
      id<ORDoubleVar> o = [ORFactory doubleVar:mdl name:@"o"];
      id<ORDoubleVar> k = [ORFactory doubleVar:mdl low:4.0 up:6.0 elow:zero eup:zero name:@"o"];
      id<ORDoubleVar> w = [ORFactory doubleVar:mdl name:@"w"];
      id<ORDoubleVar> u = [ORFactory doubleVar:mdl name:@"u"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      [zero release];
      
      [mdl add:[x set: @(11.34)]];
      [mdl add:[o set: @(2.43)]];
      //[mdl add:[w set: @(0.9f)]];
      [mdl add:[w set: [x plus :y]]];
      [mdl add:[u set: [o plus: k]]];
      [mdl add:[z set: [w sub: u]]];
      //[mdl add:[z set: @(5.0e-1)]];
      //[mdl add:[z set: [x plus:[y plus: w]]]];
      //[mdl add:[y set: @(4.0f)]];
      //[mdl add:[w set: @(1.11f)]];
      //[mdl add:[z set:[[x plus: y] sub: [x div: y]]]];
      
      
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<ORDoubleVarArray> vs = [mdl doubleVars];
      id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
         [cp lexicalOrderedSearch:vars do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [cp floatSplit:i withVars:x];
         }];
         NSLog(@"%@",cp);
         printDvar("x", x);
         printDvar("y", y);
         printDvar("o", o);
         printDvar("w", w);
         printDvar("u", u);
         printDvar("z", z);
         
      }];
      //struct ORResult r = REPORT(0, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
      //return r;
      //}];
      
   }
   return 0;
}
