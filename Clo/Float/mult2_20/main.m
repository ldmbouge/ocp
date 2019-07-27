#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

#define LARGE_NUMBER 4.0e+14
#define NBLOOPS 20


int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
         
         id<ORModel> model = [ORFactory createModel];
         
         id<ORFloatVarArray> d = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"m"];
         id<ORFloatVarArray> nextValue = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS-1) names:@"nextValue"];
         
       NSMutableArray* toadd = [[NSMutableArray alloc] init];
         
         [toadd addObject:[d[0] eq:@(2.f)]];
         
         for(ORInt i = 0; i < NBLOOPS; i++){
            [toadd addObject:[nextValue[i] lt:@(1.f)]];
            [toadd addObject:[nextValue[i] gt:@(1.0e-1f)]];
            [toadd addObject:[d[i+1] eq:[d[i] mul:nextValue[i]]]];
         }
         
         [toadd addObject:[d[NBLOOPS] lt:@(1.0e-2f)]];
         
         
         id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
         
         [ORCmdLineArgs defaultRunner:args model:model program:cp];
         
   }
   return 0;
}


