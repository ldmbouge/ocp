/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORUtilities/ORTypes.h>
#import <ORFoundation/ORError.h>
#import <ORFoundation/ORExprI.h>
#import <ORFoundation/ORFactory.h>
#import "ORArrayI.h"

/**********************************************************************************************/
/*                          ORIntArray                                                        */
/**********************************************************************************************/

@implementation ORIntArrayI
{
   id<ORTracker> _tracker;
   ORInt*          _array;
   ORInt             _low;
   ORInt              _up;
   ORInt              _nb;
   id<ORIntRange>  _range;
}

-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker size: (ORInt) nb value: (ORInt) value
{
   self = [super init];
   _tracker = tracker;
   _array = malloc(nb * sizeof(ORInt));
   _low = 0;
   _up = nb-1;
   _nb = nb;
   _range = [ORFactory intRange: tracker low: _low up: _up];
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
   _range = [ORFactory intRange: tracker low: _low up: _up];  
   for (ORInt i=0 ; i < _nb; i++) 
      _array[i] = clo(i);
   return self;
}
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range value: (ORInt) value
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
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with:(ORInt(^)(ORInt)) clo
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
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 range: (id<ORIntRange>) r2 with:(ORInt(^)(ORInt,ORInt)) clo
{
   self = [super init];
   _tracker = tracker;
   _nb = (r1.up - r1.low + 1) * (r2.up - r2.low + 1);
   _low = 0;
   _up = _nb-1;
   _range = [ORFactory intRange: tracker low: _low up: _up];
   _array = malloc(_nb * sizeof(ORInt));
   int k = 0;
   for (ORInt i=r1.low ; i <= r1.up; i++) 
      for (ORInt j=r2.low ; j <= r2.up; j++)         
         _array[k++] = clo(i,j);
   return self;
}
-(id<ORIntRange>) range
{
   return _range;
}
-(void) dealloc
{
   _array += _low;
   free(_array);
   [super dealloc];
}
-(int*)base
{
   return _array;
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
-(id)objectAtIndexedSubscript: (NSInteger) key
{
   if (key < _low || key > _up)
      @throw [[ORExecutionError alloc] initORExecutionError: "Index out of range in ORIntArrayElement"];
   return [NSNumber numberWithInt:_array[key]];
}
-(void)setObject: (NSNumber*) newValue atIndexedSubscript: (NSInteger) idx
{
   if (idx < _low || idx > _up)
      @throw [[ORExecutionError alloc] initORExecutionError: "Index out of range in ORIntArrayElement"];
   _array[idx] = [newValue intValue];
}
-(void) enumerateWith: (void(^)(ORInt obj,int idx)) block
{
   for(ORInt i=_low;i<=_up;i++)
      block(_array[i],i);
}
-(ORInt) sumWith: (ORInt(^)(ORInt value,int idx))block {
    __block ORInt sum = 0;
    [self enumerateWith:^(ORInt obj, ORInt idx) {
        sum += block(obj, idx);
    }];
    return sum;
}
-(id<ORExpr>)elt:(id<ORExpr>)idx
{
   return [ORFactory elt: _tracker intArray: self index: idx];
}
-(ORInt) low
{
   return _low;
}
-(ORInt) up
{
   return _up;
}
-(ORInt) max {
    ORInt v = _array[_low];
    for(int i = _low+1; i <= _up; i++)
        if(_array[i] > v) v = _array[i];
    return v;
}
-(ORInt) min {
    ORInt v = _array[_low];
    for(int i = _low+1; i <= _up; i++)
        if(_array[i] < v) v = _array[i];
    return v;
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
//      [rv appendFormat:@"%d:%d",i,_array[i]];
      [rv appendFormat:@"%d",_array[i]];
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
-(void)visit:(ORVisitor*)v
{
   [v visitIntArray:self];
}
@end

/**********************************************************************************************/
/*                          ORDoubleArray                                                     */
/**********************************************************************************************/

@implementation ORDoubleArrayI
{
    id<ORTracker> _tracker;
    ORDouble*        _array;
    ORInt             _low;
    ORInt              _up;
    ORInt              _nb;
    id<ORIntRange>  _range;
}

-(ORDoubleArrayI*) init: (id<ORTracker>) tracker size: (ORInt) nb value: (ORDouble) value
{
    self = [super init];
    _tracker = tracker;
    _array = malloc(nb * sizeof(ORDouble));
    _low = 0;
    _up = nb-1;
    _nb = nb;
    _range = [ORFactory intRange: tracker low: _low up: _up];
    for (ORInt i=0 ; i < _nb; i++)
        _array[i] = value;
    return self;
}
-(ORDoubleArrayI*) init: (id<ORTracker>) tracker size: (ORInt) nb with:(ORDouble(^)(ORInt)) clo
{
    self = [super init];
    _tracker = tracker;
    _array = malloc(nb * sizeof(ORDouble));
    _low = 0;
    _up = nb-1;
    _nb = nb;
    _range = [ORFactory intRange: tracker low: _low up: _up];
    for (ORInt i=0 ; i < _nb; i++)
        _array[i] = clo(i);
    return self;
}
-(ORDoubleArrayI*) init: (id<ORTracker>) tracker range: (id<ORIntRange>) range value: (ORDouble) value
{
    self = [super init];
    _tracker = tracker;
    _low = range.low;
    _up = range.up;
    _nb = _up - _low + 1;
    _range = range;
    _array = malloc(_nb * sizeof(ORDouble));
    _array -= _low;
    for (ORInt i=_low ; i <= _up; i++)
        _array[i] = value;
    return self;
}
-(ORDoubleArrayI*) init: (id<ORTracker>) tracker range: (id<ORIntRange>) range with:(ORDouble(^)(ORInt)) clo
{
    self = [super init];
    _tracker = tracker;
    _low = range.low;
    _up = range.up;
    _nb = _up - _low + 1;
    _range = range;
    _array = malloc(_nb * sizeof(ORDouble));
    _array -= _low;
    for (ORInt i=_low ; i <= _up; i++)
        _array[i] = clo(i);
    return self;
}
-(ORDoubleArrayI*) init: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 range: (id<ORIntRange>) r2 with:(ORDouble(^)(ORInt,ORInt)) clo
{
    self = [super init];
    _tracker = tracker;
    _nb = (r1.up - r1.low + 1) * (r2.up - r2.low + 1);
    _low = 0;
    _up = _nb-1;
    _range = [ORFactory intRange: tracker low: _low up: _up];
    _array = malloc(_nb * sizeof(ORDouble));
    int k = 0;
    for (ORInt i=r1.low ; i <= r1.up; i++)
        for (ORInt j=r2.low ; j <= r2.up; j++)
            _array[k++] = clo(i,j);
    return self;
}
-(id<ORIntRange>) range
{
    return _range;
}
-(void) dealloc
{
    _array += _low;
    free(_array);
    [super dealloc];
}

-(ORDouble) at: (ORInt) value
{
    if (value < _low || value > _up)
        @throw [[ORExecutionError alloc] initORExecutionError: "Index out of range in ORDoubleArrayElement"];
    return _array[value];
}
-(void) set: (ORDouble) value at:(ORInt)idx
{
    if (idx < _low || idx > _up)
        @throw [[ORExecutionError alloc] initORExecutionError: "Index out of range in ORDoubleArrayElement"];
    _array[idx] = value;
}
-(void) enumerateWith: (void(^)(ORDouble obj,int idx)) block
{
    for(ORInt i=_low;i<=_up;i++)
        block(_array[i],i);
}
-(ORFloat) sumWith: (ORFloat(^)(ORFloat value,int idx))block {
    __block ORFloat sum = 0.0;
    [self enumerateWith:^(ORDouble obj, int idx) {
        sum += block(obj, idx);
    }];
    return sum;
}
-(ORInt) low
{
    return _low;
}
-(ORInt) up
{
    return _up;
}
-(id<ORExpr>)elt:(id<ORExpr>)idx
{
   return [ORFactory elt: _tracker doubleArray: self index: idx];
}
-(ORDouble) max {
    ORDouble v = _array[_low];
    for(int i = _low+1; i <= _up; i++)
        if(_array[i] > v) v = _array[i];
    return v;
}
-(ORDouble) min {
    ORDouble v = _array[_low];
    for(int i = _low+1; i <= _up; i++)
        if(_array[i] < v) v = _array[i];
    return v;
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
        [rv appendFormat:@"%d:%f",i,_array[i]];
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
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_tracker];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_low];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_up];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_nb];
    for(ORInt i=_low;i<=_up;i++)
        [aCoder encodeValueOfObjCType:@encode(ORDouble) at:_array+i];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    _tracker = [[aDecoder decodeObject] retain];
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_low];
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_up];
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_nb];
    _array =  malloc(sizeof(ORDouble)*_nb);
    _array -= _low;
    for(ORInt i=_low;i<=_up;i++)
        [aDecoder decodeValueOfObjCType:@encode(ORDouble) at:_array+i];
    return self;
}
-(void) visit: (ORVisitor*) v
{
   [v visitDoubleArray: self];
}

