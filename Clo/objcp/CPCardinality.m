/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORArrayI.h>
#import "CPTypes.h"
#import "CPEngineI.h"
#import "CPIntVarI.h"
#import "CPCardinality.h"

static void computeCardinalities(id<CPIntVarArray> ax,
                                 id<ORIntArray> clow,
                                 id<ORIntArray> cup,
                                 ORInt** lowArrayr,
                                 ORInt** upArrayr,
                                 ORInt* lr,
                                 ORInt* ur)
{
    ORInt l1 = [clow low];
    ORInt u1 = [clow up];
    ORInt l2 = [cup low];
    ORInt u2 = [cup up];
    ORInt l = min(l1,l2);
    ORInt u = max(u1,u2);
    ORInt lx = [ax low];
    ORInt ux = [ax up];
    ORInt sx = ux - lx + 1;
    for(ORInt i=lx; i <= ux; i++) {
        ORInt m = [[ax at: i] min];
        ORInt M = [[ax at: i] max];
        l = min(l,m);
        u = max(u,M);
    }
    ORInt s = u - l + 1;
    ORInt* lowArray = (ORInt*) malloc(sizeof(ORInt)*s); 
    ORInt* upArray = (ORInt*) malloc(sizeof(ORInt)*s); 
    lowArray -= l;
    upArray -= l;
    for(ORInt i = l; i <= u; i++) {
        lowArray[i] = 0;
        upArray[i] = sx;
    }
    for(ORInt i = l1; i <= u1; i++) 
        lowArray[i] = [clow at: i];
    for(ORInt i = l2; i <= u2; i++)
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
    for(ORInt i=_lx;i<=_ux; i++) {
        ORInt m = [_x[i] min];
        ORInt M = [_x[i] max];
        _lo = _lo < m ? _lo : m;
        _uo = _uo > M ? _uo : M;
    }
    _lo = _lo < _values.low ? _values.low : _lo;
    _uo = _uo > _values.up ? _values.up   : _uo;
    _so = _uo - _lo + 1;
    
    ORInt* lb = malloc(sizeof(ORInt)*_so);
    ORInt* ub = malloc(sizeof(ORInt)*_so);
    for(ORInt k = _so - 1;k>=0;--k) {
        lb[k] = _low[k] < 0   ? 0   : _low[k];
        ub[k] = _up[k]  > _sx ? (ORInt)_sx : _up[k];
        if (lb[k] > ub[k])
            @throw [[NSException alloc] initWithName:@"BoundViolation" 
                                              reason:@"lower bound must be <= upper bound in cardinality" 
                                            userInfo:nil];
    }
    _low = lb - _lo;
    _up  = ub - _lo;
}

-(id)initCardinalityCst:(CPEngineI*)m values:(ORRange) r low:(ORInt*)low array:(id)ax up:(ORInt*)up
{
    self = [super initCPCoreConstraint: m];
    _fdm = m;
    _values = r;
    _low = low;
    _up  = up;
    _lo = _uo = 0;
    _so = 0;
    _required = _possible = 0;
    if ([ax isKindOfClass:[NSArray class]]) {
        _sx = (ORInt)[ax count];
        _x = malloc(sizeof(CPIntVar*)*_sx);
        NSEnumerator* k = [ax objectEnumerator];
        id xi;
        ORInt i=0;
        while ((xi = [k nextObject])) 
            _x[i++] = xi;
        _lx = 0;
        _ux = (ORInt)_sx - 1;
        [k release];
    } 
    else if ([ax isKindOfClass:[ORIdArrayI class]]) {
        _sx = (ORInt)[ax count];
        _x  = malloc(sizeof(CPIntVar*)*_sx);
        int i=0;
        id<CPIntVarArray> xa = ax;
        for(ORInt k=[xa low];k<=[xa up];k++)
            _x[i++] = (CPIntVar*) [xa at:k];
        _lx = 0;
        _ux = (ORInt)_sx -1;
    }
    [self findValueRange];
    return self;
}

