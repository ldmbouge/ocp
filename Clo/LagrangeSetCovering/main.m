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

NSArray* autosplit(NSArray* vars, NSArray* cstrs) {
   if([vars count] <= 2) return [NSArray arrayWithObject: [NSSet setWithArray: vars]];
   
   // Partition variables
   NSSet* allVars = [NSSet setWithArray: vars];
   NSMutableSet* splitSet = [NSMutableSet setWithObject: [vars firstObject]];
   BOOL changed = YES;
   while (changed) {
      changed = NO;
      for(id<ORConstraint> c in cstrs) {
         NSMutableSet* cstrVars = [[c allVars] mutableCopy];
         [cstrVars intersectSet: allVars];
         if([splitSet intersectsSet: cstrVars]) {
            NSInteger oldCount = [splitSet count];
            NSArray* varArray = [cstrVars allObjects];
            [splitSet addObjectsFromArray: varArray];
            [varArray release];
            if([splitSet count] > oldCount) changed = YES;
         }
      }
   }
   
   // Partition failed, return everything
   if([vars count] - [splitSet count] <= 1) {
      [splitSet release];
      return [NSArray arrayWithObject: [NSSet setWithArray: vars]];
   }
   
   // Recursively partition
   NSArray* split0 = [splitSet allObjects];
   NSMutableArray* split1 = [vars mutableCopy];
   [split1 removeObjectsInArray: split0];
   [splitSet release];
   
   NSMutableArray* res = [[NSMutableArray alloc] initWithCapacity: 32];
   NSArray* r0 = autosplit(split0, cstrs);
   [res addObjectsFromArray: r0];
   [r0 release];
   NSArray* r1 = autosplit(split1, cstrs);
   [res addObjectsFromArray: r1];
   [r1 release];
   
   return res;
}

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
    [m minimize: Sum(m, i, setRange, [s[i] mul: @(i % 6)])];
    for(ORInt n = [universe low]; n <= [universe up]; n++) {
        id<ORExpr> expr = [ORFactory sum: m over: setRange
                                suchThat: ^bool(ORInt i) { return [[instance.sets at: i] member: n]; }
                                      of: ^id<ORExpr>(ORInt i) { return [s at: i]; }];
       id<ORConstraint> c = [m add: [expr geq: @1]];
       [cstrs addObject: c];
    }
   
    NSDate* t0 = [NSDate date];
   
   ORInt coupledCount = 600;
   //NSArray* myCoupled = [ORLagrangianTransform coupledConstraints: m];
   NSMutableArray* coupled = [[NSMutableArray alloc] initWithCapacity: 50];
   for(int i = 0; i < coupledCount; i++) [coupled addObject: [cstrs objectAtIndex: cstrs.count-i-1]];
   
   ORLagrangianTransform* t = [[ORLagrangianTransform alloc] init];
   id<ORParameterizedModel> lagrangeModel = [t apply: m relaxing: coupled];
   
   NSArray* split = autosplit([s toNSArray], [lagrangeModel hardConstraints]);
   id<ORRunnable> lr = [[ORLagrangeRelax alloc] initWithModel: lagrangeModel]; //withSurrogateSplit: split];
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
