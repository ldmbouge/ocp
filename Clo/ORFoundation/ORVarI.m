//
//  ORVarI.m
//  Clo
//
//  Created by Laurent Michel on 10/5/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import "ORVarI.h"
#import "ORError.h"
#import "ORFactory.h"

@interface ORIntVarSnapshot : NSObject<ORSnapshot,NSCoding> {
   ORUInt    _name;
   ORInt     _value;
}
-(ORIntVarSnapshot*)initIntVarSnapshot:(id<ORIntVar>)v;
-(void)restoreInto:(NSArray*)av;
-(int)intValue;
-(BOOL)boolValue;
-(NSString*)description;
@end

@implementation ORIntVarSnapshot
-(ORIntVarSnapshot*)initIntVarSnapshot:(id<ORIntVar>)v
{
   self = [super init];
   _name = [v getId];
   _value = [v min];
   return self;
}
-(void)restoreInto:(NSArray*)av
{
   id<ORIntVar> theVar = [av objectAtIndex:_name];
   [theVar restore:self];
}
-(int)intValue
{
   return _value;
}
-(BOOL)boolValue
{
   return _value;
}
-(NSString*)description
{   
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"int(%d) : %d",_name,_value];
   return buf;
}

- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_value];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_value];
   return self;
}
@end


@implementation ORIntVarI
{
@protected
   id<ORTracker>  _tracker;
   id<ORIntRange> _domain;
   BOOL           _dense;
   BOOL           _isBool;
   ORUInt         _name;
}
-(ORIntVarI*) initORIntVarI: (id<ORTracker>) track domain: (id<ORIntRange>) domain
{
   self = [super init];
   _impl = nil;
   _tracker = track;
   _domain = domain;
   _dense = true;
   _isBool = ([domain low] == 0 && [domain up] == 1);
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
   [aCoder encodeValueOfObjCType:@encode(BOOL) at:&_dense];
   [aCoder encodeValueOfObjCType:@encode(BOOL) at:&_isBool];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _impl = [aDecoder decodeObject];
   _tracker = [aDecoder decodeObject];
   _domain  = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(BOOL) at:&_dense];
   [aDecoder decodeValueOfObjCType:@encode(BOOL) at:&_isBool];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   return self;
}

-(BOOL) isVariable
{
   return YES;
}
-(NSString*) description
{
   if (_impl == nil)
      return [NSString stringWithFormat:@"var<OR>{int}:%03d(%@,%c)",_name,[_domain description],_dense ? 'D':'S'];
   else
      return [NSString stringWithFormat:@"var<OR>{int}:%03d(%@,%c,%@)",_name,[_domain description],_dense ? 'D':'S',_impl];
}

-(void) setId: (ORUInt) name
{
   _name = name;
}
-(ORInt) getId
{
   return _name;
}
-(ORInt) value
{
   if (_impl)
      return [[_impl dereference] value];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
   
}
-(id) snapshot
{
   return [[ORIntVarSnapshot alloc] initIntVarSnapshot:self];
}
-(void)restore:(id<ORSnapshot>)s
{
   ORInt theValue = [s intValue];
   [_impl restoreValue:theValue];
}
-(ORInt) min
{
   if (_impl)
      return [(id<ORIntVar>)[_impl dereference] min];
   else
      return [_domain low];
}
-(ORInt) max
{
   if (_impl)
      return [(id<ORIntVar>)[_impl dereference] max];
   else
      return [_domain up];
}
-(ORInt) domsize
{
   if (_impl)
      return [[_impl dereference] domsize];
   else
      return [_domain size];
}
-(ORBounds)bounds
{
   if (_impl)
      return [(id<ORIntVar>)[_impl dereference] bounds];
   else {
      ORBounds b = {[_domain low],[_domain up]};
      return b;
   }
}
-(BOOL) member: (ORInt) v
{
   if (_impl)
      return [(id<ORIntVar>)[_impl dereference] member: v];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
}
-(BOOL) bound
{
   if (_impl)
      return [(id<ORIntVar>)[_impl dereference] bound];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
   
}
-(BOOL) isBool
{
   if (_impl)
      return [(id<ORIntVar>)[_impl dereference] isBool];
   else
      return _isBool;
}
-(NSSet*)constraints
{
   if (_impl)
      return [(id<ORIntVar>)[_impl dereference] constraints];
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
-(BOOL) hasDenseDomain
{
   return _dense;
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
   char d = _dense ? 'D':'S';
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
   id<ORFloatVar>   _impl;
   id<ORTracker>    _tracker;
   ORFloat          _low;
   ORFloat          _up;
   ORUInt           _name;
}
-(ORFloatVarI*) initORFloatVarI: (id<ORTracker>) track low: (ORFloat) low up: (ORFloat) up
{
   self = [super init];
   _impl = nil;
   _tracker = track;
   _low = low;
   _up = up;
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
   [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_low];
   [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_up];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _impl = [aDecoder decodeObject];
   _tracker = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_low];
   [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_up];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   return self;
}
-(NSString*) description
{
   if (_impl == nil)
      return [NSString stringWithFormat:@"var<OR>{int}:%03d(%f,%f)",_name,_low,_up];
   else
      return [NSString stringWithFormat:@"var<OR>{int}:%03d(%f,%f) - %@",_name,_low,_up,_impl];
}
-(void) setId: (ORUInt) name
{
   _name = name;
}
-(ORInt) getId
{
   return _name;
}
-(id) snapshot  // [ldm] to fix
{
   assert(FALSE);
   return nil;
}
-(void)restore:(id<ORSnapshot>)s  // [ldm] to fix
{
   assert(FALSE);
}

-(ORFloat) value
{
   if (_impl)
      return [(id<ORIntVar>) [_impl dereference] value];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
   
}
-(BOOL) bound
{
   if (_impl)
      return [[_impl dereference] bound];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
   
}

-(ORFloat) min
{
   if (_impl)
      return [(id<ORFloatVar>)[_impl dereference] min];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
}
-(ORFloat) max
{
   if (_impl)
      return [(id<ORFloatVar>)[_impl dereference] max];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
   
}
-(NSSet*) constraints
{
   if (_impl)
      return [(id<ORFloatVar>)[_impl dereference] constraints];
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
@end
