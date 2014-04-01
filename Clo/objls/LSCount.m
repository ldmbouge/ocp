/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSCount.h"
#import "LSIntVar.h"

@implementation LSCount
-(id)init:(id<LSEngine>)engine count:(id<ORIdArray>)src card:(id<ORIdArray>)cnt;
{
   self = [super initWith:engine];
   _src = src;
   _cnt = cnt;
   _old = [ORFactory intArray:engine range:_src.range value:0];
   return self;
}
-(void)dealloc
{
   NSLog(@"deallocating count %p",self);
   [super dealloc];
}
-(void)define
{
   for(ORInt i=_src.low;i <= _src.up;i++)
      [self addTrigger:[_src[i] addListener:self with:^{
         LSIntVar* vk = _src[i];
         [_cnt[[_old at:i]] decr];
         [_cnt[vk.value] incr];
         [_old set:vk.value at:i];
      }]];
   for(ORInt i=_cnt.low;i <= _cnt.up;i++)
      [_cnt[i] addDefiner:self];
}
-(void)post
{
   for(ORInt i=_cnt.low;i <= _cnt.up;i++) {
      LSIntVar* cardi = _cnt[i];
      [cardi setValue:0];
   }
   for(ORInt i=_src.low;i <= _src.up;i++) {
      LSIntVar* si = _src[i];
      [_cnt[si.value] incr];
      [_old set:si.value at:i];
   }
}
// [pvh] all is done in the closures
-(void)execute
{
}
-(id<NSFastEnumeration>) outbound
{
   return _cnt;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<LSCount(%p) : %d,%@>",self,_name,_rank];
   return buf;
}
@end

@implementation LSWeightedCount
-(id)init:(id<LSIntVarArray>)src weight: (id<ORIntArray>) w count:(id<LSIntVarArray>)cnt;
{
   id<LSEngine> engine = [src[src.range.low] engine];
   self = [super initWith: engine];
   _src = src;
   _cnt = cnt;
   _w = w;
   _old = [ORFactory intArray:engine range:_src.range value:0];
   return self;
}
-(void)dealloc
{
   NSLog(@"deallocating count %p",self);
   [super dealloc];
}
-(void)define
{
   for(ORInt i=_src.low;i <= _src.up;i++)
      [self addTrigger:[_src[i] addListener:self with:^{
         LSIntVar* vk = _src[i];
         ORInt oi = [_old at:i];
         [_cnt[oi] setValue: _cnt[oi].value - [_w at: i]];
         [_cnt[vk.value] setValue: _cnt[vk.value].value + [_w at: i]];
         [_old set:vk.value at:i];
      }]];
   for(ORInt i=_cnt.low;i <= _cnt.up;i++)
      [_cnt[i] addDefiner:self];
}
-(void)post
{
   for(ORInt i=_cnt.low;i <= _cnt.up;i++) {
      LSIntVar* cardi = _cnt[i];
      [cardi setValue:0];
   }
   for(ORInt i=_src.low;i <= _src.up;i++) {
      LSIntVar* si = _src[i];
      [_cnt[si.value] setValue: [_w at: i]];
      [_old set:si.value at:i];
   }
}
// [pvh] all is done in the closures
-(void)execute
{
}
-(id<NSFastEnumeration>) outbound
{
   return _cnt;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<LSCount(%p) : %d,%@>",self,_name,_rank];
   return buf;
}
@end

@implementation LSInv
-(id)init:(id<LSEngine>)engine var:(id<LSIntVar>)x equal:(ORInt(^)())fun src:(NSArray*)vars
{
   self = [super initWith:engine];
   _x = x;
   _fun = [fun copy];
   _src = [vars retain];
   return self;
}
-(void)dealloc
{
   [_src release];
   [_fun release];
   [super dealloc];
}
-(void)define
{
   for(id<LSVar> s in _src)
      [self addTrigger:[s addListener:self]];
   [_x addDefiner:self];
}
-(void)post
{
   [_x setValue:_fun()];
}
-(void)execute
{
   [_x setValue:_fun()];
}
-(id<NSFastEnumeration>)outbound
{
   return [NSSet setWithObject:_x];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<LSInv(%p) : %d,%@> defines %@ from %@",self,_name,_rank,_x,_src];
   return buf;
}
@end

