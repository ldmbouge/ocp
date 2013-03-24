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
@interface LPSolver : NSObject<LPProgram>
-(id<LPProgram>) initLPSolver: (id<ORModel>) model;
-(ORFloat) dual: (id<ORConstraint>) c;
@end

// LPSolverFactory
@interface LPSolverFactory : NSObject
+(id<LPProgram>) solver: (id<ORModel>) model;
@end

