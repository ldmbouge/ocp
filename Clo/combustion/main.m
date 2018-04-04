//
//  main.m
//  combustion
//
//  Created by Zitoun on 12/02/2018.
//



int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         
         id<ORGroup> g = [args makeGroup:model];
         [model add:g];
         //         NSLog(@"%@", model);
         id<ORFloatVarArray> vars = [model floatVars];
         id<CPProgram> cp = [args makeProgram:model];
         __block bool found = false;
         
         [cp solveOn:^(id<CPCommonProgram> p) {
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            found=true;
            for(id<ORFloatVar> v in vars){
               id<CPFloatVar> cv = [cp concretize:v];
               found &= [p bound: v];
               //               NSLog(@"%@ : %16.16e (%s)",v,[p floatValue:v],[p bound:v] ? "YES" : "NO");
               
               NSLog(@"%@",cv);
            }
         } withTimeLimit:[args timeOut]];
         NSLog(@"nb fail : %d",[[cp engine] nbFailures]);
         struct ORResult re = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return re;
      }];
      
   }
   return 0;
}