@implementation LSSum
-(id)init:(id<LSEngine>)engine sum:(id<LSIntVar>)x array:(id<LSIntVarArray>)terms
{
   self = [super initWith:engine];
   _sum = x;
   _terms = terms;
   for(id<LSIntVar> t in terms) {
      assert(t != nil && [t conformsToProtocol:@protocol(LSIntVar)]);
   }
   _old = [ORFactory intArray:engine range:_terms.range value:0];
   return self;
}
-(void)define
{
   for(ORInt i = _terms.range.low; i <= _terms.range.up;i++)
      [self addTrigger:[_terms[i] addListener:self with:^{
         ORInt nv    = [_terms[i] value];
         ORInt delta = nv -  [_old at:i];
         [_sum setValue: [_sum value] + delta];
         [_old set:nv at:i];
      }]];
   [_sum addDefiner:self];
}
-(void)post
{
   ORInt ttl = 0;
   for(ORInt i = _terms.range.low; i <= _terms.range.up;i++) {
      ORInt term = [_terms[i] value];
      [_old set:term at:i];
      ttl += term;
   }
   [_sum setValue:ttl];
}
-(id<NSFastEnumeration>)outbound
{
   return [NSSet setWithObject:_sum];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<LSSum(%p) : %d,%@> : %@ == sum(%@)",self,_name,_rank,_sum,_terms];
   return buf;
}
@end


@implementation LSScaledSum
-(id)init:(id<LSEngine>)engine sum:(id<LSIntVar>)x coefs:(id<ORIntArray>)c array:(id<LSIntVarArray>)terms
{
   self = [super initWith:engine];
   _sum   = x;
   _coefs = c;
   _terms = terms;
   for(id<LSIntVar> t in terms) {
      assert(t != nil && [t conformsToProtocol:@protocol(LSIntVar)]);
   }
   _old = [ORFactory intArray:engine range:_terms.range value:0];
   return self;
}
-(void)define
{
   for(ORInt i = _terms.range.low; i <= _terms.range.up;i++)
      [self addTrigger:[_terms[i] addListener:self with:^{
         ORInt nv    = [_terms[i] value];
         ORInt delta = nv -  [_old at:i];
         if (delta) {
            [_sum setValue: [_sum value] + [_coefs at:i] * delta];
            [_old set:nv at:i];
         }
      }]];
   [_sum addDefiner:self];
}
-(void)post
{
   ORInt ttl = 0;
   for(ORInt i = _terms.range.low; i <= _terms.range.up;i++) {
      ORInt term = [_terms[i] value];
      [_old set:term at:i];
      ttl += [_coefs at:i] * term;
   }
   [_sum setValue:ttl];
}
-(id<NSFastEnumeration>)outbound
{
   return [NSSet setWithObject:_sum];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<LSScaledSum(%p) : %d,%@> : %@ == sum(%@,%@)",self,_name,_rank,_sum,_terms,_coefs];
   return buf;
}
@end

@implementation LSFactory (LSGlobalInvariant)
+(LSCount*)count:(id<LSEngine>)engine vars:(id<LSIntVarArray>)x card:(id<LSIntVarArray>)c
{
   LSCount* gi = [[LSCount alloc] init:engine count:x card:c];
   [engine trackMutable:gi];
   return gi;
}
+(id)inv:(LSIntVar*)x equal:(ORInt(^)())fun vars:(NSArray*)av
{
   LSInv* gi = [[LSInv alloc] init:[x engine] var:x equal:fun src:av];
   [[x engine] trackMutable:gi];
   return gi;
}
+(LSSum*)sum:(id<LSIntVar>)x over:(id<LSIntVarArray>)terms
{
   LSSum* gi = [[LSSum alloc] init:[x engine] sum:x array:terms];
   [[x engine] trackMutable:gi];
   return gi;
}
+(LSScaledSum*)sum:(id<LSIntVar>)x is:(id<ORIntArray>)c times:(id<LSIntVarArray>)terms
{
   LSScaledSum* gi = [[LSScaledSum alloc] init:[x engine] sum:x coefs:c array:terms];
   [[x engine] trackMutable:gi];
   return gi;
}

@end
