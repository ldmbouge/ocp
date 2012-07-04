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
#import "CPArrayI.h"
#import "CPConstraintI.h"
#import "ORTrail.h"
#import "CPBasicConstraint.h"

@interface CPCardinalityDC : CPActiveConstraint<CPConstraint,NSCoding> {
    CPIntVarArrayI* _x;
    CPIntArrayI*    _lb;
    CPIntArrayI*    _ub;
    
    CPIntVarI**     _var;         
    CPInt           _varSize;
    
    CPInt           _valMin;           // smallest value
    CPInt           _valMax;           // largest value
    CPInt           _valSize;          // number of values
    CPInt*          _low;              // _low[i] = lower bound on value i
    CPInt*          _up;               // _up[i]  = upper bound on value i
 
    CPInt*          _flow;           // the flow for a value
    CPInt           _nbAssigned;     // number of variable assigned
    
    CPInt*          _varMatch;       // the value of a variable
    CPInt*          _valFirstMatch;  // The first variable matched to a value
    CPInt*          _nextMatch;      // The next variable matched to a value; indexed by variable id
    CPInt*          _prevMatch;      // The previous variable matched to a value; indexed by variable id
    
    CPULong         _magic;
    CPULong*        _varMagic;
    CPULong*        _valueMagic;
    
    CPInt           _dfs;
    CPInt           _component;
    
    CPInt*          _varComponent;
    CPInt*          _varDfs;
    CPInt*          _varHigh;
    
    CPInt*          _valComponent;
    CPInt*          _valDfs;
    CPInt*          _valHigh;
    
    CPInt           _sinkComponent;
    CPInt           _sinkDfs;
    CPInt           _sinkHigh;
    
    CPInt*          _stack;
    CPInt*          _type;
    CPInt           _top;
    
    bool            _posted;
}
-(CPCardinalityDC*) initCPCardinalityDC: (CPIntVarArrayI*) x low: (id<CPIntArray>) lb up: (id<CPIntArray>) ub;
-(void) dealloc;

-(CPStatus) post;
-(void) propagate;
-(NSSet*) allVars;
-(CPUInt) nbUVars;
@end
