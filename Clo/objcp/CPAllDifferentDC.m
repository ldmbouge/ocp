/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPAllDifferentDC.h"
#import "CPBasicConstraint.h"
#import "CPEngineI.h"
#import "CPIntVarI.h"
#import "CPError.h"

@implementation CPAllDifferentDC
{
   id<ORIntVarArray> _x;
   CPIntVarI**     _var;
   UBType*         _member;
   ORInt           _varSize;
   ORInt*          _match;
   ORInt*          _varSeen;
   
   ORInt           _min;
   ORInt           _max;
   ORInt           _valSize;
   ORInt*          _valMatch;
   ORInt           _sizeMatching;
   ORInt*          _valSeen;
   ORInt           _magic;
   
   ORInt          _dfs;
   ORInt          _component;
   
   ORInt*         _varComponent;
   ORInt*         _varDfs;
   ORInt*         _varHigh;
   
   ORInt*         _valComponent;
   ORInt*         _valDfs;
   ORInt*         _valHigh;
   
   ORInt*         _stack;
   ORInt*         _type;
   ORInt          _top;
   
   bool           _posted;
}
static bool findMaximalMatching(CPAllDifferentDC* ad);
static bool findAlternatingPath(CPAllDifferentDC* ad,ORInt i);
static bool findAlternatingPathValue(CPAllDifferentDC* ad,ORInt v);
static void initSCC(CPAllDifferentDC* ad);
static void findSCC(CPAllDifferentDC* ad);
static void findSCCvar(CPAllDifferentDC* ad,ORInt k);
static void findSCCval(CPAllDifferentDC* ad,ORInt k);
static void prune(CPAllDifferentDC* ad);

-(void) initInstanceVariables 
{
    _idempotent = YES;
    _priority = HIGHEST_PRIO-2;
    _posted = false;
}

-(CPAllDifferentDC*) initCPAllDifferentDC: (id<CPSolver>) cp over: (id<ORIntVarArray>) x
{
   self = [super initCPActiveConstraint: [cp engine]];
   _x = x;
   [self initInstanceVariables];
   return self;
}

-(void) dealloc
{
//   NSLog(@"AllDifferent dealloc called ...");
    if (_posted) {
        free(_var);
        _valMatch += _min;
        free(_match);
        free(_valMatch);
        free(_varSeen);
        _valSeen += _min;
        free(_valSeen);
        _valComponent += _min;
        _valDfs += _min;
        _valHigh += _min;
        free(_valComponent);
        free(_valDfs);
        free(_valHigh);
        free(_varComponent);
        free(_varDfs);
        free(_varHigh);
        free(_stack);
        free(_type);
        [super dealloc];
    }
}

-(NSSet*) allVars
{
    if (_posted)
        return [[NSSet alloc] initWithObjects:_var count:_varSize];
    else
        @throw [[ORExecutionError alloc] initORExecutionError: "Alldifferent: allVars called before the constraints is posted"];
    return NULL;
}

-(ORUInt) nbUVars
{
    if (_posted) {
        ORUInt nb=0;
        for(ORUInt k=0;k<_varSize;k++)
            nb += ![_var[k] bound];
        return nb;
    }
    else 
        @throw [[ORExecutionError alloc] initORExecutionError: "Alldifferent: nbUVars called before the constraints is posted"];
    return 0;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_x];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    _x = [aDecoder decodeObject];
    [self initInstanceVariables];
   return self;
}

static ORStatus removeOnBind(CPAllDifferentDC* ad,ORInt k)
{
   CPIntVarI** var = ad->_var;
   ORInt nb = ad->_varSize;
   ORInt val = minDom(var[k]);
   for(ORInt i = 0; i < nb; i++)
      if (i != k) 
         removeDom(var[i], val);
   return ORSuspend;
}

