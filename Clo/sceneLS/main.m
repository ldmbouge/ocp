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
#import <objls/LSFactory.h>
#import <objls/LSConstraint.h>
#import <objls/LSSolver.h>

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];
         id<ORAnnotation> notes = [ORFactory annotation];
         
         NSError* error = nil;
         NSString* cwd = [[NSFileManager defaultManager] currentDirectoryPath];
         NSString* fp  = [cwd stringByAppendingString:@"/scene.xml"];
         NSXMLDocument* doc = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL  fileURLWithPath:fp] options:NSXMLDocumentTidyXML error:&error];
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
         int vals[5] = {5,5,5,4,0};
         ORInt maxScene = (ORInt) [sc count];
         id<ORIntRange> Actors = RANGE(model,0,(ORInt)[an count] - 1);
         id<ORIntRange> Scenes = RANGE(model,0,maxScene-1);
         id<ORIntRange> Days   = RANGE(model,1,5);
         id<ORIntArray>    fee = [ORFactory intArray:model array:xmlFee];
         id<ORIdArray> appears = [ORFactory idArray:model array:sc ];
         
         id<ORIdArray> which = [ORFactory idArray:model range:Actors with:^id(ORInt a) {
            return filterSet(model, Scenes, ^ORBool(ORInt i) { return [(id<ORIntSet>)appears[i] member:a];});
         }];
         id<ORIntVarArray> __block shoot = [ORFactory intVarArray:model range:Scenes domain:Days];
         id<ORIntArray> low = [ORFactory intArray:model range:Days value:0];
         id<ORIntArray> up  = [ORFactory intArray:model range:Days values:vals];
         
         [notes hard:[model add:[ORFactory cardinality:shoot low:low up:up]]];
         [model minimize:Sum2(model, a, Actors, d, Days,
                              [Or(model, s, which[a], [shoot[s] eq:@(d)]) mul:@([fee at:a])
                               ])];
         
         id<LSProgram> __block cp = [ORFactory createLSProgram:model annotation:notes];
         BOOL __block found = NO;
         ORInt __block it = 0;
         ORInt __block best = FDMAXINT;
         id<ORIntMatrix> tabu = [ORFactory intMatrix:cp range:Scenes :Scenes using:^int(ORInt i, ORInt j) { return 0;}];
         [cp solve:^{
            int scene[] = {4,1,2,3,3,1,2,4,2,2,3,1,1,3,2,4,4,3,1};
            for(ORInt i=shoot.range.low;i <= shoot.range.up;i++)
               [cp label:shoot[i] with:scene[i]];
            for(ORInt i=shoot.range.low;i <= shoot.range.up;i++) {
               printf("%d,",[cp intValue:shoot[i]]);
            }
            printf("\n");
            
               while (++it <= 400) {
               [cp sweep:^(id<ORSweep> sweep) {
                  for(ORInt s1=Scenes.low;s1 <= Scenes.up;s1++) {
                     for(ORInt s2=Scenes.low;s2 <= Scenes.up;s2++) {
                        if ([cp intValue:shoot[s1]] == [cp intValue:shoot[s2]] || [tabu at:s1 :s2] > it)
                           continue;
                        ORInt delta = [cp deltaWhenSwap:shoot[s1] with:shoot[s2]];
//                        printf("DELTA %d <-> %d = %d\n",s1,s2,delta);
                        [sweep forMininum:delta do:^{
                           //printf("\tBEFORE: %d  DELTA=%d\n",[cp getViolations],delta);
                           [cp swap:shoot[s1] with:shoot[s2]];
                           //printf("\tAFTER : %d\n",[cp getViolations]);
                           //printf("MANUAL TOTAL COST: %d\n",debug());
                           [tabu set:it+20 at:s1 :s2];
                           [tabu set:it+20 at:s2 :s1];
                           if ([cp getViolations] < best) {
                              best = [cp getViolations];
                              printf("(%d)",best);fflush(stdout);
                              [cp saveSolution];
                           }
                        }];
                     }
                  }
               }];
               it++;
            }
         }];
         printf("\n");
         NSLog(@"Solver status: %@\n",cp);
         struct ORResult res = REPORT(found, it, best,0);
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}

