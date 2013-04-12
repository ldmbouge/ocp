/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORVarI.h"
#import "ORError.h"
#import "ORFactory.h"

@implementation ORIntVarI
{
@protected
   id<ORTracker>  _tracker;
   id<ORIntRange> _domain;
   BOOL           _hasBounds;
}
-(ORIntVarI*) initORIntVarI: (id<ORTracker>) track domain: (id<ORIntRange>) domain
{
   self = [super init];
   _impl = nil;
   _tracker = track;
   _domain = domain;
   _hasBounds = true;
   _ba[0] = YES; // dense
   _ba[1] = ([domain low] == 0 && [domain up] == 1); // isBool
   [track trackVariable: self];
   return self;
}


-(void) dealloc
{
   [super dealloc];
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_impl];
   [aCoder encodeObject:_tracker];
   [aCoder encodeObject:_domain];
   [aCoder encodeValueOfObjCType:@encode(ORBool) at:&_ba[0]];
   [aCoder encodeValueOfObjCType:@encode(ORBool) at:&_ba[1]];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _impl = [aDecoder decodeObject];
   _tracker = [aDecoder decodeObject];
   _domain  = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORBool) at:&_ba[0]];
   [aDecoder decodeValueOfObjCType:@encode(ORBool) at:&_ba[1]];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   return self;
}

-(ORBool) isVariable
{
   return YES;
}
-(NSString*) description
{
   if (_impl == nil)
      return [NSString stringWithFormat:@"var<OR>{int}:%03d(%@,%c)",_name,[_domain description],_ba[0] ? 'D':'S'];
   else
      return [NSString stringWithFormat:@"var<OR>{int}:%03d(%@,%c,%@)",_name,[_domain description],_ba[0] ? 'D':'S',_impl];
}
-(ORInt) value
{
   return [self intValue];
}
-(ORInt) intValue
{
   if (_impl) {
      return [(id<ORIntVar>)[_impl dereference] intValue];
   }
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
}
-(ORFloat) floatValue
{
   if (_impl) {
      return [(id<ORIntVar>)[_impl dereference] floatValue];
   }
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
}
-(ORInt) min
{
   id<ORIntVar> end = [_impl dereference];
   if (end)
      return [end min];
   else
      return [_domain low];
}
-(ORInt) max
{
   id<ORIntVar> end = [_impl dereference];
   if (end)
      return [end max];
   else
      return [_domain up];
}
-(ORInt) low
{
   return [_domain low];
}
-(ORInt) up
{
   return [_domain up];
}

-(ORInt) domsize
{
   if (_impl) {
      id<ORIntVar> end = [_impl dereference];
      if (end)
         return [end domsize];
      else return [_domain size];
   } else
      return [_domain size];
}
-(ORBounds)bounds
{
   id<ORIntVar> end = [_impl dereference];
   if (end)
      return [end bounds];
   else {
      ORBounds b = {[_domain low],[_domain up]};
      return b;
   }
}
-(ORBool) member: (ORInt) v
{
   if (_impl)
      return [(id<ORIntVar>)[_impl dereference] member: v];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
}
-(ORBool) bound
{
   if (_impl)
      return [(id<ORIntVar>)[_impl dereference] bound];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
   
}
-(ORBool) isBool
{
   if (_impl)
      return [(id<ORIntVar>)_impl isBool];
   else
      return _ba[1]; // isBool
}
-(NSSet*)constraints
{
   if (_impl)
      return [(id<ORIntVar>)_impl constraints];
   else
      @throw [[ORExecutionError alloc] initORExecutionError:"The variable has no concretization"];
}
-(id<ORTracker>) tracker
{
   return _tracker;
}
-(id<ORIntRange>) domain
{
   return _domain;
}
-(ORBool) hasDenseDomain
{
   return _ba[0]; // dense
}
-(ORInt)scale
{
   return 1;
}
-(ORInt)shift
{
   return 0;
}
-(ORInt)literal
{
   return 0;
}
-(id<ORIntVar>)base
{
   return self;
}
-(void) visit: (id<ORVisitor>) v
{
   [v visitIntVar: self];
}
@end

