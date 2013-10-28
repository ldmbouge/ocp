/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

// MIPSolver
#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModelTransformation.h>

#import "MIPProgram.h"
#import "MIPSolver.h"
#import <objmp/MIPSolverI.h>

@interface ORMIPFloatVarSnapshot : NSObject <ORSnapshot,NSCoding> {
   ORUInt    _name;
   ORFloat   _value;
}
-(ORMIPFloatVarSnapshot*) initMIPFloatVarSnapshot: (id<ORFloatVar>) v with: (id<MIPProgram>) solver;
-(ORFloat) floatValue;
-(NSString*) description;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
@end

@implementation ORMIPFloatVarSnapshot
-(ORMIPFloatVarSnapshot*) initMIPFloatVarSnapshot: (id<ORFloatVar>) v with: (id<MIPProgram>) solver
{
   self = [super init];
   _name = [v getId];
   _value = [solver floatValue: v];
   return self;
}
-(ORInt) intValue
{
   @throw [[ORExecutionError alloc] initORExecutionError: "intValue not implemented"];
}
-(ORBool) boolValue
{
   @throw [[ORExecutionError alloc] initORExecutionError: "boolValue not implemented"];
}
-(ORFloat) floatValue
{
   return _value;
}
-(ORBool) isEqual: (id) object
{
   if ([object isKindOfClass:[self class]]) {
      ORMIPFloatVarSnapshot* other = object;
      if (_name == other->_name) {
         return (_value == other->_value);
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
   [buf appendFormat:@"float(%d) : (%f)",_name,_value];
   return buf;
}

- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_value];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_value];
   return self;
}
@end

@interface ORMIPIntVarSnapshot : NSObject <ORSnapshot,NSCoding> {
   ORUInt _name;
   ORInt  _value;
}
-(ORMIPIntVarSnapshot*) initMIPIntVarSnapshot: (id<ORIntVar>) v with: (id<MIPProgram>) solver;
-(ORInt) intValue;
-(NSString*) description;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
-(ORUInt)getId;
@end