@end


/**********************************************************************************************/
/*                          ORFloatArray                                                     */
/**********************************************************************************************/

@implementation ORFloatArrayI
{
    id<ORTracker> _tracker;
    ORDouble*        _array;
    ORInt             _low;
    ORInt              _up;
    ORInt              _nb;
    id<ORIntRange>  _range;
}

-(ORFloatArrayI*) init: (id<ORTracker>) tracker size: (ORInt) nb value: (ORFloat) value
{
    self = [super init];
    _tracker = tracker;
    _array = malloc(nb * sizeof(ORFloat));
    _low = 0;
    _up = nb-1;
    _nb = nb;
    _range = [ORFactory intRange: tracker low: _low up: _up];
    for (ORInt i=0 ; i < _nb; i++)
        _array[i] = value;
    return self;
}
-(ORFloatArrayI*) init: (id<ORTracker>) tracker size: (ORInt) nb with:(ORFloat(^)(ORInt)) clo
{
    self = [super init];
    _tracker = tracker;
    _array = malloc(nb * sizeof(ORFloat));
    _low = 0;
    _up = nb-1;
    _nb = nb;
    _range = [ORFactory intRange: tracker low: _low up: _up];
    for (ORInt i=0 ; i < _nb; i++)
        _array[i] = clo(i);
    return self;
}
-(ORFloatArrayI*) init: (id<ORTracker>) tracker range: (id<ORIntRange>) range value: (ORFloat) value
{
    self = [super init];
    _tracker = tracker;
    _low = range.low;
    _up = range.up;
    _nb = _up - _low + 1;
    _range = range;
    _array = malloc(_nb * sizeof(ORFloat));
    _array -= _low;
    for (ORInt i=_low ; i <= _up; i++)
        _array[i] = value;
    return self;
}
-(ORFloatArrayI*) init: (id<ORTracker>) tracker range: (id<ORIntRange>) range with:(ORFloat(^)(ORInt)) clo
{
    self = [super init];
    _tracker = tracker;
    _low = range.low;
    _up = range.up;
    _nb = _up - _low + 1;
    _range = range;
    _array = malloc(_nb * sizeof(ORFloat));
    _array -= _low;
    for (ORInt i=_low ; i <= _up; i++)
        _array[i] = clo(i);
    return self;
}
-(ORFloatArrayI*) init: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 range: (id<ORIntRange>) r2 with:(ORFloat(^)(ORInt,ORInt)) clo
{
    self = [super init];
    _tracker = tracker;
    _nb = (r1.up - r1.low + 1) * (r2.up - r2.low + 1);
    _low = 0;
    _up = _nb-1;
    _range = [ORFactory intRange: tracker low: _low up: _up];
    _array = malloc(_nb * sizeof(ORFloat));
    int k = 0;
    for (ORInt i=r1.low ; i <= r1.up; i++)
        for (ORInt j=r2.low ; j <= r2.up; j++)
            _array[k++] = clo(i,j);
    return self;
}
-(id<ORIntRange>) range
{
    return _range;
}
-(void) dealloc
{
    _array += _low;
    free(_array);
    [super dealloc];
}

