//
//  main.m
//  testFloat
//
//  Created by Remy on 19/07/2016.
//
//

#import <ORProgram/ORProgram.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        id<ORModel> mdl = [ORFactory createModel];
        id<ORFloatVar> x = [ORFactory floatVar:mdl];
        id<ORFloatVar> y = [ORFactory floatVar:mdl];
        id<ORFloatVar> z = [ORFactory floatVar:mdl];
       
        [mdl add:[x set: @(0.1f)]];
        [mdl add:[y set: @(0.2f)]];
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
            /* OBJ-CP
             x : 1.00000001e-01 (YES)
             ex: [0.00000000e+00;0.00000000e+00]
             y : 2.00000003e-01 (YES)
             ey: [0.00000000e+00;0.00000000e+00]
             z : 3.00000012e-01 (YES)
             ez: [2.23517418e-08;2.23517418e-08]
             */
            /* FLUCTUAT
             x : [1.00000001e-1;1.00000002e-1]
             ex: [-1.49011612e-8;-1.49011611e-8]
             y : [2.00000002e-1;2.00000003e-1]
             ey: [-1.49011612e-8;-1.49011611e-8]
             z : [3.00000011e-1;3.00000012e-1]
             ex: [-3.97364299e-8;-3.97364298e-8]
             */
        }];
    }
    return 0;
}

