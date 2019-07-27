#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"


int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      id<ORModel> model = [ORFactory createModel];
      id<ORFloatVar> x = [ORFactory floatVar:model low:-10.0f up:10.0f name:@"x"];
      id<ORFloatVar> y = [ORFactory floatVar:model name:@"y"];
      id<ORFloatVar> z = [ORFactory floatVar:model name:@"z"];
      
      NSMutableArray* toadd = [[NSMutableArray alloc] init];
   
      [toadd addObject:[y eq:[[x mul:x] sub:@(2.f)]]];
      
      [toadd addObject:[y eq:@(0.0f)]]; /* */
      
      [toadd addObject:[z eq:[@(1.f) div:y]]];
      
      
      id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
     
      [ORCmdLineArgs defaultRunner:args model:model program:cp];
      return 0;
   }
}


