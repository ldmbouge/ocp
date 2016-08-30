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
        id<ORFloatVar> y = [ORFactory floatVar:mdl domain:r0];
        id<ORFloatVar> z = [ORFactory floatVar:mdl domain:r0];
        id<ORFloatVar> r = [ORFactory floatVar:mdl domain:r0];
        
        [mdl add:[x eq: @(1e7f)]];
        //[mdl add:[y eq: @(10.0f)]];
        [mdl add:[y eq: [x plus:@(1.f)]]];
        [mdl add:[z eq: [x sub:@(1.f)]]];
        [mdl add:[r eq: [y sub:z]]];
         [mdl add:[r neq: @(2.f)]];
        //[mdl add:[z eq: [x div:y]]];
       // [mdl add:[x3 eq:[[[x0 mul:@(2.0f)] plus: [x1 mul:@(3.0f)]] plus:[x2 mul:@(4.0f)]]]];
        
        NSLog(@"model: %@",mdl);
        id<CPProgram> p = [ORFactory createCPProgram:mdl];
        [p solve:^{
            NSLog(@"helloword %@ !",p);
            NSLog(@"x : %f (%s)",[p floatValue:x],[p bound:x] ? "YES" : "NO");
            NSLog(@"y : %f (%s)",[p floatValue:y],[p bound:y] ? "YES" : "NO");
          //  id zc = [p concretize:z];
          //  NSLog(@"cz : %@",zc);
            NSLog(@"z : %f (%s)",[p floatValue:z],[p bound:z] ? "YES" : "NO");
            NSLog(@"r : %f (%s)",[p floatValue:r],[p bound:r] ? "YES" : "NO");//*/
        }];
    }
    return 0;
}
