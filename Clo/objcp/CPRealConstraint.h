/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPBitDom.h>
#import <objcp/CPVar.h>

@class CPRealVarI;
@class CPIntVar;
@class CPEngine;
@protocol CPRealVarArray;

@interface CPRealSquareBC : CPCoreConstraint { // z == x^2
   CPRealVarI* _x;
   CPRealVarI* _z;
}
-(id)initCPRealSquareBC:(id)z equalSquare:(id)x;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRealEquationBC : CPCoreConstraint {
   id<CPRealVarArray> _x;
   id<ORFloatArray>    _coefs;
   ORFloat             _c;
}
-(id)init:(id<CPRealVarArray>)x coef:(id<ORFloatArray>)coefs eqi:(ORFloat)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRealINEquationBC : CPCoreConstraint {
   id<CPRealVarArray> _x;
   id<ORFloatArray>    _coefs;
   ORFloat             _c;
}
-(id)init:(id<CPRealVarArray>)x coef:(id<ORFloatArray>)coefs leqi:(ORFloat)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRealEqualc : CPCoreConstraint {
   CPRealVarI* _x;
   ORFloat      _c;
}
-(id) init:(id)x and:(ORFloat)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRealElementCstBC : CPCoreConstraint { // y == c[x]
@private
   CPIntVar*       _x;
   CPRealVarI*     _y;
   id<ORFloatArray> _c;
}
-(id) init: (id) x indexCstArray:(id<ORFloatArray>) c equal:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRealVarMinimize : CPCoreConstraint<ORSearchObjectiveFunction>
-(id)        init: (id<CPRealVar>) x;
-(void)  post;
-(ORStatus)  check;
-(void)      updatePrimalBound;
-(void)      tightenPrimalBound: (id<ORObjectiveValue>) newBound;
-(id<ORObjectiveValue>) primalBound;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
-(id<ORFloatVar>) var;
-(id<ORObjectiveValue>)value;
@end

@interface CPRealVarMaximize : CPCoreConstraint<ORSearchObjectiveFunction>
-(id)        init: (id<CPRealVar>) x;
-(void)  post;
-(ORStatus)  check;
-(void)      updatePrimalBound;
-(void)      tightenPrimalBound: (id<ORObjectiveValue>) newBound;
-(id<ORObjectiveValue>) primalBound;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
-(id<ORFloatVar>) var;
-(id<ORObjectiveValue>)value;
@end