-(ORFloat) at: (ORInt) value
{
    if (value < _low || value > _up)
        @throw [[ORExecutionError alloc] initORExecutionError: "Index out of range in ORFloatArrayElement"];
    return _array[value];
}
-(void) set: (ORFloat) value at:(ORInt)idx
{
    if (idx < _low || idx > _up)
        @throw [[ORExecutionError alloc] initORExecutionError: "Index out of range in ORFloatArrayElement"];
    _array[idx] = value;
}
-(void) enumerateWith: (void(^)(ORFloat obj,int idx)) block
{
    for(ORInt i=_low;i<=_up;i++)
        block(_array[i],i);
}
-(ORFloat) sumWith: (ORFloat(^)(ORFloat value,int idx))block {
    __block ORFloat sum = 0.0;
    [self enumerateWith:^(ORFloat obj, int idx) {
        sum += block(obj, idx);
    }];
    return sum;
}
-(ORInt) low
{
    return _low;
}
-(ORInt) up
{
    return _up;
}
-(id<ORExpr>)elt:(id<ORExpr>)idx
{
    return [ORFactory elt: _tracker doubleArray: self index: idx];
}
-(ORFloat) max {
    ORFloat v = _array[_low];
    for(int i = _low+1; i <= _up; i++)
        if(_array[i] > v) v = _array[i];
    return v;
}
-(ORFloat) min {
    ORFloat v = _array[_low];
    for(int i = _low+1; i <= _up; i++)
        if(_array[i] < v) v = _array[i];
    return v;
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
        [rv appendFormat:@"%d:%f",i,_array[i]];
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
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_tracker];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_low];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_up];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_nb];
    for(ORInt i=_low;i<=_up;i++)
        [aCoder encodeValueOfObjCType:@encode(ORFloat) at:_array+i];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    _tracker = [[aDecoder decodeObject] retain];
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_low];
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_up];
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_nb];
    _array =  malloc(sizeof(ORDouble)*_nb);
    _array -= _low;
    for(ORInt i=_low;i<=_up;i++)
        [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:_array+i];
    return self;
}
-(void) visit: (ORVisitor*) v
{
    [v visitFloatArray: self];
}

