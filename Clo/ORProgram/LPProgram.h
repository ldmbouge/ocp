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

@protocol LPProgram <ORASolver>
-(LPSolverI*) solver;
-(void) solve;
-(id<LPColumn>) createColumn;
-(void) addColumn: (id<LPColumn>) column;
-(ORFloat) dual: (id<ORConstraint>) c;
-(ORFloat) reducedCost: (id<ORFloatVar>) v;
@end

