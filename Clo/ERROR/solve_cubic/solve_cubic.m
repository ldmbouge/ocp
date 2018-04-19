//
//  solve_cubic.m
//  ORUtilities
//
//  Created by Remy Garcia on 19/04/2018.
//

#import <ORProgram/ORProgram.h>

#define printFvar(name, var) NSLog(@""name" : [% 20.20e, % 20.20e]f (%s)",[(id<CPFloatVar>)[cp concretize:var] min],[(id<CPFloatVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 20.20e, % 20.20e]q",[(id<CPFloatVar>)[cp concretize:var] minErrF],[(id<CPFloatVar>)[cp concretize:var] maxErrF]);
#define getFmin(var) [(id<CPFloatVar>)[cp concretize:var] min]
#define getFminErr(var) *[(id<CPFloatVar>)[cp concretize:var] minErr]

#define printDvar(name, var) NSLog(@""name" : [% 24.24e, % 24.24e]d (%s)",[(id<CPDoubleVar>)[cp concretize:var] min],[(id<CPDoubleVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 24.24e, % 24.24e]q",[(id<CPDoubleVar>)[cp concretize:var] minErrF],[(id<CPDoubleVar>)[cp concretize:var] maxErrF]);
#define getDmin(var) [(id<CPDoubleVar>)[cp concretize:var] min]
#define getDminErr(var) *[(id<CPDoubleVar>)[cp concretize:var] minErr]

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORDoubleVar> a = [ORFactory doubleVar:mdl low:-145.0 up:-142.0 name:@"a"];
      id<ORDoubleVar> b = [ORFactory doubleVar:mdl low:5085.0 up:5089.0 name:@"b"];
      id<ORDoubleVar> c = [ORFactory doubleVar:mdl low:-50068.0 up:-50063.0 name:@"c"];
      
      id<ORDoubleVar> q = [ORFactory doubleVar:mdl name:@"q"];
      id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
      id<ORDoubleVar> Q = [ORFactory doubleVar:mdl name:@"Q"];
      id<ORDoubleVar> R = [ORFactory doubleVar:mdl name:@"R"];
      id<ORDoubleVar> Q3 = [ORFactory doubleVar:mdl name:@"Q3"];
      id<ORDoubleVar> R2 = [ORFactory doubleVar:mdl name:@"R2"];
      id<ORDoubleVar> CR2 = [ORFactory doubleVar:mdl name:@"CR2"];
      id<ORDoubleVar> CQ3 = [ORFactory doubleVar:mdl name:@"CQ3"];

      /*[mdl add:[a set:@(-143.0)]];
      [mdl add:[b set:@(5087.0)]];
      [mdl add:[c set:@(-50065.0)]];*/
      [mdl add:[q set: [[a mul: a] sub: [@(3.0) mul: b]]]];
      [mdl add:[r set: [[[[[@(2.0f) mul: a] mul: a] mul: a] sub: [[@(9.0) mul: a] mul: b]] plus: [@(27.0) mul: c]]]];
      
      [mdl add:[Q set: [q div: @(9.0)]]];
      [mdl add:[R set: [r div: @(54.0)]]];
      
      [mdl add:[Q3 set: [[Q mul: Q] mul: Q]]];
      [mdl add:[R2 set: [R mul: R]]];
      
      [mdl add:[CR2 set: [[@(729.0) mul: r] mul: r]]];
      [mdl add:[CQ3 set: [[[@(2916.0) mul: q] mul: q] mul: q]]];
      
      //[mdl add:[R eq:@(0.0)]];
      //[mdl add:[Q eq:@(0.0)]];
      
      //[mdl add:[CR2 eq:CQ3]];
      
      
      [mdl add:[R2 lt:Q3]];
      
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<ORDoubleVarArray> vs = [mdl doubleVars];
      id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp setMinErrorFD:a minErrorF:0.0f];
      [cp setMaxErrorFD:a maxErrorF:0.0f];
      [cp setMinErrorFD:b minErrorF:0.0f];
      [cp setMaxErrorFD:b maxErrorF:0.0f];
      [cp setMinErrorFD:c minErrorF:0.0f];
      [cp setMaxErrorFD:c maxErrorF:0.0f];
      
      //[cp setMinErrorFD:R2 minErrorF:0.0f];
      //
      [cp setMaxErrorFD:R2 maxErrorF:0.0f];
      
      //[cp setMinErrorFD:Q minErrorF:0.0f];
      //[cp setMaxErrorFD:Q maxErrorF:0.0f];

      [cp solve:^{
         [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
            [cp floatSplit:i call:s withVars:x];
         }];
         NSLog(@"%@",cp);
         printDvar("a", a);
         printDvar("b", b);
         printDvar("c", c);
         
         printDvar("q", q);
         printDvar("r", r);
         
         printDvar("Q", Q);
         printDvar("R", R);
         
         printDvar("Q3", Q3);
         printDvar("R2", R2);
      
         printDvar("CR2", CR2);
         printDvar("CQ3", CQ3);
         
      }];
      //struct ORResult r = REPORT(0, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
      //return r;
      //}];
      
   }
   return 0;
}
