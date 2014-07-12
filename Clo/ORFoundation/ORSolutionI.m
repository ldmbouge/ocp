/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import "ORModeling.h"
#import "ORSolutionI.h"


@interface ORIntVarSnapshot : NSObject<ORSnapshot,NSCoding> {
   ORUInt    _name;
   ORInt     _value;
   ORBool    _bound;
}
-(ORIntVarSnapshot*) initIntVarSnapshot: (id<ORIntVar>) v with: (id<ORASolver>) solver;
-(int) intValue;
-(ORBool) boolValue;
-(NSString*) description;
-(ORBool)isEqual: (id) object;
-(NSUInteger) hash;
-(ORUInt)getId;
@end

@implementation ORIntVarSnapshot
-(ORIntVarSnapshot*) initIntVarSnapshot: (id<ORIntVar>) v with: (id<ORASolver>) solver;
{
   self = [super init];
   _name = [v getId];
   
   id<ORQueryIntVar> x = [solver concretize: v];
   if ([x bound]) {
      _bound = TRUE;
      _value = [x value];
   }
   else {
      _value = 0;
      _bound = FALSE;
   }
   return self;
}
-(ORUInt)getId
{
   return _name;
}
-(ORBool) bound
{
   return _bound;
}
-(ORInt) intValue
{
   return _value;
}
-(ORFloat) floatValue
{
   return _value;
}
-(ORBool) boolValue
{
   return _value;
}
-(ORBool)isEqual: (id) object
{
   if ([object isKindOfClass:[self class]]) {
      ORIntVarSnapshot* other = object;
      if (_name == other->_name) {
         return _value == other->_value && _bound == other->_bound;
      }
      else
         return NO;
   } else
      return NO;
}
-(NSUInteger) hash
{
   return (_name << 16) + _value;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   if (_bound)
      [buf appendFormat:@"int(%d) : %d",_name,_value];
   else
      [buf appendFormat:@"int(%d) : NA",_name];
   return buf;
}
- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_value];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_bound];
}
- (id) initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_value];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_bound];
   return self;
}
@end

@interface ORFloatVarSnapshot : NSObject <ORSnapshot,NSCoding>
{
   ORUInt    _name;
   ORFloat   _value;
   ORBool    _bound;
}
-(ORFloatVarSnapshot*) initFloatVarSnapshot: (id<ORFloatVar>) v with: (id<ORASolver>) solver;
-(ORUInt) getId;
-(ORFloat) floatValue;
-(ORInt) intValue;
-(NSString*) description;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
@end

@implementation ORFloatVarSnapshot
-(ORFloatVarSnapshot*) initFloatVarSnapshot: (id<ORFloatVar>) v with: (id<ORASolver>) solver;
{
   self = [super init];
   _name = [v getId];
   id<ORQueryFloatVar> x = [solver concretize: v];
   if ([x bound]) {
      _bound = TRUE;
      _value = [x value];
   }
   else {
      _value = 0;
      _bound = FALSE;
   }
   return self;
}
-(ORInt) intValue
{
   @throw [[ORExecutionError alloc] initORExecutionError: "intValue called on a snapshot for float variables"];
   return 0;
}
-(ORBool) boolValue
{
   @throw [[ORExecutionError alloc] initORExecutionError: "boolValue called on a snapshot for float variables"];
   return 0;
}
-(ORFloat) floatValue
{
   return _value;
}
-(ORBool) bound
{
   return _bound;
}
-(ORUInt) getId
{
   return _name;
}
-(ORBool) isEqual: (id) object
{
   if ([object isKindOfClass:[self class]]) {
      ORFloatVarSnapshot* other = object;
      if (_name == other->_name) {
         return _value == other->_value && _bound == other->_bound;
      }
      else
         return NO;
   }
   else
      return NO;
}
-(NSUInteger)hash
{
   return (_name << 16) + (ORInt) _value;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"float(%d) : %f",_name,_value];
   return buf;
}
- (void) encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_value];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_bound];
}
- (id) initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_value];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_bound];
   return self;
}
@end

