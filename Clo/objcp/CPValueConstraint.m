/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <ORFoundation/ORFoundation.h>
#import "CPValueConstraint.h"
#import "CPEngineI.h"
#import "CPIntVarI.h"

@implementation CPReifyNotEqualcDC
-(id)initCPReifyNotEqualcDC:(CPIntVarBase*)b when:(CPIntVarBase*)x neq:(ORInt)c
{
   self = [super initCPCoreConstraint:[b engine]];
    _b = b;
    _x = x;
    _c = c;
    return self;
}
-(ORStatus) post
{
   if ([_b bound]) {
      if ([_b min] == true) 
         [_x remove:_c];
      else 
         [_x bind:_c];
   } 
   else if ([_x bound]) 
      [_b bind:[_x min] != _c];
   else if (![_x member:_c])
      [_b remove:false];
   else {
      [_b whenBindDo: ^void {
         if ([_b min]==true)
            [_x remove:_c];
         else 
            [_x bind:_c];
      } onBehalf:self];
      [_x setLoseTrigger: _c do: ^(void) { [_b bind:true]; } onBehalf:self];
      [_x whenBindDo: ^(void) { [_b bind:[_x min] != _c];} onBehalf:self];
   }
   return ORSuspend;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
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
-(id) initCPReifyEqualcDC: (CPIntVarBase*) b when: (CPIntVarBase*) x eq: (ORInt) c
{
   self = [super initCPCoreConstraint:[b engine]];
    _b = b;
    _x = x;
    _c = c;
    return self;
}

-(ORStatus) post
{
    if ([_b bound]) {
        if ([_b min] == true) 
            [_x bind:_c];
        else 
            [_x remove:_c];
    } 
    else if ([_x bound]) 
        [_b bind:[_x min] == _c];   
    else if (![_x member:_c])
        [_b bind:false];
    else {
        [_b setBindTrigger: ^ {
           if ([_b min] == true) {
                [_x bind:_c];
           } else {
              [_x remove:_c];
           }
        } onBehalf:self];
        [_x setLoseTrigger: _c do: ^ {
           [_b bind:false];
        } onBehalf:self];
        [_x setBindTrigger: ^ {
           [_b bind:[_x min] == _c];
        } onBehalf:self];
    }
   return ORSuspend;
} 
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
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

// ==============================================================================================

@implementation CPReifyEqualBC
-(id) initCPReifyEqualBC: (CPIntVarBase*) b when: (CPIntVarBase*) x eq: (CPIntVarBase*) y
{
   self = [super initCPCoreConstraint:[b engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}

-(ORStatus) post
{
   if (bound(_b)) {
      if (minDom(_b)) {
         [[_b engine] addInternal: [CPFactory equal:_x to:_y plus:0]]; // Rewrite as x==y  (addInternal can throw)
         return ORSkip;
      } else {
         [[_b engine] addInternal: [CPFactory notEqual:_x to:_y]];     // Rewrite as x!=y  (addInternal can throw)
         return ORSkip;
      }
   }
   else if (bound(_x) && bound(_y))        //  b <=> c == d =>  b <- c==d
      [_b bind:minDom(_x) == minDom(_y)];
   else if (bound(_x)) {
      [[_b engine] addInternal: [CPFactory reify:_b with:_y eqi:minDom(_x)]];
      return ORSkip;
   }
   else if (bound(_y)) {
      [[_b engine] addInternal: [CPFactory reify:_b with:_x eqi:minDom(_y)]];
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
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
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

// ==============================================================================================

@implementation CPReifyEqualDC
-(id) initCPReifyEqualDC: (CPIntVarBase*) b when: (CPIntVarBase*) x eq: (CPIntVarBase*) y
{
   self = [super initCPCoreConstraint:[b engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}

-(ORStatus) post
{
   if (bound(_b)) {
      if (minDom(_b)) {
         [[_b engine] addInternal: [CPFactory equal:_x to:_y plus:0]]; // Rewrite as x==y
         return ORSkip;
      } else {
         [[_b engine] addInternal: [CPFactory notEqual:_x to:_y]];     // Rewrite as x!=y
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
-(void)listenOn:(CPIntVarBase*)a inferOn:(CPIntVarBase*)other
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
-(void)reifiedOp:(CPIntVarBase*)a equal:(ORInt)c equiv:(CPIntVarBase*)b
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
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
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

// ==============================================================================================

@implementation CPReifyNEqualBC
-(id) initCPReify: (CPIntVarBase*) b when: (CPIntVarBase*) x neq: (CPIntVarBase*) y
{
   self = [super initCPCoreConstraint:[b engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}

-(ORStatus) post
{
   if (bound(_b)) {
      if (minDom(_b)) {
         [[_b engine] addInternal: [CPFactory notEqual:_x to:_y]];         // Rewrite as x==y  (addInternal can throw)
         return ORSkip;
      } else {
         [[_b engine] addInternal: [CPFactory equal:_x to:_y plus:0]];     // Rewrite as x==y  (addInternal can throw)
         return ORSkip;
      }
   }
   else if (bound(_x) && bound(_y))        //  b <=> c == d =>  b <- c==d
      [_b bind:minDom(_x) != minDom(_y)];
   else if (bound(_x)) {
      [[_b engine] addInternal: [CPFactory reify:_b with:_y neqi:minDom(_x)]];
      return ORSkip;
   }
   else if (bound(_y)) {
      [[_b engine] addInternal: [CPFactory reify:_b with:_x neqi:minDom(_y)]];
      return ORSkip;
   } else {      // nobody is bound. D(x) INTER D(y) = EMPTY => b = YES
      if (maxDom(_x) < minDom(_y) || maxDom(_y) < minDom(_x))
         [_b bind:YES];
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
      if (bound(_x))            // TRUE <=> (y != c)
         [_y remove:minDom(_x)];
      else  if (bound(_y))      // TRUE <=> (x != c)
         [_x remove:minDom(_y)];
   }
   else if (maxDom(_b)==0) {     // b is FALSE
      if (bound(_x))
         bindDom(_y, minDom(_x));
      else if (bound(_y))
         bindDom(_x, minDom(_y));
      else {                    // FALSE <=> (x == y)
         [_x updateMin:minDom(_y) andMax:maxDom(_y)];
         [_y updateMin:minDom(_x) andMax:maxDom(_x)];
      }
   }
   else {                        // b is unknown
      if (bound(_x) && bound(_y))
         [_b bind: minDom(_x) != minDom(_y)];
      else if (maxDom(_x) < minDom(_y) || maxDom(_y) < minDom(_x))
         [_b bind:YES];
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPReifyNEqualBC:%02d %@ <=> (%@ == %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
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

// ==============================================================================================

@implementation CPReifyNEqualDC
-(id) initCPReify: (CPIntVarBase*) b when: (CPIntVarBase*) x neq: (CPIntVarBase*) y
{
   self = [super initCPCoreConstraint:[b engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}

-(ORStatus) post
{
   if (bound(_b)) {
      if (minDom(_b)) {
         [[_b engine] addInternal: [CPFactory notEqual:_x to:_y]]; // Rewrite as x!=y
         return ORSkip;
      } else {
         [[_b engine] addInternal: [CPFactory equal:_x to:_y plus:0]]; // Rewrite as x==y
         return ORSkip;
      }
   }
   else if (bound(_x) && bound(_y))        //  b <=> c == d =>  b <- c==d
      [_b bind:minDom(_x) != minDom(_y)];
   else if (bound(_x))
      [self reifiedOp:_y notEqual:minDom(_x) equiv:_b];
   else if (bound(_y))
      [self reifiedOp:_x notEqual:minDom(_y) equiv:_b];
   else {      // nobody is bound. D(x) INTER D(y) = EMPTY => b = YES
      if (maxDom(_x) < minDom(_y) || maxDom(_y) < minDom(_x))
         [_b bind:YES];
      else {   // nobody bound and domains of (x,y) overlap
         [_b whenBindPropagate:self];
         [self listenOn:_x inferOn:_y];
         [self listenOn:_y inferOn:_x];
      }
   }
   return ORSuspend;
}
-(void)listenOn:(CPIntVarBase*)a inferOn:(CPIntVarBase*)other
{
   [a whenLoseValue:self do:^(ORInt c) {    // c NOTIN(a)
      if (bound(other) && minDom(other)==c) // FALSE <=> other==c & c NOTIN(a)
         [_b bind:YES];
   }];
   [a whenBindDo:^{
      if (minDom(_b)==1)           // TRUE <=> other != c
         [other remove: minDom(a)];
      else if (maxDom(_b)==0)     // FALSE <=> other != c -> other == c
         [other bind:minDom(a)];
      else {                      // b <=> y != c
         if (!memberDom(other, minDom(a)))
            [_b bind:YES];
         if (bound(other))
            [_b bind:minDom(a) != minDom(other)];
      }
   } onBehalf:self];
}
-(void)reifiedOp:(CPIntVarBase*)a notEqual:(ORInt)c equiv:(CPIntVarBase*)b
{
   if (!memberDom(a, c)) {                   // b <=> c != a & c NOTIN D(a)
      [b bind:YES];                          // -> b=YES
   } else {                                  // b <=> c != a & c IN D(a)
      [a whenLoseValue:self do:^(ORInt v) {
         if (v == c)
            [b bind:YES];
      }];
      [a whenBindDo:^{
         [b bind:c != minDom(a)];
      } onBehalf:self];
      [b whenBindDo:^{
         if (minDom(b))
            [a remove:c];
         else
            [a bind:c];
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
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
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

@implementation CPReifyLEqualBC
-(id) initCPReifyLEqualBC:(CPIntVarBase*)b when:(CPIntVarBase*)x leq:(CPIntVarBase*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(ORStatus) post
{
   if (bound(_b)) {
      if (minDom(_b)) {  // YES <=>  x <= y
         [_x updateMax:maxDom(_y)];
         [_y updateMin:minDom(_x)];
      } else {            // NO <=> x <= y   ==>  YES <=> x > y
         if (bound(_x)) { // c > y
            [_y updateMax:minDom(_x) - 1];
         } else {         // x > y
            [_y updateMax:maxDom(_x) - 1];
            [_x updateMin:minDom(_y) + 1];
         }
      }
      if (!bound(_x))
         [_x whenChangeBoundsPropagate:self];
      if (!bound(_y))
         [_y whenChangeBoundsPropagate:self];
   } else {
      if (maxDom(_x) <= minDom(_y))
         [_b bind:YES];
      else if (minDom(_x) > maxDom(_y))
         [_b bind:NO];
      else {
         [_x whenChangeBoundsPropagate:self];
         [_y whenChangeBoundsPropagate:self];
         [_b whenBindPropagate:self];
      }
   }
   return ORSuspend;
}
-(void)propagate
{
   if (bound(_b)) {
      if (minDom(_b)) {
         [_x updateMax:maxDom(_y)];
         [_y updateMin:minDom(_x)];
      } else {
         [_x updateMin:minDom(_y) + 1];
         [_y updateMax:maxDom(_x) - 1];
      }
   } else {
      if (maxDom(_x) <= minDom(_y)) {
         assignTRInt(&_active, NO, _trail);
         [_b bind:YES];
      } else if (minDom(_x) > maxDom(_y)) {
         assignTRInt(&_active, NO, _trail);
         [_b bind:NO];
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_b,_x,_y, nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_b bound];
}
@end
// ==============================================================================================

@implementation CPReifyLEqualDC
-(id) initCPReifyLEqualDC: (CPIntVarBase*) b when: (CPIntVarBase*) x leqi: (ORInt) c
{
   self = [super initCPCoreConstraint:[b engine]];
   _b = b;
   _x = x;
   _c = c;
   return self;
}

-(ORStatus) post
{
   if ([_b bound]) {
      if ([_b min])
         [_x updateMax:_c];
      else
         [_x updateMin:_c+1];
   }
   else if ([_x max] <= _c)
      [_b bind:YES];
   else if ([_x min] > _c)
      [_b bind:NO];
   else {
      [_b whenBindPropagate:self];
      [_x whenChangeBoundsPropagate:self];
   }
   return ORSuspend;
}
-(void) propagate
{
   if (bound(_b)) {
      assignTRInt(&_active, NO, _trail);
      if (_b.min)
         [_x updateMax:_c];
      else [_x updateMin:_c+1];
   } else {
      if (_x.min > _c) {
         assignTRInt(&_active, NO, _trail);
         [_b bind:NO];
      } else if (_x.max <= _c) {
         assignTRInt(&_active, NO, _trail);
         [_b bind:YES];
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
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
-(id) initCPReifyGEqualDC: (CPIntVarBase*) b when: (CPIntVarBase*) x geq: (ORInt) c
{
   self = [super initCPCoreConstraint:[b engine]];
   _b = b;
   _x = x;
   _c = c;
   return self;
}

-(ORStatus) post  // b <=>  x >= c
{
   if ([_b bound]) {
      if ([_b min])
         [_x updateMin:_c];
      else
         [_x updateMax:_c-1];
   }
   else if ([_x min] >= _c)
      [_b bind:YES];
   else if ([_x max] < _c)
      [_b bind:NO];
   else {
      [_b whenBindPropagate:self];
      [_x whenChangeBoundsPropagate:self];
   }
   return ORSuspend;
}
-(void) propagate
{
   if (bound(_b)) {
      assignTRInt(&_active, NO, _trail);
      if (_b.min)
         [_x updateMin:_c];
      else [_x updateMax:_c-1];
   } else {
      if (_x.min >= _c) {
         assignTRInt(&_active, NO, _trail);
         [_b bind:YES];
      } else if (_x.max < _c) {
         assignTRInt(&_active, NO, _trail);
         [_b bind:NO];
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
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
   if ([[x class] conformsToProtocol:@protocol(ORIdArray)]) {
      id<CPIntVarArray> xa = x;
      self = [super initCPCoreConstraint:[[xa at:[xa low]] engine]];
      _nb = [x count];
      _x  = malloc(sizeof(CPIntVarBase*)*_nb);
      ORInt low = [xa low];
      ORInt up = [xa up];
      ORInt i = 0;
      for(ORInt k=low;k <= up;k++)
         _x[i++] = (CPIntVarBase*) [xa at:k];
   }
   else
      assert(FALSE);
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
    _at = malloc(sizeof(id<CPTrigger>)*(_c+1));
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
    for(ORInt i=(ORInt)_nb-1;i >= 0;--i) {
        if (listen > 0 && [_x[i] max] == true) { // Still in the domain and in need of more watches
            --listen; // the closure must capture the correct value of listen!
            _at[listen] = [_x[i] setLoseTrigger: true do: ^ 
                           {
                               // Look for another support among the non-tracked variables.
                               ORLong j = _last;
                               bool jOk = false;
                               if (_last >= 0) {
                                  do {
                                     j=(j+1) % (_nb - _c - 1);
                                     jOk = [_x[_notTriggered[j]] member:true];
                                  } while (j != _last && !jOk);
                               }
                               if (jOk) {
                                   ORInt nextVar = _notTriggered[j];
                                   id<CPTrigger> toMove = _at[listen];
                                   [toMove detach];                        // remove the trigger
                                   _notTriggered[j] = [toMove localID];    // remember that this variable no longer has a trigger
                                   [_x[nextVar] watch:true with:toMove];   // start watching the new variable
                                   [toMove setLocalID:nextVar];            // update the trigger with the (*local*) variable id
                                   _last = j;
                               } 
                               else {  // Ok, we couldn't find any other support => so we must bind the remaining ones
                                   for(ORInt k=0;k<_c+1;k++) {
                                       if (k != listen) {
                                           [_x[[_at[k] localID]] updateMin:true];
                                       }
                                   }
                               }
                           }
                           onBehalf:self];                           
           [_at[listen] setLocalID:i]; // local identifier of var being watched.
        } 
        else 
            _notTriggered[nbNW++] = i;
    }   
    assert(nbNW == _nb - _c - 1);
    _last = _nb - _c - 2;  // where we will start the circular scan among the unWatched variables.
    return ORSuspend;
}

-(NSSet*)allVars
{
   NSMutableSet* rv = [[[NSMutableSet alloc] initWithCapacity:_nb] autorelease];
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
    _x = malloc(sizeof(CPIntVarBase*)*_nb);   
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
-(id) initCPSumBool:(id<CPIntVarArray>)xa eq:(ORInt)c
{
   id<CPEngine> engine = [[xa at: [xa low]] engine];
   self = [super initCPCoreConstraint:engine];
   _xa = xa;
   _nb = [xa count];
   _x  = malloc(sizeof(CPIntVarBase*)*_nb);
   ORInt low = [xa low];
   ORInt up = [xa up];
   ORInt i = 0;
   for(ORInt k=low;k <= up;k++)
      _x[i++] = (CPIntVarBase*) [xa at:k];
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
      [_x[k] whenBindDo:^{ [self propagateIdx:k];} onBehalf:self];
   }
   return ORSuspend;
}
-(void)propagateIdx:(ORInt)k
{
   ORInt nb1 = 0;
   if ([_x[k] min]) {  // ONE more TRUE
      if (_nbOne._val + 1 == _c) {
         for(ORInt i=0;i<_nb;i++) {
            nb1 += ([_x[i] min]==YES);   // already a ONE
            if (![_x[i] bound])
               [_x[i] bind:FALSE];
         }
         if (nb1 != _c)
            failNow();                     // too many ONES!
      }
      else
         assignTRInt(&_nbOne,_nbOne._val + 1,_trail);
   } else { // ONE more FALSE
      if (_nb - _nbZero._val -  1 == _c) { // we have maxed out the # of FALSE
         for(ORInt i=0;i < _nb;i++) {
            //printf("%d / %lld\n",i,_nb);
            ORInt mv =[_x[i] min];
            //ORInt mv =minDom(_x[i]);  // [ldm] If I use this line, the program crashes (bibd -q3 -h2) during inits (Release only!)
            nb1 += (mv == 1);   // already a ONE
            //nb1 += (minDom(_x[i])==YES);   // already a ONE
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
}
-(NSSet*)allVars
{
   NSMutableSet* rv = [[[NSMutableSet alloc] initWithCapacity:_nb] autorelease];
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
   _x = malloc(sizeof(CPIntVarBase*)*_nb);
   for(ORInt k=0;k<_nb;k++)
      _x[k] = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end


