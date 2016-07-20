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
        id<ORFloatRange> r0 = [ORFactory floatRange:mdl low:0.0 up:10.0];
        id<ORFloatVar> a = [ORFactory floatVar:mdl domain:r0];
        NSLog(@"Range: %@",r0);
        NSLog(@"Variable: %@",a);
        id<CPProgram> p = [ORFactory createCPProgram:mdl];
        [p solve:^{
            NSLog(@"helloword %@ !",p);
        }];
    }
    return 0;
}
