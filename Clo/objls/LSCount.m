/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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
      [self addTrigger:[_src[i] addListener:self term:i]];
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
-(void)pull:(ORInt)k
{
   LSIntVar* vk = _src[k];
   [_cnt[[_old at:k]] decr];
   [_cnt[[vk value]] incr];
   [_old set:vk.value at:k];
}
-(void)execute
{}
-(id<NSFastEnumeration>)outbound
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

@implementation LSGElement
-(id)init:(id<LSEngine>)engine count:(id<LSIntVarArray>)x card:(id<LSIntVarArray>)c result:(id<LSIntVarArray>)y
{
   self = [super initWith:engine];
   _x = x;
   _c = c;
   _y = y;
   return self;
}
-(void)define
{
   for(ORInt i=_x.low;i <= _x.up;i++)
      [self addTrigger:[_x[i] addListener:self term:i with:^{
         [_y[i] setValue: _c[_x[i].value].value];
      }]];
   for(ORInt i=_c.low;i <= _c.up;i++)
      [self addTrigger:[_c[i] addListener:self term:i with:^{
         ORInt k = _x.low;
         for(id<LSIntVar> xk in _x) {
            if (xk.value == i)
               [_y[k] setValue:_c[i].value];
            ++k;
         }
         //NSLog(@"wakeup because of c[i]");
      }]];
   for(ORInt i=_y.low;i <= _y.up;i++)
      [_y[i] addDefiner:self];
}
-(void)execute
{}
-(void)post
{
   for(ORInt i=_x.low;i <= _x.up;i++)
      [_y[i] setValue:_c[_x[i].value].value];
}
-(id<NSFastEnumeration>)outbound
{
   return _y;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<LSGElement(%p) : %d,%@>",self,_name,_rank];
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
      [self addTrigger:[s addListener:self term:-1]];
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
   [buf appendFormat:@"<LSInv(%p) : %d,%@>",self,_name,_rank];
   return buf;
}
@end

@implementation LSSum
-(id)init:(id<LSEngine>)engine sum:(id<LSIntVar>)x array:(id<LSIntVarArray>)terms
{
   self = [super initWith:engine];
   _sum = x;
   _terms = terms;
   _old = [ORFactory intArray:engine range:_terms.range value:0];
   return self;
}
-(void)define
{
   for(ORInt i = _terms.range.low; i <= _terms.range.up;i++)
      [self addTrigger:[_terms[i] addListener:self term:i]];
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
-(void)pull:(ORInt)k
{
   ORInt nv    = [_terms[k] value];
   ORInt delta = nv -  [_old at:k];
   [_sum setValue: [_sum value] + delta];
   [_old set:nv at:k];
}
-(id<NSFastEnumeration>)outbound
{
   return [NSSet setWithObject:_sum];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<LSSum(%p) : %d,%@>",self,_name,_rank];
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
+(LSGElement*)gelt:(id<LSEngine>)e x:(id<LSIntVarArray>)x card:(id<LSIntVarArray>)c result:(id<LSIntVarArray>)y
{
   LSGElement* gi = [[LSGElement alloc] init:e count:x card:c result:y];
   [e trackMutable:gi];
   return gi;
}
@end
