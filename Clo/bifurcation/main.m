//
//  main.m
//  bifurcation
//
//  Created by Zitoun on 12/02/2018.
//
#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
//
//variable:
//X in [-1.0e8,1.0e8] ;
//Y in [-1.0e8,1.0e8] ;
//Z in [-1.0e8,1.0e8] ;
//
//body: solve system all
//5*X^9 - 6*X^5*Y + X*Y^4 + 2*X*Z = 0 ;
//2*X^2*Y^3 - 2*X^6*Y + 2*Y*Z = 0 ;
//X^2 + Y^2 - 0.265625 = 0 ;

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVar> x = [ORFactory floatVar:model low:-1.0e8f up:1.0e8f name:@"X"];
         id<ORFloatVar> y = [ORFactory floatVar:model low:-1.0e8f up:1.0e8f name:@"Y"];
         id<ORFloatVar> z = [ORFactory floatVar:model low:-1.0e8f up:1.0e8f name:@"Z"];
         id<ORGroup> g = [args makeGroup:model];
         [model add:g];
         
         id<ORExpr> c5 = [ORFactory float:model value:5.f];
         id<ORExpr> c6 = [ORFactory float:model value:6.f];
         id<ORExpr> c2 = [ORFactory float:model value:2.f];
         
         id<ORExpr> f1 = [ORFactory expr:c5 mul:x power:9];
         id<ORExpr> f2 = [ORFactory expr:c6 mul:x power:5];
         id<ORExpr> f3 = [ORFactory expr:x mul:y power:4];
         id<ORExpr> f4 = [ORFactory expr:[ORFactory expr:c2 mul:x power:2] mul:y power:3];
         id<ORExpr> f5 = [ORFactory expr:c2 mul:x power:6];

         //5*X^9 - 6*X^5*Y + X*Y^4 + 2*X*Z = 0 ;
         [g add:[[[[f1 sub:[f2 mul:y]] plus:f3] plus:[[c2 mul:x] mul:z]] eq:@(0.0f)]];
         
         //2*X^2*Y^3 - 2*X^6*Y + 2*Y*Z = 0 ;
         [g add:[[[f4 sub:[f5 mul:y]] plus:[[c2 mul:y] mul:z]] eq:@(0.0f)]];
         
         //X^2 + Y^2 - 0.265625 = 0 ;
         [g add:[[[[x mul:x] plus:[y mul:y]] sub:@(0.265625f)] eq:@(0.0f)]];
         
         [g add:[x gt:@(0.0f)]];
         [g add:[x lt:@(3.f)]];
                  NSLog(@"%@", model);
         
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
