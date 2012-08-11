/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPConstraintI.h>
#import <objcp/CPBitDom.h>

@class CPIntVarI;
@class CPEngine;

// PVH: where is _active being used
@interface CPEqualc : CPActiveConstraint<NSCoding> {
   @private
   CPIntVarI* _x;
   CPInt  _c;
}
-(id) initCPEqualc:(id)x and:(CPInt)c;
-(void) dealloc;
-(ORStatus)post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPDiffc : CPActiveConstraint<NSCoding> {
@private
   CPIntVarI* _x;
   CPInt      _c;
}
-(id) initCPDiffc:(id)x and:(CPInt)c;
-(void) dealloc;
-(ORStatus)post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPEqualBC : CPActiveConstraint<NSCoding> {
@private
   CPIntVarI*  _x;
   CPIntVarI*  _y;
   CPInt _c;
}
-(id) initCPEqualBC: (id) x and: (id) y  and: (CPInt) c;
-(void) dealloc;
-(ORStatus) post;
-(void) propagate;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPEqualDC : CPActiveConstraint<NSCoding> {
@private
   CPIntVarI*  _x;
   CPIntVarI*  _y;
   CPInt _c;
}
-(id) initCPEqualDC: (id) x and: (id) y  and: (CPInt) c;
-(void) dealloc;
-(ORStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPEqual3DC : CPActiveConstraint<NSCoding> {
   CPIntVarI* _x;
   CPIntVarI* _y;
   CPIntVarI* _z;   
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
-(CPUInt)nbUVars;
@end

typedef int (^intgetter) (void) ;

@interface CPNotEqual : CPActiveConstraint<NSCoding> {
@private
   CPIntVarI* _x;
   CPIntVarI* _y;
   CPInt  _c;
}
-(id) initCPNotEqual: (id) x and: (id) y  and: (CPInt) c;
-(ORStatus) post;
-(void) propagate;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPBasicNotEqual : CPActiveConstraint<NSCoding> {
   CPIntVarI* _x;
   CPIntVarI* _y;
}
-(id) initCPBasicNotEqual:(id)x and:(id) y;
-(ORStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPLEqualBC : CPActiveConstraint<NSCoding> {  // x <= y
@private
   CPIntVarI*  _x;
   CPIntVarI*  _y;   
}
-(id) initCPLEqualBC:(id)x and:(id) y;
-(ORStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPLEqualc : CPActiveConstraint<NSCoding> { // x <= c
@private
   CPIntVarI* _x;
   CPInt      _c;
}
-(id) initCPLEqualc:(id)x and:(CPInt) c;
-(ORStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPMultBC : CPActiveConstraint<NSCoding> { // z == x * y
   CPIntVarI* _x;
   CPIntVarI* _y;
   CPIntVarI* _z;
}
-(id) initCPMultBC:(id)x times:(id)y equal:(id)z;
-(ORStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPAbsBC : CPActiveConstraint<NSCoding> { // abs(x)==y
   CPIntVarI* _x;
   CPIntVarI* _y;
}
-(id)initCPAbsBC:(id)x equal:(id)y;
-(ORStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPAbsDC : CPActiveConstraint<NSCoding> { // abs(x)==y
   CPIntVarI* _x;
   CPIntVarI* _y;
}
-(id)initCPAbsDC:(id)x equal:(id)y;
-(ORStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPOrDC : CPActiveConstraint<NSCoding> { // b == (x || y)
   CPIntVarI* _b;
   CPIntVarI* _x;
   CPIntVarI* _y;
}
-(id)initCPOrDC:(id)b equal:(id)x or:(id)y;
-(ORStatus)post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPAndDC : CPActiveConstraint<NSCoding> { // b == (x && y)
   CPIntVarI* _b;
   CPIntVarI* _x;
   CPIntVarI* _y;
}
-(id)initCPAndDC:(id)b equal:(id)x and:(id)y;
-(ORStatus)post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPImplyDC : CPActiveConstraint<NSCoding> { // b == (x => y)
   CPIntVarI* _b;
   CPIntVarI* _x;
   CPIntVarI* _y;
}
-(id)initCPImplyDC:(id)b equal:(id)x imply:(id)y;
-(ORStatus)post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPAllDifferenceVC : CPActiveConstraint<NSCoding> {
   CPIntVarI**   _x;
   CPLong       _nb;
}
-(id) initCPAllDifferenceVC: (id<CPSolver>) cp over: (id<ORIntVarArray>) x;
-(id) initCPAllDifferenceVC: (CPIntVarI**) x nb: (CPInt) n;
-(id) initCPAllDifferenceVC: (id) x;
-(void) dealloc;
-(ORStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPIntVarMinimize : CPCoreConstraint<ORObjective>
-(id)        initCPIntVarMinimize: (id<ORIntVar>) x;
-(void)      dealloc;
-(ORStatus)  post;
-(ORStatus)  check;
-(void)      updatePrimalBound;
-(CPInt)       primalBound;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPIntVarMaximize : CPCoreConstraint<ORObjective>
-(id)        initCPIntVarMaximize: (id<ORIntVar>) x;
-(void)      dealloc;
-(ORStatus)  post;
-(ORStatus)  check;
-(void)      updatePrimalBound;
-(CPInt)       primalBound;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end
