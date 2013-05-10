/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

// MIPSolver
#import <ORFoundation/ORFoundation.h>
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
   @throw [[ORExecutionError alloc] initORExecutionError: "floatValue not implemented"];
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

@interface ORMIPTakeSnapshot  : NSObject<ORVisitor>
-(ORMIPTakeSnapshot*) initORMIPTakeSnapshot: (id<MIPProgram>) solver;
-(void) dealloc;

-(void) visitTrailableInt:(id<ORTrailableInt>)v;
-(void) visitIntSet:(id<ORIntSet>)v;
-(void) visitIntRange:(id<ORIntRange>)v;
-(void) visitTable:(id<ORTable>) v;

-(void) visitIntVar: (id<ORIntVar>) v;
-(void) visitFloatVar: (id<ORFloatVar>) v;
-(void) visitAffineVar:(id<ORIntVar>) v;
-(void) visitBitVar: (id<ORBitVar>) v;
-(void) visitIdArray: (id<ORIdArray>) v;
-(void) visitIdMatrix: (id<ORIdMatrix>) v;
-(void) visitIntArray:(id<ORIntArray>) v;
-(void) visitFloatArray:(id<ORIntArray>) v;
-(void) visitIntMatrix:(id<ORIntMatrix>) v;
-(void) visitRestrict:(id<ORRestrict>)cstr;
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr;
-(void) visitCardinality: (id<ORCardinality>) cstr;
-(void) visitPacking: (id<ORPacking>) cstr;
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr;
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr;
-(void) visitCircuit:(id<ORCircuit>) cstr;
-(void) visitNoCycle:(id<ORNoCycle>) cstr;
-(void) visitLexLeq:(id<ORLexLeq>) cstr;
-(void) visitPackOne:(id<ORPackOne>) cstr;
-(void) visitKnapsack:(id<ORKnapsack>) cstr;
-(void) visitAssignment:(id<ORAssignment>)cstr;
-(void) visitMinimizeVar: (id<ORObjectiveFunction>) v;
-(void) visitMaximizeVar: (id<ORObjectiveFunction>) v;
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) e;
-(void) visitMinimizeExpr: (id<ORObjectiveFunctionExpr>) e;
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) o;
-(void) visitMinimizeLinear: (id<ORObjectiveFunctionLinear>) o;
-(void) visitEqualc: (id<OREqualc>)c;
-(void) visitNEqualc: (id<ORNEqualc>)c;
-(void) visitLEqualc: (id<ORLEqualc>)c;
-(void) visitGEqualc: (id<ORGEqualc>)c;
-(void) visitEqual: (id<OREqual>)c;
-(void) visitAffine: (id<ORAffine>)c;
-(void) visitNEqual: (id<ORNEqual>)c;
-(void) visitLEqual: (id<ORLEqual>)c;
-(void) visitPlus: (id<ORPlus>)c;
-(void) visitMult: (id<ORMult>)c;
-(void) visitSquare: (id<ORSquare>)c;
-(void) visitMod: (id<ORMod>)c;
-(void) visitModc: (id<ORModc>)c;
-(void) visitAbs: (id<ORAbs>)c;
-(void) visitOr: (id<OROr>)c;
-(void) visitAnd:( id<ORAnd>)c;
-(void) visitImply: (id<ORImply>)c;
-(void) visitElementCst: (id<ORElementCst>)c;
-(void) visitElementVar: (id<ORElementVar>)c;
-(void) visitReifyEqualc: (id<ORReifyEqualc>)c;
-(void) visitReifyEqual: (id<ORReifyEqual>)c;
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>)c;
-(void) visitReifyNEqual: (id<ORReifyNEqual>)c;
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>)c;
-(void) visitReifyLEqual: (id<ORReifyLEqual>)c;
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>)c;
-(void) visitReifyGEqual: (id<ORReifyGEqual>)c;
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) c;
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>)c;
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>)c;
-(void) visitSumEqualc:(id<ORSumEqc>)c;
-(void) visitSumLEqualc:(id<ORSumLEqc>)c;
-(void) visitSumGEqualc:(id<ORSumGEqc>)c;
// Bit
-(void) visitBitEqual:(id<ORBitEqual>)c;
-(void) visitBitOr:(id<ORBitOr>)c;
-(void) visitBitAnd:(id<ORBitAnd>)c;
-(void) visitBitNot:(id<ORBitNot>)c;
-(void) visitBitXor:(id<ORBitXor>)c;
-(void) visitBitShiftL:(id<ORBitShiftL>)c;
-(void) visitBitRotateL:(id<ORBitRotateL>)c;
-(void) visitBitSum:(id<ORBitSum>)c;
-(void) visitBitIf:(id<ORBitIf>)c;

