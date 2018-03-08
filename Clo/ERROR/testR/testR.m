//
//  main.m
//  testFloat
//
//  Created by Remy on 01/12/2017.
//
//

#import <ORProgram/ORProgram.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
       id<ORModel> mdl = [ORFactory createModel];
       //id<ORFloatRange> r0 = [ORFactory floatRange:mdl low:1.f up:5.f];
       id<ORFloatRange> r1 = [ORFactory floatRange:mdl low:0.2f up:0.4f];
       id<ORFloatVar> x = [ORFactory floatVar:mdl];// domain:r0];
       id<ORFloatVar> y = [ORFactory floatVar:mdl domain:r1];
       id<ORFloatVar> z = [ORFactory floatVar:mdl];
       
        [mdl add:[x set: @(0.1f)]];
        //[mdl add:[y set: @(0.4f)]];
        //[mdl add:[x set: y]];
        //[mdl add:[y set: @(0.2f)]];
        [mdl add:[z set: [x plus:y]]];
       
       
       NSLog(@"model: %@",mdl);
       id<ORFloatVarArray> vs = [mdl floatVars];
       id<CPProgram> p = [ORFactory createCPProgram:mdl];
       id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[p engine]];

        [p solve:^{
            [p lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
               [p floatSplit:i call:s withVars:x];
            }];
           
            NSLog(@"%@",p);
            /* format of 8.8e to have the same value displayed as in FLUCTUAT */
            /* Use printRational(ORRational r) to print a rational inside the solver */
            NSLog(@"x : %8.8e (%s)",[p floatValue:x],[p bound:x] ? "YES" : "NO");
            NSLog(@"ex: [%8.8e;%8.8e]",[p minError:x],[p maxError:x]);
            NSLog(@"y : %8.8e (%s)",[p floatValue:y],[p bound:y] ? "YES" : "NO");
            NSLog(@"ey: [%8.8e;%8.8e]",[p minError:y],[p maxError:y]);
            NSLog(@"z : %8.8e (%s)",[p floatValue:z],[p bound:z] ? "YES" : "NO");
            NSLog(@"ez: [%8.8e;%8.8e]",[p minError:z],[p maxError:z]);
        }];
    }
    return 0;
}

