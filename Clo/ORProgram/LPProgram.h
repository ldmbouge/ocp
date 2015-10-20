/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>

@class LPSolverI;
@protocol ORModel;

@protocol LPColumn <NSObject>
-(void) addObjCoef: (ORDouble) coef;
-(void) addConstraint: (id<ORConstraint>) cstr coef: (ORDouble) coef;
@end

@protocol LPSolution
-(ORDouble) dblValue: (id<ORRealVar>) var;
-(ORDouble) dual: (id<ORConstraint>) c;
-(ORDouble) reducedCost: (id<ORRealVar>) x;
@end

@protocol LPProgram <ORASolver>
-(LPSolverI*) solver;
-(void) setGamma: (id*) gamma;
-(void) setModelMappings: (id<ORModelMappings>) mappings;
-(id*)  gamma;
-(void) solve;
-(id<LPColumn>) createColumn;
-(id<LPColumn>) createColumn: (ORDouble) low up: (ORDouble) up;
-(void) addColumn: (id<LPColumn>) column;
-(ORDouble) dual: (id<ORConstraint>) c;
-(ORDouble) reducedCost: (id<ORRealVar>) v;
-(ORDouble) dblValue: (id<ORRealVar>) v;
-(id<ORObjectiveValue>) objectiveValue;
-(id<ORSolutionPool>) solutionPool;
-(id<ORSolution>) captureSolution;
@end

@protocol LPRelaxation <ORASolver>
-(LPSolverI*) solver;
-(void) setGamma: (id*) gamma;
-(void) setModelMappings: (id<ORModelMappings>) mappings;
-(id*)  gamma;
-(OROutcome) solve;
-(ORDouble) dual: (id<ORConstraint>) c;
-(ORDouble) reducedCost: (id<ORVar>) v;
-(ORDouble) dblValue: (id<ORVar>) v;
-(ORDouble) objective;
-(id<ORObjectiveValue>) objectiveValue;
-(ORDouble) lowerBound: (id<ORVar>) v;
-(ORDouble) upperBound: (id<ORVar>) v;
-(void) updateLowerBound: (id<ORVar>) v with: (ORDouble) lb;
-(void) updateUpperBound: (id<ORVar>) v with: (ORDouble) ub;
@end

