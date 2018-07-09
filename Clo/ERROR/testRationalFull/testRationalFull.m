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
      /*ORRational low;
      ORRational low_y;
      ORRational up;
      rational_init(&low);
      rational_init(&low_y);
      rational_init(&up);
      rational_set_d(&low, 0.1);
      rational_set_d(&low_y, 0.5);
      rational_set_d(&up, 2.5);*/
      id<ORModel> mdl = [ORFactory createModel];
      //id<ORRationalVar> x = [ORFactory rationalVar:mdl low:low up:up name:@"x"];
      //id<ORRationalVar> y = [ORFactory rationalVar:mdl low:low_y up:up name:@"y"];
      id<ORIntRange> r0 = [ORFactory intRange:mdl low:1 up:25];
      id<ORIntRange> r1 = [ORFactory intRange:mdl low:5 up:25];
      id<ORIntVar> x = [ORFactory intVar:mdl domain:r0];
      id<ORIntVar> y = [ORFactory intVar:mdl domain:r1];

      
      //[mdl add:[x set: @(11.34)]];
      [mdl add:[x eq: y]];
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      //id<ORFloatVarArray> vs = [mdl floatVars];
      //id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];

      [cp solve:^{
         /*[cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
            [cp floatSplit:i call:s withVars:x];
         }];*/
         NSLog(@"%@",cp);
         //NSLog(@"%@ (%s)",[cp concretize:x],[cp bound:x] ? "YES" : "NO");
         //NSLog(@"x : [%8.8e;%8.8e] (%s)",[cp minQ:x],[cp maQ:x],[cp bound:x] ? "YES" : "NO");
         NSLog(@"x : [%d;%d] (%s)",[cp min:x],[cp max:x],[cp bound:x] ? "YES" : "NO");
         NSLog(@"y : [%d;%d] (%s)",[cp min:y],[cp max:y],[cp bound:y] ? "YES" : "NO");
      }];
   }
   return 0;
}
