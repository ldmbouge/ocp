/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/ORSolution.h>

// [pvh] generic but absolutely boring and this is how it should be.
// The essence is in the concrete variables and the protocols

@protocol ORQueryIntVar
-(ORInt) intValue;
-(ORBool) bound;
@end;

@protocol ORQueryRealVar
-(ORDouble) doubleValue;
-(ORBool) bound;
@end;

@implementation ORSolution

-(ORSolution*) initORSolution: (id<ORModel>) model with: (id<ORASolver>) solver
{
   self = [super init];
    _model = model;
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
  for(id<ORObject> obj in _varShots) {
    if ([obj getId] == [var getId])
      return obj;
  }
  return nil;
  
   // NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
   //    return [obj getId] == [var getId];
   // }];
   // if (idx < [_varShots count])
   //    return [_varShots objectAtIndex:idx];
   // else
   //    return nil;
}
-(ORInt) intValue: (id) var
{
  for(id obj in _varShots) {
    if ([obj getId] == [var getId])
      return [obj intValue];
  }
  return 0;
   // NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
   //    return [obj getId] == [var getId];
   // }];
   // id snap = [_varShots objectAtIndex:idx];
   // return [snap intValue];
}
-(ORBool) boolValue: (id) var
{
  for(id obj in _varShots) {
    if ([obj getId] == [var getId])
      return [obj intValue];
  }
  return NO;
   // NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
   //    return [obj getId] == [var getId];
   // }];
   // id snap = [_varShots objectAtIndex:idx];
   // return [snap intValue];
}
-(ORDouble) doubleValue: (id<ORRealVar>) var
{
  for(id<ORObject> obj in _varShots) {
    if ([obj getId] == [var getId])
      return [(id<ORQueryRealVar>)obj doubleValue];
  }
  return 0.0;
   // NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
   //    return [obj getId] == [var getId];
   // }];
   // id<ORQueryRealVar> snap = [_varShots objectAtIndex:idx];
   // return [snap doubleValue];
}
-(NSUInteger) count
{
   return [_varShots count];
}
-(id<ORModel>) model
{
    return _model;
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
   [_varShots enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [buf appendFormat:@"%@%c",obj,idx < last ? ',' : ')'];
   }];
   return buf;
}
@end

@implementation ORParameterizedSolution

-(ORParameterizedSolution*) initORParameterizedSolution:(id<ORParameterizedModel>)model with:(id<ORASolver>)solver
{
    self = [super initORSolution: model with: solver];
    NSArray* ap = [model parameters];
    NSMutableArray* paramShots = [[NSMutableArray alloc] initWithCapacity: [ap count]];
    for(id obj in ap) {
        id shot = [[solver concretize: obj] takeSnapshot: [obj getId]];
        if (shot)
            [paramShots addObject: shot];
        [shot release];
    }
    _paramShots = paramShots;
    return self;
}

-(void) dealloc
{
    [_paramShots release];
    [super dealloc];
}

-(ORBool) isEqual: (id) object
{
    if ([object isKindOfClass: [self class]]) {
        ORParameterizedSolution* other = object;
        if (_objValue && other->_objValue) {
            if ([_objValue isEqual:other->_objValue]) {
                return [_varShots isEqual:other->_varShots] && [_paramShots isEqual: other->_paramShots];
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
-(id) value: (id) var
{
    if([var conformsToProtocol: @protocol(ORParameter)]) {
        NSUInteger idx = [_paramShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [obj getId] == [var getId];
        }];
        if (idx < [_paramShots count])
            return [_paramShots objectAtIndex:idx];
        else return nil;
    }
    return [super value: var];
}
-(ORDouble) paramValue: (id<ORParameter>) param;
{
    NSUInteger idx = [_paramShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj getId] == [param getId];
    }];
    id<ORQueryRealVar> snap = [_paramShots objectAtIndex:idx];
    return [snap doubleValue];
}
-(NSUInteger) count
{
    return [_varShots count] + [_paramShots count];
}
- (void) encodeWithCoder: (NSCoder *)aCoder
{
    [super encodeWithCoder: aCoder];
    [aCoder encodeObject:_paramShots];
}
- (id) initWithCoder:(NSCoder *) aDecoder
{
    self = [super initWithCoder: aDecoder];
    _paramShots = [[aDecoder decodeObject] retain];
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
    [_varShots enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [buf appendFormat:@"%@%c",obj,idx < last ? ',' : ')'];
    }];
    [_paramShots enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [buf appendFormat:@"%@%c",obj,idx < last ? ',' : ')'];
    }];
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
-(void) emptyPool
{
  @synchronized(self) {
    [_all removeAllObjects];
  }
}

-(void) addSolution:(id<ORSolution>)s
{
   @synchronized(self) {
    [_all addObject:s];
   }
   [_solutionAddedInformer notifyWithSolution: s];
}

-(id<ORSolution>) objectAtIndexedSubscript: (NSUInteger) key
{
   return [_all objectAtIndexedSubscript:key];
}

-(void) enumerateWith:(void(^)(id<ORSolution>))block
{
  @synchronized(self) {
    for(id obj in _all)
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
   @synchronized(self) {
     [_all enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop) {
	 [buf appendFormat:@"\t%@\n",obj];
       }];
   }
   [buf appendFormat:@"]"];
   return buf;
}

-(id<ORSolution>) best
{
   __block id<ORSolution> sel = nil;
   __block id<ORObjectiveValue> bestSoFar = nil;
   @synchronized(self) {
     [_all enumerateObjectsUsingBlock:^(id<ORSolution> obj,NSUInteger idx, BOOL *stop) {
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
       }];
   }
   return [sel retain];
}
@end

