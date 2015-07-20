/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>

@class LPSolverI;
@protocol ORModel;

@protocol LPColumn <NSObject>
-(void) addObjCoef: (ORFloat) coef;
-(void) addConstraint: (id<ORConstraint>) cstr coef: (ORFloat) coef;
@end

@protocol LPSolution
-(ORFloat) floatValue: (id<ORFloatVar>) var;
-(ORFloat) dual: (id<ORConstraint>) c;
-(ORFloat) reducedCost: (id<ORFloatVar>) x;
@end

@protocol LPProgram <ORASolver>
-(LPSolverI*) solver;
-(void) setGamma: (id*) gamma;
-(void) setModelMappings: (id<ORModelMappings>) mappings;
-(id*)  gamma;
-(void) solve;
-(id<LPColumn>) createColumn;
-(id<LPColumn>) createColumn: (ORFloat) low up: (ORFloat) up;
-(void) addColumn: (id<LPColumn>) column;
-(ORFloat) dual: (id<ORConstraint>) c;
-(ORFloat) reducedCost: (id<ORFloatVar>) v;
-(ORFloat) floatValue: (id<ORFloatVar>) v;
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
-(ORFloat) dual: (id<ORConstraint>) c;
-(ORFloat) reducedCost: (id<ORVar>) v;
-(ORFloat) floatValue: (id<ORVar>) v;
-(ORFloat) objective;
-(id<ORObjectiveValue>) objectiveValue;
-(ORFloat) lowerBound: (id<ORVar>) v;
-(ORFloat) upperBound: (id<ORVar>) v;
-(void) updateLowerBound: (id<ORVar>) v with: (ORFloat) lb;
-(void) updateUpperBound: (id<ORVar>) v with: (ORFloat) ub;
@end

