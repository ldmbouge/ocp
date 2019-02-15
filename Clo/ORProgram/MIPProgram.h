/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>

@class MIPSolverI;
@protocol ORModel;
@protocol ORFloatParam;


@protocol MIPProgram <ORASolver>
-(MIPSolverI*) solver;
-(void) setGamma: (id*) gamma;
-(void) setModelMappings: (id<ORModelMappings>) mappings;
-(id*)  gamma;
-(OROutcome) solve;
-(ORDouble) doubleValue: (id<ORRealVar>) v;
-(ORInt) intValue: (id<ORIntVar>) v;
-(void) setIntVar: (id<ORIntVar>)v value:(ORInt)val;
-(ORDouble) paramValue: (id<ORRealParam>)p;
-(void) param: (id<ORRealParam>)p setValue: (ORDouble)val;
-(id<ORObjectiveValue>) objectiveValue;
-(ORDouble) bestObjectiveBound;
-(id<ORSolutionPool>) solutionPool;
-(id<ORSolution>) captureSolution;
-(id<ORExplorer>)  explorer;
-(void) setIntParameter: (const char*) name val: (ORInt) val;
@end

