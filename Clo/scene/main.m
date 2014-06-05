/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"

id<ORIntSet> filterSet(id<ORTracker> t,id<ORIntIterable> s,ORBool(^cond)(ORInt i))
{
   id<ORIntSet> sub = [ORFactory intSet:t];
   [s enumerateWithBlock:^(ORInt i) {
      if (cond(i))
         [sub insert:i];
   }];
   return sub;
}

ORInt sumSet(id<ORIntIterable> s,ORInt(^term)(ORInt i))
{
   ORInt __block ttl = 0;
   [s enumerateWithBlock:^(ORInt i) {
      ttl += term(i);
   }];
   return ttl;
}

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];
         id<ORAnnotation> notes = [ORFactory annotation];
         ORInt maxScene = 19;
         id<ORIntRange> Scenes = RANGE(model,0,maxScene-1);
         id<ORIntRange> Days   = RANGE(model,0,4);
         typedef enum : NSUInteger {
            Patt=0, Casta, Scolaro, Murphy, Brown, Hacket,Anderson, McDougal, Mercer, Spring, Thompson
         } Actor;
         id<ORIntArray>    fee = [ORFactory intArray:model array:@[@26481,@25043,@30310,@4085,@7562,@9381,@8770,@5788,@7423,@3303,@9593]];
         id<ORIdArray> appears = [ORFactory idArray:model array:@[
                   [ORFactory intSet:model set:[NSSet setWithObjects:@(Hacket), nil]],
                   [ORFactory intSet:model set:[NSSet setWithObjects:@(Patt),@(Hacket),@(Brown),@(Murphy),nil]],
				       [ORFactory intSet:model set:[NSSet setWithObjects:@(McDougal),@(Scolaro),@(Mercer),@(Brown),nil]],
				       [ORFactory intSet:model set:[NSSet setWithObjects:@(Casta),@(Mercer),nil]],
				       [ORFactory intSet:model set:[NSSet setWithObjects:@(Mercer),@(Anderson),@(Patt),@(McDougal),@(Spring),nil]],
				       [ORFactory intSet:model set:[NSSet setWithObjects:@(Thompson),@(McDougal),@(Anderson),@(Scolaro),@(Spring),nil]],
				       [ORFactory intSet:model set:[NSSet setWithObjects:@(Casta),@(Patt),nil]],
				       [ORFactory intSet:model set:[NSSet setWithObjects:@(Mercer),@(Murphy),nil]],
				       [ORFactory intSet:model set:[NSSet setWithObjects:@(Casta),@(McDougal),@(Mercer),@(Scolaro),@(Thompson),nil]],
				       [ORFactory intSet:model set:[NSSet setWithObjects:@(Casta),@(McDougal),@(Scolaro),@(Patt),nil]],
				       [ORFactory intSet:model set:[NSSet setWithObjects:@(Patt),nil]],
				       [ORFactory intSet:model set:[NSSet setWithObjects:@(Hacket),@(Thompson),@(McDougal),@(Murphy),@(Brown),nil]],
				       [ORFactory intSet:model set:[NSSet setWithObjects:@(Hacket),@(Murphy),@(Casta),@(Patt),nil]],
				       [ORFactory intSet:model set:[NSSet setWithObjects:@(Anderson),@(Scolaro),nil]],
				       [ORFactory intSet:model set:[NSSet setWithObjects:@(Thompson),@(Murphy),@(McDougal),@(Patt),nil]],
				       [ORFactory intSet:model set:[NSSet setWithObjects:@(Scolaro),@(McDougal),@(Casta),@(Mercer),nil]],
				       [ORFactory intSet:model set:[NSSet setWithObjects:@(Scolaro),@(Patt),@(Brown),nil]],
				       [ORFactory intSet:model set:[NSSet setWithObjects:@(Scolaro),@(McDougal),@(Hacket),@(Thompson),nil]],
				       [ORFactory intSet:model set:[NSSet setWithObjects:@(Casta),nil]],
								  ]];

         id<ORIdArray> which = [ORFactory idArray:model range:RANGE(model,Patt,Thompson) with:^id(ORInt a) {
            return filterSet(model, Scenes, ^ORBool(ORInt i) { return [(id<ORIntSet>)appears[i] member:a];});
         }];
         id<ORIntVarArray> __block shoot = [ORFactory intVarArray:model range:Scenes domain:Days];
         id<ORIntArray> low = [ORFactory intArray:model range:Days value:0];
         id<ORIntArray> up  = [ORFactory intArray:model range:Days value:5];
         
         [notes dc:[model add:[ORFactory cardinality:shoot low:low up:up]]];
         [model minimize:Sum2(model, a, RANGE(model,Patt,Thompson), d, Days,
                              [Or(model, s, which[a], [shoot[s] eq:@(d)]) mul:@([fee at:a])
                              ])];
         
         id<CPProgram> __block cp = [args makeProgram:model annotation:notes];
         BOOL __block found = NO;
         id<ORIntRange> sr  = shoot.range;
         [cp onSolution:^{
            @autoreleasepool {
               id<ORIntArray> shootSol = [ORFactory intArray:cp range:shoot.range with:^ORInt(ORInt s) { return [cp intValue:shoot[s]];}];
               NSLog(@"Sol:(%@) %@",[[cp objective] value],shootSol);
            }
            found = YES;
         }];
         [cp solve:^{
            while (![cp allBound:shoot]) {
               ORInt s;
               {
                  // [ldm] With ARC, it is _capital_ to put the selector definition in a block.
                  //       otherwise, the block (and more importantly even, the closures it is defined on
                  //       live on when we enter and leave the tryall. But since we can leave the tryall several times
                  //       the release would be sent to the variables captured by those closures repeatedly!
                  //       By embedding in a block, the selector, closures and the variables the closures capture are sent a release
                  //       as soon as we leave the block and well before we head into the tryall. In essence the block
                  //       plays its role and control the lifetime of the selector and its captured variables.
                  id<ORSelect> sel = [ORFactory select:cp range:sr
                                              suchThat:^bool(ORInt s)    { return ! [cp bound:shoot[s]];}
                                             orderedBy:^ORFloat(ORInt s) {
                                                return ([cp domsize:shoot[s]] << 20) - sumSet(appears[s], ^ORInt(ORInt a) { return [fee at:a];});
                                             }];
                  s = [sel min];
               }
               if (s != MAXINT) {
                  ORInt mday = max(-1,[cp maxBound:shoot]);
                  [cp tryall:Days suchThat:^bool(ORInt d) { return d <= mday + 1 && [cp member:d in:shoot[s]];} in:^(ORInt d) {
                     [cp label:shoot[s] with:d];
                  } onFailure:^(ORInt d) {
                     [cp diff:shoot[s] with:d];
                  }];
               }
            }
         }];
         NSLog(@"Solver status: %@\n",cp);
         struct ORResult res = REPORT(found, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}

