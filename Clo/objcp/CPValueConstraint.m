/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "ORFoundation/ORFoundation.h"
#import "CPValueConstraint.h"
#import "CPEngineI.h"
#import "CPIntVarI.h"

@implementation CPReifyNotEqualcDC
-(id)initCPReifyNotEqualcDC:(CPIntVarI*)b when:(CPIntVarI*)x neq:(ORInt)c
{
    self = [super initCPCoreConstraint];
    _b = b;
    _x = x;
    _c = c;
    return self;
}
-(ORStatus) post
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
      return ORSuspend;
   } 
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,_b, nil];   
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPReifyNotEqualcDC:%02d %@ <=> (%@ != %d)>",_name,_b,_x,_c];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_b];
    [aCoder encodeObject:_x];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    _b = [aDecoder decodeObject];
    _x = [aDecoder decodeObject];
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
    return self;
}
@end

@implementation CPReifyEqualcDC
-(id) initCPReifyEqualcDC: (CPIntVarI*) b when: (CPIntVarI*) x eq: (ORInt) c
{
   self = [super initCPCoreConstraint];
    _b = b;
    _x = x;
    _c = c;
    return self;
}

-(ORStatus) post
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
           if ([_b min] == true) {
               assert([_x bound]);
                [_x bind:_c];
           } else {
              assert([_x member:_c]==FALSE);
              [_x remove:_c];
           }
        } onBehalf:self];
        [_x setLoseTrigger: _c do: ^ {
           assert([_b bound]);
           [_b bind:false];
        } onBehalf:self];
        [_x setBindTrigger: ^ {
           assert([_b bound]);
           [_b bind:[_x min] == _c];
        } onBehalf:self];
        return ORSuspend;
    }   
} 
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,_b, nil];   
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPReifyEqualcDC:%02d %@ <=> (%@ == %d)>",_name,_b,_x,_c];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_b];
    [aCoder encodeObject:_x];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}

- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    _b = [aDecoder decodeObject];
    _x = [aDecoder decodeObject];
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
    return self;
}
@end

@implementation CPReifyEqualBC
-(id) initCPReifyEqualBC: (CPIntVarI*) b when: (CPIntVarI*) x eq: (CPIntVarI*) y
{
   self = [super initCPCoreConstraint];
   _b = b;
   _x = x;
   _y = y;
   return self;
}

-(ORStatus) post
{
   if (bound(_b)) {
      if (minDom(_b)) {
         [[_b solver] add: [CPFactory equal:_x to:_y plus:0]]; // Rewrite as x==y
         return ORSkip;
      } else {
         [[_b solver] add: [CPFactory notEqual:_x to:_y]];     // Rewrite as x!=y
         return ORSkip;
      }
   }
   else if (bound(_x) && bound(_y))        //  b <=> c == d =>  b <- c==d
      [_b bind:minDom(_x) == minDom(_y)];
   else if (bound(_x)) {
      [[_b solver] add: [CPFactory reify:_b with:_y eqi:minDom(_x)]];
      return ORSkip;
   }
   else if (bound(_y)) {
      [[_b solver] add: [CPFactory reify:_b with:_x eqi:minDom(_y)]];
      return ORSkip;
   } else {      // nobody is bound. D(x) INTER D(y) = EMPTY => b = NO
      if (maxDom(_x) < minDom(_y) || maxDom(_y) < minDom(_x))
         [_b bind:NO];
      else {   // nobody bound and domains of (x,y) overlap
         
         [_b whenBindPropagate:self];
         [_x whenChangeBoundsPropagate:self];
         [_y whenChangeBoundsPropagate:self];
      }
   }
   return ORSuspend;
}

