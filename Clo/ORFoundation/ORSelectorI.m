/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORUtilities/ORPQueue.h>
#import <ORFoundation/ORDataI.h>
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
   ORInt2Double         _order;
   ORInt2Double       _tieBreak;
   ORDouble         _direction;
   BOOL           _randomized;
}
-(OROPTSelect*) initOROPTSelectWithRange: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Double) order randomized: (ORBool) randomized
{
   self = [super init];
   _range = range;
   _filter = [filter copy];
   _order = [order copy];
   _tieBreak = nil;
   _stream = [[ORRandomStreamI alloc] init];
   _direction = 1;
   _randomized = randomized;
   return self;
}

-(OROPTSelect*) initOROPTSelectWithRange: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Double) order tieBreak: (ORInt2Double) tb
{
   self = [self initOROPTSelectWithRange:range suchThat:filter orderedBy:order randomized:NO];
   _tieBreak = [tb copy];
   return self;
}
-(void) setTieBreak :(ORInt2Double) tb
{
   if((id)_tieBreak!=nil) [_tieBreak release];
   _tieBreak = [tb copy];
}
-(void) dealloc
{
   [_filter release];
   [_order release];
   if((id)_tieBreak!=nil) [_tieBreak release];
   [_stream release];
   [super dealloc];
}

-(ORSelectorResult) min
{
   _direction = 1.0;
   return [self choose];
}
-(ORSelectorResult) max
{
   _direction = -1.0;
   return [self choose];
}
-(ORSelectorResult) any
{
   _direction = 0.0;
   return [self choose];
}
-(ORSelectorResult) choose
{
   __block ORDouble bestFound = MAXDBL;
   __block ORLong bestRand = 0x7fffffffffffffff;
   __block ORInt found = 0;
   __block ORInt indexFound = MAXINT;
   __block ORDouble tbValue = MAXDBL;
   [_range enumerateWithBlock:^(ORInt i) {
       if ((id)_filter==nil || _filter(i)) {
         ORDouble val = _direction * (_order ? _order(i) : 0.0);
         if (val < bestFound || !found) {
            bestFound = val;
            indexFound = i;
            found = 1;
            bestRand = [_stream next];
            if(_tieBreak != nil)
               tbValue = _tieBreak(i);
               
         }
         else if (_randomized && val == bestFound) {
            ORLong r = [_stream next];
            if (r < bestRand) {
               indexFound = i;
               bestRand = r;
            }
         }
         else if ((id)_tieBreak!=nil && val == bestFound) {
            ORDouble tmp = _tieBreak(i);
            if(tmp > tbValue){
               indexFound = i;
               tbValue = tmp;
               
            }
         }
      }
 
   }];
    return (ORSelectorResult){found,indexFound};
}
@end

@implementation ORSelectI
{
   OROPTSelect* _select;
}
-(id<ORSelect>) initORSelectI: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Double) order randomized: (ORBool) randomized
{
   self = [super init];
   _select = [[OROPTSelect alloc] initOROPTSelectWithRange:range suchThat: filter orderedBy:order randomized: randomized];
   return self;
}
-(id<ORSelect>) initORSelectI: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Double) order tiebreak: (ORInt2Double) tb
{
   self = [super init];
   _select = [[OROPTSelect alloc] initOROPTSelectWithRange:range suchThat: filter orderedBy:order tieBreak:tb];
   return self;
}
-(void) setTieBreak :(ORInt2Double) tb
{
   [_select setTieBreak:tb];
}
-(void) dealloc
{
   //NSLog(@"Deallocating ORSelectI");
   [_select release];
   [super dealloc];
}

-(ORSelectorResult) min
{
   return [_select min];
}
-(ORSelectorResult) max
{
   return [_select max];
}
-(ORSelectorResult) any
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
   _bestValue = MAXDBL;
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
   _bestValue = MAXDBL;
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
