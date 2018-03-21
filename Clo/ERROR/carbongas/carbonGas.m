//
//  carbonGas.m
//
//  Created by Remy Garcia on 06/03/2018.
//
#import <ORProgram/ORProgram.h>

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORFloatVar> p = [ORFactory floatVar:mdl];
      id<ORFloatVar> a = [ORFactory floatVar:mdl];
      id<ORFloatVar> b = [ORFactory floatVar:mdl];
      id<ORFloatVar> t = [ORFactory floatVar:mdl];
      id<ORFloatVar> n = [ORFactory floatVar:mdl];
      id<ORFloatVar> k = [ORFactory floatVar:mdl];
      id<ORFloatVar> v = [ORFactory floatVar:mdl  low:0.1f up:0.5f];
      id<ORFloatVar> r = [ORFactory floatVar:mdl];
      
      [mdl add:[p set: @(35000000.0f)]];
      [mdl add:[a set: @(0.401f)]];
      [mdl add:[b set: @(4.27e-05f)]];
      [mdl add:[t set: @(300.0f)]];
      [mdl add:[n set: @(1000.0f)]];
      [mdl add:[k set: @(1.3806503e-23f)]];

      [mdl add:[r set: [[[p plus: [[a mul: [n div: v]] mul: [n div: v]]] mul: [v sub: [n mul: b]]] sub: [[k mul: n] mul: t]]]];
      //[mdl add:[r set:[n div: v]]];
      
      
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      
      [cp solve:^{
         NSLog(@"%@",cp);
         /* format of 8.8e to have the same value displayed as in FLUCTUAT */
         /* Use printRational(ORRational r) to print a rational inside the solver */
         NSLog(@"p : [%8.8e,%8.8e] (%s)",[cp minF:p],[cp maxF:p],[cp bound:p] ? "YES" : "NO");
         NSLog(@"ep: [%8.8e,%8.8e]",[cp minError:p],[cp maxError:p]);
         NSLog(@"a : [%8.8e,%8.8e] (%s)",[cp minF:a],[cp maxF:a],[cp bound:a] ? "YES" : "NO");
         NSLog(@"ea: [%8.8e,%8.8e]",[cp minError:a],[cp maxError:a]);
         NSLog(@"b : [%8.8e,%8.8e] (%s)",[cp minF:b],[cp maxF:b],[cp bound:b] ? "YES" : "NO");
         NSLog(@"eb: [%8.8e,%8.8e]",[cp minError:b],[cp maxError:b]);
         NSLog(@"t : [%8.8e,%8.8e] (%s)",[cp minF:t],[cp maxF:t],[cp bound:t] ? "YES" : "NO");
         NSLog(@"et: [%8.8e,%8.8e]",[cp minError:t],[cp maxError:t]);
         NSLog(@"n : [%8.8e,%8.8e] (%s)",[cp minF:n],[cp maxF:n],[cp bound:n] ? "YES" : "NO");
         NSLog(@"en: [%8.8e,%8.8e]",[cp minError:n],[cp maxError:n]);
         NSLog(@"k : [%8.8e,%8.8e] (%s)",[cp minF:k],[cp maxF:k],[cp bound:k] ? "YES" : "NO");
         NSLog(@"ek: [%8.8e,%8.8e]",[cp minError:k],[cp maxError:k]);
         NSLog(@"v : [%8.8e,%8.8e] (%s)",[cp minF:v],[cp maxF:v],[cp bound:v] ? "YES" : "NO");
         NSLog(@"ev: [%8.8e,%8.8e]",[cp minError:v],[cp maxError:v]);
         NSLog(@"r : [%8.8e,%8.8e] (%s)",[cp minF:r],[cp maxF:r],[cp bound:r] ? "YES" : "NO");
         NSLog(@"er: [%8.8e,%8.8e]",[cp minError:r],[cp maxError:r]);
      }];
   }
   return 0;
}