-(void)propagate
{
   if (minDom(_b)) {            // b is TRUE
      if (bound(_x))            // TRUE <=> (y == c)         
         [_y bind:minDom(_x)];
      else  if (bound(_y))      // TRUE <=> (x == c)
         [_x bind:minDom(_y)];
      else {                    // TRUE <=> (x == y)
         [_x updateMin:minDom(_y) andMax:maxDom(_y)];
         [_y updateMin:minDom(_x) andMax:maxDom(_x)];
      }
   }
   else if (maxDom(_b)==0) {     // b is FALSE
      if (bound(_x))
         removeDom(_y, minDom(_x));
      else if (bound(_y))
         removeDom(_x, minDom(_y));
   }
   else {                        // b is unknown
      if (bound(_x) && bound(_y))
         [_b bind: minDom(_x) == minDom(_y)];
      else if (maxDom(_x) < minDom(_y) || maxDom(_y) < minDom(_x))
         [_b bind:NO];
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPReifyEqualBC:%02d %@ <=> (%@ == %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,_y,_b, nil];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_b bound];
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
}

- (id) initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   return self;
}
@end

@implementation CPReifyEqualDC
-(id) initCPReifyEqualDC: (CPIntVarI*) b when: (CPIntVarI*) x eq: (CPIntVarI*) y
{
   self = [super initCPCoreConstraint];
   _b = b;
   _x = x;
   _y = y;
   return self;
}

-(ORStatus) post
{
   if (bound(_b)) {
      if (minDom(_b)) {
         [[_b solver] add: [CPFactory equal:_x to:_y plus:0]]; // Rewrite as x==y
         return ORSkip;
      } else {
         [[_b solver] add: [CPFactory notEqual:_x to:_y]];     // Rewrite as x!=y
         return ORSkip;
      }
   }
   else if (bound(_x) && bound(_y))        //  b <=> c == d =>  b <- c==d
      [_b bind:minDom(_x) == minDom(_y)];
   else if (bound(_x))
      [self reifiedOp:_y equal:minDom(_x) equiv:_b];
   else if (bound(_y))
      [self reifiedOp:_x equal:minDom(_y) equiv:_b];   
   else {      // nobody is bound. D(x) INTER D(y) = EMPTY => b = NO
      if (maxDom(_x) < minDom(_y) || maxDom(_y) < minDom(_x))
         [_b bind:NO];
      else {   // nobody bound and domains of (x,y) overlap
         [_b whenBindPropagate:self];
         [self listenOn:_x inferOn:_y];
         [self listenOn:_y inferOn:_x];
      }
   }
   return ORSuspend;
}
-(void)listenOn:(CPIntVarI*)a inferOn:(CPIntVarI*)other
{
   [a whenLoseValue:self do:^(ORInt c) {  // c NOTIN(a)
      if (bound(other) && minDom(other)==c) // FALSE <=> other==c & c NOTIN(a)
            [_b bind:NO];
   }];
   [a whenBindDo:^{
      if (minDom(_b)==1)           // TRUE <=> other == c
         [other bind: minDom(a)];
      else if (maxDom(_b)==0)     // FALSE <=> other == c -> other != c
         [other remove:minDom(a)];
      else {                      // b <=> y == c
         if (!memberDom(other, minDom(a)))
            [_b bind:NO];
         if (bound(other))
            [_b bind:minDom(a) == minDom(other)];
      }
   } onBehalf:self];
   
}
-(void)reifiedOp:(CPIntVarI*)a equal:(ORInt)c equiv:(CPIntVarI*)b
{
   if (!memberDom(a, c)) {                   // b <=> c == a & c NOTIN D(a)
      [b bind:NO];                           // -> b=NO
   } else {                                  // b <=> c == a & c IN D(a)
      [a whenLoseValue:self do:^(ORInt v) {
         if (v == c)
            [b bind:NO];
      }];
      [a whenBindDo:^{
         [b bind:c == minDom(a)];
      } onBehalf:self];
      [b whenBindDo:^{
         if (minDom(b))
            [a bind:c];
         else
            [a remove:c];
      } onBehalf:self];
   }
}
-(void)propagate
{
   if (minDom(_b)) {
      if (bound(_x))            // TRUE <=> (y == c)
         [_y bind:minDom(_x)];
      else  if (bound(_y))      // TRUE <=> (x == c)
         [_x bind:minDom(_y)];
      else {                    // TRUE <=> (x == y)
         [_x updateMin:minDom(_y) andMax:maxDom(_y)];
         [_y updateMin:minDom(_x) andMax:maxDom(_x)];
         ORBounds b = bounds(_x);
         for(ORInt i = b.min;i <= b.max; i++) {
            if (!memberBitDom(_x, i))
               [_y remove:i];
            if (!memberBitDom(_x, i))
               [_x remove:i];
         }
      }
   }
   else {
      if (bound(_x))             // FALSE <=> y == c => y != c
         [_y remove:minDom(_x)];
      else if (bound(_y))        // FALSE <=> x == c => x != c
         [_x remove:minDom(_y)];
      // x != y
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPReifyEqualDC:%02d %@ <=> (%@ == %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,_y,_b, nil];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_b bound];
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
}

