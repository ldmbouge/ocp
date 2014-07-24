/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSPropagator.h"
#import <ORUtilities/ORPQueue.h>
#import "LSVar.h"
#import "LSIntVar.h"
#import "LSFactory.h"
#import "LSCount.h"

// [pvh] used in atomic mode

@implementation LSBlock
-(id)initWith:(id<LSEngine>)engine block:(ORClosure)block atPriority:(id<LSPriority>)p
{
   self = [super initWith:engine];
   _block  = [block copy];
   _rank   = [p retain];
   return self;
}
-(void)dealloc
{
   [_block release];
   [_rank release];
   [super dealloc];
}
-(void)define
{
}
-(void)post
{
}
-(void)execute
{
   _block();
   [self release]; // [ldm] we should no longer need him after execution.
}
-(id<LSPriority>)rank
{
   return _rank;
}
-(void)setRank:(id<LSPriority>)rank
{
   [_rank release];
   _rank = [rank retain];
}
@end

@implementation LSPropagator
-(id)initWith:(LSEngineI*)engine
{
   self = [super init];
   _engine = engine;
   _inbound = [[NSMutableSet alloc] initWithCapacity:2];
   _rank = [[[engine space] nifty] retain];    
   _inQueue = NO;
   return self;
}
-(void)dealloc
{
   [_inbound release];
   [super dealloc];
}
-(void)post
{
}
-(void)define
{
   NSLog(@"Warning: define of abstract LSPropagator called");
}
-(void)addTrigger:(id)link
{
   [_inbound addObject:link];
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
-(NSUInteger)inDegree
{
   return [_inbound count];
}
-(id<NSFastEnumeration>)inbound
{
   return _inbound;
}
-(void)execute
{
}
@end

// ==============================================================
// Core Views

@interface LSViewPropagator : LSPropagator {
   id _target;
}
-(id)initWith:(id<LSEngine>)engine src:(NSArray*)src trg:(id)var;
-(void)post;
-(void)define;
-(void)execute;
@end

@implementation LSViewPropagator
-(id)initWith:(id<LSEngine>)engine src:(NSArray*)src trg:(id)var;
{
   self = [super initWith:engine];
   _target = var;
   for(id<LSVar> sv in src)
      [self addTrigger:[sv addListener:self]];
   [_engine trackObject:self];
   [_engine add:self];
   return self;
}
-(void)post
{
}
-(void)define
{
}
-(void)execute
{
   [_engine notify:_target];
}
-(id<NSFastEnumeration>)outbound
{
   return [NSSet setWithObject:_target];
}
@end


// [pvh] This guy is a variable: This is not a propagator
// [pvh] There are a lot of redundancies with LSIntVar

@implementation LSCoreView
-(id)initWith:(LSEngineI*)engine  domain:(id<ORIntRange>)d src:(NSArray*)src
{
   self = [super init];
   _engine = engine;
   _dom = d;
   _src = src;
   LSViewPropagator* vp = [[LSViewPropagator alloc] initWith:_engine src:src trg:self];
   _outbound = [[NSMutableSet alloc] initWithCapacity:2];
   _inbound  = [[NSMutableSet alloc] initWithObjects:vp, nil];
   _closures  = [[NSMutableArray alloc] initWithCapacity:2];
   [_engine trackVariable:self];
   _rank    = [[[engine space] nifty] retain];
   return self;
}
-(void)dealloc
{
   [_src release];
   [_closures release];
   [_outbound release];
   [_inbound release];
   [super dealloc];
}
-(void)setHardDomain:(id<ORIntRange>)newDomain
{
   _dom  = newDomain;
}
-(NSArray*)sourceVars
{
   return _src;
}
-(LSEngineI*)engine
{
   return _engine;
}
-(id<ORIntRange>)domain
{
   return _dom;
}
-(void)setValue:(ORInt)v
{
   assert(NO);
}
-(id)addListener:(id)p
{
   [_outbound addObject:p];
   return self;
}
-(id)addListener:(id)p with:(ORClosure)block
{
   [_outbound addObject:p];
   [_closures addObject:[block copy]];
   return self;
}
-(id)addDefiner:(id)p
{
   assert(NO);
   return p;
}
-(NSUInteger)inDegree
{
   return 1;
}
-(id<NSFastEnumeration>)outbound
{
   return _outbound;
}
-(id<NSFastEnumeration>)inbound
{
   return _inbound;
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
-(void)enumerateOutbound:(void(^)(id))block
{
   for(id<LSPropagator> p in _outbound)
      block(p);
}
-(void)scheduleOutbound:(LSEngineI*)engine
{
   for(void(^closure)() in _closures)
      closure();
   for(id p in _outbound)
      [engine schedule:p];
}
-(id<LSGradient>)decrease:(id<LSIntVar>)x
{
   assert(NO);
   return nil;
}
-(id<LSGradient>)increase:(id<LSIntVar>)x
{
   assert(NO);
   return nil;
}
-(ORInt)valueWhenVar:(id<LSIntVar>)x equal:(ORInt)v
{
   assert(NO);
   return 1;
}
@end
// ========================================================================================
// Int Views

// [pvh]: As discussed this is probably a bad idea long term, since it does not support increase/decrease

@implementation LSIntVarView
-(id)initWithEngine:(LSEngineI*)engine domain:(id<ORIntRange>)d fun:(ORInt(^)())fun src:(NSArray*)src
{
   self = [super initWith:engine domain:d src:src];
   _fun = [fun copy];
   return self;
}
-(void)dealloc
{
   [_fun release];
   [super dealloc];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"view<LS>(%p,%d,%@) = %d",self,_name,_rank,_fun()];
   return buf;
}
-(ORInt)value
{
   return _fun();
}
-(ORInt)valueWhenVar:(LSIntVar*)x equal:(ORInt)v  // [ldm] alternative to lookahead. Not faster, but this class will disappear anyway
{
   ORInt ov = getLSIntValue(x);
   [x setValueSilent:v];
   ORInt rv = _fun();
   [x setValueSilent:ov];
   return rv;
}

@end
// ==============================================================

// [pvh] This is a view for x == c

@implementation LSEQLitView
-(id)initWithEngine:(LSEngineI*)engine on:(id<LSIntVar>)x eqLit:(ORInt)c
{
   self = [super initWith:engine domain:RANGE(engine,0,1) src:@[x]];
   _x   = x;
   _lit = c;
   return self;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"EQLitView<LS>(%p,%d,%@) (%p == %d) = %d",self,_name,_rank,_x,_lit,[self value]];
   return buf;
}
-(ORInt)value
{
   return getLSIntValue(_x) == _lit;
}
-(ORInt)valueWhenVar:(id<LSIntVar>)x equal:(ORInt)v
{
   if (getId(_x) == getId(x))
      return v == _lit;
   else return getLSIntValue(_x) == _lit;
}

