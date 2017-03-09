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
        id<ORModel> model = [ORFactory createModel];
        id<ORIntRange> r1 = [ORFactory intRange:model low:1 up:2];
        id<ORIntRange> r2 = [ORFactory intRange:model low:0 up:10];
        id<ORIntVar> x = [ORFactory intVar:model value:5];
        id<ORIntVar> y = [ORFactory intVar:model domain:r1];
        id<ORIntVar> a = [ORFactory intVar:model domain:r2];
        id<ORIntVar> z = [ORFactory intVar:model domain:r2];
        
        id<ORIntVarArray> vars = [model intVars];
        
        id<ORConstraint> c = [[x plus: y] gt: @(6)];
        id<ORConstraint> nc = [[[x plus: y] gt: @(6)] neg];
        id<ORGroup> g = [ORFactory group:model];
        [g add:[z eq: [x plus: y]]];
        [g add:[a eq: [z sub: @(2)]]];
        id<ORGroup> g_1 = [ORFactory group:model];
        [g_1 add:[a eq: [x sub: y]]];
        [g_1 add:[z eq: [a plus: @(2)]]];
        [model add:[[c land:g] lor:[nc land:g_1]]];
        
        NSLog(@"model: %@",model);
        id<CPProgram> p = [ORFactory createCPProgram:model];
        [p solveAll:^{
            [p labelArray:vars];
            NSLog(@"x : %d (%s)",[p intValue:x],[p bound:x] ? "YES" : "NO");
            NSLog(@"y : %d (%s)",[p intValue:y],[p bound:y] ? "YES" : "NO");
            NSLog(@"a : %d (%s)",[p intValue:a],[p bound:a] ? "YES" : "NO");
            NSLog(@"z : %d (%s)",[p intValue:z],[p bound:z] ? "YES" : "NO");
            //  id zc = [p concretize:z];
            //  NSLog(@"cz : %@",zc);
        }];
    }
    return 0;
}
