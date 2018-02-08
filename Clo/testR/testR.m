//
//  main.m
//  testFloat
//
//  Created by Remy on 19/07/2016.
//
//

#import <ORProgram/ORProgram.h>
#import <objcp/CPFloatVarI.h>
//#import "gmp.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        id<ORModel> mdl = [ORFactory createModel];
        //id<ORFloatRange> r0 = [ORFactory floatRange:mdl low:-1e8f up:1e8f];
        id<ORFloatVar> x = [ORFactory floatVar:mdl];
        id<ORFloatVar> y = [ORFactory floatVar:mdl];
        id<ORFloatVar> z = [ORFactory floatVar:mdl];
        //id<ORFloatVar> r = [ORFactory floatVar:mdl domain:r0];
        
        [mdl add:[x eq: @(0.1f)]];
        [mdl add:[y eq: @(0.2f)]];
        [mdl add:[z eq: [x plus:y]]];
        //[mdl add:[r eq: [y sub:z]]];
        
        NSLog(@"model: %@",mdl);
        id<ORFloatVarArray> vars = [mdl floatVars];
        id<CPProgram> p = [ORFactory createCPProgram:mdl];

        [p solve:^{
            [p lexicalOrderedSearch:vars do:^(id<ORFloatVar> b) {
                [p floatSplit:b];
            }];
            NSLog(@"helloword %@ !",p);
            NSLog(@"x : %16.16e (%s)",[p floatValue:x],[p bound:x] ? "YES" : "NO");
            NSLog(@"[%16.16e;%16.16e]",[p minError:x],[p maxError:x]);
            NSLog(@"y : %f (%s)",[p floatValue:y],[p bound:y] ? "YES" : "NO");
            NSLog(@"z : %f (%s)",[p floatValue:z],[p bound:z] ? "YES" : "NO");
            //NSLog(@"r : %f (%s)",[p floatValue:r],[p bound:r] ? "YES" : "NO");//*/
        }];
    }
    return 0;
}

