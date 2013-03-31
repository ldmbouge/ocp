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
@end

@protocol ORLPSolution <ORObject>
-(id<ORSnapshot>) value: (id<ORFloatVar>) var;
-(ORFloat) floatValue: (id<ORFloatVar>) var;
-(ORFloat) reducedCost: (id<ORFloatVar>) var;
-(ORFloat) dual: (id<ORConstraint>) var;
-(id<ORObjectiveValue>) objectiveValue;
@end

@protocol ORLPSolutionPool <NSObject>
-(void) addSolution: (id<ORLPSolution>)s;
-(void) enumerateWith: (void(^)(id<ORLPSolution>)) block;
-(id<ORInformer>) solutionAdded;
-(id<ORLPSolution>) best;
@end

@protocol LPProgram <ORASolver>
-(LPSolverI*) solver;
-(void) solve;
-(id<LPColumn>) createColumn;
-(id<LPColumn>) createColumn: (ORFloat) low up: (ORFloat) up;
-(void) addColumn: (id<LPColumn>) column;
-(ORFloat) dual: (id<ORConstraint>) c;
-(ORFloat) reducedCost: (id<ORFloatVar>) v;
-(ORFloat) floatValue: (id<ORFloatVar>) v;
-(id<ORLPSolutionPool>) lpSolutionPool;
@end

