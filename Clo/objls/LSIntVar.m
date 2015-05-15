/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSIntVar.h"
#import "LSEngineI.h"
#import "LSFactory.h"
#import "LSCount.h"

@interface LSIntVarSnapshot : NSObject {
   ORUInt    _name;
   ORInt     _value;
}
-(id) init: (LSIntVar*)v with: (ORUInt) name;
-(int) intValue;
-(ORBool) boolValue;
-(NSString*) description;
-(ORBool)isEqual: (id) object;
-(NSUInteger) hash;
-(ORUInt)getId;
@end

@implementation LSIntVarSnapshot
-(id) init: (LSIntVar*)v with: (ORUInt) name
{
   self = [super init];
   _name = name;
   _value = v->_value;
   return self;
}
-(ORUInt)getId
{
   return _name;
}
-(ORInt) intValue
{
   return _value;
}
-(ORFloat) floatValue
{
   return _value;
}
-(ORBool) boolValue
{
   return _value;
}
-(ORBool)isEqual: (id) object
{
   if ([object isKindOfClass:[self class]]) {
      LSIntVarSnapshot* other = object;
      if (_name == other->_name) {
         return _value == other->_value;
      }
      else
         return NO;
   } else
      return NO;
}
-(NSUInteger) hash
{
   return (_name << 16) + _value;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"int(%d) : %d",_name,_value];
   return buf;
}
@end


// =======================================================================================
// Int Variables

@implementation LSIntVar
Class __lsivc = nil;
+(void)load
{
   __lsivc = [LSIntVar class];
}
-(id)initWithEngine:(LSEngineI*)engine domain:(id<ORIntRange>)d
{
   self = [super init];
   _engine = engine;
   _dom    = d;
   _value = d.low;
   _status = LSFinal;
   _outbound = [[NSMutableSet alloc] initWithCapacity:2];
   _closures  = [[NSMutableArray alloc] initWithCapacity:2];
   _inbound  = nil;
   [_engine trackVariable:self];
   _rank = [[[engine space] nifty] retain];
   return self;
}
-(void)dealloc
{
   NSLog(@"Deallocating LSIntVar %@",self);
   [_outbound release];
   [_closures release];
   [super dealloc];
}
- (BOOL)isEqual:(id)object
{
   if ([object isKindOfClass:[LSIntVar class]]) {
      return _name == getId(object);
   } else return NO;
}
-(id) takeSnapshot: (ORInt) vid
{
   return [[LSIntVarSnapshot alloc] init:self with:vid];
}

-(void)setHardDomain:(id<ORIntRange>)newDomain
{
   _dom = newDomain;
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
// [pvh] use in views probably; not sure I like it
-(ORInt)lookahead:(id<LSIntVar>)y onAssign:(ORInt)v
{
   ORInt old = _value;
   _value = v;
   ORInt rv = [y value];
   _value = old;
   return rv;
}
// [pvh] at the top-level, we should forbid users to assign values to variables defined by invariants
-(void)setValueSilent:(ORInt)v
{
   _value = v;
}
-(ORInt)valueWhenVar:(id<LSIntVar>)x equal:(ORInt)v
{
   if (getId(x)==_name)
      return v;
   else return _value;
}
-(void)setValue:(ORInt)v
{
   if (v == _value)
      return;
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
-(id) addListener:(id)p with:(ORClosure)block
{
   [_outbound addObject:p];
   [_closures addObject:[block copy]];
   return self;
}
-(id)addDefiner:(id)p
{
   if (_inbound==nil)
      _inbound = [[NSMutableSet alloc] initWithCapacity:8];
   [_inbound addObject:p];
   return p;
}
-(void)enumerateOutbound:(void(^)(id))block
{
   for(id<LSPropagator> p in _outbound)
      block(p);
}
-(void)scheduleOutbound:(LSEngineI*)engine
{
   for(void(^closure)() in _closures)
      closure();
   for(id<LSPropagator> p in _outbound) {
      [engine schedule: p];
   }
}
-(id<LSGradient>)decrease:(id<LSIntVar>)x
{
   if (getId(x) == _name) {
      id<LSIntVar> fv = [LSFactory intVar:_engine domain:RANGE(_engine,0,_dom.up - _dom.low)];
      [_engine add:[LSFactory inv:fv equal:^ORInt{ return _value - _dom.low;} vars:@[self]]];
      return [LSGradient varGradient:fv];
   }
   else
      return [LSGradient cstGradient:0];
}
-(id<LSGradient>)increase:(id<LSIntVar>)x
{
   if (getId(x) == _name) {
      id<LSIntVar> fv = [LSFactory intVar:_engine domain:RANGE(_engine,0,_dom.up - _dom.low)];
      [_engine add:[LSFactory inv:fv equal:^ORInt{ return _dom.up - _value;} vars:@[self]]];
      return [LSGradient varGradient:fv];
   }
   else
      return [LSGradient cstGradient:0];
}
@end
