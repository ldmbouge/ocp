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
#import <ORModeling/ORLinearize.h>
#import <ORModeling/ORFlatten.h>
#import <ORProgram/ORRunnable.h>
#import <ORProgram/ORParallelRunnable.h>
#import <ORProgram/ORColumnGeneration.h>
#import <ORProgram/LPRunnable.h>
#import <ORProgram/CPRunnable.h>
#import <ORProgram/ORLagrangeRelax.h>
#import <ORProgram/ORLagrangianTransform.h>
#import "SetCoveringInstanceParser.h"

int main (int argc, const char * argv[])
{
    NSMutableString* logData = [[NSMutableString alloc] init];
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
    [m minimize: Sum(m, i, setRange, [s[i] mul: @(i%3+1)])];
    for(ORInt n = [universe low]; n <= [universe up]; n++) {
        id<ORExpr> expr = [ORFactory sum: m over: setRange
                                suchThat: ^bool(ORInt i) { return [[instance.sets at: i] member: n]; }
                                      of: ^id<ORExpr>(ORInt i) { return [s at: i]; }];
       id<ORConstraint> c = [m add: [expr geq: @1]];
       [cstrs addObject: c];
    }
   
    NSDate* t0 = [NSDate date];
   
   ORInt coupledCount = 250;
   //NSArray* myCoupled = [ORLagrangianTransform coupledConstraints: m];
   NSMutableArray* coupled = [[NSMutableArray alloc] initWithCapacity: 50];
   for(int i = 0; i < coupledCount; i++) [coupled addObject: [cstrs objectAtIndex: cstrs.count-i-1]];
   
   ORLagrangianTransform* t = [ORFactory lagrangianTransform];
   id<ORParameterizedModel> lagrangeModel = [t apply: m relaxing: coupled];
   
    id<ORRunnable> lr = [ORFactory MIPSubgradient: lagrangeModel bound: 169];
    //[(MIPSubgradient*)lr setSolverTimeLimit: 5];
    [[(id<ORLowerBoundStreamProducer>)lr lowerBoundStreamInformer] wheneverNotifiedDo: ^(ORFloat lb) {
        NSDate* t1 = [NSDate date];
        NSTimeInterval time = [t1 timeIntervalSinceDate: t0];
        [logData appendFormat: @"%f %f\n", time, lb];
    }];
   [lr run];

//   id<ORRunnable> r = [ORFactory MIPRunnable: m];
//   [r run];
//   id<ORSolution> sol= [[[r solver] solutionPool] best];
//   id<ORObjectiveValueFloat> objValue = (id<ORObjectiveValueFloat>)[sol objectiveValue];
//   NSLog(@"BEST: %f", [objValue floatValue]);
   
    //NSLog(@"lower bound: %f", [(ORLagrangeRelax*)lr bestBound]);
    
    NSDate* t1 = [NSDate date];
    NSTimeInterval time = [t1 timeIntervalSinceDate: t0];
    NSLog(@"Time: %f", time);
    
    [logData writeToFile: @"/Users/dan/Desktop/logdat.txt" atomically: YES encoding: NSASCIIStringEncoding error: nil];
    
    return 0;
}
