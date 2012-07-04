/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import "CPTypes.h"
#import "CPDataI.h"
#import "CPArray.h"
#import "CPConstraintI.h"
#import "ORTrail.h"
#import "CPBasicConstraint.h"

@interface CPCircuitI : CPActiveConstraint<CPConstraint,NSCoding> {
    CPIntVarArrayI*  _x;
    CPIntVarI**      _var;
    CPInt            _varSize;  
    CPInt            _low;
    CPInt            _up;
    id<CPTRIntArray> _pred;
    id<CPTRIntArray> _succ;
    id<CPTRIntArray> _length;
    bool             _noCycle;
    bool             _posted;
}
-(CPCircuitI*) initCPCircuitI: (CPIntVarArrayI*) x;
-(CPCircuitI*) initCPNoCycleI: (CPIntVarArrayI*) x;
-(void) dealloc;
-(CPStatus) post;
-(void) encodeWithCoder: (NSCoder*) aCoder;
-(id) initWithCoder: (NSCoder*) aDecoder;

static CPStatus assign(CPCircuitI* cstr,int i);
@end

