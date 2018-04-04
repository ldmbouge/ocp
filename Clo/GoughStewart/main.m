//
//  main.m
//  GoughStewart
//
//  Created by Zitoun on 12/02/2018.
//
#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];
         id<ORGroup> g = [args makeGroup:model];
         
         fesetround(FE_TONEAREST);

         id<ORFloatVar> x1 = [ORFactory floatVar:model low:-2.0f up:5.57f name:@"x1"];
         id<ORFloatVar> x2 = [ORFactory floatVar:model low:-6.25f up:1.30f name:@"x2"];
         id<ORFloatVar> x3 = [ORFactory floatVar:model low:-5.39f up:0.7f name:@"x3"];
         
         id<ORFloatVar> y1 = [ORFactory floatVar:model low:-5.57f up:2.7f name:@"y1"];
         id<ORFloatVar> y2 = [ORFactory floatVar:model low:-6.25f up:2.7f name:@"y2"];
         id<ORFloatVar> y3 = [ORFactory floatVar:model low:-5.39f up:3.11f name:@"y3"];
         
         id<ORFloatVar> z1 = [ORFactory floatVar:model low:0.0f up:5.57f name:@"z1"];
         id<ORFloatVar> z2 = [ORFactory floatVar:model low:-2.00f up:6.25f name:@"z2"];
         id<ORFloatVar> z3 = [ORFactory floatVar:model low:-3.61f up:5.39f name:@"z3"];
         
         id<ORFloatVar> r1 = [ORFactory floatVar:model name:@"r1"];
         id<ORFloatVar> r2 = [ORFactory floatVar:model name:@"r2"];
         id<ORFloatVar> r3 = [ORFactory floatVar:model name:@"r3"];

         id<ORFloatVar> r4 = [ORFactory floatVar:model name:@"r4"];
         id<ORFloatVar> r5 = [ORFactory floatVar:model name:@"r5"];
         id<ORFloatVar> r6 = [ORFactory floatVar:model name:@"r6"];

         id<ORFloatVar> r7 = [ORFactory floatVar:model name:@"r7"];
         id<ORFloatVar> r8 = [ORFactory floatVar:model name:@"r8"];
         id<ORFloatVar> r9 = [ORFactory floatVar:model name:@"r9"];
         
         id<ORExpr> c6 = [ORFactory float:model value:6.f];
         id<ORExpr> c7 = [ORFactory float:model value:7.f];
         id<ORExpr> c8 = [ORFactory float:model value:8.f];
         id<ORExpr> c2 = [ORFactory float:model value:2.f];
         id<ORExpr> c10 = [ORFactory float:model value:10.f];
         id<ORExpr> c12 = [ORFactory float:model value:-12.f];
         id<ORExpr> c14 = [ORFactory float:model value:-14.f];
         id<ORExpr> c15 = [ORFactory float:model value:15.f];
         id<ORExpr> c18 = [ORFactory float:model value:18.f];
         id<ORExpr> c25 = [ORFactory float:model value:25.f];
         id<ORExpr> c30 = [ORFactory float:model value:30.f];
         id<ORExpr> c35 = [ORFactory float:model value:35.f];
         id<ORExpr> c36 = [ORFactory float:model value:36.f];
         id<ORExpr> c45 = [ORFactory float:model value:45.f];
         
         [g add:[r1 eq:@(31.f)]];
         [g add:[r2 eq:@(39.f)]];
         [g add:[r3 eq:@(29.f)]];
         
//         model.add(x1*x1 + y1*y1 + z1*z1 == 31);
//         model.add(x2*x2 + y2*y2 + z2*z2 == 39);
//         model.add(x3*x3 + y3*y3 + z3*z3 == 29);
         
         [g add:[r1 eq:[[[x1 mul:x1] plus:[y1 mul:y1]] plus:[z1 mul:z1]]]];
         [g add:[r2 eq:[[[x2 mul:x2] plus:[y2 mul:y2]] plus:[z2 mul:z2]]]];
         [g add:[r3 eq:[[[x3 mul:x3] plus:[y3 mul:y3]] plus:[z3 mul:z3]]]];
         
         [g add:[r4 eq:@(51.f)]];
         [g add:[r5 eq:@(50.f)]];
         [g add:[r6 eq:@(34.f)]];
         
