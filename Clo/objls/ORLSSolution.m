/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORLSSolution.h"
#import <ORFoundation/ORVar.h>

@interface ORLSIntVarSnapshot : NSObject<ORSnapshot,NSCoding> {
   ORUInt    _name;
   ORInt     _value;
}
-(id) init: (id<ORIntVar>) v with: (id<LSProgram>) solver;
-(int) intValue;
-(ORBool) boolValue;
-(NSString*) description;
-(ORBool)isEqual: (id) object;
-(NSUInteger) hash;
-(ORUInt)getId;
@end

@implementation ORLSIntVarSnapshot
-(id) init: (id<ORIntVar>) v with: (id<LSProgram>) solver;
{
   self = [super init];
   _name = [v getId];
   _value = [solver intValue: v];
   return self;
}
-(ORUInt)getId
{
   return _name;
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
      ORLSIntVarSnapshot* other = object;
      if (_name == other->_name) {
         return _value == other->_value;
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
   [buf appendFormat:@"int(%d) : %d",_name,_value];
   return buf;
}
- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_value];
}
- (id) initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_value];
   return self;
}
@end


@interface ORLSTakeSnapshot  : ORNOopVisit<NSObject>
-(id) init: (id<LSProgram>) solver;
@end

@implementation ORLSTakeSnapshot
{
   id<LSProgram> _solver;
   id            _snapshot;
}
-(id) init: (id<LSProgram>) solver
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
-(void) visitIntVar: (id<ORIntVar>) v
{
   _snapshot = [[ORLSIntVarSnapshot alloc] init: v with: _solver];
}
-(void) visitFloatVar: (id<ORFloatVar>) v
{
//   _snapshot = [[ORCPFloatVarSnapshot alloc] initCPFloatVarSnapshot: v with: _solver];
}
@end


@implementation ORLSSolution {
   NSMutableArray*      _varShots;
   id<ORObjectiveValue> _objValue;
}

-(id) initORLSSolution: (id<ORModel>) model with: (id<LSProgram>) solver
{
   self = [super init];
   NSArray* av  = [model variables];
   ORInt nbVars = (ORInt)[av count];
   _varShots = [[NSMutableArray alloc] initWithCapacity:nbVars];
   _objValue = nil;
   ORLSTakeSnapshot* visit = [[ORLSTakeSnapshot alloc] init: solver];
   for(id obj in av) {
      id shot = [visit snapshot:obj];
      if (shot)
         [_varShots addObject: shot];
      [shot release];
   }
   if ([model objective])
      _objValue = [[solver objective] value];
   else
      _objValue = nil;
   [visit release];
   return self;
}
-(id<ORSnapshot>) value: (id) var
{
   ORInt vid = getId(var);
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return getId(obj) == vid;
   }];
   if (idx < [_varShots count])
      return [_varShots objectAtIndex:idx];
   else
      return nil;
}
-(ORInt) intValue: (id<ORIntVar>) var
{
   return [[self value:var] intValue];
}
-(ORBool) boolValue: (id<ORIntVar>) var
{
   return [[self value:var] boolValue];
}
-(ORFloat) floatValue: (id<ORFloatVar>) var
{
   return [[self value:var] floatValue];
}
-(ORFloat) floatMin: (id<ORFloatVar>) var
{
   return 0.0;
}
-(ORFloat) floatMax: (id<ORFloatVar>) var
{
   return 0.0;
}
-(id<ORObjectiveValue>) objectiveValue
{
   return _objValue;
}
@end
