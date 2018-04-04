//
//  main.m
//  testFloat
//
//  Created by Zitoun on 19/07/2016.
//
//

#import <ORProgram/ORProgram.h>

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORFloatRange> r0 = [ORFactory floatRange:mdl low:-1e8f up:1e8f];
      id<ORFloatVar> x = [ORFactory floatVar:mdl domain:r0];
//      id<ORFloatVar> y = [ORFactory floatVar:mdl domain:r0];
//      id<ORFloatVar> z = [ORFactory floatVar:mdl domain:r0];
//      id<ORFloatVar> r = [ORFactory floatVar:mdl domain:r0];
      
//      [mdl add:[x eq:@(1.e7f)]];
//      [mdl add:[y eq: [x plus:@(1.f)]]];
//      [mdl add:[z eq: [x sub:@(1.f)]]];
//      [mdl add:[r eq: [y sub:z]]];
      [mdl add:[x set:@(0.0f)]];
//      [mdl add:[y set:@(0.0f)]];
//      [mdl add:[r set:@(-0.f)]];
//      [mdl add:[r set:[x mul:y]]];
      
      NSLog(@"model: %@",mdl);
//      [mdl floatVars];
      id<CPProgram> p = [ORFactory createCPProgram:mdl];
      [p solve:^{
         NSLog(@"helloword %@ !",p);
         NSLog(@"x : %16.16e (%s)",[p floatValue:x],[p bound:x] ? "YES" : "NO");
//         NSLog(@"y : %16.16e (%s)",[p floatValue:y],[p bound:y] ? "YES" : "NO");
//         NSLog(@"z : %16.16e (%s)",[p floatValue:z],[p bound:z] ? "YES" : "NO");
//       NSLog(@"r : %16.16e (%s)",[p floatValue:r],[p bound:r] ? "YES" : "NO");//*/
      }];
   }
   return 0;
}
