#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#include <fenv.h>

void check_solution(float a,float b, float c, float r, float q, float Q, float R, float R2, float Q3, float CR2, float CQ3){
   bool err = false;
   float q_c = (a * a - 3 * b);
   float r_c = (2 * a * a * a - 9 * a * b + 27 * c);
   
   float Q_c = q / 9;
   float R_c = r / 54;
   
   float Q3_c = Q * Q * Q;
   float R2_c = R * R;
   
   float CR2_c = 729 * r * r;
   float CQ3_c = 2916 * q * q * q;
   if(r_c != r){
      err = true;
      printf("(r_c)%16.16e != (r)%16.16e \n",r_c,r);
   }
   if(q_c != q){
      err = true;
      printf("(q_c)%16.16e != (q)%16.16e \n",q_c,q);
   }
   if(Q_c != Q){
      err = true;
      printf("(Q_c)%16.16e != (Q)%16.16e \n",Q_c,Q);
   }
   if(R_c != R){
      err = true;
      printf("(R_c)%16.16e != (R)%16.16e \n",R_c,R);
   }
   if(Q3_c != Q3){
      err = true;
      printf("(Q3_c)%16.16e != (Q3)%16.16e \n",Q3_c,Q3);
      
   }
   if(R2_c != R2){
      err = true;
      printf("(R2_c)%16.16e != (R2)%16.16e \n",R2_c,R2);
   }
   if(CR2_c != CR2){
      err = true;
      printf("(CR2_c)%16.16e != (CR2)%16.16e \n",CR2_c,CR2);
   }
   if(CQ3_c != CQ3){
      err = true;
      printf("(CQ3_c)%16.16e != (CQ3)%16.16e \n",CQ3_c,CQ3);
   }
   if(!err)
      printf("Les inputs sont correctes\n");
}

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
         fesetround(FE_TONEAREST);
         id<ORModel> model = [ORFactory createModel];
         id<ORFloatVar> c_0 = [ORFactory floatVar:model name:@"c"];
         id<ORFloatVar> r_0 = [ORFactory floatVar:model name:@"r"];
         id<ORFloatVar> a_0 = [ORFactory floatVar:model name:@"a"];
         id<ORFloatVar> Q_0 = [ORFactory floatVar:model name:@"Q"];
         id<ORFloatVar> R2_0 = [ORFactory floatVar:model name:@"R2"];
         id<ORFloatVar> CR2_0 = [ORFactory floatVar:model name:@"CR2"];
         id<ORFloatVar> CQ3_0 = [ORFactory floatVar:model name:@"CQ3"];
         id<ORFloatVar> Q3_0 = [ORFactory floatVar:model name:@"Q3"];
         id<ORFloatVar> R_0 = [ORFactory floatVar:model name:@"R"];
         id<ORFloatVar> q_0 = [ORFactory floatVar:model name:@"q"];
         id<ORFloatVar> b_0 = [ORFactory floatVar:model name:@"b"];
         
         NSMutableArray* toadd = [[NSMutableArray alloc] init];
         
         
         [toadd addObject:[q_0 eq: [[a_0 mul: a_0] sub: [b_0 mul:@(3.f)]]]];
         
         [toadd addObject:[r_0 eq: [[[[[a_0 mul:@(2.f)] mul: a_0] mul: a_0] sub: [[a_0 mul:@(9.f)] mul: b_0]] plus: [c_0 mul:@(27.f)]]]];
         
         
         [toadd addObject:[Q_0 eq: [q_0 div:@(9.f)]]];
         
         [toadd addObject:[R_0 eq: [r_0 div:@(54.f)]]];
         
         
         [toadd addObject:[Q3_0 eq: [[Q_0 mul:Q_0] mul:Q_0]]];
         
         [toadd addObject:[R2_0 eq: [R_0 mul:R_0]]];
         
         
         [toadd addObject:[CR2_0 eq: [[r_0 mul:@(729.f)] mul: r_0]]];
         
         [toadd addObject:[CQ3_0 eq: [[[q_0 mul:@(2916.f)] mul: q_0] mul: q_0]]];
         
         //assert(!(R == 0 && Q == 0));
         [toadd addObject:[R_0 eq:@(0.0f)]];
         [toadd addObject:[Q_0 eq:@(0.0f)]];
         //         [toadd add:[a_0 eq:@(15.0f)]];
         
     
      id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
      id<ORVarArray> vars =  [args makeDisabledArray:cp from:[model FPVars]];
      NSLog(@"%@",model);
      __block ORBool isSat;
      [args measure:^struct ORResult(){
         ORBool hascycle = NO;
         if([args cycleDetection]){
            hascycle = [args isCycle:model];
            NSLog(@"%s",(hascycle)?"YES":"NO");
         }
         isSat = false;
         if(!hascycle){
            id<ORIntArray> locc = [VariableLocalOccCollector collect:[model constraints] with:[model variables] tracker:model];
            [(CPCoreSolver*)cp setLOcc:locc];
            [cp solveOn:^(id<CPCommonProgram> p) {
               [args launchHeuristic:cp restricted:vars];
               //               check_solution([p floatValue:a], [p floatValue:b], [p floatValue:c], [p floatValue:s], [p floatValue:squared_area]);
               isSat = [args checkAllbound:model with:cp];
            } withTimeLimit:[args timeOut]];
         }
         struct ORResult r = FULLREPORT(isSat, [[cp engine] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation],[[cp engine] nbStaticRewrites],[[cp engine] nbDynRewrites]);
         printf("%s\n",(isSat)?"sat":"unsat");
         return r;
      }];
      return 0;
   }
}
