//
//  range_add_mult.m
//  Clo
//
//  Created by Rémy Garcia on 05/09/2018.
//
#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#include <fenv.h>


int main(int argc, const char * argv[]) {
  @autoreleasepool {
    ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
    fesetround(FE_TONEAREST);
    id<ORModel> model = [ORFactory createModel];
    id<ORFloatVar> x = [ORFactory floatVar:model low:0.0f up:180.0f name:@"x"];
    id<ORFloatVar> y = [ORFactory floatVar:model low:-180.0f up:0.0f name:@"y"];
    id<ORFloatVar> z = [ORFactory floatVar:model low:0.0f up:1.0f name:@"z"];
    id<ORFloatVar> res = [ORFactory floatVar:model name:@"r"];
    
    NSMutableArray* toadd = [[NSMutableArray alloc] init];
    
    
    [toadd addObject:[[x plus: y] geq: @(0.0f)]];
    
    [toadd addObject:[res set: [x plus: [y mul: z]]]];
    
    [toadd addObject:[res lt: @(0.0f)]];
    //         [toadd addObject:[[res lt: @(0.0f)] lor: [res gt: @(360.0f)]]];
    
    
    id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
    [ORCmdLineArgs defaultRunner:args model:model program:cp restricted:@[x,y,z]];
    
    
  }
  return 0;
}
