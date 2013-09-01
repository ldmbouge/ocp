/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPBitDom.h>
#import <objcp/CPVar.h>

@class CPIntVarBase;
@class ORIntSetI;
@class CPEngine;
@protocol CPIntVarArray;


@interface CPRestrictI : CPCoreConstraint<NSCoding> {
@private
   CPIntVarBase* _x;
   ORIntSetI* _r;
}
-(id) initRestrict:(id<CPIntVar>)x to:(id<ORIntSet>)r;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

// PVH: where is _active being used
@interface CPEqualc : CPCoreConstraint<NSCoding> {
   @private
   CPIntVarBase* _x;
   ORInt  _c;
}
-(id) initCPEqualc:(id)x and:(ORInt)c;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDiffc : CPCoreConstraint<NSCoding> {
@private
   CPIntVarBase* _x;
   ORInt      _c;
}
-(id) initCPDiffc:(id)x and:(ORInt)c;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPEqualBC : CPCoreConstraint<NSCoding> {
@private
   CPIntVarBase*  _x;
   CPIntVarBase*  _y;
   ORInt _c;
}
-(id) initCPEqualBC: (id<CPIntVar>) x and: (id<CPIntVar>) y  and: (ORInt) c;
-(ORStatus) post;
-(void) propagate;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPEqualDC : CPCoreConstraint<NSCoding> {
@private
   CPIntVarBase*  _x;
   CPIntVarBase*  _y;
   ORInt _c;
}
-(id) initCPEqualDC: (id) x and: (id) y  and: (ORInt) c;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPAffineBC : CPCoreConstraint { // y == a x + b
   CPIntVarBase* _y;
   CPIntVarBase* _x;
   ORInt      _a;
   ORInt      _b;
}
-(id)initCPAffineBC:(id)y equal:(ORInt)a times:(id)x plus:(ORInt)b;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPAffineAC : CPCoreConstraint {  // y == a x + b
   CPIntVarBase* _y;
   CPIntVarBase* _x;
   ORInt      _a;
   ORInt      _b;
}
-(id)initCPAffineAC:(id)y equal:(ORInt)a times:(id)x plus:(ORInt)b;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPEqual3BC : CPCoreConstraint {
   CPIntVarBase* _x;
   CPIntVarBase* _y;
   CPIntVarBase* _z;
}
-(id) initCPEqual3BC: (id) x plus: (id) y  equal: (id) z;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPEqual3DC : CPCoreConstraint<NSCoding> {
   CPIntVarBase* _x;
   CPIntVarBase* _y;
   CPIntVarBase* _z;   
   CPBitDom*  _fx;
   CPBitDom*  _fy;
   CPBitDom*  _fz;
   TRIntArray _xs;
   TRIntArray _ys;
   TRIntArray _zs;
}
-(id) initCPEqual3DC: (id) x plus: (id) y  equal: (id) z;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

typedef int (^intgetter) (void) ;

@interface CPNotEqual : CPCoreConstraint<NSCoding> {
@private
   CPIntVarBase* _x;
   CPIntVarBase* _y;
   ORInt  _c;
}
-(id) initCPNotEqual: (id) x and: (id) y  and: (ORInt) c;
-(ORStatus) post;
-(void) propagate;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPBasicNotEqual : CPCoreConstraint<NSCoding> {
   CPIntVarBase* _x;
   CPIntVarBase* _y;
}
-(id) initCPBasicNotEqual:(id)x and:(id) y;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPLEqualBC : CPCoreConstraint<NSCoding> {  // x <= y + c
@private
   CPIntVarBase*  _x;
   CPIntVarBase*  _y;
   ORInt       _c;
}
-(id) initCPLEqualBC:(id)x and:(id) y plus:(ORInt) c;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPLEqualc : CPCoreConstraint<NSCoding> { // x <= c
@private
   CPIntVarBase* _x;
   ORInt      _c;
}
-(id) initCPLEqualc:(id)x and:(ORInt) c;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPGEqualc : CPCoreConstraint<NSCoding> { // x >= c
@private
   CPIntVarBase* _x;
   ORInt      _c;
}
-(id) initCPGEqualc:(id)x and:(ORInt) c;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPMultBC : CPCoreConstraint<NSCoding> { // z == x * y
   CPIntVarBase* _x;
   CPIntVarBase* _y;
   CPIntVarBase* _z;
}
-(id) initCPMultBC:(id)x times:(id)y equal:(id)z;
-(ORStatus) post;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
@end

