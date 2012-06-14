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


#import "CPValueConstraint.h"
#import "CPSolverI.h"
#import "CPIntVarI.h"
#import "CPArrayI.h"

@implementation CPReifyNotEqualDC
-(id)initCPReifyNotEqualDC:(CPIntVarI*)b when:(CPIntVarI*)x neq:(CPInt)c
{
    self = [super initCPCoreConstraint];
    _b = b;
    _x = x;
    _c = c;
    return self;
}
-(CPStatus) post
{
    if ([_b bound]) {
        if ([_b min] == true) 
            return [_x remove:_c];
        else 
            return [_x bind:_c];
    } 
    else if ([_x bound]) 
        return [_b bind:[_x min] != _c];
    else if (![_x member:_c])
        return [_b remove:false];
    else {
        [_b whenBindDo: ^CPStatus(void) 
         {
             if ([_b min]==true)
                 return [_x remove:_c];
             else 
                 return [_x bind:_c];
         } onBehalf:self   
         ];
        [_x setLoseTrigger: _c do: ^CPStatus(void) { return [_b bind:true]; } onBehalf:self];
        [_x whenBindDo: ^CPStatus(void) 
         {
             return [_b bind:[_x min] != _c];
         } onBehalf:self
         ];
      return CPSuspend;
   } 
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,_b, nil];   
}
-(CPUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_b];
    [aCoder encodeObject:_x];
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_c];
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    _b = [aDecoder decodeObject];
    _x = [aDecoder decodeObject];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_c];
    return self;
}
@end

@implementation CPReifyEqualDC

-(id) initCPReifyEqualDC: (CPIntVarI*) b when: (CPIntVarI*) x eq: (CPInt) c
{
   self = [super initCPCoreConstraint];
    _b = b;
    _x = x;
    _c = c;
    return self;
}

-(CPStatus) post
{
    if ([_b bound]) {
        if ([_b min] == true) 
            return [_x bind:_c];
        else 
            return [_x remove:_c];
    } 
    else if ([_x bound]) 
        return [_b bind:[_x min] == _c];   
    else if (![_x member:_c])
        return [_b bind:false];
    else {
        [_b setBindTrigger: ^CPStatus(void) {
            if ([_b min] == true)
                return [_x bind:_c];
            else 
                return [_x remove:_c];
        } onBehalf:self];
        [_x setLoseTrigger: _c do: ^CPStatus(void) { return [_b bind:false]; } onBehalf:self];
        [_x setBindTrigger: ^CPStatus(void) { return [_b bind:[_x min] == _c]; } onBehalf:self];
        return CPSuspend;
    }   
} 
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,_b, nil];   
}
-(CPUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_b];
    [aCoder encodeObject:_x];
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_c];
}

- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    _b = [aDecoder decodeObject];
    _x = [aDecoder decodeObject];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_c];
    return self;
}
@end

@implementation CPSumBoolGeq

-(id) initCPSumBoolGeq: (id) x geq: (CPInt) c
{
    if ([x isKindOfClass:[NSArray class]]) {
        self = [super initCPCoreConstraint];
        _nb = [x count];
        _x = malloc(sizeof(CPIntVarI*)*_nb);
        for(CPInt k=0;k<_nb;k++)
            _x[k] = [x objectAtIndex:k];
    } 
    else if ([x isKindOfClass:[CPIntVarArrayI class]]) {
        CPIntVarArrayI* xa = x;
        self = [super initCPCoreConstraint];
        _nb = [x count];
        _x  = malloc(sizeof(CPIntVarI*)*_nb);
        CPInt low = [x low];
        CPInt up = [x up];
        CPInt i = 0;
        for(CPInt k=low;k <= up;k++)
            _x[i++] = (CPIntVarI*) [xa at:k];
    }      
    _c = c;
    _at = 0;
    _notTriggered = 0;
    return self;
}

-(void) dealloc
{
    free(_x);
    if (_at) free(_at);
    if (_notTriggered) free(_notTriggered);
    [super dealloc];
}

-(CPStatus) post
{
    _at = malloc(sizeof(CPTrigger*)*(_c+1));
    _notTriggered = malloc(sizeof(CPInt)*(_nb - _c - 1));
    int nbTrue = 0;
    int nbPos  = 0;
    for(CPInt i=0;i<_nb;i++) {
        if ([_x[i] updateMin:0] == CPFailure)
            return CPFailure;
        if ([_x[i] updateMax:1] == CPFailure)
            return CPFailure;
        nbTrue += ([_x[i] bound] && [_x[i] min] == true);
        nbPos  += ![_x[i] bound];
    }
    if (nbTrue >= _c) 
        return CPSuccess;
    if (nbTrue + nbPos < _c) 
        return CPFailure;
    if (nbTrue + nbPos == _c) {
        // We already know that all the possible should be true. Do it.
        for(CPInt i=0;i<_nb;++i) {
            if ([_x[i] bound]) 
                continue;
            if ([_x[i] updateMin:true] == CPFailure)
                return CPFailure;
        }
        return CPSuccess;      
    }
    CPInt listen = _c+1;
    CPInt nbNW   = 0;
    for(CPInt i=_nb-1;i >= 0;--i) {
        if (listen > 0 && [_x[i] max] == true) { // Still in the domain and in need of more watches
            --listen; // the closure must capture the correct value of listen!
            _at[listen] = [_x[i] setLoseTrigger: true do: ^CPStatus() 
                           {
                               // Look for another support among the non-tracked variables.
                               CPInt j = _last;
                               bool jOk = false;
                               do {
                                   j=(j+1) % (_nb - _c - 1);
                                   jOk = [_x[_notTriggered[j]] member:true];
                               } while (j != _last && !jOk);
                               if (jOk) {
                                   CPInt nextVar = _notTriggered[j];
                                   // This is manipulating the list directly: very dangerous
                                   // We should abstract the triggers
                                   CPTrigger* toMove = _at[listen];
                                   // remove the trigger
                                   toMove->_next->_prev = toMove->_prev;
                                   toMove->_prev->_next = toMove->_next;
                                   // put it in the next variable to track
                                   [_x[nextVar] watch:true with:toMove];
                                   // would be better to do before setting the trigger
                                   _notTriggered[j] = toMove->_vId;
                                   toMove->_vId = nextVar;
                                   _last = j;
                               } 
                               else {  // Ok, we couldn't find any other support => so we must bind the remaining ones
                                   for(CPInt k=0;k<_c+1;k++) {
                                       if (k != listen) {
                                           CPStatus ok = [_x[_at[k]->_vId] updateMin:true];
                                           if (!ok) 
                                               return CPFailure;
                                       }
                                   }
                               }
                               return CPSuspend;
                           }
                           onBehalf:self];                           
            _at[listen]->_vId = i; // local identifier of var being watched.
        } 
        else 
            _notTriggered[nbNW++] = i;
    }   
    assert(nbNW == _nb - _c - 1);
    _last = _nb - _c - 2;  // where we will start the circular scan among the unWatched variables.
    return CPSuspend;
}

-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x count:_nb];
}
-(CPUInt)nbUVars
{
   CPUInt nb=0;
   for(CPUInt k=0;k<_nb;k++) 
      nb += ![_x[k] bound];
   return nb;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];   
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_nb];
    for(CPInt k=0;k<_nb;k++) 
        [aCoder encodeObject:_x[k]];
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_nb];
    _x = malloc(sizeof(CPIntVarI*)*_nb);   
    for(CPInt k=0;k<_nb;k++) 
        _x[k] = [aDecoder decodeObject];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_c];
    return self;
}
@end


