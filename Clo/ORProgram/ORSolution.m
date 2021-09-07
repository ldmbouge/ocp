/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import "ORSolution.h"

// [pvh] generic but absolutely boring and this is how it should be. The essence is in the concrete variables and the protocols

@protocol ORQueryIntVar
-(ORInt) intValue;
-(ORBool) bound;
@end;

@protocol ORQueryFloatVar
-(ORFloat) floatValue;
-(ORBool) bound;
@end;

@implementation ORSolution

-(ORSolution*) initORSolution: (id<ORModel>) model with: (id<ORASolver>) solver
{
   self = [super init];
   NSArray* av = [model variables];
   NSArray* ac = [model constraints];
   ORULong sz = [av count];
   NSMutableArray* varShots = [[NSMutableArray alloc] initWithCapacity:sz];
   for(id obj in av) {
//      NSLog(@" variable id: %d",[obj getId]);
      id shot = [[solver concretize: obj] takeSnapshot: [obj getId]];
      if (shot)
         [varShots addObject: shot];
      [shot release];
   }
   _varShots = varShots;

   for(id obj in ac) {
//      NSLog(@" Constraint id: %d",[obj getId]);
      id shot = [[solver concretize: obj] takeSnapshot: [obj getId]];
      if (shot)
         [varShots addObject: shot];
      [shot release];
   }
   if ([model objective])
      _objValue = [solver objectiveValue];
   else
      _objValue = nil;
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
  ORInt vid = [var getId];
  for(id obj in _varShots) {
    if ([obj getId] == vid)
      return [obj intValue];
  }
  return 0;
}
-(ORBool) boolValue: (id) var
{
  ORInt vid = [var getId];
  for(id obj in _varShots) {
    if ([obj getId] == vid)
      return [obj intValue];
  }
  return 0;
}
-(ORFloat) floatValue: (id<ORFloatVar>) var
{
  ORInt vid = [var getId];
  for(id obj in _varShots) {
    if ([obj getId] == vid)
      return [obj floatValue];
  }
  return 0;
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
   int idx=0;
   for(id obj in _varShots) {
      [buf appendFormat:@"%@%c",obj,idx < last ? ',' : ')'];
      ++idx;
   }     
   return buf;
}
@end

@implementation ORSolutionPool
-(id) init
{
   self = [super init];
   _all = [[NSMutableArray alloc] initWithCapacity:64];
   _solutionAddedInformer = [ORFactory solutionInformer];
   return self;
}

-(void) dealloc
{
   [_all release];
   [super dealloc];
}
-(NSUInteger) count
{
   return [_all count];
}
-(void) addSolution:(id<ORSolution>)s
{
   [_all addObject:s];
   [_solutionAddedInformer notifyWithSolution: s];
}

-(id<ORSolution>) objectAtIndexedSubscript: (NSUInteger) key
{
   return [_all objectAtIndexedSubscript:key];
}

-(void) enumerateWith:(void(^)(id<ORSolution>))block
{
  for(id obj in _all) {
    block(obj);
  }
}

-(id<ORInformer>)solutionAdded
{
   return _solutionAddedInformer;
}

-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"pool["];
   for(id obj in _all)
      [buf appendFormat:@"\t%@\n",obj];
   [buf appendFormat:@"]"];
   return buf;
}

-(id<ORSolution>) best
{
   __block id<ORSolution> sel = nil;
   __block id<ORObjectiveValue> bestSoFar = nil;
   for(id obj in _all) {
     if (bestSoFar == nil) {
       bestSoFar = [obj objectiveValue];
       sel = obj;
     }
     else {
       id<ORObjectiveValue> nv = [obj objectiveValue];
       if ([bestSoFar compare: nv] == 1) {
	 bestSoFar = nv;
	 sel = obj;
       }
     }
   }
   return [sel retain];
}
@end

