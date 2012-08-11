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
@class CPEngineI;

@interface CPReifyNotEqualcDC : CPCoreConstraint<NSCoding> {
@private
    CPIntVarI* _b;
    CPIntVarI* _x;
    CPInt      _c;
}
-(id) initCPReifyNotEqualcDC:(id<ORIntVar>)b when:(id<ORIntVar>)x neq:(CPInt)c;
-(ORStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPReifyEqualcDC : CPCoreConstraint<NSCoding> {
@private
    CPIntVarI* _b;
    CPIntVarI* _x;
    CPInt      _c;
}
-(id) initCPReifyEqualcDC:(id<ORIntVar>)b when:(id<ORIntVar>)x eq:(CPInt)c;
-(ORStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPReifyEqualBC : CPCoreConstraint<NSCoding> {
@private
   CPIntVarI* _b;
   CPIntVarI* _x;
   CPIntVarI* _y;
}
-(id) initCPReifyEqualBC:(id<ORIntVar>)b when:(id<ORIntVar>)x eq:(id<ORIntVar>)y;
-(ORStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPReifyEqualDC : CPCoreConstraint<NSCoding> {
@private
   CPIntVarI* _b;
   CPIntVarI* _x;
   CPIntVarI* _y;
}
-(id) initCPReifyEqualDC:(id<ORIntVar>)b when:(id<ORIntVar>)x eq:(id<ORIntVar>)y;
-(ORStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPReifyLEqualDC : CPCoreConstraint<NSCoding> {
@private
   CPIntVarI* _b;
   CPIntVarI* _x;
   CPInt      _c;
}
-(id) initCPReifyLEqualDC:(id<ORIntVar>)b when:(id<ORIntVar>)x leq:(CPInt)c;
-(ORStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPReifyGEqualDC : CPCoreConstraint<NSCoding> {
@private
   CPIntVarI* _b;
   CPIntVarI* _x;
   CPInt      _c;
}
-(id) initCPReifyGEqualDC:(id<ORIntVar>)b when:(id<ORIntVar>)x geq:(CPInt)c;
-(ORStatus) post;
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
-(ORStatus) post;
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
-(ORStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end
