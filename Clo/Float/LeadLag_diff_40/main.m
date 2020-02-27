//
//  LeadLag_diff_10.m
//  rumps
//
//  Created by cpjm on 25/08/2019.
//  Copyright © 2019 Laurent Michel. All rights reserved.
//

#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

/*
 // LeadLag (These Nasrine Damouche P96, L6.2 & L6.3
 // Original
 y = [2.1,17.9]; xc0 = 0.0; xc1 = 0.0; yd = 5.0; Ac11 = 1.0; Bc0 = 1.0;
 Bc1 = 0.0; Cc0 = 564.48; Ac00 = 0.499; Ac01 = −0.05; Ac10 = 0.01;
 Cc1 = 0.0; Dc = −1280.0; t = 0.0;
 while(t < 5.0) do {
 yc = (y − yd);
 if (yc < −1.0) { yc = −1.0; }
 if(1.0 < yc) { yc = 1.0; }
 xc0 = (Ac00 * xc0) + (Ac01 * xc1) + (Bc0 * yc);
 xc1 = (Ac10 * xc0) + (Ac11 * xc1) + (Bc1 * yc);
 u = (Cc0 * xc0) + (Cc1 * xc1) + (Dc * yc);
 t = (t + 0.1);
 }
 
 // Optimized
 y = [2.1,17.9]; t = 0.0; xc1 = 0.0; xc0 = 0.0;
 while(t < 5.0) do {
 yc = (−5.0 + y);
 if (yc < −1.0) { yc = −1.0; }
 if (1.0 < yc) { yc = 1.0; }
 u = (((564.48 * xc0)+(0.0 * xc1))+(−1280.0 * yc ));
 xc0 = (((−0.05 * xc1)+(1.0 * yc))+(0.499 * xc0));
 xc1 = (((0.01 * xc0)+(0.0 * yc))+(1.0 * xc1));
 t = (t + 0.1);
 }
 */

#define NBLOOPS 40

