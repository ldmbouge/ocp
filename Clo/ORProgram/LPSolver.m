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
#import <ORFoundation/ORExprEval.h>


@interface ORLPFloatVarSnapshot : NSObject <ORSnapshot,NSCoding> {
   ORUInt    _name;
   ORFloat   _value;
   ORFloat   _reducedCost;
   
}
-(ORLPFloatVarSnapshot*) initLPFloatVarSnapshot: (id<ORFloatVar>) v with: (id<LPProgram>) solver;
-(ORFloat) floatValue;
-(ORFloat) reducedCost;
-(NSString*) description;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
-(ORUInt)getId;
@end

@interface ORLPFloatParamSnapshot : NSObject <ORSnapshot,NSCoding> {
   ORUInt    _name;
   ORFloat   _value;
   
}
-(ORLPFloatParamSnapshot*) initLPFloatParamSnapshot: (id<ORFloatParam>) p with: (id<LPProgram>) solver;
-(ORFloat) floatValue;
-(NSString*) description;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
-(ORUInt)getId;
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
-(ORUInt)getId
{
   return _name;
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
-(ORFloat) reducedCost
{
   return _reducedCost;
}
-(ORBool) isEqual: (id) object
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

@implementation ORLPFloatParamSnapshot
-(ORLPFloatParamSnapshot*) initLPFloatParamSnapshot: (id<ORFloatParam>) p with: (id<LPProgram>) solver
{
   self = [super init];
   _name = [p getId];
   _value = [solver paramFloatValue: p];
   return self;
}
-(ORUInt)getId
{
   return _name;
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
      ORLPFloatParamSnapshot* other = object;
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
   [buf appendFormat:@"floatparam(%d) : %f",_name,_value];
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


@interface ORLPConstraintSnapshot : NSObject <ORSnapshot,NSCoding> {
   ORUInt    _name;
   ORFloat   _dual;
}
-(ORLPConstraintSnapshot*) initLPConstraintSnapshot: (id<ORConstraint>) cstr with: (id<LPProgram>) solver;
-(ORFloat) dual;
-(NSString*) description;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
-(ORUInt)getId;
@end

@implementation ORLPConstraintSnapshot
-(ORLPConstraintSnapshot*) initLPConstraintSnapshot: (id<ORConstraint>) cstr with: (id<LPProgram>) solver
{
   self = [super init];
   _name = [cstr getId];
   _dual = [solver dual: cstr];
   return self;
}
-(ORUInt)getId
{
   return _name;
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
   @throw [[ORExecutionError alloc] initORExecutionError: "boolValue not implemented"];   
}
-(ORFloat) dual
{
   return _dual;
}
-(ORBool) isEqual: (id) object
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

@interface ORLPSolutionI : ORObject<ORLPSolution>
-(ORLPSolutionI*) initORLPSolutionI: (id<ORModel>) model with: (id<LPProgram>) solver;
-(id<ORSnapshot>) value: (id<ORFloatVar>) var;
-(ORFloat) reducedCost: (id<ORFloatVar>) var;
-(ORFloat) dual: (id<ORConstraint>) var;
-(NSUInteger) count;
-(ORBool)isEqual: (id) object;
-(NSUInteger) hash;
-(id<ORObjectiveValue>) objectiveValue;
@end


@implementation ORLPSolutionI {
   NSArray*             _varShots;
   NSArray*             _paramShots;
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
   
   if([[model source] conformsToProtocol: @protocol(ORParameterizedModel)]) {
      NSArray* ap = [(id<ORParameterizedModel>)[model source] parameters];
      ORULong sz = [ap count];
      NSMutableArray* snapshots = [[NSMutableArray alloc] initWithCapacity:sz];
      [av enumerateObjectsUsingBlock: ^void(id obj, NSUInteger idx, BOOL *stop) {
         ORLPFloatParamSnapshot* shot = [[ORLPFloatParamSnapshot alloc] initLPFloatParamSnapshot: obj with: solver];
         [snapshots addObject: shot];
         [shot release];
      }];
      _paramShots = snapshots;
   }
   else _paramShots = nil;
   
   NSArray* ac = [model constraints];
   sz = [ac count];
   snapshots = [[NSMutableArray alloc] initWithCapacity:sz];
   [ac enumerateObjectsUsingBlock: ^void(id obj, NSUInteger idx, BOOL *stop) {
      ORLPConstraintSnapshot* shot = [[ORLPConstraintSnapshot alloc] initLPConstraintSnapshot: obj with: solver];
      [snapshots addObject: shot];
      [shot release];
   }];
   _cstrShots = snapshots;
   // PVH to change
   if ([model objective])
      _objValue = [solver objectiveValue];
   else
      _objValue = nil;
   return self;
}

-(void) dealloc
{
   NSLog(@"dealloc ORLPSolutionI");
   [_varShots release];
   [_cstrShots release];
   [_objValue release];
   [super dealloc];
}

-(ORBool) isEqual: (id) object
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
   @throw [[ORExecutionError alloc] initORExecutionError: "No int variable in LP solutions"];   
}
-(ORBool) boolValue: (id) var
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No boolean variable in LP solutions"];
}
-(ORFloat) floatValue: (id<ORFloatVar>) var
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [var getId];
   }];
   return [(id<ORSnapshot>) [_varShots objectAtIndex:idx] floatValue];
}
-(ORFloat) paramFloatValue: (id<ORFloatParam>)p
{
   NSUInteger idx = [_paramShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [p getId];
   }];
   return [(id<ORSnapshot>) [_paramShots objectAtIndex:idx] floatValue];
}
-(ORFloat) floatMin: (id<ORFloatVar>) var
{
   return [self floatValue: var];
}
-(ORFloat) floatMax: (id<ORFloatVar>) var
{
   return [self floatValue: var];  
}
-(ORFloat) reducedCost: (id<ORFloatVar>) var
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [var getId];
   }];
   return [[_varShots objectAtIndex:idx] reducedCost];
}
-(ORFloat) dual: (id<ORConstraint>) cstr
{
   NSUInteger idx = [_cstrShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [cstr getId];
   }];
   return [[_cstrShots objectAtIndex:idx] dual];
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


