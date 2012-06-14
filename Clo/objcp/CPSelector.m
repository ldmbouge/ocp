/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/

#import "CPSelector.h"
#import "CPTrail.h"
#import "CPI.h"
#if !defined(__APPLE__)
#import <values.h>
#endif

@implementation OPTSelect

-(OPTSelect*) initOPTSelectWithRange: (CPRange) range filteredBy: (CPInt2Bool) filter orderedBy: (CPInt2Int) order
{
    self = [super init];
    _range = range;
    _filter = [filter copy];
    _order = [order copy];
    _stream = [[CPRandomStream alloc] init];
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
    CPInt low = _range.low;
    CPInt up = _range.up;
    
    float bestFound = MAXFLOAT;
    float bestRand = MAXFLOAT;
    CPInt indexFound = low - 1;
    
    for(CPInt i = low; i <= up; i++) {
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
-(CPSelect*) initCPSelect: (CoreCPI*) cp withRange: (CPRange) range filteredBy: (CPInt2Bool) filter orderedBy: (CPInt2Int) order
{
    self = [super init];
    _select = [[OPTSelect alloc] initOPTSelectWithRange:range filteredBy: filter orderedBy:order];
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

-(CPSelectMinRandomized*) initWithRange: (CPRange) range filteredBy: (CPInt2Bool) filter orderedBy: (CPInt2Int) order
{
  self = [super init];
  _range = range;
  _filter = [filter copy];
  _order = [order copy];
  _stream = [[CPRandomStream alloc] init];
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
  CPInt low = _range.low;
  CPInt up = _range.up;

  float bestFound = MAXFLOAT;
  float bestRand = MAXFLOAT;
  CPInt indexFound = low - 1;

  for(CPInt i = low; i <= up; i++) {
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

-(CPSelectMax*) initSelectMin:(CoreCPI*)cp range: (CPRange) range filteredBy: (CPInt2Bool) filter orderedBy: (CPInt2Int) order
{
   self = [super init];
   _range = range;
   _used = malloc(sizeof(bool)*(range.up - range.low + 1));
   memset(_used,0,sizeof(bool)*(range.up - range.low + 1));
   _filter = [filter copy];
   _order = [order copy];
   [[cp trail] trailClosure: ^() { [self release]; }];
   return self;
}

-(void) dealloc
{
   free(_used);
  [_filter release];
  [_order release];
  [super dealloc];
}
-(CPInt) min 
{
   return _range.low;
}
-(CPInt) max
{
   return _range.up;
}
-(CPInt) choose
{
   CPInt low = _range.low;
   CPInt up  = _range.up;   
   float bestFound = -MAXFLOAT;
   CPInt indexFound = low - 1;   
   for(CPInt i = low; i <= up; i++) {
      if (!_filter(i) && !_used[i-low]) {
         float val = _order(i);
         if (val > bestFound) {
            bestFound = val;
            indexFound = i;
         }
      }
   }
   _used[indexFound - low] = YES;
   return indexFound;
}
@end
