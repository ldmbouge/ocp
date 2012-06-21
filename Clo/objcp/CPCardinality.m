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

#import "CPTypes.h"
#import "CPSolverI.h"
#import "CPIntVarI.h"
#import "CPArrayI.h"
#import "CPCardinality.h"

static void computeCardinalities(CPIntVarArrayI* ax,
                                 CPIntArrayI* clow,
                                 CPIntArrayI* cup,
                                 CPInt** lowArrayr,
                                 CPInt** upArrayr,
                                 CPInt* lr,
                                 CPInt* ur)
{
    CPInt l1 = [clow low];
    CPInt u1 = [clow up];
    CPInt l2 = [cup low];
    CPInt u2 = [cup up];
    CPInt l = min(l1,l2);
    CPInt u = max(u1,u2);
    CPInt lx = [ax low];
    CPInt ux = [ax up];
    CPInt sx = ux - lx + 1;
    for(CPInt i=lx; i <= ux; i++) {
        CPInt m = [[ax at: i] min];
        CPInt M = [[ax at: i] max];
        l = min(l,m);
        u = max(u,M);
    }
    CPInt s = u - l + 1;
    CPInt* lowArray = (CPInt*) malloc(sizeof(CPInt)*s); 
    CPInt* upArray = (CPInt*) malloc(sizeof(CPInt)*s); 
    lowArray -= l;
    upArray -= l;
    for(CPInt i = l; i <= u; i++) {
        lowArray[i] = 0;
        upArray[i] = sx;
    }
    for(CPInt i = l1; i <= u1; i++) 
        lowArray[i] = [clow at: i];
    for(CPInt i = l2; i <= u2; i++)
        upArray[i] = [cup at: i];
    *lr = l;
    *ur = u;
    *lowArrayr = lowArray;
    *upArrayr = upArray;
}

@implementation CPCardinalityCst

-(void) findValueRange
{
    _lo = MAXINT;
    _uo = -MAXINT;
    for(CPInt i=_lx;i<=_ux; i++) {
        CPInt m = [_x[i] min];
        CPInt M = [_x[i] max];
        _lo = _lo < m ? _lo : m;
        _uo = _uo > M ? _uo : M;
    }
    _lo = _lo < _values.low ? _values.low : _lo;
    _uo = _uo > _values.up ? _values.up   : _uo;
    _so = _uo - _lo + 1;
    
    CPInt* lb = malloc(sizeof(CPInt)*_so);
    CPInt* ub = malloc(sizeof(CPInt)*_so);
    for(CPInt k = _so - 1;k>=0;--k) {
        lb[k] = _low[k] < 0   ? 0   : _low[k];
        ub[k] = _up[k]  > _sx ? (CPInt)_sx : _up[k];
        if (lb[k] > ub[k])
            @throw [[NSException alloc] initWithName:@"BoundViolation" 
                                              reason:@"lower bound must be <= upper bound in cardinality" 
                                            userInfo:nil];
    }
    _low = lb - _lo;
    _up  = ub - _lo;
}

-(id)initCardinalityCst:(CPSolverI*)m values:(CPRange) r low:(CPInt*)low array:(id)ax up:(CPInt*)up
{
    self = [super initCPActiveConstraint: m];
    _fdm = m;
    _values = r;
    _low = low;
    _up  = up;
    _lo = _uo = 0;
    _so = 0;
    _required = _possible = 0;
    if ([ax isKindOfClass:[NSArray class]]) {
        _sx = [ax count];
        _x = malloc(sizeof(CPIntVarI*)*_sx);
        NSEnumerator* k = [ax objectEnumerator];
        id xi;
        CPInt i=0;
        while ((xi = [k nextObject])) 
            _x[i++] = xi;
        _lx = 0;
        _ux = (CPInt)_sx - 1;
        [k release];
    } 
    else if ([ax isKindOfClass:[CPIntVarArrayI class]]) {
        _sx = [ax count];
        _x  = malloc(sizeof(CPIntVarI*)*_sx);
        int i=0;
        CPIntVarArrayI* xa = ax;
        for(CPInt k=[ax low];k<=[ax up];k++)
            _x[i++] = (CPIntVarI*) [xa at:k];
        _lx = 0;
        _ux = (CPInt)_sx -1;
    }
    [self findValueRange];
    return self;
}

-(id) initCardinalityCst: (CPIntVarArrayI*) ax low: (CPIntArrayI*) low up: (CPIntArrayI*) up
{
    self = [super initCPActiveConstraint: [ax solver]];
    _required = _possible = 0;   
    _fdm = (CPSolverI*)[ax solver];

    _sx = [ax count];
    _x  = malloc(sizeof(CPIntVarI*)*_sx);
    int i=0;
    CPIntVarArrayI* xa = ax;
    for(CPInt k=[ax low];k<=[ax up];k++)
        _x[i++] = (CPIntVarI*) [xa at:k];
    _lx = 0;
    _ux = (CPInt)_sx-1;
    computeCardinalities(ax,low,up,&_low,&_up,&_lo,&_uo);
    _so = _uo - _lo + 1;
    return self;
}

-(void) dealloc
{
    _low += _lo;
    _up  += _lo;
    free(_low);
    free(_up);
    free(_x);
    if (_required) {
        _required += _lo;
        free(_required);
    }
    if (_possible) {
        _possible += _lo;
        free(_possible);
    }
    [super dealloc];
}

