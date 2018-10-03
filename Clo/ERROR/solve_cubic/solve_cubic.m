//
//  solve_cubic.m
//  ORUtilities
//
//  Created by Remy Garcia on 19/04/2018.
//

#import <ORProgram/ORProgram.h>

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> a = [ORFactory doubleVar:mdl low:14.0 up:16.0 elow:zero eup:zero name:@"a"];
      id<ORDoubleVar> b = [ORFactory doubleVar:mdl low:-200.0 up:200.0 elow:zero eup:zero name:@"b"];
      id<ORDoubleVar> c = [ORFactory doubleVar:mdl low:-200.0 up:200.0 elow:zero eup:zero name:@"c"];
      id<ORDoubleVar> q = [ORFactory doubleVar:mdl name:@"q"];
      id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
      id<ORDoubleVar> Q = [ORFactory doubleVar:mdl low:-INFINITY up:INFINITY elow:zero eup:zero name:@"Q"];
      id<ORDoubleVar> R = [ORFactory doubleVar:mdl low:-INFINITY up:INFINITY elow:zero eup:zero name:@"R"];
      [zero release];
      
      //id<ORDoubleVar> Q3 = [ORFactory doubleVar:mdl name:@"Q3"];
      //id<ORDoubleVar> R2 = [ORFactory doubleVar:mdl name:@"R2"];
      //id<ORDoubleVar> CR2 = [ORFactory doubleVar:mdl name:@"CR2"];
      //id<ORDoubleVar> CQ3 = [ORFactory doubleVar:mdl name:@"CQ3"];
      
      /*[mdl add:[a set:@(1.500000000000006217248938e+01)]];
       [mdl add:[b set:@(7.500000000000062527760747e+01)]];
       [mdl add:[c set:@(1.250000000000015916157281e+02)]];*/
      
      //[mdl add:[a lt:@(15.1)]];
      //[mdl add:[c gt:@(125.25)]];
      //[mdl add:[a lt:@(15.1)]];
      
      [mdl add:[a set:@(15.0)]];
      /*[mdl add:[b set:@(75.0)]];
      [mdl add:[c set:@(125.0)]];*/
      
      /*[mdl add:[b set:@(5087.0)]];
       [mdl add:[c set:@(-50065.0)]];*/
      
      [mdl add:[q set: [[a mul: a] sub: [@(3.0) mul: b]]]];
      [mdl add:[r set: [[[[[@(2.0) mul: a] mul: a] mul: a] sub: [[@(9.0) mul: a] mul: b]] plus: [@(27.0) mul: c]]]];
      
      
      [mdl add:[Q set: [q div: @(9.0)]]];
      [mdl add:[R set: [r div: @(54.0)]]];
      
      
      //[mdl add:[Q3 set: [[Q mul: Q] mul: Q]]];
      //[mdl add:[R2 set: [R mul: R]]];
      
      
      //[mdl add:[CR2 set: [[@(729.0) mul: r] mul: r]]];
      //[mdl add:[CQ3 set: [[[@(2916.0) mul: q] mul: q] mul: q]]];
      
      //[mdl add:[a lt:@(15.6)]];
      
      [mdl add:[R eq:@(0.0)]];
      [mdl add:[Q eq:@(0.0)]];
      
      
      //[mdl add:[CR2 eq:CQ3]];
      
      
      
      
      //[mdl add:[R2 lt:Q3]];
      
      
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<ORDoubleVarArray> vs = [mdl doubleVars];
      id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      /*[cp setMinErrorDD:R minErrorF:0.0];
      [cp setMaxErrorDD:R maxErrorF:0.0];
      [cp setMinErrorDD:Q minErrorF:0.0];
      [cp setMaxErrorDD:Q maxErrorF:0.0];*/
      
      [cp solve:^{
         [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
            [cp floatSplitD:i call:s withVars:x];
         }];
         NSLog(@"%@",cp);
         NSLog(@"a : [%16.16e;%16.16e] (%s)",[cp minD:a],[cp maxD:a],[cp bound:a] ? "YES" : "NO");
         NSLog(@"ea: [%@;%@]",[cp minDQ:a],[cp  maxDQ:a]);
         NSLog(@"b : [%16.16e;%16.16e] (%s)",[cp minD:b],[cp maxD:b],[cp bound:b] ? "YES" : "NO");
         NSLog(@"eb: [%@;%@]",[cp minDQ:b],[cp  maxDQ:b]);
         NSLog(@"c : [%16.16e;%16.16e] (%s)",[cp minD:c],[cp maxD:c],[cp bound:c] ? "YES" : "NO");
         NSLog(@"ec: [%@;%@]",[cp minDQ:c],[cp  maxDQ:c]);
         NSLog(@"Q : [%16.16e;%16.16e] (%s)",[cp minD:Q],[cp maxD:Q],[cp bound:Q] ? "YES" : "NO");
         NSLog(@"eQ: [%@;%@]",[cp minDQ:Q],[cp  maxDQ:Q]);
         NSLog(@"R : [%16.16e;%16.16e] (%s)",[cp minD:R],[cp maxD:R],[cp bound:R] ? "YES" : "NO");
         NSLog(@"eR: [%@;%@]",[cp minDQ:R],[cp  maxDQ:R]);
      }];
   }
   return 0;
}
