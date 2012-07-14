/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPTypes.h>
#import <objcp/CPArray.h>
#import <objcp/CPConstraintI.h>
#import <objcp/CPBasicConstraint.h>

@interface CPCardinalityDC : CPActiveConstraint<CPConstraint,NSCoding> {
    id<CPIntVarArray> _x;
    id<CPIntArray>  _lb;
    id<CPIntArray>  _ub;
    
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
-(CPCardinalityDC*) initCPCardinalityDC: (id<CPIntVarArray>) x low: (id<CPIntArray>) lb up: (id<CPIntArray>) ub;
-(void) dealloc;

-(CPStatus) post;
-(void) propagate;
-(NSSet*) allVars;
-(CPUInt) nbUVars;
@end
