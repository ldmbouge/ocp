//
//  main.m
//  diet
//
//  Created by Laurent Michel on 5/24/16.
//
//

#import <ORProgram/ORProgram.h>

int ub[7] = { 0,4,3,2,8,2,2};
int r1[7] = { 0,110,205,160,160,420,260 };
int r2[7] = { 0,4,32,13,8,4,14};
int r3[7] = { 0,2,12,54,285,22,80};
int o[7]  = { 0,3,24,13,9,20,19};

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORLong startTime = [ORRuntimeMonitor cputime];
      id<ORModel> model = [ORFactory createModel];
      id<ORIntRange> V = RANGE(model,1,6);
      id<ORRealVarArray> x = (id)[ORFactory idArray:model range:V with:^id _Nonnull(ORInt k) {
         return [ORFactory realVar:model low:0 up:ub[k]];
         //return [ORFactory intVar:model bounds:RANGE(model,0,ub[k])];
      }];
      [model add:[Sum(model,j,V,[@(r1[j]) mul: x[j]]) geq: @(2000)]];
      [model add:[Sum(model,j,V,[@(r2[j]) mul: x[j]]) geq: @(55)]];
      [model add:[Sum(model,j,V,[@(r3[j]) mul: x[j]]) geq: @(800)]];
      [model minimize:Sum(model,j,V,[@(o[j]) mul: x[j]])];

      id<MIPProgram> mip = [ORFactory createMIPProgram: model];
      [mip solve];
      ORLong endTime = [ORRuntimeMonitor cputime];
      printf("Execution Time: %lld \n",endTime - startTime);
      NSLog(@"Objective     : %@",[mip objectiveValue]);
      for(ORInt i=1;i <= 6;i++)
         NSLog(@"x[%d] = %f",i,[mip doubleValue:x[i]]);
      [mip release];
      return 0;
   }
   return 0;
}