@end



// ------------------------------------------------------------------------------------------

@implementation ORIdArrayI
{
   id<ORTracker>  _tracker;
   id*              _array;
   ORInt              _low;
   ORInt               _up;
   ORInt               _nb;
   id<ORIntRange>   _range;
}

-(ORIdArrayI*) initORIdArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range
{
   self = [super init];
   _tracker = tracker;
   _low = [range low];
   _up  = [range up];
   _nb  = _up - _low + 1;
   _range = range;
   _array = malloc(_nb * sizeof(id));
   memset(_array,0,sizeof(id)*_nb);
   _array -= _low;
   return self;
}
-(id)copyWithZone:(NSZone *)zone
{
   ORIdArrayI* rv =  [[ORIdArrayI allocWithZone:zone] initORIdArray:_tracker range:_range];
   for(ORInt i=_low;i<=_up;i++)
       [rv set:[self at:i] at:i];
   return rv;
}
-(BOOL)isEqual:(id)object
{
   if ([object isKindOfClass:[ORIdArrayI class]]) {
      ORIdArrayI* o = object;
      if (_low == o->_low && _up == o->_up) {
         for(ORInt i=_low;i<=_up;i++) {
            BOOL ok = [[self at:i] getId] == [[o at:i] getId];
            if (!ok)
               return NO;
         }
         return YES;
      } else return NO;
   } else return NO;
}
- (NSUInteger)hash
{
   ORInt sz =  _up - _low + 1;
   NSUInteger h = 0;
   for(ORInt k=_low;k <= _up;k++)
      h = h * 7 + [_array[k] getId];
   return (h << (int)(log(sz)/log(2))) + sz;
}

