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
#import <ORProgram/ORProgramFactory.h>
#import <objcp/CPFactory.h>
#import "ORRunnable.h"
#import "ORParallelCombinator.h"
#import <ORModeling/ORLinearize.h>
#import <ORModeling/ORFlatten.h>

int main (int argc, const char * argv[])
{
    id<ORModel> model = [ORFactory createModel];
    ORInt n = 8;
    id<ORIntRange> R = RANGE(model,1,n);
    
    id<ORUniformDistribution> distr = [ORFactory uniformDistribution: model range: RANGE(model, 1, 20)];
    id<ORIntArray> cost =[ORFactory intArray: model range: R range: R with: ^ORInt (ORInt i, ORInt j) { return [distr next]; }];
    
    //id<ORInteger> nbSolutions = [ORFactory integer: model value: 0];
    
    id<ORIntVarArray> tasks  = [ORFactory intVarArray: model range: R domain: R];
    id<ORIntVar> assignCost = [ORFactory intVar: model domain: RANGE(model, n, n * 20)];
    
    [model minimize: assignCost];
    [model add: [ORFactory alldifferent: tasks]];
    [model add: [assignCost eq: Sum(model, i, R, [cost elt: [tasks[i] plus:@((i-1)*n -  1)]])]];
    
    id<ORModel> lm = [ORFactory linearizeModel: model];
    id<ORRunnable> r0 = [ORFactory CPRunnable: model];
    id<ORRunnable> r1 = [ORFactory CPRunnable: lm];
    id<ORRunnable> pr = [ORFactory composeCompleteParallel: r0 with: r1];
    [pr run];
    
    for(id<ORIntVar> v in [lm variables])
        NSLog(@"var(%@): %i-%i", [v description], [v min], [v max]);
    NSLog(@"SOL: %@", assignCost);
    [ORFactory shutdown];
   
    return 0;
}

