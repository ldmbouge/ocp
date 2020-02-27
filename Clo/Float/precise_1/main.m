#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
    
    id<ORModel> model = [ORFactory createModel];
    id<ORFloatVar> x = [ORFactory floatVar:model low:10.0 up:10.0 name:@"x"];
    id<ORFloatVar> y = [ORFactory floatVar:model low:0.4 up:0.4 name:@"y"];
    id<ORFloatVar> z = [ORFactory floatVar:model name:@"z"];
    
    
    NSMutableArray* toadd = [[NSMutableArray alloc] init];
    
    
    [toadd addObject:[z set:[x plus:y]]];
    
    [toadd addObject:[[z lt:@(10.39999)] lor:[z gt:@(10.40001)]]];
    
    
    //            [model add:[res lt:fc]];
    
    id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
    
    [ORCmdLineArgs defaultRunner:args model:model program:cp restricted:@[x,y]];
    
  }
  return 0;
}

