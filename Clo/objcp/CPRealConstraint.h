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
#import <objcp/CPVar.h>

@class CPRealVarI;
@class CPIntVar;
@class CPEngine;
@class CPRealParamI;
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

@interface CPRealWeightedVarBC : CPCoreConstraint { // z == x^2
    CPRealVarI* _x;
    CPRealVarI* _z;
    CPRealParamI* _w;
}
-(id)initCPRealWeightedVarBC:(id)z equal:(id)x weight: (id)w;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRealEquationBC : CPCoreConstraint {
   id<CPRealVarArray> _x;
   id<ORDoubleArray>    _coefs;
   ORDouble             _c;
}
-(id)init:(id<CPRealVarArray>)x coef:(id<ORDoubleArray>)coefs eqi:(ORDouble)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRealINEquationBC : CPCoreConstraint {
   id<CPRealVarArray> _x;
   id<ORDoubleArray>    _coefs;
   ORDouble             _c;
}
-(id)init:(id<CPRealVarArray>)x coef:(id<ORDoubleArray>)coefs leqi:(ORDouble)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRealEqualc : CPCoreConstraint {
   CPRealVarI* _x;
   ORDouble      _c;
}
-(id) init:(id)x and:(ORDouble)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRealElementCstBC : CPCoreConstraint { // y == c[x]
@private
   CPIntVar*       _x;
   CPRealVarI*     _y;
   id<ORDoubleArray> _c;
}
-(id) init: (id) x indexCstArray:(id<ORDoubleArray>) c equal:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRealVarMinimize : CPCoreConstraint<ORSearchObjectiveFunction>
-(id)        init: (id<CPRealVar>) x;
-(void)  post;
-(ORStatus)  check;
-(ORBool)   isBound;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
-(id<ORRealVar>) var;
@end

@interface CPRealVarMaximize : CPCoreConstraint<ORSearchObjectiveFunction>
-(id)        init: (id<CPRealVar>) x;
-(void)  post;
-(ORStatus)  check;
-(ORBool)   isBound;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
-(id<ORRealVar>) var;
@end

