/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/LPProgram.h>
#import <objcp/CPFactory.h>
#import "../ORModeling/ORLinearize.h"
#import "../ORModeling/ORFlatten.h"
#import <ORProgram/ORRunnable.h>
#import "ORParallelRunnable.h"
#import "ORColumnGeneration.h"
#import "LPRunnable.h"
#import "CPRunnable.h"
#import "ORLagrangeRelax.h"
#import "ORLagrangianTransform.h"
#import "SetCoveringInstanceParser.h"


int main (int argc, const char * argv[])
{
    id<ORModel> m = [ORFactory createModel];
    NSString* execPath = [NSString stringWithFormat: @"%s", argv[0]];
    NSString* basePath = [execPath stringByDeletingLastPathComponent];
    NSString* path = [NSString pathWithComponents: [NSArray arrayWithObjects:basePath,
                                                    @"simple.msc", nil]];
                                                    //@"frb30-15-1.msc", nil]];
    NSLog(@"path: %@", path);
    SetCoveringInstanceParser* parser = [[SetCoveringInstanceParser alloc] init];
    SetCoveringInstance* instance = [parser parseInstanceFile: m path: path];
    id<ORIntRange> setRange = RANGE(m, 0, (ORInt)instance.sets.count-1);
    id<ORIntRange> universe = RANGE(m, 1, (ORInt)instance.universe);
    id<ORIntVarArray> s = [ORFactory intVarArray: m range: setRange domain: RANGE(m, 0, 1)];
   
   NSMutableArray* cstrs = [[NSMutableArray alloc] initWithCapacity: [universe size]];
    [m minimize: Sum(m, i, setRange, [s[i] mul: @(i%6+1)])];
    for(ORInt n = [universe low]; n <= [universe up]; n++) {
        id<ORExpr> expr = [ORFactory sum: m over: setRange
                                suchThat: ^bool(ORInt i) { return [[instance.sets at: i] member: n]; }
                                      of: ^id<ORExpr>(ORInt i) { return [s at: i]; }];
       id<ORConstraint> c = [m add: [expr geq: @1]];
       [cstrs addObject: c];
    }
   
    NSDate* t0 = [NSDate date];
   
   // Build Split
//   block 1: 22 -- 1..97
//   block 2: 22 -- 98..189
//   block 3: 19 -- 190..284
//   block 4: 22 -- 285..374
//   block 5: 17 -- 375..475
//   block 6: 20 -- 476..561
//   block 7: 19 -- 562..654
//   block 8: 19 -- 655..730
//   block 9: 20 -- 731..820
//   block 10: 20 -- 821..899

   NSMutableArray* u = [[NSMutableArray alloc] initWithCapacity: 12];
   ORInt splitCount = 10;
   ORInt coupledCount = 100;
   
   NSMutableSet* us = [[NSMutableSet alloc] initWithCapacity: 64];
   for(int i = 1; i <= 97; i++) [us addObject: @(i)];
   [u addObject: us];
   us = [[NSMutableSet alloc] initWithCapacity: 64];
   for(int i = 98; i <= 189; i++) [us addObject: @(i)];
   [u addObject: us];
   us = [[NSMutableSet alloc] initWithCapacity: 64];
   for(int i = 190; i <= 284; i++) [us addObject: @(i)];
   [u addObject: us];
   us = [[NSMutableSet alloc] initWithCapacity: 64];
   for(int i = 285; i <= 374; i++) [us addObject: @(i)];
   [u addObject: us];
   us = [[NSMutableSet alloc] initWithCapacity: 64];
   for(int i = 375; i <= 475; i++) [us addObject: @(i)];
   [u addObject: us];
   us = [[NSMutableSet alloc] initWithCapacity: 64];
   for(int i = 476; i <= 561; i++) [us addObject: @(i)];
   [u addObject: us];
   us = [[NSMutableSet alloc] initWithCapacity: 64];
   for(int i = 562; i <= 654; i++) [us addObject: @(i)];
   [u addObject: us];
   us = [[NSMutableSet alloc] initWithCapacity: 64];
   for(int i = 655; i <= 730; i++) [us addObject: @(i)];
   [u addObject: us];
   us = [[NSMutableSet alloc] initWithCapacity: 64];
   for(int i = 731; i <= 820; i++) [us addObject: @(i)];
   [u addObject: us];
   us = [[NSMutableSet alloc] initWithCapacity: 64];
   for(int i = 821; i <= 899; i++) [us addObject: @(i)];
   [u addObject: us];
   
   NSMutableArray* split = [[NSMutableArray alloc] initWithCapacity: 10];
   for(int b = 0; b < splitCount; b++) {
      NSMutableSet* splitSet = [[NSMutableSet alloc] initWithCapacity: 10];
      [split addObject: splitSet];
      for(int i = [setRange low]; i <= [setRange up]; i++) {
         [((NSSet*)[u objectAtIndex: b]) enumerateObjectsUsingBlock: ^(id obj, BOOL *stop) {
            if([instance.sets[i] member: [obj intValue]]) {
               [splitSet addObject: s[i]];
               *stop = YES;
            }
         }];
      }
   }
   
   NSMutableArray* coupled = [[NSMutableArray alloc] initWithCapacity: 50];
   for(int i = 0; i < coupledCount; i++) [coupled addObject: [cstrs objectAtIndex: cstrs.count-i-1]];
   
   ORLagrangianTransform* t = [[ORLagrangianTransform alloc] init];
   id<ORParameterizedModel> lagrangeModel = [t apply: m relaxing: coupled];
   id<ORRunnable> lr = [[ORLagrangeRelax alloc] initWithModel: lagrangeModel withSurrogateSplit: split];
   [lr run];

//   id<ORRunnable> r = [ORFactory MIPRunnable: m];
//   [r run];
//   id<ORSolution> sol= [[[r solver] solutionPool] best];
//   id<ORObjectiveValueFloat> objValue = (id<ORObjectiveValueFloat>)[sol objectiveValue];
//   NSLog(@"BEST: %f", [objValue floatValue]);
//   NSLog(@"%@", sol);
   
    //NSLog(@"lower bound: %f", [(ORLagrangeRelax*)lr bestBound]);
    
    NSDate* t1 = [NSDate date];
    NSTimeInterval time = [t1 timeIntervalSinceDate: t0];
    NSLog(@"Time: %f", time);
    
    return 0;
}
