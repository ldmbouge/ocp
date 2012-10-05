/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

@protocol ORTracer;

@protocol ORSolverConcretizer <NSObject>
-(id<ORIntVar>) intVar: (id<ORIntVar>) v;
-(id<ORFloatVar>) floatVar: (id<ORFloatVar>) v;
-(id<ORIntVar>) affineVar:(id<ORIntVar>) v;
-(id<ORIdArray>) idArray: (id<ORIdArray>) a;
-(id<ORConstraint>) alldifferent: (id<ORAlldifferent>) cstr;
-(id<ORConstraint>) cardinality: (id<ORCardinality>) cstr;
-(id<ORConstraint>) binPacking: (id<ORBinPacking>) cstr;
-(id<ORConstraint>) algebraicConstraint: (id<ORAlgebraicConstraint>) cstr;
-(id<ORConstraint>) tableConstraint: (id<ORTableConstraint>) cstr;
-(id<ORObjective>) minimize: (id<ORObjectiveFunction>) v;
-(id<ORObjective>) maximize: (id<ORObjectiveFunction>) v;
@end

@protocol ORSolver <NSObject,ORASolver,ORTracker,ORSolutionProtocol>
-(id<ORTracer>)    tracer;
-(id<OREngine>)    engine;
-(id<ORObjective>) objective;
-(id<ORSolverConcretizer>) concretizer;
-(void)            addModel: (id) model;

-(ORStatus)        close;
-(bool)            closed;
-(NSMutableArray*) allVars;
@end

