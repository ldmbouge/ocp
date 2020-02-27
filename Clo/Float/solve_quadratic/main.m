#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
int main(int argc, const char * argv[]) {
  @autoreleasepool {
    ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
    id<ORModel> model = [ORFactory createModel];
    id<ORFloatVar> c_0 = [ORFactory floatVar:model];
    id<ORFloatVar> a_0 = [ORFactory floatVar:model];
    id<ORFloatVar> disc_0 = [ORFactory floatVar:model];
    id<ORFloatVar> b_0 = [ORFactory floatVar:model];
    NSMutableArray* toadd = [[NSMutableArray alloc] init];
    [toadd addObject:[disc_0 set: [[b_0 mul: b_0] sub: [[a_0 mul:@(4.0f)] mul: c_0]]]];
    
    //assert(!(a == 0 && b == 0));
    [toadd addObject:[a_0 set:@(0.0f)]];
    [toadd addObject:[b_0 set:@(0.0f)]];
    
    
    
    id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
    
    [ORCmdLineArgs defaultRunner:args model:model program:cp restricted:@[a_0, b_0, c_0]];
  }
  return 0;
}

