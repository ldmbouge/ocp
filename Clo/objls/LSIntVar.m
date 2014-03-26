/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSIntVar.h"
#import "LSEngineI.h"
#import "LSFactory.h"
#import "LSCount.h"

@implementation LSLink
-(id)initLinkFrom:(id)src to:(id)trg type:(LSLinkType)t
{
   self = [super init];
   _src = src;
   _trg = trg;
   _t   = t;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(NSUInteger)hash
{
   return ((NSUInteger)_src ^ (NSUInteger)_trg);
}
- (BOOL)isEqual: (LSLink*)other
{
   return _src == other->_src && _trg == other->_trg;
}
-(id)target
{
   return _trg;
}
-(id)source
{
   return _src;
}
-(LSLinkType)type
{
   return _t;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<LSLink: %d -> %d (%@)>",[_src getId],[_trg getId],_t == LSLogical ? @"log" : @"prp"];
   return buf;
}
@end

@implementation LSOutbound
-(id)initWith:(NSSet*)theSet
{
   self = [super init];
   _theSet = [theSet retain];
   return self;
}
-(void)dealloc
{
   [_theSet release];
   [super dealloc];
}
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
   if (state->state == 0) {
      if (_theSet == nil)
         return 0;
      NSEnumerator* n = [_theSet objectEnumerator];
      ORInt k = 0;
      id ok = nil;
      while (k < len && (ok = [n nextObject]) != nil)
         stackbuf[k++] = [ok target];
      state->itemsPtr = stackbuf;
      state->mutationsPtr = (unsigned long*)_theSet;
      state->state = (unsigned long)n;
      return k;
   } else {
      NSEnumerator* n = (id)(state->state);
      ORInt k = 0;
      id ok = nil;
      while (k < len && (ok = [n nextObject]) != nil)
         stackbuf[k++] = [ok target];
      state->itemsPtr = stackbuf;
      state->mutationsPtr = (unsigned long*)_theSet;
      state->state = (unsigned long)n;
      return k;
   }
}
@end

@implementation LSInbound
-(id)initWith:(NSSet*)theSet
{
   self = [super init];
   _theSet = [theSet retain];
   return self;
}
-(void)dealloc
{
   [_theSet release];
   [super dealloc];
}
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
   if (state->state == 0) {
      if (_theSet == nil) {
         state->itemsPtr = stackbuf;
         state->mutationsPtr = &state->extra[0];;
         state->state = 1;
         return 0;
      }
      NSEnumerator* n = [_theSet objectEnumerator];
      ORInt k = 0;
      id ok = nil;
      while (k < len && (ok = [n nextObject]) != nil)
         stackbuf[k++] = [ok source];
      state->itemsPtr = stackbuf;
      state->mutationsPtr = (unsigned long*)_theSet;
      state->state = (unsigned long)n;
      return k;
   } else {
      NSEnumerator* n = (id)(state->state);
      ORInt k = 0;
      id ok = nil;
      while (k < len && (ok = [n nextObject]) != nil)
         stackbuf[k++] = [ok source];
      state->itemsPtr = stackbuf;
      state->mutationsPtr = (unsigned long*)_theSet;
      state->state = (unsigned long)n;
      return k;
   }
}
@end


// =======================================================================================
// Int Variables

@implementation LSIntVar

