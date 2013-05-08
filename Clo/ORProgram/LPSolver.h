/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORProgram/LPProgram.h>

// LPSolver
@interface LPSolver : ORGamma<LPProgram>
-(void) setGamma: (id*) gamma;
-(id*)  gamma;
-(void) setTau: (id<ORTau>) tau;
-(id<LPProgram>) initLPSolver: (id<ORModel>) model;
-(ORFloat) dual: (id<ORConstraint>) c;
-(ORFloat) reducedCost: (id<ORFloatVar>) x;
-(ORFloat) floatValue: (id<ORFloatVar>) x;
-(id<LPColumn>) createColumn;
-(void) addColumn: (id<LPColumn>) column;
-(id<ORObjectiveValue>) objectiveValue;
-(id<ORLPSolution>) captureSolution;
@end

// LPSolverFactory
@interface LPSolverFactory : NSObject
+(id<LPProgram>) solver: (id<ORModel>) model;
@end