//         model.add(x1*x2 + y1*y2 + z1*z2 + 6*x1 - 6*x2 == 51);
//         model.add(x1*x3 + y1*y3 + z1*z3 + 7*x1 - 2*y1 - 7*x3 + 2*y3 == 50);
//         model.add(x2*x3 + y2*y3 + z2*z3 +   x2 - 2*y2 - x3 + 2*y3 == 34);
        
         [g add:[r4 eq:[[[[[x1 mul:x2] plus:[y1 mul:y2]] plus:[z1 mul:z2]] plus:[c6 mul:x1]] sub:[c6 mul:x2]]]];
         [g add:[r5 eq:[[[[[[[x1 mul:x3] plus:[y1 mul:y3]] plus:[z1 mul:z3]] plus:[c7 mul:x1]] sub:[c2 mul:y1]] sub:[c7 mul:x3]] plus:[c2 mul:y3]]]];
         [g add:[r6 eq:[[[[[[[x2 mul:x3] plus:[y2 mul:y3]] plus:[z2 mul:z3]] plus:x2] sub:[c2 mul:y2]] sub:x3] plus:[c2 mul:y3]]]];
         
         [g add:[r7 eq:@(-32.f)]];
         [g add:[r8 eq:@(8.f)]];
         [g add:[r9 eq:@(20.f)]];
         
         
//         model.add(-12*x1 + 15*y1 - 10*x2 - 25*y2 + 18*x3 + 18*y3 == -32);
//         model.add(-14*x1 + 35*y1 - 36*x2 - 45*y2 + 30*x3 + 18*y3 ==   8);
//         model.add(  2*x1 +  2*y1 - 14*x2 -  2*y2 +  8*x3 -    y3 ==  20);
         
         
         [g add:[r7 eq:[[[[[[c12 mul:x1] plus:[c15 mul:y1]] sub:[c10 mul:x2]] sub:[c25 mul:y2]] plus:[c18 mul:x3]] plus:[c18 mul:y3]]]];
         [g add:[r8 eq:[[[[[[c14 mul:x1] plus:[c35 mul:y1]] sub:[c36 mul:x2]] sub:[c45 mul:y2]] plus:[c30 mul:x3]] plus:[c18 mul:y3]]]];
         [g add:[r9 eq:[[[[[[c2 mul:x1] plus:[c2 mul:y1]] sub:[c14 mul:x2]] sub:[c2 mul:y2]] plus:[c8 mul:x3]] sub:y3]]];
         
         [model add:g];
         
                  NSLog(@"%@", model);
         //         NSLog(@"---");
         id<ORFloatVarArray> vars = [model floatVars];
         id<CPProgram> cp = [args makeProgram:model];
         __block bool found = false;
         //         checksolution();
         fesetround(FE_TONEAREST);
         [cp solveOn:^(id<CPCommonProgram> p) {
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            for(id<ORFloatVar> v in vars){
               id<CPFloatVar> cv = [cp concretize:v];
               found &= [p bound: v];
               NSLog(@"%@ = %16.16e (%s)",v,[cv value], [p bound:v] ? "YES" : "NO");
            }
            //            checksolution([p floatValue:y[0]], [p floatValue:y_opt[0]], [p floatValue:y[NBLOOPS]],[p floatValue:y_opt[NBLOOPS]], [p floatValue:diff]);
         } withTimeLimit:[args timeOut]];
         NSLog(@"nb fail : %d",[[cp engine] nbFailures]);
         struct ORResult re = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return re;
      }];
      
   }
   return 0;
}
