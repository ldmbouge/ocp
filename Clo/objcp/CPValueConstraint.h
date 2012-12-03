/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPTypes.h>
#import <CPUKernel/CPConstraintI.h>
#import "CPIntVarI.h"

@class CPIntVarI;
@class CPEngineI;

@interface CPReifyNotEqualcDC : CPCoreConstraint<NSCoding> {
@private
    CPIntVarI* _b;
    CPIntVarI* _x;
    ORInt      _c;
}
-(id) initCPReifyNotEqualcDC:(id<CPIntVar>)b when:(id<CPIntVar>)x neq:(ORInt)c;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPReifyEqualcDC : CPCoreConstraint<NSCoding> {
@private
    CPIntVarI* _b;
    CPIntVarI* _x;
    ORInt      _c;
}
-(id) initCPReifyEqualcDC:(id<CPIntVar>)b when:(id<CPIntVar>)x eq:(ORInt)c;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPReifyEqualBC : CPCoreConstraint<NSCoding> {
@private
   CPIntVarI* _b;
   CPIntVarI* _x;
   CPIntVarI* _y;
}
-(id) initCPReifyEqualBC:(id<CPIntVar>)b when:(id<CPIntVar>)x eq:(id<CPIntVar>)y;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPReifyEqualDC : CPCoreConstraint<NSCoding> {
@private
   CPIntVarI* _b;
   CPIntVarI* _x;
   CPIntVarI* _y;
}
-(id) initCPReifyEqualDC:(id<CPIntVar>)b when:(id<CPIntVar>)x eq:(id<CPIntVar>)y;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPReifyNEqualBC : CPCoreConstraint<NSCoding> {
@private
   CPIntVarI* _b;
   CPIntVarI* _x;
   CPIntVarI* _y;
}
-(id) initCPReify:(id<CPIntVar>)b when:(id<CPIntVar>)x neq:(id<CPIntVar>)y;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPReifyNEqualDC : CPCoreConstraint<NSCoding> {
@private
   CPIntVarI* _b;
   CPIntVarI* _x;
   CPIntVarI* _y;
}
-(id) initCPReify:(id<CPIntVar>)b when:(id<CPIntVar>)x neq:(id<CPIntVar>)y;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPReifyLEqualDC : CPCoreConstraint<NSCoding> {
@private
   CPIntVarI* _b;
   CPIntVarI* _x;
   ORInt      _c;
}
-(id) initCPReifyLEqualDC:(id<CPIntVar>)b when:(id<CPIntVar>)x leq:(ORInt)c;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPReifyGEqualDC : CPCoreConstraint<NSCoding> {
@private
   CPIntVarI* _b;
   CPIntVarI* _x;
   ORInt      _c;
}
-(id) initCPReifyGEqualDC:(id<CPIntVar>)b when:(id<CPIntVar>)x geq:(ORInt)c;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPSumBoolGeq : CPCoreConstraint<NSCoding> {
    CPIntVarI**       _x;
    ORLong           _nb;
    ORInt             _c;
    CPTrigger**      _at; // the c+1 triggers.
    ORInt* _notTriggered;
    ORLong         _last;
}
-(id) initCPSumBool:(id)x geq:(ORInt)c;
-(void) dealloc;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPSumBoolEq : CPCoreConstraint<NSCoding> {
   CPIntVarI**       _x;
   ORLong           _nb;
   ORInt             _c;
}
-(id) initCPSumBool:(id)x eq:(ORInt)c;
-(void) dealloc;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end
