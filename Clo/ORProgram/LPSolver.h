/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORProgram/LPProgram.h>
#import "ORSolution.h"

// LPSolver
@interface LPSolver : ORGamma<LPProgram>
-(id<LPProgram>) initLPSolver: (id<ORModel>) model;
-(ORFloat) dual: (id<ORConstraint>) c;
-(ORFloat) reducedCost: (id<ORFloatVar>) x;
-(ORFloat) floatValue: (id<ORFloatVar>) x;
-(id<LPColumn>) createColumn;
-(void) addColumn: (id<LPColumn>) column;
-(id<ORObjectiveValue>) objectiveValue;
-(id<ORSolution>) captureSolution;
@end

@interface LPRelaxation : ORGamma<LPRelaxation>
-(id<LPRelaxation>) initLPRelaxation: (id<ORModel>) model;
-(ORFloat) dual: (id<ORConstraint>) c;
-(ORFloat) reducedCost: (id<ORVar>) x;
-(ORFloat) floatValue: (id<ORVar>) x;
-(ORFloat) objective;
-(id<ORObjectiveValue>) objectiveValue;
-(ORFloat) lowerBound: (id<ORVar>) v;
-(ORFloat) upperBound: (id<ORVar>) v;
-(void) updateLowerBound: (id<ORVar>) v with: (ORFloat) lb;
-(void) updateUpperBound: (id<ORVar>) v with: (ORFloat) ub;
@end


@interface ORSolution (LPSolver)
-(ORFloat) dual: (id<ORConstraint>) c;
-(ORFloat) reducedCost: (id<ORFloatVar>) x;
@end

// LPSolverFactory
@interface LPSolverFactory : NSObject
+(id<LPProgram>) solver: (id<ORModel>) model;
+(id<LPRelaxation>) relaxation: (id<ORModel>) model;
@end