@interface ORTakeSnapshot  : ORNOopVisit<NSObject>
-(ORTakeSnapshot*) initORTakeSnapshot: (id<ORASolver>) solver;
-(void) dealloc;
@end

@implementation ORTakeSnapshot
{
   id<ORASolver> _solver;
   id            _snapshot;
}
-(ORTakeSnapshot*) initORTakeSnapshot: (id<ORASolver>) solver
{
   self = [super init];
   _solver = solver;
   return self;
}
-(id) snapshot:(id)obj
{
   _snapshot = NULL;
   [obj visit:self];
   return _snapshot;
}
-(void) dealloc
{
   [super dealloc];
}
-(void) visitIntVar: (id<ORIntVar>) v
{
   _snapshot = [[ORIntVarSnapshot alloc] initIntVarSnapshot: v with: _solver];
}
-(void) visitFloatVar: (id<ORFloatVar>) v
{
   _snapshot = [[ORFloatVarSnapshot alloc] initFloatVarSnapshot: v with: _solver];
}
@end

@implementation ORSolution
{
   NSArray*             _varShots;
   id<ORObjectiveValue> _objValue;
}

-(ORSolution*) initORSolution: (id<ORModel>) model with: (id<ORASolver>) solver
{
   self = [super init];
   NSArray* av = [model variables];
   ORULong sz = [av count];
   NSMutableArray* snapshots = [[NSMutableArray alloc] initWithCapacity:sz];
   ORTakeSnapshot* visit = [[ORTakeSnapshot alloc] initORTakeSnapshot: solver];
   for(id obj in av) {
      id shot = [visit snapshot: obj];
      if (shot)
         [snapshots addObject: shot];
      [shot release];
   }
   _varShots = snapshots;
   
   if ([model objective])
      _objValue = [[solver objective] value];
   else
      _objValue = nil;
   [visit release];
   return self;
}

-(void) dealloc
{
   //   NSLog(@"dealloc ORSolution");
   [_varShots release];
   [_objValue release];
   [super dealloc];
}

-(ORBool) isEqual: (id) object
{
   if ([object isKindOfClass: [self class]]) {
      ORSolution* other = object;
      if (_objValue && other->_objValue) {
         if ([_objValue isEqual:other->_objValue]) {
            return [_varShots isEqual:other->_varShots];
         }
         else
            return NO;
      }
      else
         return NO;
   }
   else
      return NO;
}
-(NSUInteger) hash
{
   return [_varShots hash];
}
-(id<ORObjectiveValue>) objectiveValue
{
   return _objValue;
}
-(id) value: (id) var
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [var getId];
   }];
   if (idx < [_varShots count])
      return [_varShots objectAtIndex:idx];
   else
      return nil;
}
-(ORInt) intValue: (id) var
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [var getId];
   }];
   id<ORSnapshot,ORQueryIntVar> snap = [_varShots objectAtIndex:idx];
   return [snap intValue];
}
-(ORBool) boolValue: (id) var
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [var getId];
   }];
   id<ORSnapshot,ORQueryIntVar> snap = [_varShots objectAtIndex:idx];
   return [snap intValue];
}
-(ORFloat) floatValue: (id<ORFloatVar>) var
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [var getId];
   }];
   id<ORSnapshot,ORQueryFloatVar> snap = [_varShots objectAtIndex:idx];
   return [snap floatValue];
}
-(NSUInteger) count
{
   return [_varShots count];
}
- (void) encodeWithCoder: (NSCoder *)aCoder
{
   [aCoder encodeObject:_varShots];
   [aCoder encodeObject:_objValue];
}
- (id) initWithCoder:(NSCoder *) aDecoder
{
   self = [super init];
   _varShots = [[aDecoder decodeObject] retain];
   _objValue = [aDecoder decodeObject];
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   if (_objValue)
      [buf appendFormat:@"SOL[%@](",_objValue];
   else
      [buf appendString:@"SOL("];
   NSUInteger last = [_varShots count] - 1;
   [_varShots enumerateObjectsUsingBlock:^(id<ORSnapshot> obj, NSUInteger idx, BOOL *stop) {
      [buf appendFormat:@"%@%c",obj,idx < last ? ',' : ')'];
   }];
   return buf;
}
@end
