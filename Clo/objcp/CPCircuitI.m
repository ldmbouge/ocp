/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "CPCircuitI.h"
#import "CPBasicConstraint.h"
#import "CPEngineI.h"
#import "CPIntVarI.h"
#import "CPError.h"

@implementation CPCircuit {
   id<CPIntVarArray>  _x;
   CPIntVar**        _var;
   ORInt            _varSize;
   ORInt            _low;
   ORInt            _up;
   id<ORTRIntArray> _pred;
   id<ORTRIntArray> _succ;
   id<ORTRIntArray> _length;
   bool             _posted;
}

-(void) initInstanceVariables
{
    _priority = HIGHEST_PRIO;
    _posted = false;
}
-(CPCircuit*) initCPCircuit: (id<CPIntVarArray>) x
{
   self = [super initCPCoreConstraint: [[x at:[x low]] engine]];
   _x = x;
   [self initInstanceVariables];
   return self;
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

void assignCircuit(CPCircuit* cstr,int i)
{
    ORInt val = [cstr->_var[i] min];
    ORInt end = [cstr->_succ at: val];
    ORInt start = [cstr->_pred at: i];
    ORInt l = [cstr->_length at: start] + [cstr->_length at: val] + 1; 
    [cstr->_pred set: start at: end];
    [cstr->_succ set: end at: start];
    [cstr->_length set: l at: start];
    if (l < cstr->_varSize- 1)
        [cstr->_var[end] remove: start];
}

-(void) post
{
    if (_posted)
        return ;
    _posted = true;
    
    _low = [_x low];
    _up = [_x up];
    _varSize = (_up - _low + 1);
    _var = malloc(_varSize * sizeof(CPIntVar*));
    for(ORInt i = 0; i < _varSize; i++)
        _var[i] = (CPIntVar*) [_x at: _low + i];
    _var -= _low;
    
    id<ORIntRange> R = RANGE([_x tracker],_low,_up);
    _pred = [CPFactory TRIntArray: [_x tracker] range: R];
    _succ = [CPFactory TRIntArray: [_x tracker] range: R];
    _length = [CPFactory TRIntArray: [_x tracker] range: R];
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
            assignCircuit(self,i);
        }
        else 
            [_var[i] whenBindDo: ^ { assignCircuit(self,i); } onBehalf:self];
    }
}

@end

// low is the source and up+1 is the sink
// [pvh: this should be upgraded to see
//    if there is a path from the sink to source
//    if the current state is a path from sink to source not including everyone -> fail.

@implementation CPPath {
   id<CPIntVarArray>  _x;
   CPIntVar**         _var;
   ORInt              _varSize;
   ORInt              _low;
   ORInt              _up;
   id<ORTRIntArray>   _pred;
   id<ORTRIntArray>   _succ;
   bool             _posted;
}

-(void) initInstanceVariables
{
   _priority = HIGHEST_PRIO;
   _posted = false;
}
-(CPPath*) initCPPath: (id<CPIntVarArray>) x
{
   self = [super initCPCoreConstraint: [[x at:[x low]] engine]];
   _x = x;
   [self initInstanceVariables];
   return self;
}
-(void) dealloc
{
   NSLog(@"CPPath dealloc called ...");
   if (_posted) {
      _var += _low;
      free(_var);
   }
   [super dealloc];
}
void assignPath(CPPath* cstr,int i)
{
   ORInt val = [cstr->_var[i] min];
   ORInt end = [cstr->_succ at: val];
   ORInt start = [cstr->_pred at: i];
   [cstr->_pred set: start at: end];
   [cstr->_succ set: end at: start];
   if (end <= cstr->_up)
      [cstr->_var[end] remove: start];
   else {
      if (start == cstr->_low) {
         ORInt curr = start;
         ORInt nb = 0;
         while (curr != cstr->_up+1) {
            nb += 1;
            curr = [cstr->_var[curr] min];
         }
         if (nb < cstr->_varSize)
            failNow();
      }
   }
}

-(void) post
{
   if (_posted)
      return ;
   _posted = true;
   
   _low = [_x low];
   _up = [_x up];
   _varSize = (_up - _low + 1);
   _var = malloc(_varSize * sizeof(CPIntVar*));
   for(ORInt i = 0; i < _varSize; i++)
      _var[i] = (CPIntVar*) [_x at: _low + i];
   _var -= _low;
   
   id<ORIntRange> R = RANGE([_x tracker],_low,_up+1);
   _pred = [CPFactory TRIntArray: [_x tracker] range: R];
   _succ = [CPFactory TRIntArray: [_x tracker] range: R];
   for(int i = _low; i <= _up+1; i++) {
      [_pred set: i at: i];
      [_succ set: i at: i];
   }
   for(int i = _low; i <= _up; i++) {
      [_var[i] remove: i];
      [_var[i] updateMin: _low+1];
      [_var[i] updateMax: _up+1];
   }
   for(int i = _low; i <= _up; i++) {
      if ([_var[i] bound]) {
         assignPath(self,i);
      }
      else
         [_var[i] whenBindDo: ^ { assignPath(self,i); } onBehalf:self];
   }
}
@end


@implementation CPSubCircuit {
   id<CPIntVarArray>  _x;
   CPIntVar**        _var;
   ORInt             _varSize;
   ORInt             _low;
   ORInt             _up;
   id<ORTRIntArray>  _pred;
   id<ORTRIntArray>  _succ;
   bool             _noCycle;
   bool             _posted;
}

-(void) initInstanceVariables
{
   _priority = HIGHEST_PRIO;
   _posted = false;
}
-(CPSubCircuit*) initCPSubCircuit: (id<CPIntVarArray>) x
{
   self = [super initCPCoreConstraint: [[x at:[x low]] engine]];
   _x =x;
   [self initInstanceVariables];
   return self;
}
-(void) dealloc
{
   NSLog(@"SubCircuit dealloc called ...");
   if (_posted) {
      _var += _low;
      free(_var);
   }
   [super dealloc];
}

ORStatus assignSubCircuit(CPSubCircuit* cstr,int i)
{
   ORInt val = [cstr->_var[i] min];
   if (val != i) {
      ORInt end = [cstr->_succ at: val];
      ORInt start = [cstr->_pred at: i];
      [cstr->_pred set: start at: end];
      [cstr->_succ set: end at: start];
      [cstr->_var[end] remove: start];
   }
   return ORSuspend;
}

-(void) post
{
   if (_posted)
      return ;
   _posted = true;
   
   _low = [_x low];
   _up = [_x up];
   _varSize = (_up - _low + 1);
   _var = malloc(_varSize * sizeof(CPIntVar*));
   for(ORInt i = 0; i < _varSize; i++)
      _var[i] = (CPIntVar*) [_x at: _low + i];
   _var -= _low;
   
   id<ORIntRange> R = RANGE([_x tracker],_low,_up);
   _pred = [CPFactory TRIntArray: [_x tracker] range: R];
   _succ = [CPFactory TRIntArray: [_x tracker] range: R];
   for(int i = _low; i <= _up; i++) {
      [_pred set: i at: i];
      [_succ set: i at: i];
   }
   for(int i = _low; i <= _up; i++) {
      [_var[i] updateMin: _low];
      [_var[i] updateMax: _up];
   }
   for(int i = _low; i <= _up; i++) {
      if ([_var[i] bound]) {
         assignSubCircuit(self,i);
      }
      else
         [_var[i] whenBindDo: ^ { assignSubCircuit(self,i); } onBehalf:self];
   }
}

@end

