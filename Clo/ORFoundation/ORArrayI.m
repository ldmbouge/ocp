/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORTypes.h"
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
   _range = (ORRange){_low,_up};
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
   _range = (ORRange){_low,_up};
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
   _range = range;
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
   _range = range;
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
   _range = (ORRange){_low,_up};
   _array = malloc(_nb * sizeof(ORInt));
   int k = 0;
   for (ORInt i=r1.low ; i <= r1.up; i++) 
      for (ORInt j=r2.low ; j <= r2.up; j++)         
         _array[k++] = clo(i,j);
   return self;
}
-(ORRange) range
{
   return _range;
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
-(id<ORExpr>)elt:(id<ORExpr>)idx
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
   _range = range;
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
      @throw [[ORExecutionError alloc] initORExecutionError: "Index out of range in ORVarArrayElement"];
   return _array[value];
}
-(void) set: (id) x at: (ORInt) value
{
   if (value < _low || value > _up)
      @throw [[ORExecutionError alloc] initORExecutionError: "Index out of range in ORVarArrayElement"];
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
-(ORRange) range
{
   return _range;
}
-(NSString*)description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendString:@"["];
   for(ORInt i=_low;i<=_up;i++) {
      [rv appendFormat:@"%d:",i];
      if (_array[i]!=nil)
         [rv appendString:[_array[i] description]];
      else [rv appendString:@"nil"];
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

// Matrix ------------------------------------------------------------------


@implementation ORIdMatrixI

-(ORIdMatrixI*) initORIdMatrix:(id<ORTracker>)tracker arity:(ORInt)ar ranges:(ORRange*)rs;
{
   self = [super init];
   _tracker = tracker;
   _arity = ar;
   _range = malloc(sizeof(ORRange)*_arity);
   _low = malloc(sizeof(ORInt) * _arity);
   _up = malloc(sizeof(ORInt) * _arity);
   _size = malloc(sizeof(ORInt) * _arity);
   _i = malloc(sizeof(ORRange) * _arity);
   _nb = 1;
   for(ORInt k=0;k < _arity;k++) {
      _range[k] = rs[k];
      _low[k] = rs[k].low;
      _up[k] = rs[k].up;
      _size[k] = rs[k].up - rs[k].low + 1;
      _nb *= _size[k];
   }
   _flat = malloc(sizeof(id)*_nb);
   return self;
}
-(ORIdMatrixI*) initORIdMatrix:(id<ORTracker>) tracker range: (ORRange) r0 : (ORRange) r1 : (ORRange) r2
{
   return self = [self initORIdMatrix: tracker arity:3 ranges:(ORRange[]){r0,r1,r2}];
}

-(ORIdMatrixI*) initORIdMatrix:(id<ORTracker>) tracker range: (ORRange) r0 : (ORRange) r1
{
   return self = [self initORIdMatrix: tracker arity:2 ranges:(ORRange[]){r0,r1}];
}

-(void) dealloc
{
   //   NSLog(@"ORIdMatrix %p dealloc called...\n",self);
   free(_range);
   free(_low);
   free(_up);
   free(_size);
   free(_i);
   free(_flat);
   [super dealloc];
}
-(ORInt) arity
{
   return _arity;
}
-(ORInt) index
{
   for(ORInt k = 0; k < _arity; k++)
      if (_i[k] < _low[k] || _i[k] > _up[k])
         @throw [[ORExecutionError alloc] initORExecutionError: "Wrong index in ORIntVarMatrix"];
   int idx = _i[0] - _low[0];
   for(ORInt k = 1; k < _arity; k++)
      idx = idx * _size[k] + (_i[k] - _low[k]);
   return idx;
}
-(ORRange) range: (ORInt) i
{
   if (i < 0 || i >= _arity)
      @throw [[ORExecutionError alloc] initORExecutionError: "Wrong index in ORIntVarMatrix"];
   return _range[i];
}
-(id) flat:(ORInt)i
{
   return _flat[i];
}
-(id) at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2
{
   if (_arity != 3)
      @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in ORIntVarMatrix"];
   _i[0] = i0;
   _i[1] = i1;
   _i[2] = i2;
   return _flat[[self index]];
}
-(id) at: (ORInt) i0 : (ORInt) i1
{
   if (_arity != 2)
      @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in ORIntVarMatrix"];
   _i[0] = i0;
   _i[1] = i1;
   return _flat[[self index]];
}
-(void) set: (id) x at: (ORInt) i0 : (ORInt) i1
{
   if (_arity != 2)
      @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in ORIntVarMatrix"];
   _i[0] = i0;
   _i[1] = i1;
   _flat[[self index]] = x;
}
-(void) set: (id) x at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2
{
   if (_arity != 3)
      @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in ORIntVarMatrix"];
   _i[0] = i0;
   _i[1] = i1;
   _i[2] = i2;
   _flat[[self index]] = x;
}

-(NSUInteger)count
{
   return _nb;
}
-(void) descriptionAux: (ORInt) i string: (NSMutableString*) rv
{
   if (i == _arity) {
      [rv appendString:@"["];
      for(ORInt k = 0; k < _arity; k++)
         [rv appendFormat:@"%d%c",_i[k], k < _arity-1 ? ',' : ']'];
      [rv appendString:@" ="];
      [rv appendFormat:@"%@ \n",[_flat[[self index]] description]];
   }
   else {
      for(ORInt k = _low[i]; k <= _up[i]; k++) {
         _i[i] = k;
         [self descriptionAux: i+1 string: rv];
      }
   }
}
-(NSString*)description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [self descriptionAux: 0 string: rv];
   return rv;
}
-(id<ORTracker>) tracker
{
   return _tracker;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_tracker];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_arity];
   for(ORInt i = 0; i < _arity; i++) {
      [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_range[i].low];
      [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_range[i].up];
   }
   for(ORInt i=0 ; i < _nb ;i++)
      [aCoder encodeObject:_flat[i]];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _tracker = [[aDecoder decodeObject] retain];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_arity];
   _range = malloc(sizeof(ORRange) * _arity);
   _low = malloc(sizeof(ORInt) * _arity);
   _up = malloc(sizeof(ORInt) * _arity);
   _size = malloc(sizeof(ORInt) * _arity);
   _i = malloc(sizeof(ORRange) * _arity);
   _nb = 1;
   for(ORInt i = 0; i < _arity; i++) {
      [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_low[i]];
      [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_up[i]];
      _range[i] = (ORRange){_low[i],_up[i]};
      _size[i] = (_up[i] - _low[i] + 1);
      _nb *= _size[i];
   }
   _flat = malloc(sizeof(id) * _nb);
   for(ORInt i=0 ; i < _nb ;i++)
      _flat[i] = [aDecoder decodeObject];
   return self;
}
@end

