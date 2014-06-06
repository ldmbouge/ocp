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
         
         NSError* error = nil;
         NSXMLDocument* doc = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL URLWithString:@"file:///Users/ldm/scene.xml"] options:NSXMLDocumentTidyXML error:&error];
         NSXMLElement* elt = [doc rootElement];
         NSArray* an = [elt nodesForXPath:@"/scene/actors/actor/name/text()" error:&error];
         NSArray* rf = [elt nodesForXPath:@"/scene/actors/actor/fee/text()" error:&error];
         NSArray* ri = [elt nodesForXPath:@"/scene/actors/actor/@id" error:&error];
         NSMutableArray* sc = (id)[elt nodesForXPath:@"/scene/appearances/scene" error:&error];
         id tmp[rf.count];
         for(ORInt i=0;i<[an count];i++)
            tmp[[[ri[i] stringValue] integerValue]] = @([[ri[i] stringValue] integerValue]);
         //NSArray* actors = [NSArray arrayWithObjects:tmp count:an.count];
         for(ORInt i=0;i < [rf count];i++)
            tmp[[[ri[i] stringValue] integerValue]] = @([[rf[i] stringValue] integerValue]);
         NSArray* xmlFee = [NSArray arrayWithObjects:tmp count:rf.count];
         for(ORInt i=0;i < [sc count];i++) {
            NSArray* actor = [sc[i] nodesForXPath:@"actor/@ref" error:&error];
            id<ORIntSet> inScene = [ORFactory intSet:model];
            for(ORInt j=0;j < [actor count];j++)
               [inScene insert:(ORInt) [[actor[j] stringValue] integerValue]];
            sc[i] = inScene;
         }
         
         ORInt maxScene = (ORInt) [sc count];
         id<ORIntRange> Actors = RANGE(model,0,(ORInt)[an count] - 1);
         id<ORIntRange> Scenes = RANGE(model,0,maxScene-1);
         id<ORIntRange> Days   = RANGE(model,0,4);
         id<ORIntArray>    fee = [ORFactory intArray:model array:xmlFee];
         id<ORIdArray> appears = [ORFactory idArray:model array:sc ];      
         
         id<ORIdArray> which = [ORFactory idArray:model range:Actors with:^id(ORInt a) {
            return filterSet(model, Scenes, ^ORBool(ORInt i) { return [(id<ORIntSet>)appears[i] member:a];});
         }];
         id<ORIntVarArray> __block shoot = [ORFactory intVarArray:model range:Scenes domain:Days];
         id<ORIntArray> low = [ORFactory intArray:model range:Days value:0];
         id<ORIntArray> up  = [ORFactory intArray:model range:Days value:5];
         
         [notes dc:[model add:[ORFactory cardinality:shoot low:low up:up]]];
         [model minimize:Sum2(model, a, Actors, d, Days,
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

