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
      id<ORRationalVar> x = [ORFactory rationalVar:mdl low:low up:up name:@"x"];
      id<ORRationalVar> y = [ORFactory rationalVar:mdl low:low_y up:up name:@"y"];
      id<ORRationalVar> z = [ORFactory rationalVar:mdl name:@"z"];
      
      ////[mdl add:[x set: @(11.34)]];
      //[mdl add:[x eq: y]];
      [mdl add:[z eq: [x plus: y]]];
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      [cp solveAll:^{
         [cp labelRational:x];
         NSLog(@"x : [%@;%@] (%s)",[cp minQ:x],[cp maxQ:x],[cp bound:x] ? "YES" : "NO");
         NSLog(@"y : [%@;%@] (%s)",[cp minQ:y],[cp maxQ:y],[cp bound:y] ? "YES" : "NO");
         NSLog(@"z : [%@;%@] (%s)",[cp minQ:z],[cp maxQ:z],[cp bound:z] ? "YES" : "NO");
      }];
      NSLog(@"%@",cp);
   }
   return 0;
}
