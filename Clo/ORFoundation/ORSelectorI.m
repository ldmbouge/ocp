/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORUtilities/ORPQueue.h>
#import "ORDataI.h"
#import "ORSelectorI.h"
#import <math.h>
#if defined(__linux__)
#import <values.h>
#endif

@implementation OROPTSelect
{
   id<ORRandomStream> _stream;
   id<ORIntIterable>   _range;
   ORInt2Bool         _filter;
   ORInt2Float         _order;
   ORDouble         _direction;
   BOOL           _randomized;
}
-(OROPTSelect*) initOROPTSelectWithRange: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Float) order randomized: (ORBool) randomized
{
   self = [super init];
   _range = range;
   _filter = [filter copy];
   _order = [order copy];
   _stream = [[ORRandomStreamI alloc] init];
   _direction = 1;
   _randomized = randomized;
   return self;
}

-(void) dealloc
{
   [_filter release];
   [_order release];
   [_stream release];
   [super dealloc];
}

-(ORInt) min
{
   _direction = 1.0;
   return [self choose];
}
-(ORInt) max
{
   _direction = -1.0;
   return [self choose];
}
-(ORInt) any
{
   _direction = 0.0;
   return [self choose];
}
-(ORInt) choose
{
   __block float bestFound = MAXFLOAT;
   __block ORLong bestRand = 0x7fffffffffffffff;
   __block ORInt indexFound = MAXINT;
   [_range enumerateWithBlock:^(ORInt i) {
       if ((id)_filter==nil || _filter(i)) {
         ORDouble val = _direction * (_order ? _order(i) : 0.0);
         if (val < bestFound) {
            bestFound = val;
            indexFound = i;
            bestRand = [_stream next];
         }
         else if (_randomized && val == bestFound) {
            ORLong r = [_stream next];
            if (r < bestRand) {
               indexFound = i;
               bestRand = r;
            }
         }
      }
 
   }];
   return indexFound;
}
@end

@implementation ORSelectI
{
   OROPTSelect* _select;
}
-(id<ORSelect>) initORSelectI: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Float) order randomized: (ORBool) randomized
{
   self = [super init];
   _select = [[OROPTSelect alloc] initOROPTSelectWithRange:range suchThat: filter orderedBy:order randomized: randomized];
   return self;
}
-(void) dealloc
{
   //NSLog(@"Deallocating ORSelectI");
   [_select release];
   [super dealloc];
}

-(ORInt) min
{
   return [_select min];
}
-(ORInt) max
{
   return [_select max];
}
-(ORInt) any
{
   return [_select any];
}
@end

@implementation ORMinSelector {
   ORClosure _bestBlock;
   ORDouble   _bestValue;
   ORLong     _bestRand;
   ORBool    _randomized;
   id<ORRandomStream> _stream;
}
-(id)init
{
   self = [super init];
   _bestRand = 0x7fffffffffffffff;
   _bestValue = MAXFLOAT;
   _bestBlock = nil;
   _randomized = YES;
   _stream = [[ORRandomStreamI alloc] init];
   return self;
}
-(void)dealloc
{
   [_bestBlock release];
   [_stream release];
   [super dealloc];
}
-(void)reset
{
   [_bestBlock release];
   _bestRand = 0x7fffffffffffffff;
   _bestValue = MAXFLOAT;
   _bestBlock = nil;
}
-(void)commit
{
   if (_bestBlock) {
      _bestBlock();
      [self reset];
   }
}
-(void)neighbor:(ORDouble)v do:(ORClosure)block
{
   if (v < _bestValue) {
      _bestValue = v;
      _bestRand  = [_stream next];
      [_bestBlock release];
      _bestBlock = [block copy];
   }
   else if (_randomized && v == _bestValue) {
      ORLong r = [_stream next];
      if (r < _bestRand) {
         _bestRand = r;
         [_bestBlock release];
         _bestBlock = [block copy];
      }
   }
}
@end