-(void) dealloc
{
   _array += _low;
   free(_array);
   [super dealloc];
}
-(id*)base
{
   return _array;
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
-(ORBool) contains: (id)obj
{
   for(ORInt i=_low;i<=_up;i++)
      if(_array[i] == obj) return YES;
   return NO;
}
-(id<ORIntRange>) range
{
   return _range;
}
-(NSString*) description
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
-(void) enumerateWith: (void(^)(id obj,int idx)) block
{
   for(ORInt i=_low;i<=_up;i++)
      block(_array[i],i);
}
-(id<ORIdArray>) map:(id(^)(id obj, int idx))block {
    id<ORIdArray> res = [[ORIdArrayI alloc] initORIdArray: [self tracker] range: [self range]];
    for(ORInt i=_low;i<=_up;i++)
        [res set: block(_array[i], i) at: i];
    return res;
}
-(NSArray*) toNSArray {
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    [self enumerateWith: ^(id obj, ORInt idx) { [arr addObject: obj]; }];
    return arr;
}
-(id<ORTracker>) tracker
{
   return _tracker;
}
-(id) objectAtIndexedSubscript: (NSUInteger)key
{
    assert(_low <= key && key <= _up);
   return _array[key];
}
-(void) setObject: (id) newValue atIndexedSubscript: (NSUInteger) key
{
    assert(_low <= key && key <= _up);
   _array[key] = newValue;
}
-(id<ORExpr>)elt:(id<ORExpr>)idx
{
   return [ORFactory elt: _tracker intVarArray: (id<ORIntVarArray>) self index: idx];
}
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id *)stackbuf
                                    count:(NSUInteger)len
{
   if (state->state >= _up - _low + 1)
      return 0;
   else {
      state->itemsPtr = _array + _low;
      state->state = _up - _low + 1;
      state->mutationsPtr = (unsigned long *)self;
      return _up - _low + 1;
   }
}
-(void) encodeWithCoder: (NSCoder*) aCoder
{
   [aCoder encodeObject:_tracker];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_low];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_up];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_nb];
   for(ORInt i=_low;i<=_up;i++)
      [aCoder encodeObject:_array[i]];
}
- (id) initWithCoder: (NSCoder *) aDecoder
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
-(void)visit:(ORVisitor*)v
{
   [v visitIdArray:self];
}

@end

// Matrix ------------------------------------------------------------------


@implementation ORIdMatrixI {
   id*              _flat;
   ORInt           _arity;
   id<ORIntRange>* _range;
   ORInt*            _low;
   ORInt*             _up;
   ORInt*           _size;
   ORInt*              _i;
   ORInt              _nb;
   id<ORIdArray>   _array;
}
-(ORIdMatrixI*) initORIdMatrix: (id<ORTracker>) tracker arity: (ORInt) ar ranges: (id<ORIntRange>*) rs;
{
   self = [super init];
   _tracker = tracker;
   _arity = ar;
   _range = malloc(sizeof(id<ORIntRange>)*_arity);
   _low = malloc(sizeof(ORInt) * _arity);
   _up = malloc(sizeof(ORInt) * _arity);
   _size = malloc(sizeof(ORInt) * _arity);
   _i = malloc(sizeof(ORInt) * _arity);
   _nb = 1;
   for(ORInt k=0;k < _arity;k++) {
      _range[k] = rs[k];
      _low[k] = [rs[k] low];
      _up[k] = [rs[k] up];
      _size[k] = _up[k] - _low[k] + 1;
      _nb *= _size[k];
   }
   _flat = malloc(sizeof(id)*_nb);
   _array = 0;
   return self;
}
-(ORIdMatrixI*) initORIdMatrix: (id<ORTracker>) tracker with: (ORIdMatrixI*) matrix
{
   self = [super init];
   _tracker = tracker;
   _arity = matrix->_arity;
   _range = malloc(sizeof(id<ORIntRange>) * _arity);
   _low = malloc(sizeof(ORInt) * _arity);
   _up = malloc(sizeof(ORInt) * _arity);
   _size = malloc(sizeof(ORInt) * _arity);
   _i = malloc(sizeof(ORInt) * _arity);
   for(ORInt k = 0; k < _arity; k++) {
      _range[k] = matrix->_range[k];
      _low[k] = matrix->_low[k];
      _up[k] = matrix->_up[k];
      _size[k] = matrix->_size[k];
   }
   _nb = matrix->_nb;
   _flat = malloc(sizeof(id) * _nb);
   for (ORInt i=0 ; i < _nb; i++)
      _flat[i] = matrix->_flat[i];
   _array = [ORFactory idArray: tracker range: RANGE(tracker,0,_nb-1) with: ^id(ORInt i) { return _flat[i]; }];
   return self;
}

