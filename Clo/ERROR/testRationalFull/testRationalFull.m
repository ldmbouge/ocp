//
//  testRationalFull.m
//  Clo
//
//  Created by Rémy Garcia on 05/07/2018.
//
//

#import <ORProgram/ORProgram.h>

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORRational* low = [[ORRational alloc] init];
      ORRational* low_y = [[ORRational alloc] init];
      ORRational* up = [[ORRational alloc] init];
      [low set: 1 and: 8];
      [low_y set: 1 and: 2];
      [up set: 5 and: 2];
      id<ORModel> mdl = [ORFactory createModel];
      id<ORFloatVar> t = [ORFactory floatVar:mdl low:0.2 up:3.0 name:@"t"];
      //id<ORRationalVar> et = [ORFactory errorVar:mdl of:t name:@"et"];
      id<ORRationalVar> x = [ORFactory rationalVar:mdl low:low up:up name:@"x"];
      id<ORRationalVar> y = [ORFactory rationalVar:mdl low:low_y up:up name:@"y"];
      id<ORRationalVar> z = [ORFactory rationalVar:mdl name:@"z"];
      [mdl add:[ORFactory channel:t with:x]];
      ////[mdl add:[x set: @(11.34)]];
      //[mdl add:[x eq: y]];
      [mdl add:[z eq: [x plus: y]]];
      //[mdl add:[et eq: x]];
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      [cp solveAll:^{
         //[cp labelRational:x];
         NSLog(@"x : [%@;%@] (%s)",[cp minQ:x],[cp maxQ:x],[cp bound:x] ? "YES" : "NO");
         NSLog(@"y : [%@;%@] (%s)",[cp minQ:y],[cp maxQ:y],[cp bound:y] ? "YES" : "NO");
         NSLog(@"z : [%@;%@] (%s)",[cp minQ:z],[cp maxQ:z],[cp bound:z] ? "YES" : "NO");
         NSLog(@"t : [%f;%f]±[%@;%@] (%s)",[cp minF:t],[cp maxF:t],[cp minFQ:t],[cp maxFQ:t],[cp bound:t] ? "YES" : "NO");
         //NSLog(@"et: [%@;%@] (%s)",[cp minQ:et],[cp maxQ:et],[cp bound:et] ? "YES" : "NO");
      }];
      NSLog(@"%@",cp);
   }
   return 0;
}
