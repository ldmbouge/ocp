//
//  solve_cubic.m
//  ORUtilities
//
//  Created by Remy Garcia on 19/04/2018.
//

#import <ORProgram/ORProgram.h>
#include <signal.h>
#include <stdlib.h>
#include <time.h>

void solve_cubic(int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORRational> tmp = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> a = [ORFactory doubleInputVar:mdl low:14.0 up:16.0  name:@"a"];
      id<ORDoubleVar> b = [ORFactory doubleInputVar:mdl low:-200.0 up:200.0  name:@"b"];
      id<ORDoubleVar> c = [ORFactory doubleInputVar:mdl low:-200.0 up:200.0  name:@"c"];
      id<ORDoubleVar> q = [ORFactory doubleVar:mdl name:@"q"];
      id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
      id<ORDoubleVar> Q = [ORFactory doubleVar:mdl name:@"Q"];
      id<ORDoubleVar> R = [ORFactory doubleVar:mdl name:@"R"];
      id<ORRationalVar> eQ = [ORFactory errorVar:mdl of:Q];
      id<ORRationalVar> eR = [ORFactory errorVar:mdl of:R];
      id<ORRationalVar> eQAbs = [ORFactory rationalVar:mdl name:@"eQAbs"];
//      id<ORRationalVar> eRAbs = [ORFactory rationalVar:mdl name:@"eRAbs"];
      //[zero release];
      
      /* Exact
       [mdl add:[a set:@(15.0)]];
      [mdl add:[b set:@(75.0)]];
      [mdl add:[c set:@(125.0)]];
       */
   
      /* Error
       [mdl add:[a set:@(1.5000039999893333586555854708421975374221801757812500000000000000000000000000000000000000000000000000e+01)];
       [mdl add:[b set:@(7.5000399999466665690306399483233690261840820312500000000000000000000000000000000000000000000000000000e+01)]];
       [mdl add:[c set:@(1.2500100000000000477484718430787324905395507812500000000000000000000000000000000000000000000000000000e+02)]];
       
       id<ORDoubleVar> a = [ORFactory doubleVar:mdl low:14.0 up:16.0 elow:zero eup:zero name:@"a"];
       id<ORDoubleVar> b = [ORFactory doubleVar:mdl low:74.9 up:75.1 elow:zero eup:zero name:@"b"];
       id<ORDoubleVar> c = [ORFactory doubleVar:mdl low:124.9 up:125.001 elow:zero eup:zero name:@"c"];
       */
      [mdl add:[q set: [[a mul: a] sub: [@(3.0) mul: b]]]];
      [mdl add:[r set: [[[[[@(2.0) mul: a] mul: a] mul: a] sub: [[@(9.0) mul: a] mul: b]] plus: [@(27.0) mul: c]]]];
            
      
      [mdl add:[Q set: [q div: @(9.0)]]];
      [mdl add:[R set: [r div: @(54.0)]]];

      [mdl add:[R eq:@(0.0)]];
      [mdl add:[Q eq:@(0.0)]];
      
//      [mdl add: [eR eq: zero]];
//      [mdl add: [eQ eq: zero]];
      
//      2021-02-23 16:24:06.956632+0100 solve_cubic_error[91696:6087427] a : [1.60000000000000000000e+01;1.60000000000000000000e+01] (YES)
//      2021-02-23 16:24:06.956746+0100 solve_cubic_error[91696:6087427] ea: [+0.00000000000000000000e+00;+0.00000000000000000000e+00]
//      2021-02-23 16:24:06.956842+0100 solve_cubic_error[91696:6087427] b : [8.53333333333333428072e+01;8.53333333333333428072e+01] (YES)
//      2021-02-23 16:24:06.956922+0100 solve_cubic_error[91696:6087427] eb: [+0.00000000000000000000e+00;+0.00000000000000000000e+00]
//      2021-02-23 16:24:06.956948+0100 solve_cubic_error[91696:6087427] c : [1.51703703703703780548e+02;1.51703703703703780548e+02] (YES)
//      2021-02-23 16:24:06.956993+0100 solve_cubic_error[91696:6087427] ec: [+0.00000000000000000000e+00;+0.00000000000000000000e+00]
//      2021-02-23 16:24:06.957049+0100 solve_cubic_error[91696:6087427] Q : [0.00000000000000000000e+00;0.00000000000000000000e+00] (YES)
//      2021-02-23 16:24:06.957158+0100 solve_cubic_error[91696:6087427] eQ: [-3.15796771448933398412e-15;-3.15796771448933398412e-15]
//      2021-02-23 16:24:06.957219+0100 solve_cubic_error[91696:6087427] R : [0.00000000000000000000e+00;0.00000000000000000000e+00] (YES)
//      2021-02-23 16:24:06.957269+0100 solve_cubic_error[91696:6087427] eR: [+1.31581988103722241450e-14;+1.31581988103722241450e-14]

      
//
      
//      [zero set_d:3.15796771448933398412e-15];
//      [mdl add: [eQAbs eq:[eQ abs]]];
//      [mdl add:[eQAbs geq:zero]];
      
      //[mdl maximize:eQAbs];
      
      //[mdl add:[[R error] geq:tmp]];
      //[mdl add:[[Q error] geq:tmp]];
      
      [tmp release];
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      //id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBBController proto]];
      id<ORDoubleVarArray> vs = [mdl doubleVars];
      id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
         [cp lexicalOrderedSearch:vars do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [cp floatSplit:i withVars:x];
         }];
//         [cp branchAndBoundSearchD:vars out:eQAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
//            [cp floatSplit:i withVars:x];
//         }];
         NSLog(@"%@",cp);
         NSLog(@"a : [%20.20e;%20.20e] (%s)",[cp minD:a],[cp maxD:a],[cp bound:a] ? "YES" : "NO");
         NSLog(@"ea: [%@;%@]",[cp minDQ:a],[cp  maxDQ:a]);
         NSLog(@"b : [%20.20e;%20.20e] (%s)",[cp minD:b],[cp maxD:b],[cp bound:b] ? "YES" : "NO");
         NSLog(@"eb: [%@;%@]",[cp minDQ:b],[cp  maxDQ:b]);
         NSLog(@"c : [%20.20e;%20.20e] (%s)",[cp minD:c],[cp maxD:c],[cp bound:c] ? "YES" : "NO");
         NSLog(@"ec: [%@;%@]",[cp minDQ:c],[cp  maxDQ:c]);
         NSLog(@"Q : [%20.20e;%20.20e] (%s)",[cp minD:Q],[cp maxD:Q],[cp bound:Q] ? "YES" : "NO");
         NSLog(@"eQ: [%@;%@]",[cp minDQ:Q],[cp  maxDQ:Q]);
         NSLog(@"R : [%20.20e;%20.20e] (%s)",[cp minD:R],[cp maxD:R],[cp bound:R] ? "YES" : "NO");
         NSLog(@"eR: [%@;%@]",[cp minDQ:R],[cp  maxDQ:R]);
      }];
   }
}

void exitfunc(int sig)
{
   exit(sig);
}

int main(int argc, const char * argv[]) {
   sranddev();
   //signal(SIGKILL, exitfunc);
   //alarm(60);
   //   LOO_MEASURE_TIME(@"rigidbody2"){
   solve_cubic(argc, argv);
   //sqroot_f(1, argc, argv);
   //}
   return 0;
}
