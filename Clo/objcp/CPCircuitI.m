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


#import "CPCircuitI.h"
#import "CPBasicConstraint.h"
#import "CPSolverI.h"
#import "CPIntVarI.h"
#import "CPArrayI.h"
#import "CPError.h"

@implementation CPCircuitI

-(void) initInstanceVariables 
{
    _idempotent = YES;
    _priority = HIGHEST_PRIO;
    _posted = false;
}

-(CPCircuitI*) initCPSubtourEliminationI: (CPIntVarArrayI*) x
{
    self = [super initCPActiveConstraint: [[x cp] solver]];
    _x = x;
    [self initInstanceVariables];
    return self;
}
-(CPCircuitI*) initCPNoCycleI: (CPIntVarArrayI*) x
{
    _noCycle = true;
    return [self initCPSubtourEliminationI: x];
}
-(CPCircuitI*) initCPCircuitI: (CPIntVarArrayI*) x
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
        freeTRIntArray(_pred);
        freeTRIntArray(_succ);
        freeTRIntArray(_length);
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
    int val = [cstr->_var[i] min];
    int end = getTRIntArray(cstr->_succ,val);
    int start = getTRIntArray(cstr->_pred,i);
    int l = getTRIntArray(cstr->_length,start) + getTRIntArray(cstr->_length,val) + 1;
    assignTRIntArray(cstr->_pred,end,start);
    assignTRIntArray(cstr->_succ,start,end);
    assignTRIntArray(cstr->_length,start,l);
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
    
    _pred = makeTRIntArray(_trail,_varSize,_low);
    _succ = makeTRIntArray(_trail,_varSize,_low);
    _length = makeTRIntArray(_trail,_varSize,_low);
    for(int i = _low; i <= _up; i++) {
        assignTRIntArray(_pred,i,i);
        assignTRIntArray(_succ,i,i);
        assignTRIntArray(_length,i,0);
    }
    for(int i = _low; i <= _up; i++) {
        if ([_var[i] remove: i] == CPFailure)
            return CPFailure;
        if ([_var[i] updateMin: _low] == CPFailure)
            return CPFailure;
        if ([_var[i] updateMax: _up] == CPFailure)
            return CPFailure;
    }
    for(int i = _low; i <= _up; i++) {
        if ([_var[i] bound]) {
            if (assign(self,i) == CPFailure)
                return CPFailure;
        }
        else 
            [_var[i] whenBindDo: ^CPStatus() { return assign(self,i); } onBehalf:self];  
    }
    return CPSuspend;
}


@end