- (id) initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   return self;
}
@end

@implementation CPReifyLEqualDC
-(id) initCPReifyLEqualDC: (CPIntVarI*) b when: (CPIntVarI*) x leq: (ORInt) c
{
   self = [super initCPCoreConstraint];
   _b = b;
   _x = x;
   _c = c;
   return self;
}

-(ORStatus) post
{
   if ([_b bound]) {
      if ([_b min])
         return [_x updateMax:_c];
      else
         return [_x updateMin:_c+1];
   }
   else if ([_x max] <= _c)
      return [_b bind:YES];
   else if ([_x min] > _c)
      return [_b bind:NO];
   else {
      [_b setBindTrigger: ^ {
         if ([_b min])
            [_x updateMax:_c];
         else
            [_x updateMin:_c+1];
      } onBehalf:self];
      [_x whenChangeMinDo:^{
         if ([_x min] > _c)
            [_b bind:NO];
      } onBehalf:self];
      [_x whenChangeMaxDo:^{
         if ([_x max] <= _c)
            [_b bind:YES];
      } onBehalf:self];
      return ORSuspend;
   }
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,_b, nil];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPReifyLEqualDC:%02d %@ <=> (%@ <= %d)>",_name,_b,_x,_c];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}

- (id) initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end


@implementation CPReifyGEqualDC
-(id) initCPReifyGEqualDC: (CPIntVarI*) b when: (CPIntVarI*) x geq: (ORInt) c
{
   self = [super initCPCoreConstraint];
   _b = b;
   _x = x;
   _c = c;
   return self;
}

-(ORStatus) post  // b <=>  x >= c
{
   if ([_b bound]) {
      if ([_b min])
         return [_x updateMin:_c];
      else
         return [_x updateMax:_c-1];
   }
   else if ([_x min] >= _c)
      return [_b bind:YES];
   else if ([_x max] < _c)
      return [_b bind:NO];
   else {
      [_b setBindTrigger: ^ {
         if ([_b min])
            [_x updateMin:_c];
         else
            [_x updateMax:_c-1];
      } onBehalf:self];
      [_x whenChangeMinDo:^{
         if ([_x min] >= _c)
            [_b bind:YES];
      } onBehalf:self];
      [_x whenChangeMaxDo:^{
         if ([_x max] < _c)
            [_b bind:NO];
      } onBehalf:self];
      return ORSuspend;
   }
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,_b, nil];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}

- (id) initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation CPSumBoolGeq