// post
-(ORStatus) post
{
    if (_posted)
        return ORSuspend;
    _posted = true;
    
    ORInt low = [_x low];
    ORInt up = [_x up];
    _varSize = (up - low + 1);
    _var = malloc(_varSize * sizeof(CPIntVarI*));
    for(ORInt i = 0; i < _varSize; i++) 
        _var[i] = (CPIntVarI*) [[_x at: low + i] dereference];

    for(ORInt i = 0; i < _varSize; i++) 
        if ([_var[i] domsize] == 1) {
           removeOnBind(self,i);
        }
        else 
           [_var[i] whenBindDo: ^{ removeOnBind(self,i);} onBehalf:self];
    
    [self findValueRange];
    [self initMatching];
    [self findInitialMatching];
    if (!findMaximalMatching(self))
       failNow();
    [self allocateSCC];
    prune(self);
    for(ORInt k = 0 ; k < _varSize; k++)
        if (![_var[k] bound])
            [_var[k] whenChangePropagate: self];
    return ORSuspend;
}
-(void) findValueRange
{
    _min = MAXINT;
    _max = -MAXINT;
    for(ORInt i = 0; i < _varSize; i++) {
        ORInt m = [_var[i] min];
        ORInt M = [_var[i] max];
        if (m < _min)
            _min = m;
        if (M > _max)
            _max = M;
    }
    if (_max == MAXINT)
        @throw [[ORExecutionError alloc] initORExecutionError: "AllDifferent constraint posted on variable with no or very large domain"]; 
    _valMatch = (ORInt*) malloc((_max-_min + 1)*sizeof(ORInt));
    _valMatch -= _min;
    for(ORInt k = _min; k <= _max; k++)
        _valMatch[k] = MAXINT;
    _valSize = _max - _min + 1; 
}
-(void) initMatching
{
    _magic = 0;
    _match = (ORInt*) malloc(sizeof(ORInt) * _varSize);
    for(ORInt k = 0 ; k < _varSize; k++)
        _match[k] = MAXINT; 
    
    _varSeen = (ORInt*) malloc(sizeof(ORInt) * _varSize);
    for(ORInt k = 0 ; k < _varSize; k++)
        _varSeen[k] = 0;
    
    _valSeen = (ORInt*) malloc(sizeof(ORInt) * _valSize);
    _valSeen -= _min;
    for(ORInt k = _min ; k <= _max; k++)
        _valSeen[k] = 0;
}
-(void) findInitialMatching
{
    _sizeMatching = 0;
    for(ORInt k = 0; k < _varSize; k++) {
        ORInt mx = [_var[k] min];
        ORInt Mx = [_var[k] max];
        for(ORInt i = mx; i <= Mx; i++)
            if (_valMatch[i] == MAXINT)
                if ([_var[k] member: i]) {
                    _match[k] = i;
                    _valMatch[i] = k;
                    _sizeMatching++;
                    break;
                }
    }
}
static bool findAlternatingPath(CPAllDifferentDC* ad,ORInt i)
{
    ORInt* _varSeen = ad->_varSeen;
    ORInt* _valMatch = ad->_valMatch;
    ORInt* _match = ad->_match;
    CPIntVarI** _var = ad->_var;
    if (_varSeen[i] != ad->_magic) {
        _varSeen[i] = ad->_magic;
        CPIntVarI* x = _var[i];
       ORInt mx = minDom(x);
       ORInt Mx = maxDom(x);
        for(ORInt v = mx; v <= Mx; v++) {
            if (_match[i] != v) {
               if (memberBitDom(x, v)) {
                    if (findAlternatingPathValue(ad,v)) {
                        _match[i] = v;
                        _valMatch[v] = i;
                        return true;
                    }
                }
            }
        }
    }
    return false;
}

static bool findAlternatingPathValue(CPAllDifferentDC* ad,ORInt v)
{
    if (ad->_valSeen[v] != ad->_magic) {
        ad->_valSeen[v] = ad->_magic;
        if (ad->_valMatch[v] == MAXINT)
            return true;
        if (findAlternatingPath(ad,ad->_valMatch[v]))
            return true;
    }
    return false;
}
static bool findMaximalMatching(CPAllDifferentDC* ad)
{
    ORInt* _match = ad->_match;
    ORInt _varSize = ad->_varSize;
    if (ad->_sizeMatching < _varSize) {
        for(ORInt k = 0; k < _varSize; k++) {
            if (_match[k] == MAXINT) {
                ad->_magic++;
                if (!findAlternatingPath(ad,k))
                    return false;
                ad->_sizeMatching++;
            }
        }
    }
    return true;
}
-(void) allocateSCC
{
    _varComponent = malloc(sizeof(ORInt)*_varSize*2);
    _varDfs = malloc(sizeof(ORInt)*_varSize*2);
    _varHigh = malloc(sizeof(ORInt)*_varSize*2);    

    _valComponent = malloc(sizeof(ORInt)*_valSize);
    _valDfs = malloc(sizeof(ORInt)*_valSize*2);
    _valHigh = malloc(sizeof(ORInt)*_valSize*2);
    _valComponent -= _min;
    _valDfs -= _min;
    _valHigh -= _min;
    
    _stack = malloc(sizeof(ORInt)*(_varSize + _valSize)*2);
    _type = malloc(sizeof(ORInt)*(_varSize + _valSize)*2);   
}

static void initSCC(CPAllDifferentDC* ad)
{
    for(ORInt k = 0 ; k < ad->_varSize; k++) {
        ad->_varComponent[k] = 0;
        ad->_varDfs[k] = 0;
        ad->_varHigh[k] = 0;
    }
    for(ORInt k = ad->_min; k <= ad->_max; k++) {
        ad->_valComponent[k] = 0;
        ad->_valDfs[k] = 0;
        ad->_valHigh[k] = 0;
    }
    ad->_top = 0;
    ad->_dfs = ad->_varSize + ad->_valSize;
    ad->_component = 0; 
}

static void findSCC(CPAllDifferentDC* ad)
{
    initSCC(ad);
    for(ORInt k = 0; k < ad->_varSize; k++) 
        if (!ad->_varDfs[k])
            findSCCvar(ad,k);
}

