/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSIntVar.h"
#import "LSEngineI.h"

@implementation LSLink
-(id)initLinkFrom:(id)src to:(id)trg for:(ORInt)k type:(LSLinkType)t
{
   self = [super init];
   _src = src;
   _trg = trg;
   _k   = k;
   _block = nil;
   _t   = t;
   return self;
}
-(id)initLinkFrom:(id)src to:(id)trg for:(ORInt)k block:(void(^)())block type:(LSLinkType)t
{
   self = [super init];
   _src = src;
   _trg = trg;
   _k   = k;
   _t   = t;
   _block = [block copy];
   return self;
}
-(void)dealloc
{
   [_block release];
   [super dealloc];
}
-(NSUInteger)hash
{
   return ((NSUInteger)_src ^ (NSUInteger)_trg) * _k;
}
- (BOOL)isEqual: (LSLink*)other
{
   return _src == other->_src && _trg == other->_trg && _k == other->_k;
}
-(id)target
{
   return _trg;
}
-(id)source
{
   return _src;
}
-(ORInt)index
{
   return _k;
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
   _inbound  = nil;
   [_engine trackVariable:self];
   _rank = [[[engine space] nifty] retain];
   return self;
}
-(void)dealloc
{
   NSLog(@"Deallocating LSIntVar %@",self);
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
   [buf appendFormat:@"var<LS>(%p,%d,%@) = %d",self,_name,_rank,_value];
   return buf;
}
-(void)setValue:(ORInt)v
{
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
-(id)addLogicalListener:(id)p term:(ORInt)k
{
   LSLink* obj = [[LSLink alloc] initLinkFrom:self to:p for:k type:LSLogical];
   [_outbound addObject:obj];
   return obj;
}
-(id)addListener:(id)p term:(ORInt)k
{
   LSLink* obj = [[LSLink alloc] initLinkFrom:self to:p for:k type:LSPropagate];
   [_outbound addObject:obj];
   return obj;
}
-(id)addListener:(id)p term:(ORInt)k with:(void(^)())block
{
   LSLink* obj = [[LSLink alloc] initLinkFrom:self to:p for:k block:block type:LSPropagate];
   [_outbound addObject:obj];
   return obj;
}
-(id)addDefiner:(id)p
{
   LSLink* obj = [[LSLink alloc] initLinkFrom:p to:self for:-1 type:LSPropagate];
   if (_inbound==nil) _inbound = [[NSMutableSet alloc] initWithCapacity:8];
   [_inbound addObject:obj];
   return obj;
}
-(void)enumerateOutbound:(void(^)(id,ORInt))block
{
   for(LSLink* lnk in _outbound)
      block(lnk.target,lnk.index);
}
-(void)propagateOutbound:(void(^)(id,ORInt))block
{
   for(LSLink* lnk in _outbound) {
      if (lnk->_block)
         lnk->_block();
      if (lnk->_t == LSPropagate)
         block(lnk->_trg,lnk->_k);
   }
}
@end
