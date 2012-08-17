/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "CPCircuitI.h"
#import "CPBasicConstraint.h"
#import "CPEngineI.h"
#import "CPIntVarI.h"
#import "CPArrayI.h"
#import "CPError.h"

@implementation CPCircuitI {
   id<ORIntVarArray>  _x;
   CPIntVarI**      _var;
   ORInt            _varSize;
   ORInt            _low;
   ORInt            _up;
   id<ORTRIntArray> _pred;
   id<ORTRIntArray> _succ;
   id<ORTRIntArray> _length;
   bool             _noCycle;
   bool             _posted;
}

-(void) initInstanceVariables
{
    _idempotent = YES;
    _priority = HIGHEST_PRIO;
    _posted = false;
}

-(CPCircuitI*) initCPSubtourEliminationI: (id<ORIntVarArray>) x
{
    self = [super initCPActiveConstraint: [[x solver] engine]];
    _x = x;
    [self initInstanceVariables];
    return self;
}
-(CPCircuitI*) initCPNoCycleI: (id<ORIntVarArray>) x
{
    _noCycle = true;
    return [self initCPSubtourEliminationI: x];
}
-(CPCircuitI*) initCPCircuitI: (id<ORIntVarArray>) x
{
    _noCycle = false;
    return [self initCPSubtourEliminationI: x];
}

-(void) dealloc 
{
    NSLog(@"Circuit dealloc called ...");
    if (_posted) {
        _var += _low;
        free(_var);
    }
    [super dealloc];
}

-(void) encodeWithCoder:(NSCoder*) aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_x];
    [aCoder encodeValueOfObjCType:@encode(bool) at:&_noCycle];
}

-(id) initWithCoder:(NSCoder*) aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self initInstanceVariables];
    _x = [aDecoder decodeObject];
    [aDecoder decodeValueOfObjCType:@encode(bool) at:&_noCycle];
    return self;
}

ORStatus assign(CPCircuitI* cstr,int i)
{
    ORInt val = [cstr->_var[i] min];
    ORInt end = [cstr->_succ at: val];
    ORInt start = [cstr->_pred at: i];
    ORInt l = [cstr->_length at: start] + [cstr->_length at: val] + 1; 
    [cstr->_pred set: start at: end];
    [cstr->_succ set: end at: start];
    [cstr->_length set: l at: start];
    if (l < cstr->_varSize- 1 || cstr->_noCycle)
        return [cstr->_var[end] remove: start];
    return ORSuspend;
}

-(ORStatus) post
{
    if (_posted)
        return ORSuspend;
    _posted = true;
    
    _low = [_x low];
    _up = [_x up];
    _varSize = (_up - _low + 1);
    _var = malloc(_varSize * sizeof(CPIntVarI*));
    for(ORInt i = 0; i < _varSize; i++)
        _var[i] = (CPIntVarI*) [_x at: _low + i];
    _var -= _low;
    
    id<ORIntRange> R = RANGE([_x solver],_low,_up);
    _pred = [CPFactory TRIntArray: [_x solver] range: R];
    _succ = [CPFactory TRIntArray: [_x solver] range: R];
    _length = [CPFactory TRIntArray: [_x solver] range: R];
    for(int i = _low; i <= _up; i++) {
        [_pred set: i at: i];
        [_succ set: i at: i];
        [_length set: 0 at: i];
    }
    for(int i = _low; i <= _up; i++) {
        [_var[i] remove: i];
        [_var[i] updateMin: _low];
        [_var[i] updateMax: _up];
    }
    for(int i = _low; i <= _up; i++) {
        if ([_var[i] bound]) {
            assign(self,i);
        }
        else 
            [_var[i] whenBindDo: ^ { assign(self,i); } onBehalf:self];  
    }
    return ORSuspend;
}

@end
