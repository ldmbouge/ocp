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
#import <ORProgram/ORConcretizer.h>
#import <objcp/CPFactory.h>
#import "../ORModeling/ORLinearize.h"
#import "../ORModeling/ORFlatten.h"
#import "ORRunnable.h"
#import "ORParallelRunnable.h"

int main (int argc, const char * argv[])
{
    id<ORModel> model = [ORFactory createModel];
    ORInt n = 40;
    id<ORIntRange> R = RANGE(model,1,n);
    
    id<ORUniformDistribution> distr = [CPFactory uniformDistribution: model range: RANGE(model, 1, 20)];
    id<ORIntArray> cost =[ORFactory intArray: model range: R range: R with: ^ORInt (ORInt i, ORInt j) { return [distr next]; }];
    
    //id<ORInteger> nbSolutions = [ORFactory integer: model value: 0];
    
    id<ORIntVarArray> tasks  = [ORFactory intVarArray: model range: R domain: R];
    id<ORIntVar> assignCost = [ORFactory intVar: model domain: RANGE(model, n, n * 20)];
    
    [model minimize: assignCost];
    [model add: [ORFactory alldifferent: tasks]];
    [model add: [assignCost eq: Sum(model, i, R, [cost elt: [tasks[i] plusi:(i-1)*n -  1]])]];
    
    id<ORModelTransformation> linearizer = [[ORLinearize alloc] initORLinearize];
    id<ORModel> lin = [ORFactory createModel];
    ORBatchModel* lm = [[ORBatchModel alloc] init: lin];
    [linearizer apply: model into: lm];
       
    id<ORRunnable> r0 = [[CPRunnableI alloc] initWithModel: model];
    id<ORRunnable> r1 = [[CPRunnableI alloc] initWithModel: lin];
    id<ORRunnableBinaryTransform> parTran = [[ORParallelRunnableTransform alloc] init];
    id<ORRunnable> pr = [parTran apply: r0 and: r1];
    [pr run];
    
    //for(id<ORIntVar> v in [[lm model] variables])
    //    NSLog(@"var(%@): %i-%i", [v description], [[v domain] low], [[v domain] up]);
    NSLog(@"SOL: %@", assignCost);
   [ORFactory shutdown];
   
    return 0;
}