-(id)initWithEngine:(LSEngineI*)engine domain:(id<ORIntRange>)d
{
   self = [super init];
   _engine = engine;
   _dom    = d;
   _value = d.low;
   _status = LSFinal;
   _outbound = [[NSMutableSet alloc] initWithCapacity:2];
   _pullers  = [[NSMutableArray alloc] initWithCapacity:2];
   _inbound  = nil;
   [_engine trackVariable:self];
   _rank = [[[engine space] nifty] retain];
   return self;
}
-(void)dealloc
{
   NSLog(@"Deallocating LSIntVar %@",self);
   [_outbound release];
   [_pullers release];
   [super dealloc];
}
-(LSEngineI*)engine
{
   return _engine;
}
-(id<LSPriority>)rank
{
   return _rank;
}
-(void)setRank:(id<LSPriority>)r
{
   [_rank release];
   _rank = [r retain];
}
-(id<ORIntRange>)domain
{
   return _dom;
}
-(NSUInteger)inDegree
{
   return _inbound ? [_inbound count] : 0;
}
-(id<NSFastEnumeration>)outbound
{
   return [[[LSOutbound alloc] initWith:_outbound] autorelease];
}
-(id<NSFastEnumeration>)inbound
{
   return [[[LSInbound alloc] initWith:_inbound] autorelease];
}

-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"var<LS>(%p,%d,%@,%@) = %d",self,_name,_rank,_dom,_value];
   return buf;
}
-(ORInt)lookahead:(id<LSIntVar>)y onAssign:(ORInt)v
{
   ORInt old = _value;
   _value = v;
   ORInt rv = [y value];
   _value = old;
   return rv;
}
-(void)setValue:(ORInt)v
{
   if (v == _value) return;
   _value = v;
   [_engine notify:self];
}
-(ORInt)value
{
   return _value;
}
-(ORInt)incr
{
   ORInt rv =  ++_value;
   [_engine notify:self];
   return rv;
}
-(ORInt)decr
{
   ORInt rv =  --_value;
   [_engine notify:self];
   return rv;
}
-(id)addLogicalListener:(id)p
{
   LSLink* obj = [[LSLink alloc] initLinkFrom:self to:p type:LSLogical];
   [_outbound addObject:obj];
   return obj;
}
-(id)addListener:(id)p
{
   LSLink* obj = [[LSLink alloc] initLinkFrom:self to:p type:LSPropagate];
   [_outbound addObject:obj];
   return obj;
}
-(id)addListener:(id)p with:(void(^)())block
{
   LSLink* obj = [[LSLink alloc] initLinkFrom:self to:p type:LSPropagate];
   [_outbound addObject:obj];
   [_pullers addObject:[block copy]];
   return obj;
}
-(id)addDefiner:(id)p
{
   LSLink* obj = [[LSLink alloc] initLinkFrom:p to:self type:LSPropagate];
   if (_inbound==nil) _inbound = [[NSMutableSet alloc] initWithCapacity:8];
   [_inbound addObject:obj];
   return obj;
}
-(void)enumerateOutbound:(void(^)(id))block
{
   for(LSLink* lnk in _outbound)
      block(lnk.target);
}
-(void)scheduleOutbound:(LSEngineI*)engine
{
   for(void(^puller)() in _pullers)
      puller();
   for(LSLink* lnk in _outbound) {
      if (lnk->_t == LSPropagate)
         [engine schedule:lnk->_trg];
   }
}

-(LSGradient)decrease:(id<LSIntVar>)x
{
   LSGradient rv;
   if (getId(x) == _name) {
      rv._gt = LSGVar;
      rv._vg = [LSFactory intVar:_engine domain:RANGE(_engine,0,_dom.up - _dom.low)];
      [_engine add:[LSFactory inv:rv._vg equal:^ORInt{ return _value - _dom.low;} vars:@[self]]];
   } else {
      rv._gt = LSGCst;
      rv._cg = 0;
   }
   return rv;
}
-(LSGradient)increase:(id<LSIntVar>)x
{
   LSGradient rv;
   if (getId(x) == _name) {
      rv._gt = LSGVar;
      rv._vg = [LSFactory intVar:_engine domain:RANGE(_engine,0,_dom.up - _dom.low)];
      [_engine add:[LSFactory inv:rv._vg equal:^ORInt{ return _dom.up - _value;} vars:@[self]]];
   } else {
      rv._gt = LSGCst;
      rv._cg = 0;
   }
   return rv;
}
@end
