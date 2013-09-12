//
//  main.m
//  who_killed_agatha
//
//  Created by Eugene Kovalev on 9/10/13.
//  Copyright (c) 2013 NICTA. All rights reserved.
//

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgram.h>

int main(int argc, const char * argv[])
{
   
   @autoreleasepool {
      id<ORModel> model = [ORFactory createModel];
      
      ORInt agatha = 1;
      ORInt butler = 2;
      ORInt charles = 3;
      id<ORIntRange> r = RANGE(model, 1, 3);
      id<ORIntRange> b = RANGE(model,0,1);
      id<ORIntVar> the_killer = [ORFactory intVar:model domain:r];
      id<ORIntVar> the_victim = [ORFactory intVar:model domain:r];
      //id<ORIntVar> the_victim = [ORFactory intVar:model value:agatha];
      
      id<ORIntVarMatrix> hates = [ORFactory intVarMatrix:model range:r :r domain:b];
      id<ORIntVarMatrix> richer = [ORFactory intVarMatrix:model range:r :r domain:b];
      
      //Constraints:
      [model add: [[hates elt:the_killer elt:the_victim] eq: @1]];
      [model add: [[richer elt:the_killer elt:the_victim] eq: @0]];
      
      for (ORUInt i = 1; i <= 3; i++) {
         [model add:[[richer at:i:i] eq:@0]];
         for (ORUInt j = 1; j <= 3; j++) {
            if (i == j) continue;
            //                [model add:[[[richer at:i :j] eq: @1]  imply:[[richer at:j :i] neq: @0]]];
            //                [model add:[[[richer at:j :i] neq: @0] imply:[[richer at:i :j]  eq: @1]]];
            [model add:[[richer at:i :j] eq: [[richer at:j:i] eq:@0]]];
         }
      }
      
      for (ORInt i = 1; i <= 3; i++){
         [model add:[[hates at:agatha:i]           imply:[[hates at:charles:i] eq: @0]]];
         [model add:[[[richer at:i:agatha] eq: @0] imply:[hates at:butler :i]]];
         [model add:[[hates at:agatha:i] 				imply:[hates at:butler :i]]];
         [model add:[Sum(model,j,r,[hates at:i :j]) leq:@2]];
      }
      [model add: [[hates at:agatha:charles] eq: @1]];
      [model add: [[hates at:agatha:agatha] eq: @1]];
      [model add: [[hates at:agatha:butler] eq: @0]];
      [model add: [the_victim eq: @(agatha)]];
      
      id<CPProgram> cpp = [ORFactory createCPProgram:model];
      
      [cpp solveAll:
       ^() {
          [cpp labelArray:[model intVars]];
          NSLog(@"Solution: Victim: %i Killer: %i",[cpp intValue:the_victim],
                [cpp intValue:the_killer]);
       }
       ];
   }
   return 0;
}

