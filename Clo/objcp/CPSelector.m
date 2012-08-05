/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "ORCrFactory.h"
#import "CPSelector.h"
#import "ORTrail.h"
#import "CPSolverI.h"
#if !defined(__APPLE__)
#import <values.h>
#endif

@implementation OPTSelect

-(OPTSelect*) initOPTSelectWithRange: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter orderedBy: (CPInt2Int) order
{
    self = [super init];
    _range = range;
    _filter = [filter copy];
    _order = [order copy];
    _stream = [ORCrFactory randomStream];
    _direction = 1;
    return self;
}

-(void) dealloc
{
    [_filter release];
    [_order release];
    [_stream release];
    [super dealloc];
}

-(CPInt) min 
{
    _direction = 1;
    return [self choose];
}
-(CPInt) max
{
    _direction = -1;
    return [self choose];
}
-(CPInt) any
{
    _direction = 0;
    return [self choose];
}
-(CPInt) choose
{
   float bestFound = MAXFLOAT;
   float bestRand = MAXFLOAT;
   ORInt indexFound = MAXINT;
   id<IntEnumerator> ite = [_range enumerator];
   while ([ite more]) {
      ORInt i = [ite next];
      if (!_filter(i)) {
         float val = _direction * _order(i);
         if (val < bestFound) {
            bestFound = val;
            indexFound = i;
            bestRand = [_stream next];
         }
         /*
          else if (val == bestFound) {
          float r = [_stream next];
          if (r < bestRand) {
          indexFound = i;
          bestRand = r;
          }
          }
          */
      }
   }
   return indexFound;
}

@end

@implementation CPSelect
-(CPSelect*) initCPSelect: (CPSolverI*) cp withRange: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter orderedBy: (CPInt2Int) order
{
    self = [super init];
    _select = [[OPTSelect alloc] initOPTSelectWithRange:range suchThat: filter orderedBy:order];
    [[cp trail] trailClosure: ^() { [self release]; }];
    return self;
}

-(void) dealloc
{
    [_select release];
    [super dealloc];
}

-(CPInt) min 
{
    return [_select min];
}
-(CPInt) max
{
    return [_select max];
}
-(CPInt) any
{
    return [_select any];
}
@end



@implementation CPSelectMinRandomized

-(CPSelectMinRandomized*) initWithRange: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter orderedBy: (CPInt2Int) order
{
   self = [super init];
   _range = range;
   _filter = [filter copy];
   _order = [order copy];
   _stream = [ORCrFactory randomStream];
   return self;
}

-(void) dealloc
{
  [_filter release];
  [_order release];
  [_stream release];
  [super dealloc];
}

-(CPInt) choose
{
   float bestFound = MAXFLOAT;
   float bestRand = MAXFLOAT;
   CPInt indexFound = MAXINT;
   id<IntEnumerator> ite = [_range enumerator];
   while ([ite more]) {
      ORInt i = [ite next];
      if (!_filter(i)) {
         float val = _order(i);
         if (val < bestFound) {
            bestFound = val;
            indexFound = i;
            bestRand = [_stream next];
         }
         else if (val == bestFound) {
            float r = [_stream next];
            if (r < bestRand) {
               indexFound = i;
               bestRand = r;
            }
         }
      }
   }
   return indexFound;
}

@end


@implementation CPSelectMax

-(CPSelectMax*) initSelectMax:(CPSolverI*)cp range: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter orderedBy: (CPInt2Int) order
{
   self = [super init];
   _range = range;
   _filter = [filter copy];
   _order = [order copy];
   [[cp trail] trailRelease:self];
   return self;
}

-(void) dealloc
{
  [_filter release];
  [_order release];
  [super dealloc];
}
-(CPInt) choose
{
   float bestFound = -MAXFLOAT;
   CPInt indexFound = MAXINT;
   id<IntEnumerator> ite = [_range enumerator];
   while ([ite more]) {
      ORInt i = [ite next];
      if (_filter(i)) {
         float val = _order(i);
         if (val > bestFound) {
            bestFound = val;
            indexFound = i;
         }
      }
   }
   return indexFound;
}
@end