@interface LPColumn : ORObject<LPColumn>
-(id<LPColumn>) initLPColumn: (LPSolver*) lpsolver with: (LPColumnI*) col;
-(void) addObjCoef: (ORFloat) coef;
-(void) addConstraint: (id<ORConstraint>) cstr coef: (ORFloat) coef;
-(ORFloat) objCoef;
@end

@implementation LPColumn
{
   LPSolver* _lpsolver;
   LPColumnI* _lpcolumn;
}
-(id<LPColumn>) initLPColumn: (LPSolver*) lpsolver with: (LPColumnI*) col
{
   self = [super init];
   _lpcolumn = col;
   _lpsolver = lpsolver;
   return self;
}
-(id)theVar
{
   return [_lpcolumn theVar];
}
-(void) dealloc
{
   [super dealloc];
}
-(NSString*)description
{
   return [_lpcolumn description];
}
-(LPColumnI*) column
{
   return _lpcolumn;
}
-(void) addObjCoef: (ORFloat) coef
{
   [_lpcolumn addObjCoef: coef];
}
-(void) addConstraint: (id<ORConstraint>) cstr coef: (ORFloat) coef
{
   [_lpcolumn addConstraint: [_lpsolver concretize: cstr] coef: coef];
}
-(ORFloat) objCoef
{
   return [_lpcolumn objCoef];
}

@end

@implementation LPSolver
{
   LPSolverI*  _lpsolver;
   id<ORModel> _model;
   id<ORLPSolutionPool> _sPool;
}
-(id<LPProgram>) initLPSolver: (id<ORModel>) model
{
   self = [super init];
   _lpsolver = [LPFactory solver];
   _model = model;
   _sPool = (id<ORLPSolutionPool>) [ORFactory createSolutionPool];
   return self;
}
-(void) dealloc
{
   NSLog(@"dealloc LPSolver");
   [_lpsolver release];
   [_sPool release];
   [super dealloc];
}
-(void)close
{}
-(id<OREngine>) engine
{
   return _lpsolver;
}
-(LPSolverI*) solver
{
   return _lpsolver;
}
-(void)enumerateColumnWith:(void(^)(id<LPColumn>))block
{
   [_lpsolver enumerateColumnWith:block];
}

-(void) solve
{
   [_lpsolver solve];
   ORLPSolutionI* sol = [self captureSolution];
   [_sPool addSolution: sol];
   [sol release];
}
-(ORFloat) dual: (id<ORConstraint>) c
{
   return [_lpsolver dual: [self concretize: c]];
}
-(ORFloat) floatValue: (id<ORFloatVar>) v
{
   return [_lpsolver floatValue: _gamma[v.getId]];
}
-(ORFloat) reducedCost: (id<ORFloatVar>) v
{
   return [_lpsolver reducedCost: _gamma[v.getId]];
}
-(ORFloat) paramFloatValue: (id<ORFloatParam>)p
{
   return [_lpsolver floatParamValue: _gamma[p.getId]];
}
-(ORFloat) paramFloat: (id<ORFloatParam>)p setValue: (ORFloat)val
{
   [_lpsolver setORFloatParameter: _gamma[p.getId] value: val];
   return val;
}
-(ORInt) intValue: (id<ORIntVar>) v
{
   return (ORInt)[_lpsolver floatValue: _gamma[v.getId]];
}
-(ORInt) intExprValue: (id<ORExpr>)e {
   return (ORInt)[self floatExprValue: e];
}
-(ORFloat) floatExprValue: (id<ORExpr>)e {
   ORFloatExprEval* eval = [[ORFloatExprEval alloc] initORFloatExprEval: self];
   ORFloat v = [eval floatValue: e];
   [eval release];
   return v;
}
-(id<LPColumn>) freshColumn
{
   LPColumnI* col = [_lpsolver freshColumn];
   id<LPColumn> o = [[LPColumn alloc] initLPColumn: self with: col];
   [self trackMutable: o];
   return o;
}
-(id<LPColumn>) createColumn: (ORFloat) low up: (ORFloat) up
{
   LPColumnI* col = [_lpsolver createColumn:nil low:low up: up];
   id<LPColumn> o = [[LPColumn alloc] initLPColumn: self with: col];
   [self trackMutable: o];
   return o;
}

