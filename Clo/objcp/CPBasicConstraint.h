/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPConstraintI.h>
#import <CPUKernel/CPGroup.h>
#import <objcp/CPBitDom.h>
#import <objcp/CPVar.h>

@class CPIntVar;
@class ORIntSetI;
@class CPEngine;
@class CPBitDom;
@protocol CPIntVarArray;


@interface CPRestrictI : CPCoreConstraint {
@private
   CPIntVar* _x;
   ORIntSetI* _r;
}
-(id) initRestrict:(id<CPIntVar>)x to:(id<ORIntSet>)r;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFalse : CPCoreConstraint
-(id)init:(id<CPEngine>)engine;
-(void)post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

// PVH: where is _active being used
@interface CPEqualc : CPCoreConstraint {
   @private
   CPIntVar* _x;
   ORInt  _c;
}
-(id) initCPEqualc:(id)x and:(ORInt)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDiffc : CPCoreConstraint {
@private
   CPIntVar* _x;
   ORInt      _c;
}
-(id) initCPDiffc:(id)x and:(ORInt)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPEqualBC : CPCoreConstraint {
@private
   CPIntVar*  _x;
   CPIntVar*  _y;
   ORInt _c;
}
-(id) initCPEqualBC: (id<CPIntVar>) x and: (id<CPIntVar>) y  and: (ORInt) c;
-(void) post;
-(void) propagate;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPEqualDC : CPCoreConstraint {
@private
   CPIntVar*  _x;
   CPIntVar*  _y;
   ORInt _c;
}
-(id) initCPEqualDC: (id) x and: (id) y  and: (ORInt) c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPAffineBC : CPCoreConstraint { // y == a x + b
   CPIntVar* _y;
   CPIntVar* _x;
   ORInt      _a;
   ORInt      _b;
}
-(id)initCPAffineBC:(id)y equal:(ORInt)a times:(id)x plus:(ORInt)b;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPAffineAC : CPCoreConstraint {  // y == a x + b
   CPIntVar* _y;
   CPIntVar* _x;
   ORInt      _a;
   ORInt      _b;
}
-(id)initCPAffineAC:(id)y equal:(ORInt)a times:(id)x plus:(ORInt)b;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPEqual3BC : CPCoreConstraint {
   CPIntVar* _x;
   CPIntVar* _y;
   CPIntVar* _z;
}
-(id) initCPEqual3BC: (id) x plus: (id) y  equal: (id) z;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPEqual3DC : CPCoreConstraint {
   CPIntVar* _x;
   CPIntVar* _y;
   CPIntVar* _z;   
   CPBitDom*  _fx;
   CPBitDom*  _fy;
   CPBitDom*  _fz;
   TRIntArray _xs;
   TRIntArray _ys;
   TRIntArray _zs;
}
-(id) initCPEqual3DC: (id) x plus: (id) y  equal: (id) z;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

typedef int (^intgetter) (void) ;

@interface CPNotEqual : CPCoreConstraint {
@private
   CPIntVar* _x;
   CPIntVar* _y;
   ORInt  _c;
}
-(id) initCPNotEqual: (id) x and: (id) y  and: (ORInt) c;
-(void) post;
-(void) propagate;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPBasicNotEqual : CPCoreConstraint {
   CPIntVar* _x;
   CPIntVar* _y;
}
-(id) initCPBasicNotEqual:(id)x and:(id) y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPLEqualBC : CPCoreConstraint {  // x <= y + c
@private
   CPIntVar*  _x;
   CPIntVar*  _y;
   ORInt      _c;
}
-(id) initCPLEqualBC:(id)x and:(id) y plus:(ORInt) c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPLEqualc : CPCoreConstraint { // x <= c
@private
   CPIntVar* _x;
   ORInt      _c;
}
-(id) initCPLEqualc:(id)x and:(ORInt) c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPGEqualc : CPCoreConstraint { // x >= c
@private
   CPIntVar* _x;
   ORInt      _c;
}
-(id) initCPGEqualc:(id)x and:(ORInt) c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPMultBC : CPCoreConstraint { // z == x * y
   CPIntVar* _x;
   CPIntVar* _y;
   CPIntVar* _z;
}
-(id) initCPMultBC:(id)x times:(id)y equal:(id)z;
-(void) post;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
@end

@interface CPSquareBC : CPCoreConstraint { // z = x^2
   CPIntVar* _x;
   CPIntVar* _z;
}
-(id)initCPSquareBC:(id)z equalSquare:(id)x;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPSquareDC : CPSquareBC   // z == x^2 (DC variant)
-(id)initCPSquareDC:(id)z equalSquare:(id)x;
-(void) post;
@end

@interface CPModcBC : CPCoreConstraint { // y == x MOD c
   CPIntVar* _x;
   CPIntVar* _y;
   ORInt      _c;
}
-(id)initCPModcBC:(id)x mod:(ORInt)c equal:(id)y;
-(void) post;
@end

@interface CPModcDC : CPCoreConstraint { // y == x MOD c (DCConsistency)
   CPIntVar* _x;
   CPIntVar* _y;
   ORInt      _c;
}
-(id)initCPModcDC:(id)x mod:(ORInt)c equal:(id)y;
-(void) post;
@end

