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

#import "CPAllDifferentDC.h"
#import "CPBasicConstraint.h"
#import "CPSolverI.h"
#import "CPIntVarI.h"
#import "CPArrayI.h"
#import "CPError.h"

@implementation CPAllDifferentDC
static bool findMaximalMatching(CPAllDifferentDC* ad);
static bool findAlternatingPath(CPAllDifferentDC* ad,CPInt i);
static bool findAlternatingPathValue(CPAllDifferentDC* ad,CPInt v);
static void initSCC(CPAllDifferentDC* ad);
static void findSCC(CPAllDifferentDC* ad);
static void findSCCvar(CPAllDifferentDC* ad,CPInt k);
static void findSCCval(CPAllDifferentDC* ad,CPInt k);
static void prune(CPAllDifferentDC* ad);

-(void) initInstanceVariables 
{
    _idempotent = YES;
    _priority = HIGHEST_PRIO-3;
    _posted = false;
}

-(CPAllDifferentDC*) initCPAllDifferentDC: (CPIntVarArrayI*) x
{
    self = [super initCPActiveConstraint: [[x cp] solver]];
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
        @throw [[CPExecutionError alloc] initCPExecutionError: "Alldifferent: allVars called before the constraints is posted"];
    return NULL;
}

-(CPUInt) nbUVars
{
    if (_posted) {
        CPUInt nb=0;
        for(CPUInt k=0;k<_varSize;k++)
            nb += ![_var[k] bound];
        return nb;
    }
    else 
        @throw [[CPExecutionError alloc] initCPExecutionError: "Alldifferent: nbUVars called before the constraints is posted"];
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

static CPStatus removeOnBind(CPAllDifferentDC* ad,CPInt k)
{
   CPIntVarI** var = ad->_var;
   CPInt nb = ad->_varSize;
   CPInt val = minDom(var[k]);
   for(CPInt i = 0; i < nb; i++)
      if (i != k) 
         if (removeDom(var[i], val) == CPFailure)
            return CPFailure;
   return CPSuspend;
}

// post
-(CPStatus) post
{
    if (_posted)
        return CPSuspend;
    _posted = true;
    
    CPInt low = [_x low];
    CPInt up = [_x up];
    _varSize = (up - low + 1);
    _var = malloc(_varSize * sizeof(CPIntVarI*));
    for(CPInt i = 0; i < _varSize; i++) 
        _var[i] = (CPIntVarI*) [_x at: low + i];

    for(CPInt i = 0; i < _varSize; i++) 
        if ([_var[i] domsize] == 1) {
            if (removeOnBind(self,i) == CPFailure)
                return CPFailure;
        }
        else 
           [_var[i] whenBindDo: ^CPStatus() { return removeOnBind(self,i);} onBehalf:self];
        
    
    [self findValueRange];
    [self initMatching];
    [self findInitialMatching];
    if (!findMaximalMatching(self))
        return CPFailure;
    [self allocateSCC];
    prune(self);
    for(CPInt k = 0 ; k < _varSize; k++)
        if (![_var[k] bound])
            [_var[k] whenChangePropagate: self];
    return CPSuspend;
}
-(void) findValueRange
{
    _min = MAXINT;
    _max = -MAXINT;
    for(CPInt i = 0; i < _varSize; i++) {
        CPInt m = [_var[i] min];
        CPInt M = [_var[i] max];
        if (m < _min)
            _min = m;
        if (M > _max)
            _max = M;
    }
    if (_max == MAXINT)
        @throw [[CPExecutionError alloc] initCPExecutionError: "AllDifferent constraint posted on variable with no or very large domain"]; 
    _valMatch = (CPInt*) malloc((_max-_min + 1)*sizeof(CPInt));
    _valMatch -= _min;
    for(CPInt k = _min; k <= _max; k++)
        _valMatch[k] = -1;  
    _valSize = _max - _min + 1; 
}
-(void) initMatching
{
    _magic = 0;
    _match = (CPInt*) malloc(sizeof(CPInt) * _varSize);
    for(CPInt k = 0 ; k < _varSize; k++)
        _match[k] = MAXINT; 
    
    _varSeen = (CPInt*) malloc(sizeof(CPInt) * _varSize);
    for(CPInt k = 0 ; k < _varSize; k++)
        _varSeen[k] = 0;
    
    _valSeen = (CPInt*) malloc(sizeof(CPInt) * _valSize);
    _valSeen -= _min;
    for(CPInt k = _min ; k <= _max; k++)
        _valSeen[k] = 0;
}
-(void) findInitialMatching
{
    _sizeMatching = 0;
    for(CPInt k = 0; k < _varSize; k++) {
        CPInt mx = [_var[k] min];
        CPInt Mx = [_var[k] max];
        for(CPInt i = mx; i <= Mx; i++)
            if (_valMatch[i] < 0) 
                if ([_var[k] member: i]) {
                    _match[k] = i;
                    _valMatch[i] = k;
                    _sizeMatching++;
                    break;
                }
    }
}
static bool findAlternatingPath(CPAllDifferentDC* ad,CPInt i)
{
    CPInt* _varSeen = ad->_varSeen;
    CPInt* _valMatch = ad->_valMatch;
    CPInt* _match = ad->_match;
    CPIntVarI** _var = ad->_var;
    if (_varSeen[i] != ad->_magic) {
        _varSeen[i] = ad->_magic;
        CPIntVarI* x = _var[i];
       CPInt mx = minDom(x);
       CPInt Mx = maxDom(x);
        for(CPInt v = mx; v <= Mx; v++) {
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

static bool findAlternatingPathValue(CPAllDifferentDC* ad,CPInt v)
{
    if (ad->_valSeen[v] != ad->_magic) {
        ad->_valSeen[v] = ad->_magic;
        if (ad->_valMatch[v] == -1)
            return true;
        if (findAlternatingPath(ad,ad->_valMatch[v]))
            return true;
    }
    return false;
}
static bool findMaximalMatching(CPAllDifferentDC* ad)
{
    CPInt* _match = ad->_match;
    CPInt _varSize = ad->_varSize;
    if (ad->_sizeMatching < _varSize) {
        for(CPInt k = 0; k < _varSize; k++) {
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
    _varComponent = malloc(sizeof(CPInt)*_varSize*2);
    _varDfs = malloc(sizeof(CPInt)*_varSize*2);
    _varHigh = malloc(sizeof(CPInt)*_varSize*2);    

    _valComponent = malloc(sizeof(CPInt)*_valSize);
    _valDfs = malloc(sizeof(CPInt)*_valSize*2);
    _valHigh = malloc(sizeof(CPInt)*_valSize*2);
    _valComponent -= _min;
    _valDfs -= _min;
    _valHigh -= _min;
    
    _stack = malloc(sizeof(CPInt)*(_varSize + _valSize)*2);
    _type = malloc(sizeof(CPInt)*(_varSize + _valSize)*2);   
}

static void initSCC(CPAllDifferentDC* ad)
{
    for(CPInt k = 0 ; k < ad->_varSize; k++) {
        ad->_varComponent[k] = 0;
        ad->_varDfs[k] = 0;
        ad->_varHigh[k] = 0;
    }
    for(CPInt k = ad->_min; k <= ad->_max; k++) {
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
    for(CPInt k = 0; k < ad->_varSize; k++) 
        if (!ad->_varDfs[k])
            findSCCvar(ad,k);
}

static void findSCCvar(CPAllDifferentDC* ad,CPInt k)
{
   CPInt*_varDfs = ad->_varDfs;
   CPInt*_varHigh = ad->_varHigh;
   CPInt*_stack = ad->_stack;
   CPInt*_type = ad->_type;
   CPInt*_match = ad->_match;
   CPInt*_valDfs = ad->_valDfs;
   CPInt*_valHigh = ad->_valHigh;
   CPInt*_valComponent = ad->_valComponent;
   CPInt*_varComponent = ad->_varComponent;
   
   _varDfs[k] = ad->_dfs--;
   _varHigh[k] = _varDfs[k];
   _stack[ad->_top] = k;
   _type[ad->_top] = 0;
   ad->_top++;
   
   CPIntVarI* x = ad->_var[k];
   CPBounds bx;
   [x bounds:&bx];
   for(CPInt w = bx.min; w <= bx.max; w++) {
      if (_match[k] != w) {
         if (memberBitDom(x, w)) {
            CPInt valDfs = _valDfs[w];
            if (!valDfs) {
               findSCCval(ad,w);
               if (_valHigh[w] > _varHigh[k])
                  _varHigh[k] = _valHigh[w];
            }
            else if (valDfs > _varDfs[k] && !_valComponent[w]) {
               if (valDfs > _varHigh[k])
                  _varHigh[k] = _valDfs[w];
            }
         }
      }
   }
   
   if (_varHigh[k] == _varDfs[k]) {
      ad->_component++;
      do {
         CPInt v = _stack[--ad->_top];
         CPInt t = _type[ad->_top];
         if (t == 0)
            _varComponent[v] = ad->_component;
         else
            _valComponent[v] = ad->_component;
         if (t == 0 && v == k)
            break;
      } while (true);
   }    
}

static void findSCCval(CPAllDifferentDC* ad,CPInt k)
{
    int i;
    
    CPInt*_varDfs = ad->_varDfs;
    CPInt*_varHigh = ad->_varHigh;
    CPInt*_stack = ad->_stack;
    CPInt*_type = ad->_type;
    CPInt*_match = ad->_match;
    CPInt*_valDfs = ad->_valDfs;
    CPInt*_valHigh = ad->_valHigh;
    CPInt*_valComponent = ad->_valComponent;
    CPInt*_varComponent = ad->_varComponent;
    CPInt*_valMatch = ad->_valMatch;
    
    _valDfs[k] = ad->_dfs--;
    _valHigh[k] = _valDfs[k];
    _stack[ad->_top] = k;
    _type[ad->_top] = 1;
    ad->_top++;
    
    if (_valMatch[k] != -1) {
        CPInt w = _valMatch[k];
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
            CPInt w = _match[i];
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
            CPInt v = _stack[--ad->_top];
            CPInt t = _type[ad->_top];
            if (t == 0)
                _varComponent[v] = ad->_component;
            else
                _valComponent[v] = ad->_component;
            if (t == 1 && v == k)
                break;
        } while (true);
    }    
}

static void prune(CPAllDifferentDC* ad)
{
    CPInt* _match = ad->_match;
    CPInt* _valComponent = ad->_valComponent;
    CPInt* _varComponent = ad->_varComponent;
    findSCC(ad);
    for(CPInt k = 0; k < ad->_varSize; k++) {
        CPIntVarI* x = ad->_var[k];
        CPBounds bx;
        [x bounds:&bx];
        for(CPInt w = bx.min; w <= bx.max; w++) {
            if (_match[k] != w && _varComponent[k] != _valComponent[w]) {
               if (memberDom(x,w)) {
                    if ([x remove: w] == CPFailure) {
                        @throw [[CPInternalError alloc] initCPInternalError: "AllDifferent: Unexpected failure"];
                    }
                }
            }
        }
    }   
}

-(CPStatus) propagate
{   
    for(CPInt k = 0; k < _varSize; k++) {
        if (_match[k] != MAXINT) {
           if (!memberDom(_var[k], _match[k])) {
                _valMatch[_match[k]] = -1;
                _match[k] = MAXINT;
                _sizeMatching--;
            }
        }
    }
    if (!findMaximalMatching(self)) 
        return CPFailure;
    prune(self);
    return CPSuspend;   
}

@end
