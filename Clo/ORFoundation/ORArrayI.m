/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORArrayI.h"
#import "ORError.h"
#import "ORExprI.h"

/**********************************************************************************************/
/*                          ORIntArray                                                        */
/**********************************************************************************************/

@implementation ORIntArrayI 
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker size: (ORInt) nb value: (ORInt) value
{
   self = [super init];
   _tracker = tracker;
   _array = malloc(nb * sizeof(ORInt));
   _low = 0;
   _up = nb-1;
   _nb = nb;
   for (ORInt i=0 ; i < _nb; i++) 
      _array[i] = value;
   return self;
}
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker size: (ORInt) nb with:(ORInt(^)(ORInt)) clo
{
   self = [super init];
   _tracker = tracker;
   _array = malloc(nb * sizeof(ORInt));
   _low = 0;
   _up = nb-1;
   _nb = nb;
   for (ORInt i=0 ; i < _nb; i++) 
      _array[i] = clo(i);
   return self;
}
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker range: (ORRange) range value: (ORInt) value
{
   self = [super init];
   _tracker = tracker;
   _low = range.low;
   _up = range.up;
   _nb = _up - _low + 1;
   _array = malloc(_nb * sizeof(ORInt));
   _array -= _low;
   for (ORInt i=_low ; i <= _up; i++) 
      _array[i] = value;
   return self;
}
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker range: (ORRange) range with:(ORInt(^)(ORInt)) clo
{
   self = [super init];
   _tracker = tracker;
   _low = range.low;
   _up = range.up;
   _nb = _up - _low + 1;
   _array = malloc(_nb * sizeof(ORInt));
   _array -= _low;
   for (ORInt i=_low ; i <= _up; i++) 
      _array[i] = clo(i);
   return self;
}
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker range: (ORRange) r1 range: (ORRange) r2 with:(ORInt(^)(ORInt,ORInt)) clo
{
   self = [super init];
   _tracker = tracker;
   _nb = (r1.up - r1.low + 1) * (r2.up - r2.low + 1);
   _low = 0;
   _up = _nb-1;
   _array = malloc(_nb * sizeof(ORInt));
   int k = 0;
   for (ORInt i=r1.low ; i <= r1.up; i++) 
      for (ORInt j=r2.low ; j <= r2.up; j++)         
         _array[k++] = clo(i,j);
   return self;
}

-(void) dealloc
{
   _array += _low;
   free(_array);
   [super dealloc];
}

-(ORInt) at: (ORInt) value
{
   if (value < _low || value > _up)
      @throw [[ORExecutionError alloc] initORExecutionError: "Index out of range in ORIntArrayElement"];
   return _array[value];
}
-(void) set: (ORInt) value at:(ORInt)idx
{
   if (idx < _low || idx > _up)
      @throw [[ORExecutionError alloc] initORExecutionError: "Index out of range in ORIntArrayElement"];
   _array[idx] = value;
}
-(id<ORExpr>)index:(id<ORExpr>)idx
{
   return [[ORExprCstSubI alloc] initORExprCstSubI:self index:idx];
}
-(ORInt) low
{
   return _low;
}
-(ORInt) up
{
   return _up;
}
-(NSUInteger)count
{
   return _nb;
}
-(NSString*)description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendString:@"["];
   for(ORInt i=_low;i<=_up;i++) {
      [rv appendFormat:@"%d:%d",i,_array[i]];
      if (i < _up)
         [rv appendString:@","];
   }
   [rv appendString:@"]"];
   return rv;   
}
-(id<ORTracker>) tracker
{
   return _tracker;
}

-(ORInt)virtualOffset
{
   return [_tracker virtualOffset:self];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_tracker];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_low];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_up];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_nb];
   for(ORInt i=_low;i<=_up;i++)
      [aCoder encodeValueOfObjCType:@encode(ORInt) at:_array+i];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _tracker = [[aDecoder decodeObject] retain];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_low];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_up];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_nb];
   _array =  malloc(sizeof(ORInt)*_nb);
   _array -= _low;
   for(ORInt i=_low;i<=_up;i++)
      [aDecoder decodeValueOfObjCType:@encode(ORInt) at:_array+i];
   return self;
}
@end

// ------------------------------------------------------------------------------------------

@implementation ORIdArrayI
-(ORIdArrayI*)initORIdArray: (id<ORTracker>) tracker range:(ORRange)range
{
   self = [super init];
   _tracker = tracker;
   _low = range.low;
   _up  = range.up;
   _nb  = _up - _low + 1;
   _array = malloc(_nb * sizeof(id));
   memset(_array,0,sizeof(id)*_nb);
   _array -= _low;
   return self;
}
-(void)dealloc
{
   _array += _low;
   free(_array);
   [super dealloc];
}
-(id) at: (ORInt) value
{
   if (value < _low || value > _up)
      @throw [[ORExecutionError alloc] initORExecutionError: "Index out of range in CPVarArrayElement"];
   return _array[value];
}
-(void) set: (id) x at: (ORInt) value
{
   if (value < _low || value > _up)
      @throw [[ORExecutionError alloc] initORExecutionError: "Index out of range in CPVarArrayElement"];
   _array[value] = x;
}
-(ORInt) low
{
   return _low;
}
-(ORInt) up 
{
   return _up;
}
-(NSUInteger)count
{
   return _nb;
}
-(NSString*)description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendString:@"["];
   for(ORInt i=_low;i<=_up;i++) {
      [rv appendFormat:@"%d:",i];
      [rv appendString:[_array[i] description]];
      if (i < _up)
         [rv appendString:@","];
   }
   [rv appendString:@"]"];
   return rv;      
}
-(id<ORTracker>) tracker
{
   return _tracker;
}
-(ORInt) virtualOffset
{
   return [_tracker virtualOffset:self];
}

-(id)objectAtIndexedSubscript:(NSUInteger)key
{
   return _array[key];
}
-(void)setObject:(id)newValue atIndexedSubscript:(NSUInteger)key
{
   _array[key] = newValue;
}
-(id<ORExpr>)index:(id<ORExpr>)idx
{
   assert(NO); // [ldm] must fix or ORExprVarSubI
   //return [[ORExprVarSubI alloc] initORExprVarSubI:self index:idx];
   return nil;
}
-(void)encodeWithCoder:(NSCoder*) aCoder
{
   [aCoder encodeObject:_tracker];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_low];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_up];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_nb];
   for(ORInt i=_low;i<=_up;i++)
      [aCoder encodeObject:_array[i]];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _tracker = [[aDecoder decodeObject] retain];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_low];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_up];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_nb];
   _array =  malloc(sizeof(id)*_nb);
   _array -= _low;
   for(ORInt i=_low;i<=_up;i++)
      _array[i] = [aDecoder decodeObject];
   return self;   
}
@end


