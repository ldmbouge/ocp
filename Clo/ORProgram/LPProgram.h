/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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
-(ORFloat) objCoef;
-(id)theVar;
@end

@protocol ORLPSolution <ORSolution>
-(ORFloat) reducedCost: (id<ORFloatVar>) var;
-(ORFloat) dual: (id<ORConstraint>) var;
-(id<ORObjectiveValue>) objectiveValue;
@end

@protocol ORLPSolutionPool <ORSolutionPool>
-(void) addSolution: (id<ORLPSolution>) s;
-(void) enumerateWith: (void(^)(id<ORLPSolution>)) block;
-(id<ORInformer>) solutionAdded;
-(id<ORLPSolution>) best;
@end

@protocol LPProgram <ORASolver>
-(LPSolverI*) solver;
-(void) setGamma: (id*) gamma;
-(void) setModelMappings: (id<ORModelMappings>) mappings;
-(id*)  gamma;
-(void) solve;
-(id<LPColumn>) freshColumn;
-(id<LPColumn>) createColumn: (ORFloat) low up: (ORFloat) up;
-(void) addColumn: (id<LPColumn>) column;
-(ORFloat) dual: (id<ORConstraint>) c;
-(ORFloat) reducedCost: (id<ORFloatVar>) v;
-(ORFloat) floatValue: (id<ORFloatVar>) v;
-(id<ORObjectiveValue>) objectiveValue;
-(id<ORLPSolutionPool>) solutionPool;
-(id<ORLPSolution>) captureSolution;
-(void)enumerateColumnWith:(void(^)(id<LPColumn>))block;
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

