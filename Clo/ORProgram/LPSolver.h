/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORProgram/LPProgram.h>
#import <ORProgram/ORSolution.h>

// LPSolver
@interface LPSolver : ORGamma<LPProgram>
-(id<LPProgram>) initLPSolver: (id<ORModel>) model;
-(ORDouble) dual: (id<ORConstraint>) c;
-(ORDouble) reducedCost: (id<ORRealVar>) x;
-(ORDouble) doubleValue: (id<ORRealVar>) x;
-(id<LPColumn>) createColumn;
-(void) addColumn: (id<LPColumn>) column;
-(id<ORObjectiveValue>) objectiveValue;
-(id<ORSolution>) captureSolution;
@end

@interface LPRelaxation : ORGamma<LPRelaxation>
-(id<LPRelaxation>) initLPRelaxation: (id<ORModel>) model;
-(ORDouble) dual: (id<ORConstraint>) c;
-(ORDouble) reducedCost: (id<ORVar>) x;
-(ORDouble) doubleValue: (id<ORVar>) x;
-(ORDouble) objective;
-(id<ORObjectiveValue>) objectiveValue;
-(ORDouble) lowerBound: (id<ORVar>) v;
-(ORDouble) upperBound: (id<ORVar>) v;
-(void) updateLowerBound: (id<ORVar>) v with: (ORDouble) lb;
-(void) updateUpperBound: (id<ORVar>) v with: (ORDouble) ub;
@end


@interface ORSolution (LPSolver)
-(ORDouble) dual: (id<ORConstraint>) c;
-(ORDouble) reducedCost: (id<ORRealVar>) x;
@end

// LPSolverFactory
@interface LPSolverFactory : NSObject
+(id<LPProgram>) solver: (id<ORModel>) model;
+(id<LPRelaxation>) relaxation: (id<ORModel>) model;
@end

