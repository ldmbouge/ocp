//
//  sine.m
//  ORUtilities
//
//  Created by Remy Garcia on 11/04/2018.
//

#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"
#include <fenv.h>

#define VAL 1.0
void checksolution(float IN,float res){
  if(!(IN >= -1.57079632679f && IN <= 1.57079632679f)) printf("IN n'est pas dans le bon range\n");
  float x = IN;
  
  float result = x - (x*x*x)/6.0f + (x*x*x*x*x)/120.0f + (x*x*x*x*x*x*x)/5040.0f;
  if(res != result) printf("Erreur %16.16e != %16.16e\n",res,result);
  //   else if(res < VAL && res > -VAL) printf("Erreur resultat incorrect\n");
  else printf("resultat oK\n");
}




int main(int argc, const char * argv[]) {
  @autoreleasepool {
    ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
    
    id<ORModel> model = [ORFactory createModel];
    id<ORDoubleVar> x = [ORFactory doubleVar:model low:-1.57079632679 up:1.57079632679 name:@"x"];
    id<ORDoubleVar> z = [ORFactory doubleVar:model name:@"z"];
    
    NSMutableArray* toadd = [[NSMutableArray alloc] init];
    
    [toadd addObject:[z eq: [[[x sub: [ [[x mul: x] mul: x] div: @(6.0)]] plus: [[[[[x mul: x] mul: x] mul: x] mul: x] div: @(120.0)]] sub: [[[[[[[x mul: x] mul: x] mul: x] mul: x] mul: x] mul: x] div: @(5040.0)]]]];
    
    
    [toadd addObject:[z lt: @(VAL)]];
    //      [toadd addObject:[z gt: @(-VAL)]];
    
    
    id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
    
    [ORCmdLineArgs defaultRunner:args model:model program:cp restricted:@[x]];
    
  }
  return 0;
}

