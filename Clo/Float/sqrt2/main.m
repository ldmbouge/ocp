#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
    
    id<ORModel> model = [ORFactory createModel];
    
    id<ORFloatVar> b39 = [ORFactory floatVar:model name:@"b39"];
    id<ORFloatVar> b41 = [ORFactory floatVar:model name:@"b41"];
    id<ORDoubleVar> b44 = [ORFactory doubleVar:model name:@"b44"];
    id<ORFloatVar> b46 = [ORFactory floatVar:model name:@"b46"];
    id<ORDoubleVar> b55 = [ORFactory doubleVar:model name:@"b55"];
    id<ORFloatVar> b189 = [ORFactory floatVar:model name:@"b189"];
    id<ORFloatVar> b179 = [ORFactory floatVar:model name:@"b179"];
    id<ORFloatVar> b174 = [ORFactory floatVar:model name:@"b174"];
    id<ORFloatVar> b116 = [ORFactory floatVar:model name:@"b116"];
    id<ORDoubleVar> b106 = [ORFactory doubleVar:model name:@"b106"];
    id<ORFloatVar> xf012 = [ORFactory floatVar:model name:@"xf012"];
    id<ORFloatVar> xf014 = [ORFactory floatVar:model name:@"xf014"];
    id<ORDoubleVar> xf016 = [ORFactory doubleVar:model name:@"xd016"];
    //         id<ORFloatVar> xf018 = [ORFactory floatVar:model name:@"xf018"];
    id<ORFloatVar> xf020 = [ORFactory floatVar:model name:@"xf020"];
    //         id<ORFloatVar> xf022 = [ORFactory floatVar:model name:@"xf022"];
    //         id<ORFloatVar> xf024 = [ORFactory floatVar:model name:@"xf024"];
    
    NSMutableArray* toadd = [[NSMutableArray alloc] init];

    [toadd addObject:[xf012 set:[b39 div:b41]]];
    [toadd addObject:[xf014 set:[xf012 plus:[[[[b39 plus:[[xf012 mul:xf012] minus]] toDouble] div:[[xf012 toDouble] mul:b55]] toFloat]]]];
    
    [toadd addObject:[xf016 set:[[b39 plus:[[xf014 mul:xf014] minus]] toDouble]]];
    [toadd addObject:[b189 set:[[xf016 toFloat] minus]]];
    
    [toadd addObject:[xf020 set:[xf014 plus:[[xf016 div:[b55 mul:[xf014 toDouble]]] toFloat]]]];
    [toadd addObject:[b179 set:[[[[b39 plus:[[xf020 mul:xf020] minus]] toDouble] toFloat] minus]]];
    
    [toadd addObject:[b174 set:[[b106 toFloat] minus]]];
    
    [toadd addObject:[b174 neq:@(0.0)]];
    [toadd addObject:[b179 neq:@(0.0)]];
    [toadd addObject:[b189 neq:@(0.0)]];
    
    //         [toadd addObject:[[xf018 set:b189] neg]];
    //         [toadd addObject:[[xf022 set:b179] neg]];
    //         [toadd addObject:[[xf024 set:b174] neg]];
    [toadd addObject:[[b39 set:b46] neg]];
    [toadd addObject:[b46 leq:b39]];
    [toadd addObject:[[b46 leq:[b174 minus]] neg]];
    //         [toadd addObject:[b174 set:[xf024 minus]]];
    [toadd addObject:[[b46 leq:[b179 minus]] neg]];
    //         [toadd addObject:[b179 set:[xf022 minus]]];
    [toadd addObject:[[[b189 toDouble] leq:b44] neg]];
    [toadd addObject:[[b46 leq:[b189 minus]] neg] ];
    //         [toadd addObject:[b189 set:[xf018 minus]]];
    [toadd addObject:[[b174 leq:b116] neg]];
    
    /*
    id<ORVarArray> vars = [ORFactory idArray:model range:RANGE(model, 0, 9)];
    id<ORVarArray> mvars = [model FPVars];
    ORInt i = 0;
    for(id<ORVar> v in mvars){
      if([[v prettyname] containsString:@"b"])
        vars[i++] = v;
    }
     */
    
    //         vars[8] = b174;
    //         vars[7] = b179;
    //         vars[6] = b189;
    //         vars[5] = b39;
    //         vars[4] = b41;
    //         vars[3] = b55;
    //         vars[2] = b46;
    //         vars[1] = b106;
    //         vars[0] = b116;
    
    id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
    [ORCmdLineArgs defaultRunner:args model:model program:cp restricted:@[b39,b41,b44,b46,b55,b116,b106]];
    
  }
  
  
  return 0;
}