@implementation ORMIPIntVarSnapshot
-(ORMIPIntVarSnapshot*) initMIPIntVarSnapshot: (id<ORIntVar>) v with: (id<MIPProgram>) solver
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
-(ORBool) boolValue
{
   @throw [[ORExecutionError alloc] initORExecutionError: "boolValue not implemented"];
}
-(ORFloat) floatValue
{
   return _value;
   //@throw [[ORExecutionError alloc] initORExecutionError: "floatValue not implemented"];
}
-(ORBool) isEqual: (id) object
{
   if ([object isKindOfClass:[self class]]) {
      ORMIPIntVarSnapshot* other = object;
      if (_name == other->_name) {
         return (_value == other->_value);
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
   [buf appendFormat:@"int(%d) : (%d)",_name,_value];
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

@interface ORMIPTakeSnapshot  : ORNOopVisit<NSObject> // inherits from noop -> only fill relevant methods
-(ORMIPTakeSnapshot*) initORMIPTakeSnapshot: (id<MIPProgram>) solver;
-(void) dealloc;
@end

@implementation ORMIPTakeSnapshot
{
   id<MIPProgram> _solver;
   id             _snapshot;
}
-(ORMIPTakeSnapshot*) initORMIPTakeSnapshot: (id<MIPProgram>) solver
{
   self = [super init];
   _solver = solver;
   return self;
}
-(id) snapshot
{
   return _snapshot;
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
   _snapshot = [[ORMIPIntVarSnapshot alloc] initMIPIntVarSnapshot: v with: _solver];
}
-(void) visitFloatVar: (id<ORFloatVar>) v
{
   _snapshot = [[ORMIPFloatVarSnapshot alloc] initMIPFloatVarSnapshot: v with: _solver];
}
@end

@interface ORMIPSolutionI : ORObject<ORMIPSolution>
-(ORMIPSolutionI*) initORMIPSolutionI: (id<ORModel>) model with: (id<MIPProgram>) solver;
-(id<ORSnapshot>) value: (id) var;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
-(id<ORObjectiveValue>) objectiveValue;
@end


@implementation ORMIPSolutionI {
   NSArray*             _varShots;
   id<ORObjectiveValue> _objValue;
}
-(ORMIPSolutionI*) initORMIPSolutionI: (id<ORModel>) model with: (id<MIPProgram>) solver
{
   self = [super init];
   NSArray* av = [model variables];
   ORULong sz = [av count];
   NSMutableArray* snapshots = [[NSMutableArray alloc] initWithCapacity:sz];
   ORMIPTakeSnapshot* visit = [[ORMIPTakeSnapshot alloc] initORMIPTakeSnapshot: solver];
   [av enumerateObjectsUsingBlock: ^void(id obj, NSUInteger idx, BOOL *stop) {
      [obj visit: visit];
      id shot = [visit snapshot];
      if (shot)
         [snapshots addObject: shot];
      [shot release];
   }];
   _varShots = snapshots;
   
   if ([model objective])
      _objValue = [solver objectiveValue];
   else
      _objValue = nil;
   [visit release];
   return self;

}

-(void) dealloc
{
   NSLog(@"dealloc ORLPSolutionI");
   [_varShots release];
   [_objValue release];
   [super dealloc];
}

-(ORBool) isEqual: (id) object
{
   if ([object isKindOfClass: [self class]]) {
      ORMIPSolutionI* other = object;
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
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [var getId] == [obj getId];
   }];
   if (idx != NSNotFound)
      return [_varShots objectAtIndex:idx];
   else return nil;
}
-(ORInt) intValue: (id) var
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [var getId] == [obj getId];
   }];
   return [(id<ORSnapshot>) [_varShots objectAtIndex:idx] intValue];
}
-(ORBool) boolValue: (id) var
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [var getId] == [obj getId];
   }];
   return [(id<ORSnapshot>) [_varShots objectAtIndex:idx] intValue];
}
-(ORFloat) floatValue: (id<ORFloatVar>) var
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [var getId] == [obj getId];
   }];
   return [(id<ORSnapshot>) [_varShots objectAtIndex:idx] floatValue];
}
-(NSUInteger) count
{
   return [_varShots count];
}
- (void) encodeWithCoder: (NSCoder *)aCoder
{
   [aCoder encodeObject:_varShots];
}
- (id) initWithCoder:(NSCoder *) aDecoder
{
   self = [super init];
   _varShots = [[aDecoder decodeObject] retain];
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

@implementation MIPSolver
{
   MIPSolverI*  _MIPsolver;
   id<ORModel> _model;
   id<ORMIPSolutionPool> _sPool;
}
-(id<MIPProgram>) initMIPSolver: (id<ORModel>) model
{
   self = [super init];
#if defined(__linux__)
   _MIPsolver = NULL;
#else
   _MIPsolver = [MIPFactory solver];
   _model = model;
#endif
   _sPool = (id<ORMIPSolutionPool>) [ORFactory createSolutionPool];
   return self;
}
-(void) dealloc
{
   [_MIPsolver release];
   [_sPool release];
   [super dealloc];
}
-(MIPSolverI*) solver
{
   return _MIPsolver;
}
-(void) solve
{
   [_MIPsolver solve];
   id<ORMIPSolution> s = [self captureSolution];
   [_sPool addSolution: s];
   [s release];
}
-(ORFloat) floatValue: (id<ORFloatVar>) v
{
   return [_MIPsolver floatValue: _gamma[v.getId]];
}
-(ORFloat) paramFloatValue: (id<ORFloatParam>)p
{
    return [_MIPsolver floatParamValue: _gamma[p.getId]];
}
-(ORFloat) paramFloat: (id<ORFloatParam>)p setValue: (ORFloat)val
{
    [_MIPsolver setORFloatParameter: _gamma[p.getId] value: val];
}
-(ORFloat) floatExprValue: (id<ORExpr>)e {
    ORFloatExprEval* eval = [[ORFloatExprEval alloc] initORFloatExprEval: self];
    ORFloat v = [eval floatValue: e];
    [eval release];
    return v;
}
-(ORInt) intValue: (id<ORIntVar>) v
{
   return [_MIPsolver intValue: _gamma[v.getId]];
}
-(ORInt) intExprValue: (id<ORExpr>)e {
    ORIntExprEval* eval = [[ORIntExprEval alloc] initORIntExprEval: self];
    ORInt v = [eval intValue: e];
    [eval release];
    return v;
}
-(id<ORObjectiveValue>) objectiveValue
{
   return [_MIPsolver objectiveValue];
}
-(id<ORMIPSolution>) captureSolution
{
   return [[ORMIPSolutionI alloc] initORMIPSolutionI: _model with: self];
}
-(id) trackObject: (id) obj
{
   return [_MIPsolver trackObject:obj];
}
-(id) trackConstraintInGroup:(id)obj
{
   return [_MIPsolver trackConstraintInGroup:obj];
}
-(id) trackObjective: (id) obj
{
   return [_MIPsolver trackObjective:obj];
}
-(id) trackMutable: (id) obj
{
   return [_MIPsolver trackMutable:obj];
}
-(id) trackImmutable:(id)obj
{
   return [_MIPsolver trackImmutable:obj];
}
-(id) trackVariable: (id) obj
{
   return [_MIPsolver trackVariable:obj];
}
-(id<ORMIPSolutionPool>) solutionPool
{
   return _sPool;
}
@end


@implementation MIPSolverFactory
+(id<MIPProgram>) solver: (id<ORModel>) model
{
   return [[MIPSolver alloc] initMIPSolver: model];
}
@end
