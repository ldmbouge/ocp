/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

// LPSolver
#import <ORFoundation/ORFoundation.h>
#import "LPProgram.h"
#import "LPSolver.h"
#import <objmp/LPSolverI.h>


@interface ORLPFloatVarSnapshot : NSObject <ORSnapshot,NSCoding> {
   ORUInt    _name;
   ORFloat   _value;
   ORFloat   _reducedCost;
   
}
-(ORLPFloatVarSnapshot*) initLPFloatVarSnapshot: (id<ORFloatVar>) v with: (id<LPProgram>) solver;
-(void)restoreInto:(NSArray*)av;
-(ORFloat) floatValue;
-(ORFloat) reducedCost;
-(NSString*) description;
-(BOOL) isEqual: (id) object;
-(NSUInteger) hash;
@end

@implementation ORLPFloatVarSnapshot
-(ORLPFloatVarSnapshot*) initLPFloatVarSnapshot: (id<ORFloatVar>) v with: (id<LPProgram>) solver
{
   self = [super init];
   _name = [v getId];
   _value = [solver floatValue: v];
   _reducedCost = [solver reducedCost: v];
   return self;
}
-(void) restoreInto: (NSArray*) av
{
   @throw [[ORExecutionError alloc] initORExecutionError: "restoreInto not implemented"];
}
-(ORInt) intValue
{
   @throw [[ORExecutionError alloc] initORExecutionError: "intValue not implemented"];
}
-(BOOL) boolValue
{
   @throw [[ORExecutionError alloc] initORExecutionError: "boolValue not implemented"];
}
-(ORFloat) floatValue
{
   return _value;
}
-(ORFloat) reducedCost
{
   return _reducedCost;
}
-(BOOL) isEqual: (id) object
{
   if ([object isKindOfClass:[self class]]) {
      ORLPFloatVarSnapshot* other = object;
      if (_name == other->_name) {
         return (_value == other->_value) && (_reducedCost == other->_reducedCost);
      }
      else
         return NO;
   }
   else
      return NO;
}
-(NSUInteger) hash
{
   return (_name << 16) + (ORInt) _value;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"float(%d) : (%f,%f)",_name,_value,_reducedCost];
   return buf;
}

- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_value];
   [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_reducedCost];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_value];
   [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_reducedCost];
   return self;
}
@end

@interface ORLPConstraintSnapshot : NSObject <ORSnapshot,NSCoding> {
   ORUInt    _name;
   ORFloat   _dual;
}
-(ORLPConstraintSnapshot*) initLPConstraintSnapshot: (id<ORConstraint>) cstr with: (id<LPProgram>) solver;
-(void)restoreInto:(NSArray*)av;
-(ORFloat) dual;
-(NSString*) description;
-(BOOL) isEqual: (id) object;
-(NSUInteger) hash;
@end

@implementation ORLPConstraintSnapshot
-(ORLPConstraintSnapshot*) initLPConstraintSnapshot: (id<ORConstraint>) cstr with: (id<LPProgram>) solver
{
   self = [super init];
   _name = [cstr getId];
   _dual = [solver dual: cstr];
   return self;
}
-(void) restoreInto: (NSArray*) av
{
   @throw [[ORExecutionError alloc] initORExecutionError: "restoreInto not implemented"];
}
-(ORInt) intValue
{
   @throw [[ORExecutionError alloc] initORExecutionError: "intValue not implemented"];
}
-(BOOL) boolValue
{
   @throw [[ORExecutionError alloc] initORExecutionError: "boolValue not implemented"];
}
-(ORFloat) floatValue
{
   @throw [[ORExecutionError alloc] initORExecutionError: "boolValue not implemented"];   
}
-(ORFloat) dual
{
   return _dual;
}
-(BOOL) isEqual: (id) object
{
   if ([object isKindOfClass:[self class]]) {
      ORLPConstraintSnapshot* other = object;
      if (_name == other->_name) {
         return _dual == other->_dual;
      }
      else
         return NO;
   }
   else
      return NO;
}
-(NSUInteger) hash
{
   return (_name << 16) + (ORInt) _dual;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"lp(constraint)(%d) : (%f)",_name,_dual];
   return buf;
}

- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_dual];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_dual];
   return self;
}
@end

@interface ORLPSolutionI : NSObject<ORSolution>
-(ORLPSolutionI*) initORLPSolutionI: (id<ORModel>) model with: (id<LPProgram>) solver;
-(id<ORSnapshot>) value: (id<ORFloatVar>) var;
-(ORFloat) reducedCost: (id<ORFloatVar>) var;
-(ORFloat) dual: (id<ORConstraint>) var;
-(NSUInteger) count;
-(BOOL)isEqual: (id) object;
-(NSUInteger) hash;
-(id<ORObjectiveValue>) objectiveValue;
@end


@implementation ORLPSolutionI {
   NSArray*             _varShots;
   NSArray*             _cstrShots;
   id<ORObjectiveValue> _objValue;
}

-(ORLPSolutionI*) initORLPSolutionI: (id<ORModel>) model with: (id<LPProgram>) solver
{
   self = [super init];
   NSArray* av = [model variables];
   ORULong sz = [av count];
   NSMutableArray* snapshots = [[NSMutableArray alloc] initWithCapacity:sz];
   [av enumerateObjectsUsingBlock: ^void(id obj, NSUInteger idx, BOOL *stop) {
      ORLPFloatVarSnapshot* shot = [[ORLPFloatVarSnapshot alloc] initLPFloatVarSnapshot: obj with: solver];
      [snapshots addObject: shot];
      [shot release];
   }];
   _varShots = snapshots;
   
   NSArray* ac = [model constraints];
   sz = [ac count];
   snapshots = [[NSMutableArray alloc] initWithCapacity:sz];
   [ac enumerateObjectsUsingBlock: ^void(id obj, NSUInteger idx, BOOL *stop) {
      ORLPConstraintSnapshot* shot = [[ORLPConstraintSnapshot alloc] initLPConstraintSnapshot: obj with: solver];
      [snapshots addObject: shot];
      [shot release];
   }];
   _cstrShots = snapshots;
   
   if ([model objective])
      _objValue = [[model objective] value];
   else
      _objValue = nil;
   return self;
}

-(void) dealloc
{
   [_varShots release];
   [_cstrShots release];
   [_objValue release];
   [super dealloc];
}

-(BOOL) isEqual: (id) object
{
   if ([object isKindOfClass: [self class]]) {
      ORLPSolutionI* other = object;
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
-(id<ORSnapshot>) value: (id) var
{
   NSUInteger idx = [var getId];
   if (idx < [_varShots count])
      return [_varShots objectAtIndex:idx];
   else
      return nil;
}
-(ORInt) intValue: (id) var
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No boolean variable in LP solutions"];   
}
-(BOOL) boolValue: (id) var
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No boolean variable in LP solutions"];
}

-(ORFloat) floatValue: (id<ORFloatVar>) var
{
   return [(id<ORSnapshot>) [_varShots objectAtIndex:[var getId]] floatValue];
}
-(ORFloat) reducedCost: (id<ORFloatVar>) var
{
   return [[_varShots objectAtIndex:[var getId]] reducedCost];
}
-(ORFloat) dual: (id<ORConstraint>) cstr
{
   return [[_cstrShots objectAtIndex:[cstr getId]] dual];
}
-(NSUInteger) count
{
   return [_varShots count];
}
- (void) encodeWithCoder: (NSCoder *)aCoder
{
   [aCoder encodeObject:_varShots];
    [aCoder encodeObject:_cstrShots];
   [aCoder encodeObject:_objValue];
}
- (id) initWithCoder:(NSCoder *) aDecoder
{
   self = [super init];
   _varShots = [[aDecoder decodeObject] retain];
   _cstrShots = [[aDecoder decodeObject] retain];
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
   [_cstrShots enumerateObjectsUsingBlock:^(id<ORSnapshot> obj, NSUInteger idx, BOOL *stop) {
      [buf appendFormat:@"cstr(%@%c)",obj,idx < last ? ',' : ')'];
   }];
   return buf;
}
@end


