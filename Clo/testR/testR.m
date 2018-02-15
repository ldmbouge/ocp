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
//        id<ORFloatVar> w = [ORFactory floatVar:mdl];
       
        [mdl add:[x set: @(0.1f)]];
        [mdl add:[y set: @(0.2f)]];
        [mdl add:[z set: [x plus:y]]];
//        [mdl add:[w set: [z sub:x]]];
       
        NSLog(@"model: %@",mdl);
       id<ORFloatVarArray> vs = [mdl floatVars];
       id<CPProgram> p = [ORFactory createCPProgram:mdl];
       id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[p engine]];

        [p solve:^{
            [p lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
               [p floatSplit:i call:s withVars:x];
            }];
           
            NSLog(@"%@",p);
            NSLog(@"x : %16.16e (%s)",[p floatValue:x],[p bound:x] ? "YES" : "NO");
            NSLog(@"ex: [%16.16e;%16.16e]",[p minError:x],[p maxError:x]);
            NSLog(@"y : %16.16e (%s)",[p floatValue:y],[p bound:y] ? "YES" : "NO");
            NSLog(@"ey: [%16.16e;%16.16e]",[p minError:y],[p maxError:y]);
            NSLog(@"z : %16.16e (%s)",[p floatValue:z],[p bound:z] ? "YES" : "NO");
            NSLog(@"ez: [%16.16e;%16.16e]",[p minError:z],[p maxError:z]);
//            NSLog(@"w : %16.16e (%s)",[p floatValue:w],[p bound:w] ? "YES" : "NO");
//            NSLog(@"ew: [%16.16e;%16.16e]",[p minError:w],[p maxError:w]);
        }];
    }
    return 0;
}