-(ORIdMatrixI*) initORIdMatrix:(id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2
{
   return self = [self initORIdMatrix: tracker arity:3 ranges:(id<ORIntRange>[]){r0,r1,r2}];
}

-(ORIdMatrixI*) initORIdMatrix:(id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1
{
   return self = [self initORIdMatrix: tracker arity:2 ranges:(id<ORIntRange>[]){r0,r1}];
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
-(id<ORIntRange>) range: (ORInt) i
{
   if (i < 0 || i >= _arity)
      @throw [[ORExecutionError alloc] initORExecutionError: "Wrong index in ORIntVarMatrix"];
   return _range[i];
}
-(id) flat: (ORInt) i
{
   return _flat[i];
}
-(void) setFlat:(id) x at:(ORInt)i
{
   _flat[i] = x;
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

-(id<ORExpr>) elt: (id<ORExpr>) idx i1:(ORInt)i1
{
   id<ORIntVarArray> slice = (id)[ORFactory idArray:[idx tracker] range:_range[0] with:^id(ORInt i) {
      ORInt flatOfs = ((i - _low[0]) * _size[1]) + i1 -  _low[1];
      return _flat[flatOfs];
   }];
   id<ORExpr> fe = [slice elt:idx];
   return fe;
}
-(id<ORExpr>) at: (ORInt) i0       elt:(id<ORExpr>)e1
{
   id<ORIntVarArray> slice = (id)[ORFactory idArray:[e1 tracker] range:_range[1] with:^id(ORInt j) {
      ORInt flatOfs = ((i0 - _low[0]) * _size[1]) + j -  _low[1];
      return _flat[flatOfs];
   }];
   id<ORExpr> fe = [slice elt:e1];
   return fe;
}
-(id<ORExpr>) elt: (id<ORExpr>)e0  elt:(id<ORExpr>)e1
{
   return [ORFactory elt:[e0 tracker] intVarMatrix:(id)self elt:e0 elt:e1];
}

-(NSUInteger) count
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
-(NSString*) description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [self descriptionAux: 0 string: rv];
   return rv;
}
-(id<ORTracker>) tracker
{
   return _tracker;
}
- (void) encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeObject:_tracker];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_arity];
   for(ORInt i = 0; i < _arity; i++) {
      [aCoder encodeObject: _range[i]];
      [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_low[i]];
      [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_up[i]];
   }
   for(ORInt i=0 ; i < _nb ;i++)
      [aCoder encodeObject:_flat[i]];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _tracker = [[aDecoder decodeObject] retain];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_arity];
   _range = malloc(sizeof(id<ORIntRange>) * _arity);
   _low = malloc(sizeof(ORInt) * _arity);
   _up = malloc(sizeof(ORInt) * _arity);
   _size = malloc(sizeof(ORInt) * _arity);
   _i = malloc(sizeof(ORInt) * _arity);
   _nb = 1;
   for(ORInt i = 0; i < _arity; i++) {
      _range[i] = [[aDecoder decodeObject] retain];
      [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_low[i]];
      [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_up[i]];
      _size[i] = (_up[i] - _low[i] + 1);
      _nb *= _size[i];
   }
   _flat = malloc(sizeof(id) * _nb);
   for(ORInt i=0 ; i < _nb ;i++)
      _flat[i] = [aDecoder decodeObject];
   return self;
}
-(void) visit:(ORVisitor*)v
{
   [v visitIdMatrix:self];
}
-(id<ORIdArray>) flatten
{
   if (!_array)
      _array = [ORFactory idArray: _tracker range: RANGE(_tracker,0,_nb-1) with: ^id(ORInt i) { return _flat[i]; }];
   return _array;
}
@end


