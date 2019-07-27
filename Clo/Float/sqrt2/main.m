#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
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
         
         
         [model add:[xf012 eq:[b39 div:b41]]];
         [model add:[xf014 eq:[xf012 plus:[[[[b39 plus:[[xf012 mul:xf012] minus]] toDouble] div:[[xf012 toDouble] mul:b55]] toFloat]]]];
         
         [model add:[xf016 eq:[[b39 plus:[[xf014 mul:xf014] minus]] toDouble]]];
         [model add:[b189 eq:[[xf016 toFloat] minus]]];
         
         [model add:[xf020 eq:[xf014 plus:[[xf016 div:[b55 mul:[xf014 toDouble]]] toFloat]]]];
         [model add:[b179 eq:[[[[b39 plus:[[xf020 mul:xf020] minus]] toDouble] toFloat] minus]]];
         
         [model add:[b174 eq:[[b106 toFloat] minus]]];
         
         [model add:[b174 neq:@(0.0)]];
         [model add:[b179 neq:@(0.0)]];
         [model add:[b189 neq:@(0.0)]];
         
         //         [model add:[[xf018 eq:b189] neg]];
         //         [model add:[[xf022 eq:b179] neg]];
         //         [model add:[[xf024 eq:b174] neg]];
         [model add:[[b39 eq:b46] neg]];
         [model add:[b46 leq:b39]];
         [model add:[[b46 leq:[b174 minus]] neg]];
         //         [model add:[b174 eq:[xf024 minus]]];
         [model add:[[b46 leq:[b179 minus]] neg]];
         //         [model add:[b179 eq:[xf022 minus]]];
         [model add:[[[b189 toDouble] leq:b44] neg]];
         [model add:[[b46 leq:[b189 minus]] neg] ];
         //         [model add:[b189 eq:[xf018 minus]]];
         [model add:[[b174 leq:b116] neg]];
         
         
         id<ORVarArray> vars = [ORFactory idArray:model range:RANGE(model, 0, 9)];
         id<ORVarArray> mvars = [model FPVars];
         ORInt i = 0;
         for(id<ORVar> v in mvars){
            if([[v prettyname] containsString:@"b"])
               vars[i++] = v;
         }
         
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
         
         [ORCmdLineArgs defaultRunner:args model:model program:cp];
         
      
      
   }
   return 0;
}

