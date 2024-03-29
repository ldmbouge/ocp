/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTAq, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         id<ORModel> mdl = [ORFactory createModel];
         ORInt nbConfigs = 6;
         id<ORIntRange> Configs = RANGE(mdl,1,nbConfigs);
         ORInt choiceConfig = [args size];
         ORInt nbPeriods    = [args nArg];
         id<ORIntRange> Hosts = RANGE(mdl,1,13);
         id<ORIntRange> Guests = RANGE(mdl,1,29);
         id<ORIntRange> Periods = RANGE(mdl,1,nbPeriods);
         id<ORIntArray> cap = [ORFactory intArray: mdl range: Hosts value: 0];
         id<ORIntArray> crew = [ORFactory intArray: mdl range: Guests value: 0];
         
         id<ORIntSetArray> config = [ORFactory intSetArray: mdl range: Configs];
         config[1] = COLLECT(mdl,i,RANGE(mdl,1,12),i);
         [config[1] insert: 16];
         config[2] = COLLECT(mdl,i,RANGE(mdl,1,13),i);
         config[3] = COLLECT(mdl,i,RANGE(mdl,3,13),i);
         [config[3] insert: 1];
         [config[3] insert: 19];
         config[4] = COLLECT(mdl,i,RANGE(mdl,3,13),i);
         [config[4] insert: 25];
         [config[4] insert: 26];
         config[5] = COLLECT(mdl,i,RANGE(mdl,1,11),i);
         [config[5] insert: 19];
         [config[5] insert: 21];
         config[6] = COLLECT(mdl,i,RANGE(mdl,1,9),i);
         for(ORInt i = 16; i <= 19; i++)
            [config[6] insert: i];
         
         NSLog(@"%@",config);
         
         FILE* dta = fopen("progressive.txt","r");
         ORInt h = 1;
         ORInt g = 1;
         for(ORInt i = 1; i <= 42; i++) {
            ORInt id, bcap, sz;
            fscanf(dta, "%d",&id);
            fscanf(dta, "%d",&bcap);
            fscanf(dta, "%d",&sz);
            if ([config[choiceConfig] member: id]) {
               [cap set: bcap - sz at: h];
               h++;
            }
            else {
               [crew set: sz at: g];
               g++;
            }
         }
         NSLog(@"CAP = %@",cap);
         NSLog(@"CREW= %@",crew);
         ORLong startTime = [ORRuntimeMonitor cputime];
         id<ORAnnotation> notes = [ORFactory annotation];
         id<ORIntVarMatrix> boat = [ORFactory intVarMatrix:mdl range:Guests :Periods domain: Hosts];
         for(ORInt g = Guests.low; g <= Guests.up; g++)
            [notes dc:[mdl add: [ORFactory alldifferent: All(mdl,ORIntVar, p, Periods, [boat at:g :p]) ]]];
         for(ORInt g1 = Guests.low; g1 <= Guests.up; g1++)
            for(ORInt g2 = g1 + 1; g2 <= Guests.up; g2++)
               [mdl add: [Sum(mdl,p,Periods,[[boat at: g1 : p] eq: [boat at: g2 : p]]) leq: @1]];
         for(ORInt p = Periods.low; p <= Periods.up; p++) {
            [mdl add: [ORFactory packing:mdl item:All(mdl,ORIntVar, g, Guests, [boat at: g :p]) itemSize: crew binSize:cap]];
            for(ORInt h=Hosts.low ; h <= Hosts.up; h++)
               [mdl add:[Sum(mdl, g, Guests, [[[boat at:g :p] eq:@(h)] mul: @([crew at:g])]) leq:@([cap at:h])]];
         }
         
         id<CPProgram> cp = [args makeProgram:mdl annotation:notes];
         [cp solve: ^{
	     for(ORInt p = Periods.low; p <= Periods.up; p++) {
	      //  id<ORIntVarArray> slice = All(cp,ORIntVar,i,Guests,[boat at:i :p]);
	      // [cp labelArray:slice];

	      // for(ORInt g=Guests.low;g <= Guests.up;g++) {
	      // 	[cp tryall:Hosts suchThat:^bool(ORInt h) { return [cp member:h in:[boat at: g: p]];}
	      // 		in:^(ORInt h) {
	      // 		  [cp label:[boat at:g :p] with:h];
	      // 		}
	      // 	onFailure:^(ORInt h) {
	      // 		  [cp diff:[boat at:g :p] with:h];
	      // 		}];		
	      // }
	      [cp forall:Guests 
	      	suchThat: ^ORBool(ORInt g) { return ![cp bound:[boat at:g :p]];}
		  orderedBy: nil // ^ORInt(ORInt g) { return [cp domsize:[boat at:g :p]];}
                       do:^(ORInt g) {
			   [cp tryall:Hosts suchThat: ^ORBool(ORInt h) { return [cp member:h in:[boat at: g: p]];}
                                  in:^(ORInt h) {
                                     [cp label:[boat at:g :p] with:h];
                                  }
                           onFailure:^(ORInt h) {
                              [cp diff:[boat at:g :p] with:h];
                           }];
                       }];
	    }            
            ORLong endTime = [ORRuntimeMonitor cputime];
            
            for(ORInt p = Periods.low; p <= Periods.up; p++) {
               NSMutableString* line = [[NSMutableString alloc] initWithCapacity:64];
               [line appendFormat:@"p=%2d : ",p];
               for(ORInt g = Guests.low; g <= Guests.up; g++) {
                  if ([cp bound:[boat at: g : p]])
                     [line appendFormat:@"%2d ",[cp intValue:[boat at: g :p]]];
                  else [line appendFormat:@"%@",[boat at: g :p] ];
               }
               NSLog(@"%@",line);
               [line release];
            }
            NSLog(@"Execution Time: %lld \n",endTime - startTime);
            
            int use[14];
            for(ORInt p = Periods.low; p <= Periods.up; p++) {
               for(ORInt h = 1; h <= 13; h++)
                  use[h] = 0;
               
               for(ORInt g = Guests.low; g <= Guests.up; g++)
                  use[[cp intValue:[boat at: g : p]]] += [crew at: g];
               for(ORInt h = 1; h <= 13; h++)
                  if (use[h] > [cap at: h]) {
                     printf("Bad capacity at %d - %d: %d instead of %d \n",p,h,use[h],[cap at: h]);
                     abort();
                  }
            }
            for(ORInt g1 = Guests.low; g1 <= Guests.up; g1++) {
               for(ORInt g2 = g1 + 1; g2 <= Guests.up; g2++) {
                  ORInt nbEq = 0;
                  for(ORInt p=Periods.low;p <= Periods.up;p++) {
                     nbEq += [cp intValue:[boat at: g1 : p]] == [cp intValue:[boat at: g2 :p]];
                     if (nbEq >= 2) {
                        NSLog(@"Violation of social: g1=%d g2=%d p=%d  %@   -  %@",g1,g2,p,[boat at:g1:p],[boat at:g2 :p]);
                        abort();
                     }
                  }
                  assert (nbEq <= 1);
               }
            }
            
            for(ORInt g = Guests.low; g <= Guests.up; g++) {
               for(ORInt p1 = Periods.low; p1 <= Periods.up; p1++)
                  for(ORInt p2 = p1 + 1; p2 <= Periods.up; p2++) {
                     if ([cp intValue:[boat at: g : p1]] == [cp intValue:[boat at: g : p2]]) {
                        printf("boat[%d,%d] = %d and boat[%d,%d] = %d \n",g,p1,g,p2,[cp intValue:[boat at:g : p1]],[cp intValue:[boat at: g : p2]]);
                        printf("all different is wrong \n");
                        abort();
                     }
                  }
            }
            
            for(ORInt g1 = Guests.low; g1 <= Guests.up; g1++)
               for(ORInt g2 = g1 + 1; g2 <= Guests.up; g2++) {
                  ORInt s = 0;
                  for(ORInt p = Periods.low; p <= Periods.up; p++)
                     s += [cp intValue:[boat at: g1 : p]] == [cp intValue:[boat at:g2 : p]];
                  if (s > 1) {
                     printf("guest %d and guest %d \n",g1,g2);
                     printf("social constraint is wrong \n");
                     abort();
                  }
               }
         }
          ];
         NSLog(@"Solver status: %@\n",cp);
         NSLog(@"Quitting");
         struct ORResult res = REPORT(1, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return res;
      }];
   }
   return 0;
}