int main(int argc, const char * argv[]) {
   /*
    1: Logic (10 & 5.0e-8, -> 17.748s)
    2: Disjunctive, combined (10 & 5.0e-8, -> 0.490s) (50 & 5.96e-8 -> TO)
    3: Disjunctive, separated ifs (10 & 5.0e-8, -> 0.5s) (50 & 5.96e-8 -> 11.834s)
    4: Guarded, combined (10 & 5.0e-8, -> 0.390s) (50 & 5.96e-8 -> TO)
    *: Guarded, separated ifs (10 & 5.0e-8, -> 0.306s) (50 & 5.96e-8 -> 4.63s)
    */
   int first_if = 5;
   int second_if = 5;
   
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      
      id<ORModel> model = [ORFactory createModel];
      
      NSMutableArray* toadd = [[NSMutableArray alloc] init];
      
      // Input var
      id<ORFloatVar> y = [ORFactory floatVar:model low:2.1f up:17.9f name:@"y"];
      
      // Constants
      //xc0 = 0.0; xc1 = 0.0; yd = 5.0; Ac11 = 1.0; Bc0 = 1.0;
      //Bc1 = 0.0; Cc0 = 564.48; Ac00 = 0.499; Ac01 = −0.05; Ac10 = 0.01;
      //Cc1 = 0.0; Dc = −1280.0; t = 0.0;
      id<ORExpr> yd   = [ORFactory float:model value:5.0f];
      id<ORExpr> Ac11 = [ORFactory float:model value:1.0f];
      id<ORExpr> Bc0  = [ORFactory float:model value:1.0f];
      id<ORExpr> Bc1  = [ORFactory float:model value:0.0f];
      id<ORExpr> Cc0  = [ORFactory float:model value:564.48f];
      id<ORExpr> Ac00 = [ORFactory float:model value:0.499f];
      id<ORExpr> Ac01 = [ORFactory float:model value:-0.05f];
      id<ORExpr> Ac10 = [ORFactory float:model value:0.01f];
      id<ORExpr> Cc1  = [ORFactory float:model value:0.0f];
      id<ORExpr> Dc   = [ORFactory float:model value:-1280.0f];
      
      // Local vars
      id<ORFloatVarArray> yc0 = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"yc0"];
      id<ORFloatVarArray> yc1 = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"yc1"];
      id<ORFloatVarArray> yc2 = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"yc2"];
      id<ORFloatVarArray> xc0 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"xc0"];
      id<ORFloatVarArray> xc1 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"xc1"];
      id<ORFloatVarArray> u   = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"u"];
      
      id<ORFloatVarArray> yc0_opt = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"yc0_opt"];
      id<ORFloatVarArray> yc1_opt = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"yc1_opt"];
      id<ORFloatVarArray> yc2_opt = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"yc2_opt"];
      id<ORFloatVarArray> xc0_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"xc0_opt"];
      id<ORFloatVarArray> xc1_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"xc1_opt"];
      id<ORFloatVarArray> u_opt   = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"u_opt"];
      
      id<ORFloatVar> diff = [ORFactory floatVar:model name:@"diff"];
      
      [toadd addObject:[xc0[0] set: @(0.0f)]];
      [toadd addObject:[xc1[0] set: @(0.0f)]];
      [toadd addObject:[xc0_opt[0] set: @(0.0f)]];
      [toadd addObject:[xc1_opt[0] set: @(0.0f)]];
      for (ORUInt n = 1; n <= NBLOOPS; n++) {
         [toadd addObject:[yc0[n] set:[y sub:yd]]];
         
         switch (first_if) {
            case 1: // Logic
               [toadd addObject:[[[yc0[n] lt: @(-1.0f)] land: [yc2[n] set: @(-1.0f)]] lor:
                                 [[[yc0[n] gt: @(1.0f)]  land: [yc2[n] set: @(1.0f)]] lor:
                                  [[yc0[n] geq: @(-1.0f)] land:
                                   [[yc0[n] leq: @(1.0f)]  land: [yc2[n] set: yc0[n]]]]]]];
               break;
            case 2: // Disjunctive, combined if
            {
               id<ORGroup> if_grp_1 = [args makeGroup:model];
               id<ORGroup> if_grp_2 = [args makeGroup:model];
               id<ORGroup> else_grp = [args makeGroup:model];
               
               [if_grp_1 add:[yc0[n] lt: @(-1.0f)]];
               [if_grp_1 add:[yc2[n] set: @(-1.0f)]];
               
               [if_grp_2 add:[yc0[n] gt: @(1.0f)]];
               [if_grp_2 add:[yc2[n] set: @(1.0f)]];
               
               [else_grp add:[yc0[n] geq: @(-1.0f)]];
               [else_grp add:[yc0[n] leq: @(1.0f)]];
               [else_grp add:[yc2[n] set: yc0[n]]];
               
               [toadd addObject:[ORFactory cdisj:model clauses:@[if_grp_1,if_grp_2,else_grp]]];
            }
               break;
            case 3: // Dijunctive, separates ifs
            { // Does work: if used for both (2.8s)
               id<ORGroup> if_grp   = [args makeGroup:model];
               id<ORGroup> else_grp = [args makeGroup:model];
               
               [if_grp add:[yc0[n] lt: @(-1.0f)]];
               [if_grp add:[yc1[n] set: @(-1.0f)]];
               
               [else_grp add:[yc0[n] geq: @(-1.0f)]];
               [else_grp add:[yc1[n] set: yc0[n]]];
               
               [toadd addObject:[ORFactory cdisj:model clauses:@[if_grp,else_grp]]];
            }
            {
               id<ORGroup> if_grp   = [args makeGroup:model];
               id<ORGroup> else_grp = [args makeGroup:model];
               
               [if_grp add:[yc1[n] gt: @(1.0f)]];
               [if_grp add:[yc2[n] set: @(1.0f)]];
               
               [else_grp add:[yc1[n] leq: @(1.0f)]];
               [else_grp add:[yc2[n] set: yc1[n]]];
               
               [toadd addObject:[ORFactory cdisj:model clauses:@[if_grp,else_grp]]];
            }
               break;
            case 4:
            { // Guarded, combined ifs
               id<ORExpr> ifCond_1  = [yc0[n] lt: @(-1.0f)];
               id<ORExpr> ifCond_2  = [yc0[n] gt: @(1.0f)];
               id<ORIntVar> thenGuard_1 = [ORFactory boolVar:model];
               id<ORIntVar> thenGuard_2 = [ORFactory boolVar:model];
               id<ORIntVar> elseGuard = [ORFactory boolVar:model];
               [toadd addObject: [ifCond_1 eq: thenGuard_1]];
               [toadd addObject: [ifCond_2 eq: thenGuard_2]];
               [toadd addObject: [[[ifCond_1 neg] land: [ifCond_2 neg]] eq: elseGuard]];
               
               id<ORGroup> thenGroup_1 = [ORFactory group:model guard:thenGuard_1];
               [thenGroup_1 add: [yc2[n] set: @(-1.0f)]];
               [toadd addObject:thenGroup_1];
               
               id<ORGroup> thenGroup_2 = [ORFactory group:model guard:thenGuard_2];
               [thenGroup_2 add: [yc2[n] set: @(1.0f)]];
               [toadd addObject:thenGroup_2];
               
               id<ORGroup> elseGroup = [ORFactory group:model guard:elseGuard];
               [elseGroup add: [yc2[n] set: yc0[n]]];
               [toadd addObject:elseGroup];
            }
               break;
            default:
            { // Guarded, separated ifs
               id<ORExpr> ifCond  = [yc0[n] lt: @(-1.0f)];
               id<ORIntVar> thenGuard = [ORFactory boolVar:model];
               id<ORIntVar> elseGuard = [ORFactory boolVar:model];
               [toadd addObject: [ifCond eq: thenGuard]];
               [toadd addObject: [[ifCond neg] eq: elseGuard]];
               
               id<ORGroup> thenGroup = [ORFactory group:model guard:thenGuard];
               [thenGroup add: [yc1[n] set: @(-1.0f)]];
               [toadd addObject:thenGroup];
               
               id<ORGroup> elseGroup = [ORFactory group:model guard:elseGuard];
               [elseGroup add: [yc1[n] set: yc0[n]]];
               [toadd addObject:elseGroup];
            }
            {
               id<ORExpr> ifCond  = [yc1[n] gt: @(1.0f)];
               id<ORIntVar> thenGuard = [ORFactory boolVar:model];
               id<ORIntVar> elseGuard = [ORFactory boolVar:model];
               [toadd addObject: [ifCond eq: thenGuard]];
               [toadd addObject: [[ifCond neg] eq: elseGuard]];
               
               id<ORGroup> thenGroup = [ORFactory group:model guard:thenGuard];
               [thenGroup add: [yc2[n] set: @(1.0f)]];
               [toadd addObject:thenGroup];
               
               id<ORGroup> elseGroup = [ORFactory group:model guard:elseGuard];
               [elseGroup add: [yc2[n] set: yc1[n]]];
               [toadd addObject:elseGroup];
            }
               break;
         }
         
         [toadd addObject:[xc0[n] set: [[xc0[n-1] mul: Ac00] plus:[[xc1[n-1] mul: Ac01] plus: [yc2[n] mul: Bc0]]]]];
         [toadd addObject:[xc1[n] set: [[xc0[n] mul: Ac10] plus:[[xc1[n-1] mul: Ac11] plus: [yc2[n] mul: Bc1]]]]];
         [toadd addObject:[u[n] set: [[xc0[n] mul: Cc0] plus:[[xc1[n] mul: Cc1] plus: [yc2[n] mul: Dc]]]]];
         
         [toadd addObject:[yc0_opt[n] set:[y plus: @(-5.0f)]]];
         
         switch (second_if) {
            case 1: // Logic
               [toadd addObject:[[[yc0_opt[n] lt: @(-1.0f)] land: [yc2_opt[n] set: @(-1.0f)]] lor:
                                 [[[yc0_opt[n] gt: @(1.0f)]  land: [yc2_opt[n] set: @(1.0f)]] lor:
                                  [[yc0_opt[n] geq: @(-1.0f)] land:
                                   [[yc0_opt[n] leq: @(1.0f)]  land: [yc2_opt[n] set: yc0_opt[n]]]]]]];
               break;
            case 2: // Disjunctive, combined
            {
               id<ORGroup> if_grp_1 = [args makeGroup:model];
               id<ORGroup> if_grp_2 = [args makeGroup:model];
               id<ORGroup> else_grp = [args makeGroup:model];
               
               [if_grp_1 add:[yc0_opt[n] lt: @(-1.0f)]];
               [if_grp_1 add:[yc2_opt[n] set: @(-1.0f)]];
               
               [if_grp_2 add:[yc0_opt[n] gt: @(1.0f)]];
               [if_grp_2 add:[yc2_opt[n] set: @(1.0f)]];
               
               [else_grp add:[yc0_opt[n] geq: @(-1.0f)]];
               [else_grp add:[yc0_opt[n] leq: @(1.0f)]];
               [else_grp add:[yc2_opt[n] set: yc0_opt[n]]];
               
               [toadd addObject:[ORFactory cdisj:model clauses:@[if_grp_1,if_grp_2,else_grp]]];
            }
               break;
            case 3: // Disjunctive, separated ifs
            {
               id<ORGroup> if_grp   = [args makeGroup:model];
               id<ORGroup> else_grp = [args makeGroup:model];
               
               [if_grp add:[yc0_opt[n] lt: @(-1.0f)]];
               [if_grp add:[yc1_opt[n] set: @(-1.0f)]];
               
               [else_grp add:[yc0_opt[n] geq: @(-1.0f)]];
               [else_grp add:[yc1_opt[n] set: yc0_opt[n]]];
               
               [toadd addObject:[ORFactory cdisj:model clauses:@[if_grp,else_grp]]];
            }
            {
               id<ORGroup> if_grp   = [args makeGroup:model];
               id<ORGroup> else_grp = [args makeGroup:model];
               
               [if_grp add:[yc1_opt[n] gt: @(1.0f)]];
               [if_grp add:[yc2_opt[n] set: @(1.0f)]];
               
               [else_grp add:[yc1_opt[n] leq: @(1.0f)]];
               [else_grp add:[yc2_opt[n] set: yc1_opt[n]]];
               
               [toadd addObject:[ORFactory cdisj:model clauses:@[if_grp,else_grp]]];
            }
               break;
            case 4: // Guarded, combined ifs
            {
               id<ORExpr> ifCond_1  = [yc0_opt[n] lt: @(-1.0f)];
               id<ORExpr> ifCond_2  = [yc0_opt[n] gt: @(1.0f)];
               id<ORIntVar> thenGuard_1 = [ORFactory boolVar:model];
               id<ORIntVar> thenGuard_2 = [ORFactory boolVar:model];
               id<ORIntVar> elseGuard = [ORFactory boolVar:model];
               [toadd addObject: [ifCond_1 eq: thenGuard_1]];
               [toadd addObject: [ifCond_2 eq: thenGuard_2]];
               [toadd addObject: [[[ifCond_1 neg] land: [ifCond_2 neg]] eq: elseGuard]];
               
               id<ORGroup> thenGroup_1 = [ORFactory group:model guard:thenGuard_1];
               [thenGroup_1 add: [yc2_opt[n] set: @(-1.0f)]];
               [toadd addObject:thenGroup_1];
               
               id<ORGroup> thenGroup_2 = [ORFactory group:model guard:thenGuard_2];
               [thenGroup_2 add: [yc2_opt[n] set: @(1.0f)]];
               [toadd addObject:thenGroup_2];
               
               id<ORGroup> elseGroup = [ORFactory group:model guard:elseGuard];
               [elseGroup add: [yc2_opt[n] set: yc0_opt[n]]];
               [toadd addObject:elseGroup];
            }
               break;
            default: // Guarded, separated ifs
            {
               id<ORExpr> ifCond  = [yc0_opt[n] lt: @(-1.0f)];
               id<ORIntVar> thenGuard = [ORFactory boolVar:model];
               id<ORIntVar> elseGuard = [ORFactory boolVar:model];
               [toadd addObject: [ifCond eq: thenGuard]];
               [toadd addObject: [[ifCond neg] eq: elseGuard]];
               
               id<ORGroup> thenGroup = [ORFactory group:model guard:thenGuard];
               [thenGroup add: [yc1_opt[n] set: @(-1.0f)]];
               [toadd addObject:thenGroup];
               
               id<ORGroup> elseGroup = [ORFactory group:model guard:elseGuard];
               [elseGroup add: [yc1_opt[n] set: yc0_opt[n]]];
               [toadd addObject:elseGroup];
            }
            {
               id<ORExpr> ifCond  = [yc1_opt[n] gt: @(1.0f)];
               id<ORIntVar> thenGuard = [ORFactory boolVar:model];
               id<ORIntVar> elseGuard = [ORFactory boolVar:model];
               [toadd addObject: [ifCond eq: thenGuard]];
               [toadd addObject: [[ifCond neg] eq: elseGuard]];
               
               id<ORGroup> thenGroup = [ORFactory group:model guard:thenGuard];
               [thenGroup add: [yc2_opt[n] set: @(1.0f)]];
               [toadd addObject:thenGroup];
               
               id<ORGroup> elseGroup = [ORFactory group:model guard:elseGuard];
               [elseGroup add: [yc2_opt[n] set: yc1_opt[n]]];
               [toadd addObject:elseGroup];
            }
               break;
         }
         /*
          [toadd addObject:[u_opt[n] set: [[xc0_opt[n-1] mul: @(564.48f)] plus:
          [[xc1_opt[n-1] mul: @(0.0f)] plus: [yc1_opt[n] mul: @(-1280.0f)]]]]];
          */
         [toadd addObject:[xc0_opt[n] set: [[xc1_opt[n-1] mul: @(-0.05f)] plus:
                                            [[yc2_opt[n] mul: @(1.0f)] plus: [xc0_opt[n-1] mul: @(0.499f)]]]]];
         [toadd addObject:[xc1_opt[n] set: [[xc0_opt[n] mul: @(0.01f)] plus:
                                            [[yc2_opt[n] mul: @(0.0f)] plus: [xc1_opt[n-1] mul: @(1.0f)]]]]];
         [toadd addObject:[u_opt[n] set: [[xc0_opt[n] mul: @(564.48f)] plus:
                                          [[xc1_opt[n] mul: @(0.0f)] plus: [yc2_opt[n] mul: @(-1280.0f)]]]]];
      }
      
      [toadd addObject:[diff set: [u_opt[NBLOOPS] sub: u[NBLOOPS]]]];
      [toadd addObject:[[diff mul: diff] geq:@(5.96e-8f)]];
      
      id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
      [ORCmdLineArgs defaultRunner:args model:model program:cp restricted:@[y]];
      
   }
   return 0;
}