@implementation ORIntVarAffineI {
   ORInt        _a;
   id<ORIntVar> _x;
   ORInt        _b;
}
-(ORIntVarAffineI*)initORIntVarAffineI:(id<ORTracker>)tracker var:(id<ORIntVar>)x scale:(ORInt)a shift:(ORInt)b
{
   id<ORIntRange> xr = [x domain];
   id<ORIntRange> ar;
   if (a > 0)
      ar = [ORFactory intRange:tracker low:a * [xr low] + b up:a * [xr up] + b];
   else
      ar = [ORFactory intRange:tracker low:a * [xr up] + b up:a * [xr low] + b];
   self = [super initORIntVarI:tracker domain:ar];
   _a = a;
   _x = x;
   _b = b;
   return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_a];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_b];
   [aCoder encodeObject:_x];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_a];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_b];
   _x = [aDecoder decodeObject];
   return self;
}
-(NSString*) description
{
   char d = _ba[0] ? 'D':'S';
   if (_impl == nil)
      return [NSString stringWithFormat:@"var<OR>{int}:%03d(%@,%c,(%d * %@ + %d : nil)",_name,[_domain description],d,_a,_x,_b];
   else
      return [NSString stringWithFormat:@"var<OR>{int}:%03d(%@,%c,(%d * %@ + %d : %@)",_name,[_domain description],d,_a,_x,_b,_impl];
}
-(ORInt)scale
{
   return _a;
}
-(ORInt)shift
{
   return _b;
}
-(id<ORIntVar>)base
{
   return _x;
}
-(void) visit: (id<ORVisitor>) v
{
   [v visitAffineVar: self];
}
@end

@implementation ORIntVarLitEQView {
   id<ORIntVar>   _x;
   ORInt        _lit;
}
-(ORIntVarLitEQView*)initORIntVarLitEQView:(id<ORTracker>)tracker var:(id<ORIntVar>)x eqi:(ORInt)lit
{
   self = [super initORIntVarI:tracker domain:RANGE(tracker,0,1)];
   _x = x;
   _lit = lit;
   return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_lit];
   [aCoder encodeObject:_x];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_lit];
   _x = [aDecoder decodeObject];
   return self;
}
-(ORInt)literal
{
   return _lit;
}
-(id<ORIntVar>)base
{
   return _x;
}
-(void) visit: (id<ORVisitor>)v
{
   [v visitIntVarLitEQView:self];
}
@end

@implementation ORFloatVarI
{
@protected
   id<ORTracker>    _tracker;
   ORFloat          _low;
   ORFloat          _up;
   BOOL             _hasBounds;
}
-(ORFloatVarI*) initORFloatVarI: (id<ORTracker>) track low: (ORFloat) low up: (ORFloat) up
{
   self = [super init];
   _impl = nil;
   _tracker = track;
   _low = low;
   _up = up;
   _hasBounds = true;
   [track trackVariable: self];
   return self;
}
-(ORFloatVarI*) initORFloatVarI: (id<ORTracker>) track up: (ORFloat) up
{
   self = [super init];
   _impl = nil;
   _tracker = track;
   _low = 0;
   _up = up;
   _hasBounds = true;
   [track trackVariable: self];
   return self;
}
-(ORFloatVarI*) initORFloatVarI: (id<ORTracker>) track
{
   self = [super init];
   _impl = nil;
   _tracker = track;
   _hasBounds = false;
   [track trackVariable: self];
   return self;
}

-(void) dealloc
{
   [super dealloc];
}
-(void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_impl];
   [aCoder encodeObject:_tracker];
   [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_low];
   [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_up];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
}
-(id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _impl = [aDecoder decodeObject];
   _tracker = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_low];
   [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_up];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   return self;
}
-(ORBool) isVariable
{
   return YES;
}
-(NSString*) description
{
   if (_impl == nil)
      return [NSString stringWithFormat:@"var<OR>{float}:%03d(%f,%f)",_name,_low,_up];
   else
      return [NSString stringWithFormat:@"var<OR>{float}:%03d(%f,%f) - %@",_name,_low,_up,_impl];
}
-(ORFloat) value
{
   return [self floatValue];
}
-(ORFloat) floatValue
{
   if (_impl)
      return [(id<ORFloatVar>)_impl floatValue];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
   
}
-(ORBool) bound
{
   if (_impl)
      return [_impl bound];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
   
}