@interface CPMinBC : CPCoreConstraint {
   CPIntVar* _x;
   CPIntVar* _y;
   CPIntVar* _z;   
}
-(id)initCPMin:(id)x and:(id)y equal:(id)z;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPMaxBC : CPCoreConstraint {
   CPIntVar* _x;
   CPIntVar* _y;
   CPIntVar* _z;
}
-(id)initCPMax:(id)x and:(id)y equal:(id)z;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPModBC : CPCoreConstraint { // z == x MOD y
   CPIntVar* _x;
   CPIntVar* _y;
   CPIntVar* _z;
}
-(id)initCPModBC:(id)x mod:(id)y equal:(id)z;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPAbsBC : CPCoreConstraint { // abs(x)==y
   CPIntVar* _x;
   CPIntVar* _y;
}
-(id)initCPAbsBC:(id)x equal:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPAbsDC : CPCoreConstraint { // abs(x)==y
   CPIntVar* _x;
   CPIntVar* _y;
}
-(id)initCPAbsDC:(id)x equal:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPOrDC : CPCoreConstraint { // b == (x || y)
   CPIntVar* _b;
   CPIntVar* _x;
   CPIntVar* _y;
}
-(id)initCPOrDC:(id)b equal:(id)x or:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPAndDC : CPCoreConstraint { // b == (x && y)
   CPIntVar* _b;
   CPIntVar* _x;
   CPIntVar* _y;
}
-(id)initCPAndDC:(id)b equal:(id)x and:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPImplyDC : CPCoreConstraint { // b == (x => y)
   CPIntVar* _b;
   CPIntVar* _x;
   CPIntVar* _y;
}
-(id)initCPImplyDC:(id)b equal:(id)x imply:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end


@interface CPBinImplyDC : CPCoreConstraint { // (x => y)
   CPIntVar* _x;
   CPIntVar* _y;
}
-(id)initCPBinImplyDC:(id)x imply:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end


@interface CPAllDifferenceVC : CPCoreConstraint 
-(id) initCPAllDifferenceVC: (id<CPEngine>) engine over: (id<CPIntVarArray>) x;
-(id) initCPAllDifferenceVC: (CPIntVar**) x nb: (ORInt) n;
-(id) initCPAllDifferenceVC: (id) x;
-(void) dealloc;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPIntVarMinimize : CPCoreConstraint<ORSearchObjectiveFunction>
-(id)        init: (id<CPIntVar>) x;
-(void)       post;
-(ORStatus)  check;
-(void)      updatePrimalBound;
-(void)      updateDualBound;
-(void)      tightenPrimalBound: (id<ORObjectiveValue>) newBound;
-(ORStatus) tightenDualBound: (id<ORObjectiveValue>) newBound;
-(void)     tightenLocallyWithDualBound: (id<ORObjectiveValue>) newBound;
-(id<ORObjectiveValue>) primalBound;
-(id<ORObjectiveValue>) dualBound;
-(id<ORObjectiveValue>) primalValue;
-(id<ORObjectiveValue>) dualValue;
-(ORBool)   isBound;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
-(id<ORIntVar>) var;
-(ORBool)   isMinimization;
@end

@interface CPIntVarMaximize : CPCoreConstraint<ORSearchObjectiveFunction>
-(id)        init: (id<CPIntVar>) x;
-(void)  post;
-(ORStatus)  check;
-(void)      updatePrimalBound;
-(void)      updateDualBound;
-(void)      tightenPrimalBound: (id<ORObjectiveValue>) newBound;
-(ORStatus)  tightenDualBound: (id<ORObjectiveValue>) newBound;
-(void)      tightenLocallyWithDualBound: (id<ORObjectiveValue>) newBound;
-(id<ORObjectiveValue>) primalBound;
-(id<ORObjectiveValue>) dualBound;
-(ORBool)   isBound;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
-(id<ORIntVar>) var;
-(ORBool)   isMinimization;
@end

@interface CPRelaxation : CPCoreConstraint
-(CPRelaxation*) initCPRelaxation: (NSArray*) mv var: (NSArray*) cv relaxation: (id<ORRelaxation>) relaxation;
-(void)      dealloc;
-(void)  post;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
@end

@interface CPGuardedGroup : CPGroup<CPGroup>
-(id)   init: (id<CPEngine>) engine guard:(id<CPIntVar>)guard;
-(void) post;
@end

@interface CPCDisjunction : CPCoreConstraint<CPGroup>
-(id)   init: (id<CPEngine>) engine originals:(id<CPVarArray>)origs varMap:(NSArray*)vm;
-(void) add: (id<CPConstraint>) p;
-(void) assignIdToConstraint:(id<ORConstraint>)c;
-(void) scheduleTrigger: (ORClosure) cb onBehalf: (id<CPConstraint>) c;
-(void) scheduleClosure: (id<CPClosureList>) evt;
-(void) scheduleValueClosure: (id<CPValueEvent>) evt;
-(void) enumerateWithBlock:(void(^)(ORInt,id<ORConstraint>))block;
-(void) post;
-(void) propagate;
@end
