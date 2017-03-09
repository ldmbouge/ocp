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
       /* id<ORFloatRange> r0 = [ORFactory floatRange:mdl low:-0.0f up:+0.0f];
        id<ORFloatRange> r1 = [ORFactory floatRange:mdl low:0.0f up:+0.0f];
        id<ORFloatRange> r2 = [ORFactory floatRange:mdl low:-0.0f up:+0.0f];
       */ id<ORFloatVar> x = [ORFactory floatVar:mdl];
        id<ORFloatVar> y = [ORFactory floatVar:mdl];
        id<ORFloatVar> z = [ORFactory floatVar:mdl];
        id<ORFloatVarArray> vars = [mdl floatVars];
       // float f = fp_next_float(0.f);
       
       // printf("ici :   %20.20e\n",f);
        [mdl add:[x eq: @(0.f)]];
        [mdl add:[y gt: x]];
        [mdl add:[z lt: @(1.f)]];
        
        NSLog(@"model: %@",mdl);
        id<CPProgram> p = [ORFactory createCPProgram:mdl];
        [p solve:^{
            [p floatSplitArrayOrderedByDomSize: vars];
            NSLog(@"x : %f (%s)",[p floatValue:x],[p bound:x] ? "YES" : "NO");
            NSLog(@"y : %20.20e (%s)",[p floatValue:y],[p bound:y] ? "YES" : "NO");
            //  id zc = [p concretize:z];
            //  NSLog(@"cz : %@",zc);
            NSLog(@"z : %f (%s)",[p floatValue:z],[p bound:z] ? "YES" : "NO");
        }];
    }
    return 0;
}
