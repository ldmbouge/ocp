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
#import <CPUKernel/CPTrigger.h>
#import "CPIntVarI.h"

@class CPIntVarI;
@class CPEngineI;

@interface CPReifyNotEqualcDC : CPCoreConstraint {
@private
    CPIntVar* _b;
    CPIntVar* _x;
    ORInt      _c;
}
-(id) initCPReifyNotEqualcDC:(id<CPIntVar>)b when:(id<CPIntVar>)x neq:(ORInt)c;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPReifyEqualcDC : CPCoreConstraint {
@private
    CPIntVar* _b;
    CPIntVar* _x;
    ORInt      _c;
}
-(id) initCPReifyEqualcDC:(id<CPIntVar>)b when:(id<CPIntVar>)x eq:(ORInt)c;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPReifyEqualBC : CPCoreConstraint {
@private
   CPIntVar* _b;
   CPIntVar* _x;
   CPIntVar* _y;
}
-(id) initCPReifyEqualBC:(id<CPIntVar>)b when:(id<CPIntVar>)x eq:(id<CPIntVar>)y;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPReifyEqualDC : CPCoreConstraint {
@private
   CPIntVar* _b;
   CPIntVar* _x;
   CPIntVar* _y;
}
-(id) initCPReifyEqualDC:(id<CPIntVar>)b when:(id<CPIntVar>)x eq:(id<CPIntVar>)y;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPReifyNEqualBC : CPCoreConstraint {
@private
   CPIntVar* _b;
   CPIntVar* _x;
   CPIntVar* _y;
}
-(id) initCPReify:(id<CPIntVar>)b when:(id<CPIntVar>)x neq:(id<CPIntVar>)y;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPReifyNEqualDC : CPCoreConstraint {
@private
   CPIntVar* _b;
   CPIntVar* _x;
   CPIntVar* _y;
}
-(id) initCPReify:(id<CPIntVar>)b when:(id<CPIntVar>)x neq:(id<CPIntVar>)y;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPReifyLEqualBC : CPCoreConstraint {
@private
   CPIntVar* _b;
   CPIntVar* _x;
   CPIntVar* _y;
}
-(id) initCPReifyLEqualBC:(id<CPIntVar>)b when:(id<CPIntVar>)x leq:(id<CPIntVar>)y;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPReifyLEqualDC : CPCoreConstraint {
@private
   CPIntVar* _b;
   CPIntVar* _x;
   ORInt      _c;
}
-(id) initCPReifyLEqualDC:(id<CPIntVar>)b when:(id<CPIntVar>)x leqi:(ORInt)c;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPReifyGEqualDC : CPCoreConstraint {
@private
   CPIntVar* _b;
   CPIntVar* _x;
   ORInt      _c;
}
-(id) initCPReifyGEqualDC:(id<CPIntVar>)b when:(id<CPIntVar>)x geq:(ORInt)c;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPSumBoolGeq : CPCoreConstraint {
    CPIntVar**       _x;
    ORLong           _nb;
    ORInt             _c;
    id<CPTrigger>*   _at; // the c+1 triggers.
    ORInt* _notTriggered;
    ORLong         _last;
}
-(id) initCPSumBool:(id)x geq:(ORInt)c;
-(void) dealloc;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPSumBoolEq : CPCoreConstraint {
   id<CPIntVarArray> _xa;
   CPIntVar**        _x;
   ORLong            _nb;
   ORInt              _c;
}
-(id) initCPSumBool:(id)x eq:(ORInt)c;
-(void) dealloc;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPReifySumBoolEq : CPCoreConstraint {
   id<CPIntVar>       _b;
   id<CPIntVarArray> _xa;
   ORInt              _c;
}
-(id) init:(id<CPIntVar>)b array:(id<CPIntVarArray>)x eqi:(ORInt)c;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPHReifySumBoolEq : CPCoreConstraint {
   id<CPIntVar>       _b;
   id<CPIntVarArray> _xa;
   ORInt              _c;
}
-(id) init:(id<CPIntVar>)b array:(id<CPIntVarArray>)x eqi:(ORInt)c;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPHReifySumBoolGEq : CPCoreConstraint {
   id<CPIntVar>       _b;
   id<CPIntVarArray> _xa;
   ORInt              _c;
}
-(id) init:(id<CPIntVar>)b array:(id<CPIntVarArray>)x geqi:(ORInt)c;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end