-(id) initCPSumBool: (id) x geq: (ORInt) c
{
   if ([x isKindOfClass:[NSArray class]]) {
      self = [super initCPCoreConstraint];
      _nb = [x count];
      _x = malloc(sizeof(CPIntVarI*)*_nb);
      for(ORInt k=0;k<_nb;k++)
         _x[k] = [x objectAtIndex:k];
   }
   else if ([[x class] conformsToProtocol:@protocol(ORIntVarArray)]) {
      id<ORIntVarArray> xa = x;
      self = [super initCPCoreConstraint];
      _nb = [x count];
      _x  = malloc(sizeof(CPIntVarI*)*_nb);
      ORInt low = [xa low];
      ORInt up = [xa up];
      ORInt i = 0;
      for(ORInt k=low;k <= up;k++)
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

-(ORStatus) post
{
    _at = malloc(sizeof(CPTrigger*)*(_c+1));
    _notTriggered = malloc(sizeof(ORInt)*(_nb - _c - 1));
    int nbTrue = 0;
    int nbPos  = 0;
    for(ORInt i=0;i<_nb;i++) {
       [_x[i] updateMin:0];
       [_x[i] updateMax:1];
       nbTrue += ([_x[i] bound] && [_x[i] min] == true);
       nbPos  += ![_x[i] bound];
    }
    if (nbTrue >= _c) 
        return ORSuccess;
    if (nbTrue + nbPos < _c) 
       failNow();
    if (nbTrue + nbPos == _c) {
        // We already know that all the possible should be true. Do it.
        for(ORInt i=0;i<_nb;++i) {
            if ([_x[i] bound]) 
                continue;
           [_x[i] updateMin:true];
        }
        return ORSuccess;      
    }
    ORInt listen = _c+1;
    ORInt nbNW   = 0;
    for(ORLong i=_nb-1;i >= 0;--i) {
        if (listen > 0 && [_x[i] max] == true) { // Still in the domain and in need of more watches
            --listen; // the closure must capture the correct value of listen!
            _at[listen] = [_x[i] setLoseTrigger: true do: ^ 
                           {
                               // Look for another support among the non-tracked variables.
                               ORLong j = _last;
                               bool jOk = false;
                               do {
                                   j=(j+1) % (_nb - _c - 1);
                                   jOk = [_x[_notTriggered[j]] member:true];
                               } while (j != _last && !jOk);
                               if (jOk) {
                                   ORInt nextVar = _notTriggered[j];
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
                                   for(ORInt k=0;k<_c+1;k++) {
                                       if (k != listen) {
                                           ORStatus ok = [_x[_at[k]->_vId] updateMin:true];
                                           if (!ok) 
                                              failNow();
                                       }
                                   }
                               }
                           }
                           onBehalf:self];                           
            _at[listen]->_vId = (ORInt)i; // local identifier of var being watched.
        } 
        else 
            _notTriggered[nbNW++] = (ORInt)i;
    }   
    assert(nbNW == _nb - _c - 1);
    _last = _nb - _c - 2;  // where we will start the circular scan among the unWatched variables.
    return ORSuspend;
}

-(NSSet*)allVars
{
   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:_nb];
   for(ORInt k = 0;k < _nb;k++)
      [rv addObject:_x[k]];
   return rv;
}
-(ORUInt)nbUVars
{
   ORUInt nb=0;
   for(ORUInt k=0;k<_nb;k++) 
      nb += ![_x[k] bound];
   return nb;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];   
    [aCoder encodeValueOfObjCType:@encode(ORLong) at:&_nb];
    for(ORInt k=0;k<_nb;k++) 
        [aCoder encodeObject:_x[k]];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    [aDecoder decodeValueOfObjCType:@encode(ORLong) at:&_nb];
    _x = malloc(sizeof(CPIntVarI*)*_nb);   
    for(ORInt k=0;k<_nb;k++) 
        _x[k] = [aDecoder decodeObject];
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
    return self;
}
@end

