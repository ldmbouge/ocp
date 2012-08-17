/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "OREngine.h"
#import "ORModel.h"

@protocol ORObjective <NSObject>
-(ORStatus) check;
-(void)     updatePrimalBound;
-(ORInt)    primalBound;
@end

@protocol ORSolverConcretizer <NSObject>
-(id<ORIntVar>) intVar: (id<ORIntVar>) v;
-(id<ORIntVar>) affineVar:(id<ORIntVar>) v;
-(id<ORConstraint>) alldifferent: (id<ORAlldifferent>) cstr;
-(void) expr: (id<ORExpr>) e;
@end

@protocol ORSolver <NSObject,ORTracker,ORSolutionProtocol>

-(id<OREngine>)    engine;
-(id<ORObjective>) objective;

-(id<ORSolverConcretizer>) concretizer;
-(void)            addModel: (id<ORModel>) model;

-(ORStatus)        close;
-(bool)            closed;
-(NSMutableArray*) allVars;
@end