//
-(void) visitIntegerI: (id<ORInteger>) e;
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e;
-(void) visitMutableFloatI: (id<ORMutableFloat>) e;
-(void) visitFloatI: (id<ORFloatNumber>) e;
-(void) visitExprPlusI: (id<ORExpr>) e;
-(void) visitExprMinusI: (id<ORExpr>) e;
-(void) visitExprMulI: (id<ORExpr>) e;
-(void) visitExprDivI: (id<ORExpr>) e;
-(void) visitExprModI: (id<ORExpr>) e;
-(void) visitExprEqualI: (id<ORExpr>) e;
-(void) visitExprNEqualI: (id<ORExpr>) e;
-(void) visitExprLEqualI: (id<ORExpr>) e;
-(void) visitExprSumI: (id<ORExpr>) e;
-(void) visitExprProdI: (id<ORExpr>) e;
-(void) visitExprAbsI:(id<ORExpr>) e;
-(void) visitExprNegateI:(id<ORExpr>) e;
-(void) visitExprCstSubI: (id<ORExpr>) e;
-(void) visitExprDisjunctI:(id<ORExpr>) e;
-(void) visitExprConjunctI: (id<ORExpr>) e;
-(void) visitExprImplyI: (id<ORExpr>) e;
-(void) visitExprAggOrI: (id<ORExpr>) e;
-(void) visitExprVarSubI: (id<ORExpr>) e;
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
-(void) dealloc
{
   [super dealloc];
}
-(void) visitTrailableInt: (id<ORTrailableInt>) v
{
   _snapshot = NULL;
}
-(void) visitIntSet:(id<ORIntSet>)v
{
   _snapshot = NULL;
}
-(void) visitIntRange: (id<ORIntRange>) v
{
   _snapshot = NULL;
}
-(void) visitTable:(id<ORTable>) v
{
   _snapshot = NULL;
}
-(void) visitIntVar: (id<ORIntVar>) v
{
   _snapshot = [[ORMIPIntVarSnapshot alloc] initMIPIntVarSnapshot: v with: _solver];
}
-(void) visitFloatVar: (id<ORFloatVar>) v
{
   _snapshot = [[ORMIPFloatVarSnapshot alloc] initMIPFloatVarSnapshot: v with: _solver];
}
-(void) visitAffineVar:(id<ORIntVar>) v
{
   _snapshot = NULL;
}
-(void) visitBitVar: (id<ORBitVar>) v
{
   _snapshot = NULL;
}
-(void) visitIdArray: (id<ORIdArray>) v
{
   _snapshot = NULL;
}
-(void) visitIdMatrix: (id<ORIdMatrix>) v
{
   _snapshot = NULL;
}
-(void) visitIntArray:(id<ORIntArray>) v
{
   _snapshot = NULL;
}
-(void) visitFloatArray:(id<ORIntArray>) v
{
   _snapshot = NULL;
}
-(void) visitIntMatrix:(id<ORIntMatrix>) v
{
   _snapshot = NULL;
}
-(void) visitRestrict:(id<ORRestrict>)cstr
{
   _snapshot = NULL;
}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
   _snapshot = NULL;
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   _snapshot = NULL;
}
-(void) visitPacking: (id<ORPacking>) cstr
{
   _snapshot = NULL;
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   _snapshot = NULL;
}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr
{
   _snapshot = NULL;
}
-(void) visitCircuit:(id<ORCircuit>) cstr
{
   _snapshot = NULL;
}
-(void) visitNoCycle:(id<ORNoCycle>) cstr
{
   _snapshot = NULL;
}
-(void) visitLexLeq:(id<ORLexLeq>) cstr
{
   _snapshot = NULL;
}
-(void) visitPackOne:(id<ORPackOne>) cstr
{
   _snapshot = NULL;
}
-(void) visitKnapsack:(id<ORKnapsack>) cstr
{
   _snapshot = NULL;
}
-(void) visitAssignment:(id<ORAssignment>)cstr
{
   _snapshot = NULL;
}
-(void) visitMinimizeVar: (id<ORObjectiveFunction>) v
{
   _snapshot = NULL;
}
-(void) visitMaximizeVar: (id<ORObjectiveFunction>) v
{
   _snapshot = NULL;
}
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) e
{
   _snapshot = NULL;
}
-(void) visitMinimizeExpr: (id<ORObjectiveFunctionExpr>) e
{
   _snapshot = NULL;
}
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) o
{
   _snapshot = NULL;
}
-(void) visitMinimizeLinear: (id<ORObjectiveFunctionLinear>) o
{
   _snapshot = NULL;
}
-(void) visitEqualc: (id<OREqualc>)c
{
   _snapshot = NULL;
}
-(void) visitNEqualc: (id<ORNEqualc>)c
{
   _snapshot = NULL;
}
-(void) visitLEqualc: (id<ORLEqualc>)c
{
   _snapshot = NULL;
}
-(void) visitGEqualc: (id<ORGEqualc>)c
{
   _snapshot = NULL;
}
-(void) visitEqual: (id<OREqual>)c
{
   _snapshot = NULL;
}
-(void) visitAffine: (id<ORAffine>)c
{
   _snapshot = NULL;
}
-(void) visitNEqual: (id<ORNEqual>)c
{
   _snapshot = NULL;
}
-(void) visitLEqual: (id<ORLEqual>)c
{
   _snapshot = NULL;
}
-(void) visitPlus: (id<ORPlus>)c
{
   _snapshot = NULL;
}
-(void) visitMult: (id<ORMult>)c
{
   _snapshot = NULL;
}
-(void) visitSquare: (id<ORSquare>)c
{
   _snapshot = NULL;
}
-(void) visitMod: (id<ORMod>)c
{
   _snapshot = NULL;
}
-(void) visitModc: (id<ORModc>)c
{
   _snapshot = NULL;
}
-(void) visitAbs: (id<ORAbs>)c
{
   _snapshot = NULL;
}
-(void) visitOr: (id<OROr>)c
{
   _snapshot = NULL;
}
-(void) visitAnd:( id<ORAnd>)c
{
   _snapshot = NULL;
}
-(void) visitImply: (id<ORImply>)c
{
   _snapshot = NULL;
}
-(void) visitElementCst: (id<ORElementCst>)c
{
   _snapshot = NULL;
}
-(void) visitElementVar: (id<ORElementVar>)c
{
   _snapshot = NULL;
}
-(void) visitReifyEqualc: (id<ORReifyEqualc>)c
{
   _snapshot = NULL;
}
-(void) visitReifyEqual: (id<ORReifyEqual>)c
{
   _snapshot = NULL;
}
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>)c
{
   _snapshot = NULL;
}
-(void) visitReifyNEqual: (id<ORReifyNEqual>)c
{
   _snapshot = NULL;
}
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>)c
{
   _snapshot = NULL;
}
-(void) visitReifyLEqual: (id<ORReifyLEqual>)c
{
   _snapshot = NULL;
}
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>)c
{
   _snapshot = NULL;
}
-(void) visitReifyGEqual: (id<ORReifyGEqual>)c
{
   _snapshot = NULL;
}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) c
{
   _snapshot = NULL;
}
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>)c
{
   _snapshot = NULL;
}
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>)c
{
   _snapshot = NULL;
}
-(void) visitSumEqualc:(id<ORSumEqc>)c
{
   _snapshot = NULL;
}
-(void) visitSumLEqualc:(id<ORSumLEqc>)c
{
   _snapshot = NULL;
}
-(void) visitSumGEqualc:(id<ORSumGEqc>)c
{
   _snapshot = NULL;
}
// Bit
-(void) visitBitEqual:(id<ORBitEqual>)c
{
   _snapshot = NULL;
}
-(void) visitBitOr:(id<ORBitOr>)c
{
   _snapshot = NULL;
}
-(void) visitBitAnd:(id<ORBitAnd>)c
{
   _snapshot = NULL;
}
-(void) visitBitNot:(id<ORBitNot>)c
{
   _snapshot = NULL;
}
-(void) visitBitXor:(id<ORBitXor>)c
{
   _snapshot = NULL;
}
-(void) visitBitShiftL:(id<ORBitShiftL>)c
{
   _snapshot = NULL;
}
-(void) visitBitRotateL:(id<ORBitRotateL>)c
{
   _snapshot = NULL;
}
-(void) visitBitSum:(id<ORBitSum>)c
{
   _snapshot = NULL;
}
-(void) visitBitIf:(id<ORBitIf>)c
{
   _snapshot = NULL;
}
-(void) visitIntegerI: (id<ORInteger>) e
{
   _snapshot = NULL;
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
   _snapshot = NULL;
}
-(void) visitMutableFloatI: (id<ORMutableFloat>) e
{
   _snapshot = NULL;
}
-(void) visitFloatI: (id<ORFloatNumber>) e
{
   _snapshot = NULL;
}
-(void) visitExprPlusI: (id<ORExpr>) e
{
   _snapshot = NULL;
}
-(void) visitExprMinusI: (id<ORExpr>) e
{
   _snapshot = NULL;
}
-(void) visitExprMulI: (id<ORExpr>) e
{
   _snapshot = NULL;
}
-(void) visitExprDivI: (id<ORExpr>) e
{
   _snapshot = NULL;
}
-(void) visitExprModI: (id<ORExpr>) e
{
   _snapshot = NULL;
}
-(void) visitExprEqualI: (id<ORExpr>) e
{
   _snapshot = NULL;
}
-(void) visitExprNEqualI: (id<ORExpr>) e
{
   _snapshot = NULL;
}
-(void) visitExprLEqualI: (id<ORExpr>) e
{
   _snapshot = NULL;
}
-(void) visitExprSumI: (id<ORExpr>) e
{
   _snapshot = NULL;
}
-(void) visitExprProdI: (id<ORExpr>) e
{
   _snapshot = NULL;
}
-(void) visitExprAbsI:(id<ORExpr>) e
{
   _snapshot = NULL;
}
-(void) visitExprNegateI:(id<ORExpr>) e
{
   _snapshot = NULL;
}
-(void) visitExprCstSubI: (id<ORExpr>) e
{
   _snapshot = NULL;
}
-(void) visitExprDisjunctI:(id<ORExpr>) e
{
   _snapshot = NULL;
}
-(void) visitExprConjunctI: (id<ORExpr>) e
{
   _snapshot = NULL;
}
-(void) visitExprImplyI: (id<ORExpr>) e
{
   _snapshot = NULL;
}
-(void) visitExprAggOrI: (id<ORExpr>) e
{
   _snapshot = NULL;
}
-(void) visitExprVarSubI: (id<ORExpr>) e
{
   _snapshot = NULL;
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
   NSUInteger idx = [var getId];
   if (idx < [_varShots count])
      return [_varShots objectAtIndex:idx];
   else
      return nil;
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
-(ORInt) intValue: (id<ORIntVar>) v
{
   return [_MIPsolver intValue: _gamma[v.getId]];
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