@implementation CPSumBoolEq {
   TRInt _nbOne;
   TRInt _nbZero;   
}
-(id) initCPSumBool:(id) x eq:(ORInt)c
{
   NSLog(@"%@",x);
   NSLog(@"%@",[x class]);
   if ([x isKindOfClass:[NSArray class]]) {
      id<ORSolver> solver = [[x objectAtIndex:0] solver];
      self = [super initCPActiveConstraint: [solver engine]];
      _nb = [x count];
      _x = malloc(sizeof(CPIntVarI*)*_nb);
      for(ORInt k=0;k<_nb;k++)
         _x[k] = [x objectAtIndex:k];
   }
   else {
      id<ORIntVarArray> xa = x;
      self = [super initCPActiveConstraint:[[x solver] engine]];
      _nb = [x count];
      _x  = malloc(sizeof(CPIntVarI*)*_nb);
      ORInt low = [xa low];
      ORInt up = [xa up];
      ORInt i = 0;
      for(ORInt k=low;k <= up;k++)
         _x[i++] = (CPIntVarI*) [xa at:k];
   }
   _c = c;
   return self;
}
-(void) dealloc
{
   free(_x);
   [super dealloc];
}
-(ORStatus) post
{
   int nbTrue = 0;
   int nbPos  = 0;
   for(ORInt i=0;i<_nb;i++) {
      nbTrue += minDom(_x[i])==1;
      nbPos  += !bound(_x[i]);
   }
   if (nbTrue > _c)               // too many are true already. Fail.
      failNow();
   if (nbTrue == _c) {            // All the possible should be FALSE
      for(ORInt i=0;i<_nb;++i)
         if (!bound(_x[i]))
            [_x[i] bind:NO];
      return ORSuccess;
   }
   if (nbTrue + nbPos < _c)      // We can't possibly make it to _c. fail.
      failNow();
   if (nbTrue + nbPos == _c) {   // All the possible should be TRUE
      for(ORInt i=0;i<_nb;++i)
         if (!bound(_x[i]))
             [_x[i] bind:YES];
      return ORSuccess;
   }
   _nbOne  = makeTRInt(_trail, nbTrue);
   _nbZero = makeTRInt(_trail, (ORInt)_nb - nbTrue - nbPos);
   for(ORInt k=0;k < _nb;k++) {
      if (bound(_x[k])) continue;
      [_x[k] whenBindDo:^{
         if (minDom(_x[k])) {  // ONE more TRUE
            if (_nbOne._val + 1 == _c) {
               ORInt nb1 = 0;
               for(ORInt i=0;i<_nb;i++) {
                  nb1 += (minDom(_x[i])==YES);   // already a ONE
                  if (!bound(_x[i]))
                     [_x[i] bind:FALSE];
               }
               if (nb1 != _c)
                  failNow();                     // too many ONES!
            }
            else
               assignTRInt(&_nbOne,_nbOne._val + 1,_trail);
         } else { // ONE more FALSE
            if (_nb - _nbZero._val -  1 == _c) { // we have maxed out the # of FALSE
               ORInt nb1 = 0;
               for(ORInt i=0;i < _nb;i++) {
                  nb1 += (minDom(_x[i])==YES);   // already a ONE
                  if (!bound(_x[i])) {
                     [_x[i] bind:TRUE];
                     ++nb1;                      // We just added another ONE
                  }
               }
               if (nb1 != _c)
                  failNow();
            }
            else
               assignTRInt(&_nbZero, _nbZero._val + 1, _trail);
         }
      } onBehalf:self];
   }
   return ORSuspend;
}
-(NSSet*)allVars
{
   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:_nb];
   for(ORInt k = 0;k < _nb;k++)
      [rv addObject:_x[k]];
   return rv;
}
-(ORUInt)nbUVars
{
   ORUInt nb=0;
   for(ORUInt k=0;k<_nb;k++)
      nb += ![_x[k] bound];
   return nb;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeValueOfObjCType:@encode(ORLong) at:&_nb];
   for(ORInt k=0;k<_nb;k++)
      [aCoder encodeObject:_x[k]];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   [aDecoder decodeValueOfObjCType:@encode(ORLong) at:&_nb];
   _x = malloc(sizeof(CPIntVarI*)*_nb);
   for(ORInt k=0;k<_nb;k++)
      _x[k] = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end


