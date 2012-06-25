/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "CPTypes.h"
#import "CPDataI.h"
#import "CPArrayI.h"
#import "CPConstraintI.h"
#import "CPTrail.h"
#import "CPBasicConstraint.h"

@interface CPCardinalityDC : CPActiveConstraint<CPConstraint,NSCoding> {
    CPIntVarArrayI* _x;
    CPIntArrayI*    _lb;
    CPIntArrayI*    _ub;
    
    CPIntVarI** _var;         
    CPInt       _varSize;
    
    CPInt   _valMin;           // smallest value
    CPInt   _valMax;           // largest value
    CPInt   _valSize;          // number of values
    CPInt*  _low;              // _low[i] = lower bound on value i
    CPInt*  _up;               // _up[i]  = upper bound on value i
 
    CPInt*    _flow;           // the flow for a value
    CPInt     _nbAssigned;     // number of variable assigned
    
    CPInt*    _varMatch;       // the value of a variable
    CPInt*    _valFirstMatch;  // The first variable matched to a value
    CPInt*    _nextMatch;      // The next variable matched to a value; indexed by variable id
    CPInt*    _prevMatch;      // The previous variable matched to a value; indexed by variable id
    
    CPULong   _magic;
    CPULong*  _varMagic;
    CPULong*  _valueMagic;
    
    CPInt     _sizeMatching;
    CPInt*    _valSeen;
    
    CPInt   _dfs;
    CPInt   _component;
    
    CPInt*  _varComponent;
    CPInt*  _varDfs;
    CPInt*  _varHigh;
    
    CPInt*  _valComponent;
    CPInt*  _valDfs;
    CPInt*  _valHigh;
    
    CPInt*  _stack;
    CPInt*  _type;
    CPInt   _top;
    
    bool       _posted;
}
-(CPCardinalityDC*) initCPCardinalityDC: (CPIntVarArrayI*) x low: (id<CPIntArray>) lb up: (id<CPIntArray>) ub;
-(void) dealloc;

-(CPStatus) post;
-(CPStatus) propagate;
-(NSSet*) allVars;
-(CPUInt) nbUVars;
@end