/*********************************************************************************/
/*             Multi-Dimensional Matrix of Int                                   */
/*********************************************************************************/

@implementation ORIntMatrixI
{
   id<ORTracker>   _tracker;
   ORInt*          _flat;
   ORInt           _arity;
   id<ORIntRange>* _range;
   ORInt*          _low;
   ORInt*          _up;
   ORInt*          _size;
   ORInt*          _i;
   ORInt           _nb;
}
-(ORIntMatrixI*) initORIntMatrix:(id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2
{
   self = [super init];
   _tracker = tracker;
   _arity = 3;
   _range = malloc(sizeof(id<ORIntRange>) * _arity);
   _low = malloc(sizeof(ORInt) * _arity);
   _up = malloc(sizeof(ORInt) * _arity);
   _size = malloc(sizeof(ORInt) * _arity);
   _i = malloc(sizeof(ORInt) * _arity);
   _range[0] = r0;
   _range[1] = r1;
   _range[2] = r2;
   _low[0] = [r0 low];
   _low[1] = [r1 low];
   _low[2] = [r2 low];
   _up[0] = [r0 up];
   _up[1] = [r1 up];
   _up[2] = [r2 up];
   _size[0] = (_up[0] - _low[0] + 1);
   _size[1] = (_up[1] - _low[1] + 1);
   _size[2] = (_up[2] - _low[2] + 1);
   _nb = _size[0] * _size[1] * _size[2];
   _flat = malloc(sizeof(ORInt) * _nb);
   for (ORInt i=0 ; i < _nb; i++)
      _flat[i] = 0;
   return self;
}

-(ORIntMatrixI*) initORIntMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1
{
   self = [super init];
   _tracker = tracker;
   _arity = 2;
   _range = malloc(sizeof(id<ORIntRange>) * _arity);
   _low = malloc(sizeof(ORInt) * _arity);
   _up = malloc(sizeof(ORInt) * _arity);
   _size = malloc(sizeof(ORInt) * _arity);
   _i = malloc(sizeof(ORInt) * _arity);
   _range[0] = r0;
   _range[1] = r1;
   _low[0] = [r0 low];
   _low[1] = [r1 low];
   _up[0] = [r0 up];
   _up[1] = [r1 up];
   _size[0] = (_up[0] - _low[0] + 1);
   _size[1] = (_up[1] - _low[1] + 1);
   _nb = _size[0] * _size[1];
   _flat = malloc(sizeof(ORInt) * _nb);
   for (ORInt i=0 ; i < _nb; i++)
      _flat[i] = 0;
   return self;
}
-(ORIntMatrixI*) initORIntMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 with: (ORIntxInt2Int)block {
   self = [self initORIntMatrix: tracker range: r0 : r1];
   for(ORInt i = _low[0]; i <= _up[0]; i++) {
      for(ORInt j = _low[1]; j <= _up[1]; j++) {
         [self set: block(i, j) at: i : j];
      }
   }
   return self;
}
-(ORIntMatrixI*) initORIntMatrix: (id<ORTracker>) tracker with: (ORIntMatrixI*) matrix
{
   self = [super init];
   _tracker = tracker;
   _arity = matrix->_arity;
   _range = malloc(sizeof(id<ORIntRange>) * _arity);
   _low = malloc(sizeof(ORInt) * _arity);
   _up = malloc(sizeof(ORInt) * _arity);
   _size = malloc(sizeof(ORInt) * _arity);
   _i = malloc(sizeof(ORInt) * _arity);
   for(ORInt k = 0; k < _arity; k++) {
      _range[k] = matrix->_range[k];
      _low[k] = matrix->_low[k];
      _up[k] = matrix->_up[k];
      _size[k] = matrix->_size[k];
   }
   _nb = matrix->_nb;
   _flat = malloc(sizeof(ORInt) * _nb);
   for (ORInt i=0 ; i < _nb; i++)
      _flat[i] = matrix->_flat[i];
   return self;
}
-(void) dealloc
{
   //   NSLog(@"CPIntVarMatrix dealloc called...\n");
   free(_range);
   free(_low);
   free(_up);
   free(_size);
   free(_i);
   free(_flat);
   [super dealloc];
}
-(ORInt) getIndex
{
   for(ORInt k = 0; k < _arity; k++)
      if (_i[k] < _low[k] || _i[k] > _up[k])
         @throw [[ORExecutionError alloc] initORExecutionError: "Wrong index in CPIntMatrix"];
   int idx = _i[0] - _low[0];
   for(ORInt k = 1; k < _arity; k++)
      idx = idx * _size[k] + (_i[k] - _low[k]);
   return idx;
}
-(id<ORIntRange>) range: (ORInt) i
{
   if (i < 0 || i >= _arity)
      @throw [[ORExecutionError alloc] initORExecutionError: "Wrong index in CPIntMatrix"];
   return _range[i];
}
-(ORInt) at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2
{
   if (_arity != 3)
      @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in CPIntMatrix"];
   _i[0] = i0;
   _i[1] = i1;
   _i[2] = i2;
   return _flat[[self getIndex]];
}
-(ORInt) at: (ORInt) i0 : (ORInt) i1
{
   if (_arity != 2)
      @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in CPIntMatrix"];
   _i[0] = i0;
   _i[1] = i1;
   return _flat[[self getIndex]];
}

-(void) set: (ORInt) value at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2
{
   if (_arity != 3)
      @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in CPIntVarMatrix"];
   _i[0] = i0;
   _i[1] = i1;
   _i[2] = i2;
   _flat[[self getIndex]] = value;
}
-(void) set: (ORInt) value at: (ORInt) i0 : (ORInt) i1
{
   if (_arity != 2)
      @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in CPIntVarMatrix"];
   _i[0] = i0;
   _i[1] = i1;
   _flat[[self getIndex]] = value;
}

-(NSUInteger) count
{
   return _nb;
}
-(void) descriptionAux: (ORInt) i string: (NSMutableString*) rv
{
   if (i == _arity) {
      [rv appendString:@"<"];
      for(ORInt k = 0; k < _arity; k++)
         [rv appendFormat:@"%d,",_i[k]];
      [rv appendString:@"> ="];
      [rv appendFormat:@"%d \n",_flat[[self getIndex]]];
   }
   else {
      for(ORInt k = _low[i]; k <= _up[i]; k++) {
         _i[i] = k;
         [self descriptionAux: i+1 string: rv];
      }
   }
}
-(NSString*) description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [self descriptionAux: 0 string: rv];
   return rv;
}
-(id<ORTracker>) tracker
{
   return _tracker;
}
-(void) visit:(ORVisitor*)visitor
{
   [visitor visitIntMatrix:self];
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_tracker];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_arity];
   for(ORInt i = 0; i < _arity; i++) {
      [aCoder encodeObject:_range[i]];
      [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_low[i]];
      [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_up[i]];
   }
   for(ORInt i=0 ; i < _nb ;i++)
      [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_flat[i]];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _tracker = [[aDecoder decodeObject] retain];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_arity];
   _range = malloc(sizeof(id<ORIntRange>) * _arity);
   _low = malloc(sizeof(ORInt) * _arity);
   _up = malloc(sizeof(ORInt) * _arity);
   _size = malloc(sizeof(ORInt) * _arity);
   _nb = 1;
   for(ORInt i = 0; i < _arity; i++) {
      _range[i] = [[aDecoder decodeObject] retain];
      [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_low[i]];
      [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_up[i]];
      _size[i] = (_up[i] - _low[i] + 1);
      _nb *= _size[i];
   }
   _flat = malloc(sizeof(ORInt) * _nb);
   for(ORInt i=0 ; i < _nb ;i++)
      [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_flat[i]];
   return self;
}

@end


