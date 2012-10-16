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

@protocol ORFail <ORConstraint>
@end

@protocol  OREqualc <ORConstraint>
@end

@protocol  ORNEqualc <ORConstraint>
@end

@protocol  ORLEqualc <ORConstraint>
@end

@protocol  OREqual <ORConstraint>
@end

@protocol  ORNEqual <ORConstraint>
@end

@protocol  ORLEqual <ORConstraint>
@end

@protocol  OREqual3 <ORConstraint>
@end

@protocol ORMult <ORConstraint>
@end

@protocol ORAbs <ORConstraint>
@end

@protocol OROr <ORConstraint>
@end

@protocol ORAnd <ORConstraint>
@end

@protocol ORImply <ORConstraint>
@end

@protocol ORElementCst <ORConstraint>
@end

@protocol ORElementVar <ORConstraint>
@end

@protocol ORReify <ORConstraint>
@end

@protocol ORReifyEqualc <ORReify>
@end

@protocol ORReifyNEqualc <ORReify>
@end

@protocol ORReifyEqual <ORReify>
@end

@protocol ORReifyNEqual <ORReify>
@end

@protocol ORReifyLEqualc <ORReify>
@end

@protocol ORReifyLEqual <ORReify>
@end

@protocol ORReifyGEqualc <ORReify>
@end

@protocol ORReifyGEqual <ORReify>
@end

@protocol ORSumBoolEqc <ORConstraint>
@end

@protocol ORSumBoolLEqc <ORConstraint>
@end

@protocol ORSumBoolGEqc <ORConstraint>
@end

@protocol ORSumEqc <ORConstraint>
@end

@protocol ORSumGEqc <ORConstraint>
@end

@protocol ORSumLEqc <ORConstraint>
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

@protocol ORCircuit <ORConstraint>
-(id<ORIntVarArray>) array;
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

