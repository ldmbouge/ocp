//
//  doppler1.m
//  Clo
//
//  Created by Remy Garcia on 16/03/2018.
//
#import <ORProgram/ORProgram.h>

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORFloatRange> r0 = [ORFactory floatRange:mdl low:-100.0f up:100.0f];
      id<ORFloatRange> r1 = [ORFactory floatRange:mdl low:20.0f up:20000.0f];
      id<ORFloatRange> r2 = [ORFactory floatRange:mdl low:-30.0f up:50.0f];
      id<ORFloatVar> u = [ORFactory floatVar:mdl domain:r0];
      id<ORFloatVar> v = [ORFactory floatVar:mdl domain:r1];
      id<ORFloatVar> t = [ORFactory floatVar:mdl domain:r2];
      id<ORFloatVar> t1 = [ORFactory floatVar:mdl];
      id<ORFloatVar> z = [ORFactory floatVar:mdl];
      
      [mdl add:[t1 set: [@(331.4f) plus:[@(0.6f) mul: t]]]];
      [mdl add:[z set: [[[@(0.0f) sub: t1] mul: v] div: [[t1 plus: u] mul: [t1 plus: u]]]]];
      
      NSLog(@"model: %@",mdl);
      id<CPProgram> p = [ORFactory createCPProgram:mdl];
      
      [p solve:^{
         NSLog(@"%@",p);
         //NSLog(@"%@ (%s)",[p concretize:x],[p bound:x] ? "YES" : "NO");
         /* format of 8.8e to have the same value displayed as in FLUCTUAT */
         /* Use printRational(ORRational r) to print a rational inside the solver */
         NSLog(@"u : [%8.8e;%8.8e] (%s)",[p minF:u],[p maxF:u],[p bound:u] ? "YES" : "NO");
         NSLog(@"eu: [%8.8e;%8.8e]",[p minError:u],[p maxError:u]);
         NSLog(@"v : [%8.8e;%8.8e] (%s)",[p minF:v],[p maxF:v],[p bound:v] ? "YES" : "NO");
         NSLog(@"ev: [%8.8e;%8.8e]",[p minError:t],[p maxError:t]);
         NSLog(@"t : [%8.8e;%8.8e] (%s)",[p minF:t],[p maxF:t],[p bound:t] ? "YES" : "NO");
         NSLog(@"et: [%8.8e;%8.8e]",[p minError:t],[p maxError:t]);
         NSLog(@"t1 : [%8.8e;%8.8e] (%s)",[p minF:t1],[p maxF:t1],[p bound:z] ? "YES" : "NO");
         NSLog(@"et1: [%8.8e;%8.8e]",[p minError:t1],[p maxError:t1]);
         NSLog(@"z : [%8.8e;%8.8e] (%s)",[p minF:z],[p maxF:z],[p bound:z] ? "YES" : "NO");
         NSLog(@"ez: [%8.8e;%8.8e]",[p minError:z],[p maxError:z]);
      }];
   }
   return 0;
}