-(id<LSGradient>)decrease:(id<LSIntVar>)x
{
   if (getId(_x) == getId(x))
      return [LSGradient varGradient:self];
   else
      return [LSGradient cstGradient:0];
}
-(id<LSGradient>)increase:(id<LSIntVar>)x
{
   if (getId(_x) == getId(x)) {
      id<LSIntVar> fv = [LSFactory intVar:_engine domain:_dom];
      [_engine add:[LSFactory inv:fv equal:^ORInt{
         return 1 - self.value;
      } vars:@[self]]];
      return [LSGradient varGradient:fv];
   }
   else
      return [LSGradient cstGradient:0];
}
@end

// ===============================================================================
// [ldm] View for a * x + b (affine).
// Supports gradients.

@implementation LSAffineView
-(id)initWithEngine:(id<LSEngine>)engine a:(ORInt)a times:(id<LSIntVar>)x plus:(ORInt)b
{
   ORInt lb = min(a * x.domain.low + b,a * x.domain.up + b);
   ORInt ub = max(a * x.domain.low + b,a * x.domain.up + b);
   self = [super initWith:engine domain:RANGE(engine,lb,ub) src:@[x]];
   _a = a;
   _b = b;
   _x = x;
   return self;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"AffineView<LS>(%p,%d,%@) (%d * %p  + %d) = %d",self,_name,_rank,_a,_x,_b,[self value]];
   return buf;
}
-(ORInt)value
{
   return _a * getLSIntValue(_x) + _b;
}
-(ORInt)valueWhenVar:(id<LSIntVar>)x equal:(ORInt)v
{
   if (getId(_x) == getId(x))
      return _a * v + _b;
   else
      return _a * getLSIntValue(_x) + _b;
}
-(id<LSGradient>)decrease:(id<LSIntVar>)x
{
   if (getId(_x) == getId(x)) {
      id<LSGradient> g = _a >= 0 ? [_x decrease:x] : [_x increase:_x];
      return [[g scaleBy:_a] addConst:_b];
   } else
      return [LSGradient cstGradient:0];
}
-(id<LSGradient>)increase:(id<LSIntVar>)x
{
   if (getId(_x) == getId(x)) {
      id<LSGradient> g = _a >= 0 ? [_x increase:x] : [_x decrease:_x];
      return [[g scaleBy:_a] addConst:_b];
   }
   else
      return [LSGradient cstGradient:0];
}
@end