@interface LPColumn : ORModelingObjectI<LPColumn>
-(id<LPColumn>) initLPColumn: (LPSolver*) lpsolver with: (LPColumnI*) col;
-(void) addObjCoef: (ORFloat) coef;
-(void) addConstraint: (id<ORConstraint>) cstr coef: (ORFloat) coef;
@end

@implementation LPColumn
{
   LPSolver* _lpsolver;
}
-(id<LPColumn>) initLPColumn: (LPSolver*) lpsolver with: (LPColumnI*) col
{
   self = [super init];
   _impl = col;
   _lpsolver = lpsolver;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(void) addObjCoef: (ORFloat) coef
{
   [(LPColumnI*)_impl addObjCoef: coef];
}
// pvh to fix: will need more interesting dereference once we have multiple clones
-(void) addConstraint: (id<ORConstraint>) cstr coef: (ORFloat) coef
{
   [(LPColumnI*) _impl addConstraint: [cstr dereference] coef: coef];
}
@end

@implementation LPSolver
{
   LPSolverI*  _lpsolver;
   id<ORModel> _model;
   id<ORSolutionPool> _sPool;
}
-(id<LPProgram>) initLPSolver: (id<ORModel>) model
{
   self = [super init];
#if defined(__linux__)
   _lpsolver = NULL;
#else
   _lpsolver = [LPFactory solver];
   _model = model;
#endif
   _sPool = [ORFactory createSolutionPool];
   return self;
}
-(void) dealloc
{
   [_lpsolver release];
   [_sPool release];
   [super dealloc];
}
-(LPSolverI*) solver
{
   return _lpsolver;
}
-(void) solve
{
   [_lpsolver solve];
//   id<ORSolution> s = [_model captureSolution];
//   [_sPool addSolution: s];
//   NSLog(@"Solution = %@",s);
   ORLPSolutionI* sol = [[ORLPSolutionI alloc] initORLPSolutionI: _model with: self];
   [_sPool addSolution: sol];
}
-(ORFloat) dual: (id<ORConstraint>) c
{
   return [_lpsolver dual: [c dereference]];
}
-(ORFloat) floatValue: (id<ORFloatVar>) v
{
   return [_lpsolver floatValue: [v dereference]];
}
-(ORFloat) reducedCost: (id<ORFloatVar>) v
{
   return [_lpsolver reducedCost: [v dereference]];
}
-(id<LPColumn>) createColumn
{
   LPColumnI* col = [_lpsolver createColumn];
   id<LPColumn> o = [[LPColumn alloc] initLPColumn: self with: col];
   [self trackObject: o];
   return o;
}
-(id<LPColumn>) createColumn: (ORFloat) low up: (ORFloat) up
{
   LPColumnI* col = [_lpsolver createColumn: low up: up];
   id<LPColumn> o = [[LPColumn alloc] initLPColumn: self with: col];
   [self trackObject: o];
   return o;
}

-(void) addColumn: (LPColumn*) column
{
   [_lpsolver postColumn: [column impl]];
   id<ORSolution> s = [_model captureSolution];
   [_sPool addSolution: s];
}
-(void) trackObject: (id) obj
{
   [_lpsolver trackObject:obj];
}
-(void) trackVariable: (id) obj
{
   [_lpsolver trackVariable:obj];
}
-(void) trackConstraint:(id) obj
{
   [_lpsolver trackConstraint:obj];
}
-(id<ORSolutionPool>) solutionPool
{
   return _sPool;
}
-(id<ORSolutionPool>) globalSolutionPool
{
   return _sPool;
}
-(id<ORLPSolutionPool>) lpSolutionPool
{
   return (id<ORLPSolutionPool>) _sPool;
}
@end


@implementation LPSolverFactory
+(id<LPProgram>) solver: (id<ORModel>) model
{
   return [[LPSolver alloc] initLPSolver: model];
}
@end