-(void) addColumn: (LPColumn*) column
{
   [_lpsolver postColumn: [column column]];
   ORLPSolutionI* sol = [self captureSolution];
   [_sPool addSolution: sol];
   [sol release];
}
-(id) trackObject: (id) obj
{
   return [_lpsolver trackObject:obj];
}
-(id) trackConstraintInGroup:(id)obj
{
   return [_lpsolver trackConstraintInGroup:obj];
}
-(id) trackObjective: (id) obj
{
   return [_lpsolver trackObjective:obj];
}
-(id) trackMutable: (id) obj
{
   return [_lpsolver trackMutable:obj];
}
-(id) trackVariable: (id) obj
{
   return [_lpsolver trackVariable:obj];
}
-(id) trackImmutable:(id)obj
{
   return [_lpsolver trackImmutable:obj];
}
-(id<ORLPSolutionPool>) solutionPool
{
   return _sPool;
}
-(id<ORObjectiveValue>) objectiveValue
{
   return [_lpsolver objectiveValue];
}
-(id<ORLPSolution>) captureSolution
{
   return [[ORLPSolutionI alloc] initORLPSolutionI: _model with: self];
}
-(id<ORTracker>) tracker
{
   return self;
}
@end


@implementation LPRelaxation
{
   LPSolverI*  _lpsolver;
   id<ORModel> _model;
}
-(id<LPRelaxation>) initLPRelaxation: (id<ORModel>) model
{
   self = [super init];
   _lpsolver = [LPFactory solver];
   _model = model;
   return self;
}
-(void) dealloc
{
   NSLog(@"dealloc LPSolver");
   [_lpsolver release];
   [super dealloc];
}
-(void)close
{
   [_lpsolver close];
}
-(id<OREngine>) engine
{
   return _lpsolver;
}
-(LPSolverI*) solver
{
   return _lpsolver;
}
-(OROutcome) solve
{
   return [_lpsolver solve];
}
-(ORFloat) dual: (id<ORConstraint>) c
{
   return [_lpsolver dual: [self concretize: c]];
}
-(ORFloat) floatValue: (id<ORFloatVar>) v
{
   return [_lpsolver floatValue: _gamma[v.getId]];
}
-(ORInt) intValue: (id<ORFloatVar>) v
{
   return (ORInt)[self floatValue: v];
}
-(ORFloat) reducedCost: (id<ORFloatVar>) v
{
   return [_lpsolver reducedCost: _gamma[v.getId]];
}
-(ORInt) intExprValue: (id<ORExpr>)e {
   return (ORInt)[self floatExprValue: e];
}
-(ORFloat) floatExprValue: (id<ORExpr>)e {
   ORFloatExprEval* eval = [[ORFloatExprEval alloc] initORFloatExprEval: self];
   ORFloat v = [eval floatValue: e];
   [eval release];
   return v;
}
-(ORFloat) objective
{
   return [_lpsolver lpValue];
}
-(id<ORObjectiveValue>) objectiveValue
{
   return [_lpsolver objectiveValue];
}
-(ORFloat) lowerBound: (id<ORVar>) v
{
   return [_lpsolver lowerBound: _gamma[v.getId]];
}
-(ORFloat) upperBound: (id<ORVar>) v
{
   return [_lpsolver upperBound: _gamma[v.getId]];
}
-(void) updateLowerBound: (id<ORVar>) v with: (ORFloat) lb
{
   [_lpsolver updateLowerBound: _gamma[v.getId] lb: lb];
}
-(void) updateUpperBound: (id<ORVar>) v with: (ORFloat) ub
{
   [_lpsolver updateUpperBound: _gamma[v.getId] ub: ub];
}
-(id) trackObject: (id) obj
{
   return [_lpsolver trackObject:obj];
}
-(id) trackConstraintInGroup:(id)obj
{
   return [_lpsolver trackConstraintInGroup:obj];
}
-(id) trackObjective: (id) obj
{
   return [_lpsolver trackObjective:obj];
}
-(id) trackMutable: (id) obj
{
   return [_lpsolver trackMutable:obj];
}
-(id) trackVariable: (id) obj
{
   return [_lpsolver trackVariable:obj];
}
-(id) trackImmutable:(id) obj
{
   return [_lpsolver trackImmutable:obj];
}
-(id<ORTracker>) tracker
{
   return self;
}
@end


@implementation LPSolverFactory
+(id<LPProgram>) solver: (id<ORModel>) model
{
   return [[LPSolver alloc] initLPSolver: model];
}
+(id<LPRelaxation>) relaxation: (id<ORModel>) model
{
   return [[LPRelaxation alloc] initLPRelaxation: model];
}
@end
