//
//  main.m
//  FanghuiTest
//
//  Created by Laurent Michel on 6/28/16.
//
//

#import <ORProgram/ORProgram.h>

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> m = [ORFactory createModel];
      id<ORIntRange> D = RANGE(m, 0, 10);
      id<ORIntVarArray> x = [ORFactory intVarArray:m range:D domain:RANGE(m,0,100)];
       // insert code here...
       NSLog(@"Hello, World! %@",m);
   }
    return 0;
}
