#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

#define NR 8

#if NR == 1
#define VAL 0.2f
#elif NR == 2
#define VAL 0.4f
#elif NR == 3
#define VAL 0.6f
#elif NR == 4
#define VAL 0.8f
#elif NR == 5
#define VAL 1.0f
#elif NR == 6
#define VAL 1.2f
#elif NR == 7
#define VAL 1.4f
#elif NR == 8
#define VAL 2.0f
#endif
int main(int argc, const char * argv[]) {
  @autoreleasepool {
    ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
    
    id<ORModel> model = [ORFactory createModel];
    id<ORFloatVar> x = [ORFactory floatVar:model low:-VAL up:VAL];
    id<ORFloatVar> r_0 = [ORFactory floatVar:model];
    id<ORFloatVar> f_x = [ORFactory floatVar:model];
    id<ORFloatVar> fp_x = [ORFactory floatVar:model];
    
    id<ORFloatVar> x2 = [ORFactory floatVar:model];
    id<ORFloatVar> f_x2 = [ORFactory floatVar:model];
    id<ORFloatVar> fp_x2 = [ORFactory floatVar:model];
    
    id<ORFloatVar> x3 = [ORFactory floatVar:model];
    id<ORFloatVar> f_x3 = [ORFactory floatVar:model];
    id<ORFloatVar> fp_x3 = [ORFactory floatVar:model];
    
    
    id<ORExpr> fc = [ORFactory float:model value:1.0f];
    NSMutableArray* toadd = [[NSMutableArray alloc] init];
    
    [toadd addObject:[f_x eq:[[[x sub:[[[x mul:x] mul:x] div:@(6.0f)]] plus:[[[[[x mul:x] mul:x] mul:x] mul:x] div:@(120.0f)]]
                              plus:[[[[[[[x mul:x] mul:x] mul:x] mul:x] mul:x] mul:x] div:@(5040.0f)]]]];
    
    
    [toadd addObject:[fp_x eq:[[[fc sub:[[x mul:x] div:@(2.0f)]] plus:[[[[x mul:x] mul:x] mul:x] div:@(24.0f)]]
                               plus:[[[[[[x mul:x] mul:x] mul:x] mul:x] mul:x] div:@(720.0f)]]]];
    
    [toadd addObject:[x2 eq:[x sub:[f_x div:fp_x]]]];
    
    [toadd addObject:[f_x2 eq:[[[x2 sub:[[[x2 mul:x2] mul:x2] div:@(6.0f)]] plus:[[[[[x2 mul:x2] mul:x2] mul:x2] mul:x2] div:@(120.0f)]]
                               plus:[[[[[[[x2 mul:x2] mul:x2] mul:x2] mul:x2] mul:x2] mul:x2] div:@(5040.0f)]]]];
    
    
    [toadd addObject:[fp_x2 eq:[[[fc sub:[[x2 mul:x2] div:@(2.0f)]] plus:[[[[x2 mul:x2] mul:x2] mul:x2] div:@(24.0f)]]
                                plus:[[[[[[x2 mul:x2] mul:x2] mul:x2] mul:x2] mul:x2] div:@(720.0f)]]]];
    
    [toadd addObject:[x3 eq:[x2 sub:[f_x2 div:fp_x2]]]];
    
    [toadd addObject:[f_x3 eq:[[[x3 sub:[[[x3 mul:x3] mul:x3] div:@(6.0f)]] plus:[[[[[x3 mul:x3] mul:x3] mul:x3] mul:x3] div:@(120.0f)]]
                               plus:[[[[[[[x3 mul:x3] mul:x3] mul:x3] mul:x3] mul:x3] mul:x3] div:@(5040.0f)]]]];
    
    
    [toadd addObject:[fp_x3 eq:[[[fc sub:[[x3 mul:x3] div:@(2.0f)]] plus:[[[[x3 mul:x3] mul:x3] mul:x3] div:@(24.0f)]]
                                plus:[[[[[[x3 mul:x3] mul:x3] mul:x3] mul:x3] mul:x3] div:@(720.0f)]]]];
    
    [toadd addObject:[r_0 eq:[x3 sub:[f_x3 div:fp_x3]]]];
    
    [toadd addObject:[r_0 geq:@(0.1f)]];
    
    
    id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
    
    [ORCmdLineArgs defaultRunner:args model:model program:cp restricted:@[x]];
    
  }
  return 0;
}

