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
        id<ORFloatVar> x = [ORFactory floatVar:mdl];
        id<ORFloatVar> y = [ORFactory floatVar:mdl];
        id<ORFloatVar> z = [ORFactory floatVar:mdl];
        
        [mdl add:[x eq: @(0.1f)]];
        [mdl add:[y eq: @(0.2f)]];
        [mdl add:[z eq: [x plus:y]]];
        
        NSLog(@"model: %@",mdl);
        id<ORFloatVarArray> vars = [mdl floatVars];
        id<CPProgram> p = [ORFactory createCPProgram:mdl];

        [p solve:^{
            [p lexicalOrderedSearch:vars do:^(id<ORFloatVar> b) {
                [p floatSplit:b];
            }];
            NSLog(@"helloword %@ !",p);
            NSLog(@"x : %16.16e (%s)",[p floatValue:x],[p bound:x] ? "YES" : "NO");
            NSLog(@"ex: [%16.16e;%16.16e]",[p minError:x],[p maxError:x]);
            NSLog(@"y : %16.16e (%s)",[p floatValue:y],[p bound:y] ? "YES" : "NO");
            NSLog(@"ey: [%16.16e;%16.16e]",[p minError:y],[p maxError:y]);
            NSLog(@"z : %16.16e (%s)",[p floatValue:z],[p bound:z] ? "YES" : "NO");
            NSLog(@"ez: [%16.16e;%16.16e]",[p minError:z],[p maxError:z]);
        }];
    }
    return 0;
}