-(ORFloat) min
{
   if (_impl)
      return [(id<ORFloatVar>)_impl min];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
}
-(ORFloat) max
{
   if (_impl)
      return [(id<ORFloatVar>)_impl max];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
   
}
-(NSSet*) constraints
{
   if (_impl)
      return [(id<ORFloatVar>)_impl constraints];
   else
      @throw [[ORExecutionError alloc] initORExecutionError:"The variable has no concretization"];
}
-(id<ORTracker>) tracker
{
   return _tracker;
}
-(void) visit: (id<ORVisitor>) v
{
   [v visitFloatVar: self];
}
-(ORBool) hasBounds
{
   return _hasBounds;
}
-(ORFloat) low
{
   return _low;
}
-(ORFloat) up
{
   return _up;
}
@end

@implementation ORBitVarI {
   id<ORTracker>    _tracker;
   ORUInt*          _low;
   ORUInt*          _up;
   ORUInt           _bLen;
   ORUInt           _nb;
}
-(ORBitVarI*)initORBitVarI:(id<ORTracker>)tracker low:(ORUInt*)low up:(ORUInt*)up bitLength:(ORInt)len
{
   self = [super init];
   _impl  = nil;
   _bLen = len;
   _nb = (_bLen / 32) + ((_bLen % 32) ? 1 : 0);
   _low = malloc(sizeof(ORUInt)*_nb);
   _up = malloc(sizeof(ORUInt)*_nb);
   memcpy(_low,low,sizeof(ORUInt)*_nb);
   memcpy(_up,up,sizeof(ORUInt)*_nb);
   _tracker = tracker;
   [tracker trackVariable: self];
   return self;
}
-(void)dealloc
{
   free(_low);
   free(_up);
   [super dealloc];
}
-(ORUInt*)low
{
   return _low;
}
-(ORUInt*)up
{
   return _up;
}
-(ORUInt)bitLength
{
   return _bLen;
}
-(ORBool) bound
{
   if (_impl)
      return [[_impl dereference] bound];
   else
      @throw [[ORExecutionError alloc] initORExecutionError:"The variable has no concretization"];
}
-(uint64)min
{
   if (_impl)
      return [(id<ORBitVar>)[_impl dereference] min];
   else {
      return (long long)_low[1]<<32 | _low[0];
   }
}
-(uint64)max
{
   if (_impl)
      return [(id<ORBitVar>)[_impl dereference] min];
   else {
      return (long long)_low[1]<<32 | _low[0];
   }
}
-(unsigned int)  domsize
{
   if (_impl)
      return [(id<ORBitVar>)[_impl dereference] domsize];
   else {
      @throw [[ORExecutionError alloc] initORExecutionError:"The variable has no concretization"];
   }
}
-(ORBool) member: (unsigned int*) v
{
   if (_impl)
      return [(id<ORBitVar>)[_impl dereference] member:v];
   else {
      @throw [[ORExecutionError alloc] initORExecutionError:"The variable has no concretization"];
   }
}
-(void) visit: (id<ORVisitor>)v
{
   [v visitBitVar:self];
}
-(NSSet*) constraints
{
   if (_impl)
      return [(id<ORBitVar>)[_impl dereference] constraints];
   else {
      @throw [[ORExecutionError alloc] initORExecutionError:"The variable has no concretization"];
   }   
}
-(id<ORTracker>) tracker
{
   return _tracker;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_impl];
   [aCoder encodeObject:_tracker];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_bLen];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_nb];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aCoder encodeArrayOfObjCType:@encode(ORUInt) count:_nb at:_low];
   [aCoder encodeArrayOfObjCType:@encode(ORUInt) count:_nb at:_up];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _impl = [aDecoder decodeObject];
   _tracker = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_bLen];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_nb];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   _low = malloc(sizeof(ORUInt)*_nb);
   _up = malloc(sizeof(ORUInt)*_nb);
   [aDecoder decodeArrayOfObjCType:@encode(ORUInt) count:_nb at:_low];
   [aDecoder decodeArrayOfObjCType:@encode(ORUInt) count:_nb at:_up];
   return self;
}

-(ORBool) isVariable
{
   return YES;
}
-(NSString*) description
{
   if (_impl == nil)
      return [NSString stringWithFormat:@"bitvar<OR>{int}:%03d(nil)",_name];
   else
      return [NSString stringWithFormat:@"bitvar<OR>{int}:%03d(%@)",_name,_impl];
}
-(NSString*)stringValue
{
   if (_impl)
      return [[_impl dereference] description];
   else
      return [self description];
}

@end
