/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "CPValueConstraint.h"
#import "ORFoundation/ORArrayI.h"
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
      [_b whenBindDo: ^void {
         if ([_b min]==true)
            [_x remove:_c];
         else 
            [_x bind:_c];
      } onBehalf:self];
      [_x setLoseTrigger: _c do: ^(void) { [_b bind:true]; } onBehalf:self];
      [_x whenBindDo: ^(void) { [_b bind:[_x min] != _c];} onBehalf:self];
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
        [_b setBindTrigger: ^ {
            if ([_b min] == true)
                [_x bind:_c];
            else 
                [_x remove:_c];
        } onBehalf:self];
        [_x setLoseTrigger: _c do: ^ { [_b bind:false]; } onBehalf:self];
        [_x setBindTrigger: ^ { [_b bind:[_x min] == _c]; } onBehalf:self];
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
    else if ([x isKindOfClass:[ORIdArrayI class]]) {
        id<CPIntVarArray> xa = x;
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
       [_x[i] updateMin:0];
       [_x[i] updateMax:1];
       nbTrue += ([_x[i] bound] && [_x[i] min] == true);
       nbPos  += ![_x[i] bound];
    }
    if (nbTrue >= _c) 
        return CPSuccess;
    if (nbTrue + nbPos < _c) 
       failNow();
    if (nbTrue + nbPos == _c) {
        // We already know that all the possible should be true. Do it.
        for(CPInt i=0;i<_nb;++i) {
            if ([_x[i] bound]) 
                continue;
           [_x[i] updateMin:true];
        }
        return CPSuccess;      
    }
    CPInt listen = _c+1;
    CPInt nbNW   = 0;
    for(CPLong i=_nb-1;i >= 0;--i) {
        if (listen > 0 && [_x[i] max] == true) { // Still in the domain and in need of more watches
            --listen; // the closure must capture the correct value of listen!
            _at[listen] = [_x[i] setLoseTrigger: true do: ^ 
                           {
                               // Look for another support among the non-tracked variables.
                               CPLong j = _last;
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
                                              failNow();
                                       }
                                   }
                               }
                           }
                           onBehalf:self];                           
            _at[listen]->_vId = (CPInt)i; // local identifier of var being watched.
        } 
        else 
            _notTriggered[nbNW++] = (CPInt)i;
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
    [aCoder encodeValueOfObjCType:@encode(CPLong) at:&_nb];
    for(CPInt k=0;k<_nb;k++) 
        [aCoder encodeObject:_x[k]];
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    [aDecoder decodeValueOfObjCType:@encode(CPLong) at:&_nb];
    _x = malloc(sizeof(CPIntVarI*)*_nb);   
    for(CPInt k=0;k<_nb;k++) 
        _x[k] = [aDecoder decodeObject];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_c];
    return self;
}
@end


