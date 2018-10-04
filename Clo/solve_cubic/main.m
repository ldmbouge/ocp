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
      [args measure:^struct ORResult(){
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
         id<ORGroup> g = [args makeGroup:model];
         [g add:[q_0 eq: [[a_0 mul: a_0] sub: [b_0 mul:@(3.f)]]]];
         
         [g add:[r_0 eq: [[[[[a_0 mul:@(2.f)] mul: a_0] mul: a_0] sub: [[a_0 mul:@(9.f)] mul: b_0]] plus: [c_0 mul:@(27.f)]]]];
         
         
         [g add:[Q_0 eq: [q_0 div:@(9.f)]]];
         
         [g add:[R_0 eq: [r_0 div:@(54.f)]]];
         
         
         [g add:[Q3_0 eq: [[Q_0 mul:Q_0] mul:Q_0]]];
         
         [g add:[R2_0 eq: [R_0 mul:R_0]]];
         
         
         [g add:[CR2_0 eq: [[r_0 mul:@(729.f)] mul: r_0]]];
         
         [g add:[CQ3_0 eq: [[[q_0 mul:@(2916.f)] mul: q_0] mul: q_0]]];
         
         //assert(!(R == 0 && Q == 0));
         [g add:[R_0 eq:@(0.0f)]];
         [g add:[Q_0 eq:@(0.0f)]];
//         [g add:[a_0 eq:@(15.0f)]];
         
         [model add:g];
         id<CPProgram> cp = [args makeProgram:model];
         
         id<ORFloatVarArray> vars = [model floatVars];
         __block bool found = false;
         [cp solveOn:^(id<CPCommonProgram> p) {
            [args printStats:g model:model program:cp];
            [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
            NSLog(@"Valeurs solutions : \n");
            found=true;
            for(id<ORFloatVar> v in vars){
               found &= [p bound: v];
               NSLog(@"%@ : %20.20e (%s) %@",v,[p floatValue:v],[p bound:v] ? "YES" : "NO",[p concretize:v]);
            }
            
            [args checkAbsorption:vars solver:cp];
            check_solution([p floatValue:a_0],[p floatValue:b_0],[p floatValue:c_0],[p floatValue:r_0],[p floatValue:q_0],[p floatValue:Q_0],[p floatValue:R_0], [p floatValue:R2_0],[p floatValue:Q3_0],[p floatValue:CR2_0],[p floatValue:CQ3_0]);
         } withTimeLimit:[args timeOut]];
         
         struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
      
   }
   return 0;
}
