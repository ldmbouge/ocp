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
-(void)prioritize:(PStore*)p
{
   if ([p finalNotice:self]) {
      if ([p lastTime:self]) {
         
      } else _rank = [p maxWithRank:_rank];
   }
}
-(void)define
{
   for(ORInt i=_src.low;i <= _src.up;i++)
      [self addTrigger:[_src[i] addListener:self term:i]];
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
}

@end
