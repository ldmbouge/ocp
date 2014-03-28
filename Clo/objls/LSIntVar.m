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
   return _outbound;
}
-(id<NSFastEnumeration>)inbound
{
   return _inbound;
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
-(id)addListener:(id)p
{
   [_outbound addObject:p];
   return self;
}
-(id)addListener:(id)p with:(void(^)())block
{
   [_outbound addObject:p];
   [_pullers addObject:[block copy]];
   return self;
}
-(id)addDefiner:(id)p
{
   if (_inbound==nil) _inbound = [[NSMutableSet alloc] initWithCapacity:8];
   [_inbound addObject:p];
   return p;
}
-(void)enumerateOutbound:(void(^)(id))block
{
   for(id<LSPropagator> lnk in _outbound)
      block(lnk);
}
-(void)scheduleOutbound:(LSEngineI*)engine
{
   for(void(^puller)() in _pullers)
      puller();
   for(id<LSPropagator> lnk in _outbound) {
      [engine schedule:lnk];
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