-(NSSet*)allVars
{
   NSSet* theSet = [[NSSet alloc] initWithObjects:_x count:_up - _low + 1];
   return theSet;
}
-(CPUInt)nbUVars
{
   CPUInt nb=0;
   CPUInt sz = _up - _low + 1;
   for(CPUInt k=0;k<sz;k++)
      nb += ![_x[k] bound];
   return nb;
}

-(CPStatus) bindRemainingTo: (CPInt) val
{
    int count = 0;
    for(CPInt i = _lx; i <= _ux; i++) {
        if (bound(_x[i]))
            count += ([_x[i] min] == val);
        else if ([_x[i] member: val]) {
            [_x[i] bind: val];
            count++;
        }
    }
    if (count != _low[val])
       failNow(_fdm);
    return CPSuspend;
}


static CPStatus removeFromRemaining(CPCardinalityCst* cc,CPInt val)
{
    int count = 0;
    for(CPInt i =cc->_lx; i <= cc->_ux ;i++) {
        if (bound(cc->_x[i]))
            count += ([cc->_x[i] min] == val);
        else if ([cc->_x[i] member: val]) {
            [cc->_x[i] remove: val];
        }
    }
    if (count != cc->_up[val])
       failNow(cc->_fdm);
    return CPSuspend;     
}

static CPStatus valBind(CPCardinalityCst* cc,CPIntVarI* v)
{
   CPInt val = [v min];
   assignTRInt(cc->_required+val, cc->_required[val]._val+1, cc->_trail);
   if (cc->_required[val]._val > cc->_up[val])
      failNow(cc->_fdm);
   if (cc->_required[val]._val == cc->_up[val])
      removeFromRemaining(cc,val);
   return CPSuspend;
}

static CPStatus valRemoveIdx(CPCardinalityCst* cc,CPIntVarI* v,CPInt i,CPInt val)
{
   assignTRInt(cc->_possible+val, cc->_possible[val]._val-1, cc->_trail);
   if (cc->_possible[val]._val < cc->_low[val])
      failNow(cc->_fdm);
   if (cc->_low[val] > 0 && cc->_possible[val]._val == cc->_low[val])
      [cc bindRemainingTo: val];    
   return CPSuspend;
}

-(CPStatus) post
{
    _required = malloc(sizeof(TRInt)*_so);
    _possible = malloc(sizeof(TRInt)*_so);
    for(CPInt i=0; i<_so; i++) {
        _required[i] = makeTRInt(_trail, 0);
        _possible[i] = makeTRInt(_trail, 0);
    }
    _required -= _lo;
    _possible -= _lo;
    for(CPInt i=_lx;i<=_ux;i++) {
        CPInt m = [_x[i] min];
        CPInt M = [_x[i] max];
        if (m == M) {
            assignTRInt(_possible+m,_possible[m]._val+1,_trail);
            assignTRInt(_required+m,_required[m]._val+1,_trail);
        } 
        else {
            for(CPInt v=m;v<=M;++v) 
                if ([_x[i] member:v])
                    assignTRInt(_possible+v, _possible[v]._val+1, _trail);
        }
    }
    // AC5 events
    for(CPInt i=_lx;i<=_ux;i++) {
        if ([_x[i] bound]) 
            continue;
        [_x[i] whenLoseValue: self do: ^CPStatus(CPInt val) { return valRemoveIdx(self,_x[i],i,val);}];
        [_x[i] whenBindDo: ^CPStatus() { return valBind(self,_x[i]);} onBehalf:self];
    }  
    // Need to test the condition at least once
    for(CPInt i=_lo;i<=_uo;i++) {
        if (_required[i]._val > _up[i] || _possible[i]._val < _low[i])
            failNow(_fdm);
        if (_required[i]._val == _up[i])
           removeFromRemaining(self,i);
        if (_low[i] > 0 && _possible[i]._val == _low[i])
           [self bindRemainingTo: i];
    }   
    return CPSuspend;
}
-(CPInt) nbFreeVars
{
    int t = 0;
    for(CPInt i=0;i<_sx;i++)
        t += ![_x[i] bound];
    return t;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_fdm];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_values.low];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_values.up];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_lo];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_uo];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_lx];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_ux];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_so];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_sx];
   [aCoder encodeArrayOfObjCType:@encode(CPInt)
                           count:_so
                              at:_low + _lo];
   [aCoder encodeArrayOfObjCType:@encode(CPInt)
                           count:_so
                              at:_up + _lo];
   for(int k=_lx;k<=_ux;k++)
      [aCoder encodeObject:_x[k]];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _fdm = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_values.low];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_values.up];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_lo];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_uo];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_lx];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_ux];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_so];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_sx];
   _x = malloc(sizeof(CPIntVarI*)*_sx) - _lx;
   _low = malloc(sizeof(CPInt)*_so) - _lo;
   _up  = malloc(sizeof(CPInt)*_so) - _lo;
   [aDecoder decodeArrayOfObjCType:@encode(CPInt)
                             count:_so 
                                at:_low + _lo];
   [aDecoder decodeArrayOfObjCType:@encode(CPInt)
                             count:_so 
                                at:_up + _lo];
   for(int k=_lx;k<=_ux;k++)
      _x[k] = [aDecoder decodeObject];
   return self;
}
@end