static void findSCCvar(CPAllDifferentDC* ad,ORInt k)
{
   ORInt*_varDfs = ad->_varDfs;
   ORInt*_varHigh = ad->_varHigh;
   ORInt*_stack = ad->_stack;
   ORInt*_type = ad->_type;
   ORInt*_valHigh = ad->_valHigh;
   
   _varDfs[k] = ad->_dfs--;
   _varHigh[k] = _varDfs[k];
   _stack[ad->_top] = k;
   _type[ad->_top] = 0;
   ad->_top++;
   
   CPIntVarI* x = ad->_var[k];
   ORInt m = minDom(x);
   ORInt M = maxDom(x);
   for(ORInt w = m; w <= M; w++) {
      if (ad->_match[k] != w) {
         if (memberBitDom(x, w)) {
            ORInt valDfs = ad->_valDfs[w];
            if (!valDfs) {
               findSCCval(ad,w);
               if (ad->_valHigh[w] > ad->_varHigh[k])
                  _varHigh[k] = _valHigh[w];
            }
            else if (valDfs > ad->_varDfs[k] && !ad->_valComponent[w]) {
               if (valDfs > _varHigh[k])
                  _varHigh[k] = valDfs;
            }
         }
      }
   }
   
   if (ad->_varHigh[k] == ad->_varDfs[k]) {
      ad->_component++;
      do {
         ORInt v = _stack[--ad->_top];
         ORInt t = _type[ad->_top];
         if (t == 0)
            ad->_varComponent[v] = ad->_component;
         else
            ad->_valComponent[v] = ad->_component;
         if (t == 0 && v == k)
            break;
      } while (true);
   }    
}

static void findSCCval(CPAllDifferentDC* ad,ORInt k)
{
    int i;
    
    ORInt*_varDfs = ad->_varDfs;
    ORInt*_varHigh = ad->_varHigh;
    ORInt*_stack = ad->_stack;
    ORInt*_type = ad->_type;
    ORInt*_match = ad->_match;
    ORInt*_valDfs = ad->_valDfs;
    ORInt*_valHigh = ad->_valHigh;
    ORInt*_valComponent = ad->_valComponent;
    ORInt*_varComponent = ad->_varComponent;
    ORInt*_valMatch = ad->_valMatch;
    
    _valDfs[k] = ad->_dfs--;
    _valHigh[k] = _valDfs[k];
    _stack[ad->_top] = k;
    _type[ad->_top] = 1;
    ad->_top++;
    
    if (_valMatch[k] != MAXINT) {
        ORInt w = _valMatch[k];
        if (!_varDfs[w]) {
            findSCCvar(ad,w);
            if (_varHigh[w] > _valHigh[k])
                _valHigh[k] = _varHigh[w];
        }
        else if ( (_varDfs[w] > _valDfs[k]) && (!_varComponent[w])) {
            if (_varDfs[w] > _valHigh[k])
                _valHigh[k] = _varDfs[w];
        }
    }
    else {
        for(i = 0; i < ad->_varSize; i++) {
            ORInt w = _match[i];
            if (_valDfs[w]==0) {
                findSCCval(ad,w);
                
                if (_valHigh[w] > _valHigh[k])
                    _valHigh[k] = _valHigh[w];
            }
            else if ( (_valDfs[w] > _valDfs[k]) && (!_valComponent[w])) {
                if (_valDfs[w] > _valHigh[k])
                    _valHigh[k] = _valDfs[w];
            }
        }
    }
    
    if (_valHigh[k] == _valDfs[k]) {
        ad->_component++;
        do {
            ORInt v = _stack[--ad->_top];
            ORInt t = _type[ad->_top];
            if (t == 0)
                _varComponent[v] = ad->_component;
            else
                _valComponent[v] = ad->_component;
            if (t == 1 && v == k)
                break;
        } while (true);
    }    
}
// prune
static void prune(CPAllDifferentDC* ad)
{
   ORInt* _match = ad->_match;
   ORInt* _valComponent = ad->_valComponent;
   ORInt* _varComponent = ad->_varComponent;
   findSCC(ad);
   for(ORInt k = 0; k < ad->_varSize; k++) {
      CPIntVarI* x = ad->_var[k];
      ORBounds bx = [x bounds];
      for(ORInt w = bx.min; w <= bx.max; w++) {
         if (_match[k] != w && _varComponent[k] != _valComponent[w]) {
            if (memberDom(x,w)) {
               [x remove: w];
            }
         }
      }
   }   
}
// propagate

-(void) propagate
{   
   for(ORInt k = 0; k < _varSize; k++) {
      if (_match[k] != MAXINT) {
         if (!memberDom(_var[k], _match[k])) {
            _valMatch[_match[k]] = MAXINT;
            _match[k] = MAXINT;
            _sizeMatching--;
         }
      }
   }
   if (!findMaximalMatching(self)) 
      failNow();
   prune(self);
}

@end
