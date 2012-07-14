/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "CPCircuitI.h"
#import "CPBasicConstraint.h"
#import "CPSolverI.h"
#import "CPIntVarI.h"
#import "CPArrayI.h"
#import "CPError.h"

@implementation CPCircuitI {
   id<CPIntVarArray>  _x;
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

-(void) initInstanceVariables
{
    _idempotent = YES;
    _priority = HIGHEST_PRIO;
    _posted = false;
}

-(CPCircuitI*) initCPSubtourEliminationI: (id<CPIntVarArray>) x
{
    self = [super initCPActiveConstraint: [[x cp] solver]];
    _x = x;
    [self initInstanceVariables];
    return self;
}
-(CPCircuitI*) initCPNoCycleI: (id<CPIntVarArray>) x
{
    _noCycle = true;
    return [self initCPSubtourEliminationI: x];
}
-(CPCircuitI*) initCPCircuitI: (id<CPIntVarArray>) x
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

CPStatus assign(CPCircuitI* cstr,int i)
{
    CPInt val = [cstr->_var[i] min];
    CPInt end = [cstr->_succ at: val];
    CPInt start = [cstr->_pred at: i];
    CPInt l = [cstr->_length at: start] + [cstr->_length at: val] + 1; 
    [cstr->_pred set: start at: end];
    [cstr->_succ set: end at: start];
    [cstr->_length set: l at: start];
    if (l < cstr->_varSize- 1 || cstr->_noCycle)
        return [cstr->_var[end] remove: start];
    return CPSuspend;
}

-(CPStatus) post
{
    if (_posted)
        return CPSuspend;
    _posted = true;
    
    _low = [_x low];
    _up = [_x up];
    _varSize = (_up - _low + 1);
    _var = malloc(_varSize * sizeof(CPIntVarI*));
    for(CPInt i = 0; i < _varSize; i++)
        _var[i] = (CPIntVarI*) [_x at: _low + i];
    _var -= _low;
    
    CPRange R = (CPRange){_low,_up};
    _pred = [CPFactory TRIntArray: [_x cp] range: R];
    _succ = [CPFactory TRIntArray: [_x cp] range: R];
    _length = [CPFactory TRIntArray: [_x cp] range: R];
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
    return CPSuspend;
}

@end
