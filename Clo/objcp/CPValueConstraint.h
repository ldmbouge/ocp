/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORTrail.h>
#import <objcp/CPTypes.h>
#import "CPIntVarI.h"
#import "CPConstraintI.h"

@class CPIntVarI;
@class CPSolverI;

@interface CPReifyNotEqualcDC : CPCoreConstraint<NSCoding> {
@private
    CPIntVarI* _b;
    CPIntVarI* _x;
    CPInt      _c;
}
-(id) initCPReifyNotEqualcDC:(id<CPIntVar>)b when:(id<CPIntVar>)x neq:(CPInt)c;
-(CPStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPReifyEqualcDC : CPCoreConstraint<NSCoding> {
@private
    CPIntVarI* _b;
    CPIntVarI* _x;
    CPInt      _c;
}
-(id) initCPReifyEqualcDC:(id<CPIntVar>)b when:(id<CPIntVar>)x eq:(CPInt)c;
-(CPStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPReifyEqualBC : CPCoreConstraint<NSCoding> {
@private
   CPIntVarI* _b;
   CPIntVarI* _x;
   CPIntVarI* _y;
}
-(id) initCPReifyEqualBC:(id<CPIntVar>)b when:(id<CPIntVar>)x eq:(id<CPIntVar>)y;
-(CPStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPReifyEqualDC : CPCoreConstraint<NSCoding> {
@private
   CPIntVarI* _b;
   CPIntVarI* _x;
   CPIntVarI* _y;
}
-(id) initCPReifyEqualDC:(id<CPIntVar>)b when:(id<CPIntVar>)x eq:(id<CPIntVar>)y;
-(CPStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPReifyLEqualDC : CPCoreConstraint<NSCoding> {
@private
   CPIntVarI* _b;
   CPIntVarI* _x;
   CPInt      _c;
}
-(id) initCPReifyLEqualDC:(id<CPIntVar>)b when:(id<CPIntVar>)x leq:(CPInt)c;
-(CPStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPReifyGEqualDC : CPCoreConstraint<NSCoding> {
@private
   CPIntVarI* _b;
   CPIntVarI* _x;
   CPInt      _c;
}
-(id) initCPReifyGEqualDC:(id<CPIntVar>)b when:(id<CPIntVar>)x geq:(CPInt)c;
-(CPStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end


@interface CPSumBoolGeq : CPCoreConstraint<NSCoding> {
    CPIntVarI**       _x;
    CPLong           _nb;
    CPInt             _c;
    CPTrigger**      _at; // the c+1 triggers.
    CPInt* _notTriggered;
    CPLong         _last;
}
-(id) initCPSumBool:(id)x geq:(CPInt)c;
-(void) dealloc;
-(CPStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPSumBoolEq : CPActiveConstraint<NSCoding> {
   CPIntVarI**       _x;
   CPLong           _nb;
   CPInt             _c;
}
-(id) initCPSumBool:(id)x eq:(CPInt)c;
-(void) dealloc;
-(CPStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end
