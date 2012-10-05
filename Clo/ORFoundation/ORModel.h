/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORTracker.h>
#import <ORFoundation/ORArray.h>

@protocol ORIntVarArray;
@protocol ORExpr;
@protocol ORIntVar;
@protocol OREngine;

@protocol ORConstraint <ORObject>
@end

@protocol ORAlldifferent <ORConstraint>
-(id<ORIntVarArray>) array;
@end

@protocol ORBinPacking <ORConstraint>
-(id<ORIntVarArray>) item;
-(id<ORIntArray>) itemSize;
-(id<ORIntVarArray>) binSize;
@end

@protocol ORAlgebraicConstraint <ORConstraint>
-(id<ORExpr>) expr;
@end

@protocol ORTableConstraint <ORConstraint>
-(id<ORIntVarArray>) array;
-(id<ORTable>) table;
@end

@protocol ORCardinality <ORConstraint>
-(id<ORIntVarArray>) array;
-(id<ORIntArray>) low;
-(id<ORIntArray>) up;
@end

@protocol ORObjectiveFunction <ORObject>
-(id<ORIntVar>) var;
@end

@protocol ORObjective <NSObject,ORObjectiveFunction>
-(ORStatus) check;
-(void)     updatePrimalBound;
-(void) tightenPrimalBound:(ORInt)newBound;
-(ORInt)    primalBound;
@end

@protocol ORASolver <NSObject,ORTracker>
-(id<ORObjective>) objective;
-(ORStatus)        close;
-(id<OREngine>)    engine;
@end