-(id) initCardinalityCst: (id<CPIntVarArray>) ax low: (id<ORIntArray>) low up: (id<ORIntArray>) up
{
   _fdm = (CPEngineI*) [[ax at:[ax low]] engine];
   self = [super initCPCoreConstraint: _fdm];
   _required = _possible = 0;
   
   _sx = (ORInt)[ax count];
   _x  = malloc(sizeof(CPIntVar*)*_sx);
   int i=0;
   id<CPIntVarArray> xa = ax;
   for(ORInt k=[ax low];k<=[ax up];k++)
      _x[i++] = (CPIntVar*) [xa at:k];
   _lx = 0;
   _ux = (ORInt)_sx-1;
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
-(ORUInt)nbUVars
{
   ORUInt nb=0;
   ORUInt sz = (ORUInt)(_up - _low + 1);
   for(ORUInt k=0;k<sz;k++)
      nb += ![_x[k] bound];
   return nb;
}

-(void) bindRemainingTo: (ORInt) val
{
    int count = 0;
    for(ORInt i = _lx; i <= _ux; i++) {
        if (bound(_x[i]))
            count += ([_x[i] min] == val);
        else if ([_x[i] member: val]) {
            [_x[i] bind: val];
            count++;
        }
    }
    if (count != _low[val])
       failNow();
}


static void removeFromRemaining(CPCardinalityCst* cc,ORInt val)
{
    int count = 0;
    for(ORInt i =cc->_lx; i <= cc->_ux ;i++) {
        if (bound(cc->_x[i]))
            count += ([cc->_x[i] min] == val);
        else if ([cc->_x[i] member: val]) {
            [cc->_x[i] remove: val];
        }
    }
    if (count != cc->_up[val])
       failNow();
}

static void valBind(CPCardinalityCst* cc,CPIntVar* v)
{
   ORInt val = [v min];
   assignTRInt(cc->_required+val, cc->_required[val]._val+1, cc->_trail);
   if (cc->_required[val]._val > cc->_up[val])
      failNow();
   if (cc->_required[val]._val == cc->_up[val])
      removeFromRemaining(cc,val);
}

static void valRemoveIdx(CPCardinalityCst* cc,CPIntVar* v,ORInt i,ORInt val)
{
   assignTRInt(cc->_possible+val, cc->_possible[val]._val-1, cc->_trail);
   if (cc->_possible[val]._val < cc->_low[val])
      failNow();
   if (cc->_low[val] > 0 && cc->_possible[val]._val == cc->_low[val])
      [cc bindRemainingTo: val];    
}

-(void) post
{
    _required = malloc(sizeof(TRInt)*_so);
    _possible = malloc(sizeof(TRInt)*_so);
    for(ORInt i=0; i<_so; i++) {
        _required[i] = makeTRInt(_trail, 0);
        _possible[i] = makeTRInt(_trail, 0);
    }
    _required -= _lo;
    _possible -= _lo;
    for(ORInt i=_lx;i<=_ux;i++) {
        ORInt m = [_x[i] min];
        ORInt M = [_x[i] max];
        if (m == M) {
            assignTRInt(_possible+m,_possible[m]._val+1,_trail);
            assignTRInt(_required+m,_required[m]._val+1,_trail);
        } 
        else {
            for(ORInt v=m;v<=M;++v) 
                if ([_x[i] member:v])
                    assignTRInt(_possible+v, _possible[v]._val+1, _trail);
        }
    }
    // AC5 events
    for(ORInt i=_lx;i<=_ux;i++) {
        if ([_x[i] bound]) 
            continue;
        [_x[i] whenLoseValue: self do: ^(ORInt val) { valRemoveIdx(self,_x[i],i,val);}];
        [_x[i] whenBindDo: ^ { valBind(self,_x[i]);} onBehalf:self];
    }  
    // Need to test the condition at least once
    for(ORInt i=_lo;i<=_uo;i++) {
        if (_required[i]._val > _up[i] || _possible[i]._val < _low[i])
            failNow();
        if (_required[i]._val == _up[i])
           removeFromRemaining(self,i);
        if (_low[i] > 0 && _possible[i]._val == _low[i])
           [self bindRemainingTo: i];
    }   
}
-(ORInt) nbFreeVars
{
    int t = 0;
    for(ORInt i=0;i<_sx;i++)
        t += ![_x[i] bound];
    return t;
}
@end
