/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORFoundation.h"
#import "ORSelectorI.h"

@implementation OROPTSelect
{
   id<ORZeroOneStream> _stream;
   id<ORIntIterator>   _range;
   ORInt2Bool         _filter;
   ORInt2Float         _order;
   ORFloat         _direction;
   BOOL           _randomized;
}
-(OROPTSelect*) initOROPTSelectWithRange: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Float) order randomized: (BOOL) randomized
{
   self = [super init];
   _range = range;
   _filter = [filter copy];
   _order = [order copy];
   _stream = [ORCrFactory zeroOneStream];
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
   // This rountine is not correctly randomized.
   // bestRand as MAXFLOAT, and the test simply says: choose a new value if the
   // random number is smaller than the last one selected. How does that guarantee equi-probable
   // choices? If the first values draws a small random number, it is far more likely to stay than, say the 10th
   // value. Similarly, if we draw a very large value, that first selection is very likely to be
   // pushed aside.
   /*
   float bestFound = MAXFLOAT;
   float bestRand = MAXFLOAT;
   ORInt indexFound = MAXINT;
   id<IntEnumerator> ite = [_range enumerator];
   while ([ite more]) {
      ORInt i = [ite next];
      if (_filter(i)) {
         float val = _direction * (_order ? _order(i) : 0.0);
         if (val < bestFound) {
            bestFound = val;
            indexFound = i;
            bestRand = [_stream next];
         }
         else if (_randomized && val == bestFound) {
            float r = [_stream next];
            if (r < bestRand) {
               indexFound = i;
               bestRand = r;
            }
         }
      }
   }
   return indexFound;*/
   float bestFound = MAXFLOAT;
   ORInt indexFound = MAXINT;
   ORInt nbSeen     = 0;
   ORInt maxSee     = 2;
   ORInt* seen = malloc(sizeof(ORInt)*maxSee);
   id<IntEnumerator> ite = [_range enumerator];
   while ([ite more]) {
      ORInt i = [ite next];
      if (_filter(i)) {
         float val = _direction * (_order ? _order(i) : 0.0);
         if (val < bestFound) {
            bestFound = val;
            seen[0]  = i;
            nbSeen   = 1;
         }
         else if (_randomized && val == bestFound) {
            if (nbSeen >= maxSee) {
               seen = realloc(seen, sizeof(ORInt)*maxSee*2);
               maxSee <<= 1;
            }
            seen[nbSeen++] = i;
         }
      }
   }
   ORFloat r = [_stream next];
   double w = 1.0L/nbSeen;
   indexFound = seen[(ORInt)floor(r/w)];
   free(seen);
   return indexFound;
}

@end

@implementation ORSelectI
{
   OROPTSelect* _select;
}
-(id<ORSelect>) initORSelectI: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Float) order randomized: (BOOL) randomized
{
   self = [super init];
   _select = [[OROPTSelect alloc] initOROPTSelectWithRange:range suchThat: filter orderedBy:order randomized: randomized];
   return self;
}
-(void) dealloc
{
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