@interface CPSquareBC : CPCoreConstraint { // z = x^2
   CPIntVarBase* _x;
   CPIntVarBase* _z;
}
-(id)initCPSquareBC:(id)z equalSquare:(id)x;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPSquareDC : CPSquareBC   // z == x^2 (DC variant)
-(id)initCPSquareDC:(id)z equalSquare:(id)x;
-(ORStatus) post;
@end

@interface CPModcBC : CPCoreConstraint { // y == x MOD c
   CPIntVarBase* _x;
   CPIntVarBase* _y;
   ORInt      _c;
}
-(id)initCPModcBC:(id)x mod:(ORInt)c equal:(id)y;
-(ORStatus) post;
@end

@interface CPModcDC : CPCoreConstraint { // y == x MOD c (DCConsistency)
   CPIntVarBase* _x;
   CPIntVarBase* _y;
   ORInt      _c;
}
-(id)initCPModcDC:(id)x mod:(ORInt)c equal:(id)y;
-(ORStatus) post;
@end

@interface CPMinBC : CPCoreConstraint {
   CPIntVarBase* _x;
   CPIntVarBase* _y;
   CPIntVarBase* _z;   
}
-(id)initCPMin:(id)x and:(id)y equal:(id)z;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPMaxBC : CPCoreConstraint {
   CPIntVarBase* _x;
   CPIntVarBase* _y;
   CPIntVarBase* _z;
}
-(id)initCPMax:(id)x and:(id)y equal:(id)z;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPModBC : CPCoreConstraint { // z == x MOD y
   CPIntVarBase* _x;
   CPIntVarBase* _y;
   CPIntVarBase* _z;
}
-(id)initCPModBC:(id)x mod:(id)y equal:(id)z;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPAbsBC : CPCoreConstraint<NSCoding> { // abs(x)==y
   CPIntVarBase* _x;
   CPIntVarBase* _y;
}
-(id)initCPAbsBC:(id)x equal:(id)y;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPAbsDC : CPCoreConstraint<NSCoding> { // abs(x)==y
   CPIntVarBase* _x;
   CPIntVarBase* _y;
}
-(id)initCPAbsDC:(id)x equal:(id)y;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPOrDC : CPCoreConstraint<NSCoding> { // b == (x || y)
   CPIntVarBase* _b;
   CPIntVarBase* _x;
   CPIntVarBase* _y;
}
-(id)initCPOrDC:(id)b equal:(id)x or:(id)y;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPAndDC : CPCoreConstraint<NSCoding> { // b == (x && y)
   CPIntVarBase* _b;
   CPIntVarBase* _x;
   CPIntVarBase* _y;
}
-(id)initCPAndDC:(id)b equal:(id)x and:(id)y;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPImplyDC : CPCoreConstraint<NSCoding> { // b == (x => y)
   CPIntVarBase* _b;
   CPIntVarBase* _x;
   CPIntVarBase* _y;
}
-(id)initCPImplyDC:(id)b equal:(id)x imply:(id)y;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPAllDifferenceVC : CPCoreConstraint<NSCoding> {
   CPIntVarBase**   _x;
   ORLong       _nb;
}
-(id) initCPAllDifferenceVC: (id<CPEngine>) engine over: (id<CPIntVarArray>) x;
-(id) initCPAllDifferenceVC: (CPIntVarBase**) x nb: (ORInt) n;
-(id) initCPAllDifferenceVC: (id) x;
-(void) dealloc;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPIntVarMinimize : CPCoreConstraint<ORSearchObjectiveFunction>
-(id)        init: (id<CPIntVar>) x;
-(ORStatus)  post;
-(ORStatus)  check;
-(void)      updatePrimalBound;
-(void)      tightenPrimalBound: (id<ORObjectiveValue>) newBound;
-(void)      tightenWithDualBound: (id<ORObjectiveValue>) newBound;
-(id<ORObjectiveValue>) primalBound;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
-(id<ORIntVar>) var;
-(id<ORObjectiveValue>)value;
@end

@interface CPIntVarMaximize : CPCoreConstraint<ORSearchObjectiveFunction>
-(id)        init: (id<CPIntVar>) x;
-(ORStatus)  post;
-(ORStatus)  check;
-(void)      updatePrimalBound;
-(void)      tightenPrimalBound: (id<ORObjectiveValue>) newBound;
-(void)      tightenWithDualBound: (id<ORObjectiveValue>) newBound;
-(id<ORObjectiveValue>) primalBound;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
-(id<ORIntVar>) var;
-(id<ORObjectiveValue>)value;
@end

@interface CPRelaxation : CPCoreConstraint
-(CPRelaxation*) initCPRelaxation: (NSArray*) mv var: (NSArray*) cv relaxation: (id<ORRelaxation>) relaxation;
-(void)      dealloc;
-(ORStatus)  post;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
@end

