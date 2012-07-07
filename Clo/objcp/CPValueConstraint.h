/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import "CPTypes.h"
#import "CPIntVarI.h"
#import "CPDataI.h"
#import "CPConstraintI.h"
#import "ORTrail.h"

@class CPIntVarI;
@class CPSolverI;

@interface CPReifyNotEqualDC : CPCoreConstraint<NSCoding> {
@private
    CPIntVarI* _b;
    CPIntVarI* _x;
    CPInt       _c;
}
-(id) initCPReifyNotEqualDC:(id<CPIntVar>)b when:(id<CPIntVar>)x neq:(CPInt)c;
-(CPStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPReifyEqualDC : CPCoreConstraint<NSCoding> {
@private
    CPIntVarI* _b;
    CPIntVarI* _x;
    CPInt       _c;
}
-(id) initCPReifyEqualDC:(id<CPIntVar>)b when:(id<CPIntVar>)x eq:(CPInt)c;
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
-(id) initCPSumBoolGeq:(id)x geq:(CPInt)c;
-(void) dealloc;
-(CPStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

