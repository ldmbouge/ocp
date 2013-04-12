/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORUtilities/ORConcurrency.h>
#import <ORFoundation/ORExplorer.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORFlatten.h>
#import <ORProgram/ORProgram.h>
#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPBitVar.h>

#import "CPProgram.h"
#import "CPSolver.h"
#import "CPConcretizer.h"

#if defined(__linux__)
#import <values.h>
#endif

// to do 23/12/2012
//
// 1. Look at IncModel to implement the incremental addition of constraints
// 2. Need to check how variables/constraints/objects are created during the search
// 3. Need to concretize them directly


@interface ORCPIntVarSnapshot : NSObject<ORSnapshot,NSCoding> {
   ORUInt    _name;
   ORInt     _value;
}
-(ORCPIntVarSnapshot*) initCPIntVarSnapshot: (id<ORIntVar>) v with: (id<CPCommonProgram>) solver;
-(int) intValue;
-(ORBool) boolValue;
-(NSString*) description;
-(ORBool)isEqual: (id) object;
-(NSUInteger) hash;
@end

@implementation ORCPIntVarSnapshot
-(ORCPIntVarSnapshot*) initCPIntVarSnapshot: (id<ORIntVar>) v with: (id<CPCommonProgram>) solver;
{
   self = [super init];
   _name = [v getId];
   _value = [solver intValue: v];
   return self;
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
      ORCPIntVarSnapshot* other = object;
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

@interface ORCPFloatVarSnapshot : NSObject <ORSnapshot,NSCoding>
{
   ORUInt    _name;
   ORFloat   _value;
}
-(ORCPFloatVarSnapshot*) initCPFloatVarSnapshot: (id<ORFloatVar>) v with: (id<CPCommonProgram>) solver;
-(ORFloat) floatValue;
-(ORInt) intValue;
-(NSString*) description;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
@end

@implementation ORCPFloatVarSnapshot
-(ORCPFloatVarSnapshot*) initCPFloatVarSnapshot: (id<ORFloatVar>) v with: (id<CPCommonProgram>) solver;
{
   self = [super init];
   _name = [v getId];
   _value = [solver floatValue: v];
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
-(ORBool) isEqual: (id) object
{
   if ([object isKindOfClass:[self class]]) {
      ORCPFloatVarSnapshot* other = object;
      if (_name == other->_name) {
         return _value == other->_value;
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
}
- (id) initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_value];
   return self;
}
@end

@interface ORCPTakeSnapshot  : NSObject<ORVisitor>
-(ORCPTakeSnapshot*) initORCPTakeSnapshot: (id<CPCommonProgram>) solver;
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

@implementation ORCPTakeSnapshot
{
   id<CPCommonProgram> _solver;
   id            _snapshot;
}
-(ORCPTakeSnapshot*) initORCPTakeSnapshot: (id<CPCommonProgram>) solver
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
   _snapshot = [[ORCPIntVarSnapshot alloc] initCPIntVarSnapshot: v with: _solver];
}
-(void) visitFloatVar: (id<ORFloatVar>) v
{
   _snapshot = [[ORCPFloatVarSnapshot alloc] initCPFloatVarSnapshot: v with: _solver];
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

//
-(void) visitIntegerI: (id<ORInteger>) e
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

@interface ORCPSolutionI : NSObject<ORCPSolution>
-(ORCPSolutionI*) initORCPSolutionI: (id<ORModel>) model with: (id<CPCommonProgram>) solver;
-(id<ORSnapshot>) value: (id) var;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
-(id<ORObjectiveValue>) objectiveValue;
@end


// PVH: need to be generalized when the global numbering will be available
@implementation ORCPSolutionI {
   NSArray*             _varShots;
   id<ORObjectiveValue> _objValue;
}

-(ORCPSolutionI*) initORCPSolutionI: (id<ORModel>) model with: (id<CPCommonProgram>) solver
{
   self = [super init];
   NSArray* av = [model variables];
   ORULong sz = [av count];
   NSMutableArray* snapshots = [[NSMutableArray alloc] initWithCapacity:sz];
   ORCPTakeSnapshot* visit = [[ORCPTakeSnapshot alloc] initORCPTakeSnapshot: solver];
   [av enumerateObjectsUsingBlock: ^void(id obj, NSUInteger idx, BOOL *stop) {
      [obj visit: visit];
      id shot = [visit snapshot];
      if (shot)
         [snapshots addObject: shot];
      [shot release];
   }];
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
   NSLog(@"dealloc ORLPSolutionI");
   [_varShots release];
   [_objValue release];
   [super dealloc];
}

-(ORBool) isEqual: (id) object
{
   if ([object isKindOfClass: [self class]]) {
      ORCPSolutionI* other = object;
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
   return [(id<ORSnapshot>) [_varShots objectAtIndex:[var getId]] intValue];
}
-(ORBool) boolValue: (id) var
{
   return [(id<ORSnapshot>) [_varShots objectAtIndex:[var getId]] boolValue];
}
-(ORFloat) floatValue: (id<ORFloatVar>) var
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No float variable in LP solutions"];
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

@implementation CPHeuristicSet
{
   id<CPHeuristic>*  _tab;
   ORUInt            _sz;
   ORUInt            _mx;
}
-(CPHeuristicSet*) initCPHeuristicSet
{
   self = [super init];
   _mx  = 2;
   _tab = malloc(sizeof(id<CPHeuristic>)*_mx);
   _sz  = 0;
   return self;
}
-(void) push: (id<CPHeuristic>) h
{
   if (_sz >= _mx) {
      _tab = realloc(_tab, _mx << 1);
      _mx <<= 1;
   }
   _tab[_sz++] = h;
}
-(id<CPHeuristic>) pop
{
   return _tab[--_sz];
}
-(void) reset
{
   for(ORUInt k=0;k<_sz;k++)
      [_tab[k] release];
   _sz = 0;
}
-(void) dealloc
{
   [self reset];
   free(_tab);
   [super dealloc];
}
-(void)applyToAll: (void(^)(id<CPHeuristic>,NSMutableArray*))closure with: (NSMutableArray*)av;
{
   for(ORUInt k=0;k<_sz;k++)
      closure(_tab[k],av);
}
@end


@interface ORControllerFactoryI : NSObject<ORControllerFactory> {
   id<CPCommonProgram> _solver;
   Class               _ctrlClass;
   Class               _nestedClass;
}
-(id)initORControllerFactoryI: (id<CPCommonProgram>) solver rootControllerClass:(Class)class nestedControllerClass:(Class)nc;
-(id<ORSearchController>) makeRootController;
-(id<ORSearchController>) makeNestedController;
@end

@implementation ORControllerFactoryI
-(id)initORControllerFactoryI: (id<CPCommonProgram>) solver rootControllerClass: (Class) class nestedControllerClass: (Class) nc
{
   self = [super init];
   _solver = solver;
   _ctrlClass = class;
   _nestedClass = nc;
   return self;
}
-(id<ORSearchController>) makeRootController
{
   return [[_ctrlClass alloc] initTheController: [_solver tracer] engine: [_solver engine]];
}
-(id<ORSearchController>) makeNestedController
{
   return [[_nestedClass alloc] initTheController: [_solver tracer] engine: [_solver engine]];
}
@end


/******************************************************************************************/
/*                                 CoreSolver                                             */
/******************************************************************************************/

@implementation CPCoreSolver {
@protected
   id<ORModel>           _model;
   id<CPEngine>          _engine;
   id<ORExplorer>        _search;
   id<ORSearchObjectiveFunction>  _objective;
   id<ORTrail>           _trail;
   id<ORTracer>          _tracer;
   CPHeuristicSet*       _hSet;
   id<CPPortal>          _portal;

   id<ORIdxIntInformer>  _returnLabel;
   id<ORIdxIntInformer>  _failLabel;
   BOOL                  _closed;
   BOOL                  _oneSol;
   NSMutableArray*       _doOnSolArray;
   NSMutableArray*       _doOnExitArray;
   id<ORSolutionPool>    _sPool;
}
-(CPCoreSolver*) initCPCoreSolver
{
   self = [super init];
   _model = NULL;
   _hSet = [[CPHeuristicSet alloc] initCPHeuristicSet];
   _returnLabel = _failLabel = nil;
   _portal = [[CPInformerPortal alloc] initCPInformerPortal: self];
   _objective = nil;
   _sPool   = [ORFactory createSolutionPool];
   _closed = false;
   _oneSol = YES;
   _doOnSolArray = [[NSMutableArray alloc] initWithCapacity: 1];
   _doOnExitArray = [[NSMutableArray alloc] initWithCapacity: 1];
   return self;
}
-(void) dealloc
{
   [_model release];
   [_hSet release];
   [_portal release];
   [_returnLabel release];
   [_failLabel release];
   [_sPool release];
   [_doOnSolArray release];
   [_doOnExitArray release];
   [super dealloc];
}
-(void) setSource:(id<ORModel>)src
{
   [_model release];
   _model = [src retain];
}

-(NSString*) description
{
   return [NSString stringWithFormat:@"Solver: %d vars\n\t%d constraints\n\t%d choices\n\t%d fail\n\t%d propagations",
               [_engine nbVars],[_engine nbConstraints],[_search nbChoices],[_search nbFailures],[_engine nbPropagation]];
}
-(id<ORIdxIntInformer>) retLabel
{
   if (_returnLabel==nil)
      _returnLabel = [ORConcurrency idxIntInformer];
   return _returnLabel;
}
-(id<ORIdxIntInformer>) failLabel
{
   if (_failLabel==nil)
      _failLabel = [ORConcurrency idxIntInformer];
   return _failLabel;
}
-(id<CPPortal>) portal
{
   return _portal;
}
-(ORInt) nbFailures
{
   return [_search nbFailures];
}
-(id<CPEngine>) engine
{
   return _engine;
}
-(id<ORExplorer>) explorer
{
   return _search;
}
-(id<ORSearchObjectiveFunction>) objective
{
   return [_engine objective];
}
-(id<ORTracer>) tracer
{
   return _tracer;
}
-(void) close
{
   if (!_closed) {
      _closed = true;
      if ([_engine close] == ORFailure)
         [_search fail];
      [_hSet applyToAll:^(id<CPHeuristic> h,NSMutableArray* av) { [h initHeuristic:av oneSol:_oneSol];}
                   with: [_engine variables]];
      [ORConcurrency pumpEvents];
   }
}
-(void) addHeuristic: (id<CPHeuristic>) h
{
   [_hSet push: h];
}
-(void) restartHeuristics
{
  [_hSet applyToAll:^(id<CPHeuristic> h,NSMutableArray* av) { [h restart];} with:[_engine variables]];
}

-(void) onSolution: (ORClosure) onSolution
{
   [_doOnSolArray addObject: [onSolution copy]];
}
-(void) onExit: (ORClosure) onExit
{
   [_doOnExitArray addObject: [onExit copy]];
}
-(id<ORSolutionPool>) solutionPool
{
   return _sPool;
}
-(id<ORSolution>) captureSolution
{
   return [[ORCPSolutionI alloc] initORCPSolutionI: _model with: self];
}
-(void) doOnSolution
{
   [_doOnSolArray enumerateObjectsUsingBlock:^(ORClosure block, NSUInteger idx, BOOL *stop) {
      block();
   }];
}
-(void) doOnExit
{
   [_doOnExitArray enumerateObjectsUsingBlock:^(ORClosure block, NSUInteger idx, BOOL *stop) {
      block();
   }];
}
-(void) solve: (ORClosure) search
{
   _objective = [_engine objective];
   if (_objective != nil) {
      _oneSol = NO;
      [_search optimizeModel: self using: search
                  onSolution: ^{ [self doOnSolution];}
                      onExit: ^{ [self doOnExit];}
       ];
      NSLog(@"Optimal Solution: %@ thread:%d\n",[_objective primalBound],[NSThread threadID]);
   }
   else {
      _oneSol = YES;
      [_search solveModel: self using: search
               onSolution: ^{ [self doOnSolution];}
                   onExit: ^{ [self doOnExit];}
       ];
   }
}
-(void) solveAll: (ORClosure) search
{
   _oneSol = NO;
   ORInt nbs = (ORInt) [_doOnSolArray count];
   ORInt nbe = (ORInt) [_doOnExitArray count];
   [_search solveAllModel: self using: search
               onSolution: ^{
                  for(ORInt i = 0; i < nbs; i++)
                     ((ORClosure) [_doOnSolArray objectAtIndex: i])();
               }
                   onExit: ^{
                      for(ORInt i = 0; i < nbe; i++)
                         ((ORClosure) [_doOnExitArray objectAtIndex: i])();
                   }
    ];
}
-(id<ORForall>) forall: (id<ORIntIterable>) S
{
   return [ORControl forall: self set: S];
}
-(void) forall: (id<ORIntIterable>) S orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
   [ORControl forall: S suchThat: nil orderedBy: order do: body];
}
-(void) forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
   [ORControl forall: S suchThat: filter orderedBy: order do: body];  
}
-(void) forall: (id<ORIntIterable>) S  orderedBy: (ORInt2Int) o1 and: (ORInt2Int) o2  do: (ORInt2Void) b
{
   id<ORForall> forall = [ORControl forall: self set: S];
   [forall orderedBy:o1];
   [forall orderedBy:o2];
   [forall do: b];
}
-(void) forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) suchThat orderedBy: (ORInt2Int) o1 and: (ORInt2Int) o2  do: (ORInt2Void) b
{
   id<ORForall> forall = [ORControl forall: self set: S];
   [forall suchThat: suchThat];
   [forall orderedBy:o1];
   [forall orderedBy:o2];
   [forall do: b];
}
-(void) try: (ORClosure) left or: (ORClosure) right
{
   [_search try: left or: right];   
}
-(void) tryall: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body
{
   [_search tryall: range suchThat: filter in: body];   
}
-(void) tryall: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure
{
   [_search tryall: range suchThat: filter in: body onFailure: onFailure];  
}
-(void) limitTime: (ORLong) maxTime in: (ORClosure) cl
{
   [_engine clearStatus];
   [_search limitTime: maxTime in: cl];
}
-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   [_search nestedSolve: body onSolution: onSolution onExit: onExit
                control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]]; 
}
-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution
{
   [_search nestedSolve: body onSolution: onSolution onExit:nil
                control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}
-(void) nestedSolve: (ORClosure) body
{
   [_search nestedSolve: body onSolution:nil onExit:nil
                control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}
-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   [_search nestedSolveAll: body onSolution: onSolution onExit: onExit
                   control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}
-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution
{
   [_search nestedSolveAll: body onSolution: onSolution onExit:nil
                   control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}
-(void) nestedSolveAll: (ORClosure) body
{
   [_search nestedSolveAll: body onSolution:nil onExit:nil
                   control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}
-(void) trackObject: (id) object
{
   [_engine trackObject:object];   
}
-(void) trackVariable: (id) object
{
   [_engine trackObject:object];  
}
-(void) trackConstraint: (id) obj
{
   [_engine trackConstraint:obj];
}
//-(void) add: (id<ORConstraint>) c
//{
//   @throw [[ORExecutionError alloc] initORExecutionError: "add: not implemented"];
//}
//-(void) add: (id<ORConstraint>) c annotation: (ORAnnotation) cons
//{
//   @throw [[ORExecutionError alloc] initORExecutionError: "add:consistency: not implemented"];
//}

-(void) labelImpl: (id<CPIntVar>) var with: (ORInt) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method labelImpl not implemented"];
}
-(void) diffImpl: (id<CPIntVar>) var with: (ORInt) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method diffImpl not implemented"]; 
}
-(void) lthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method lthenImpl not implemented"];
}
-(void) gthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method gthenImpl not implemented"];
}
-(void) restrictImpl: (id<CPIntVar>) var to: (id<ORIntSet>) S
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method restrictImpl not implemented"];
}
-(void) labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)var at:(ORUInt)i with:(ORBool)val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method labelBVImpl not implemented"];
}

-(void) labelBit:(int)i ofVar:(id<CPBitVar>)x
{
   [_search try: ^() { [self labelBV:x at:i with:false];}
             or: ^() {[self labelBV:x at:i with:true];}];
}
-(void) labelUpFromLSB:(id<CPBitVar>) x
{
   int i;
   CPBitVarI* bv = (CPBitVarI*) [x dereference];
   while ((i=[bv lsFreeBit])>=0) {
      NSAssert(i>=0,@"ERROR in [labelUpFromLSB] bitVar is not bound, but no free bits found when using lsFreeBit.");
      [_search try: ^() { [self labelBV:x at:i with:false];}
                or: ^() { [self labelBV:x at:i with:true];}];
   }
}


-(void) labelArray: (id<ORIntVarArray>) x
{
   x = [[_model rootModel] lookup:x];
   ORInt low = [x low];
   ORInt up = [x up];
   for(ORInt i = low; i <= up; i++)
      [self label: x[i]];
}
-(void) labelArray: (id<ORIntVarArray>) x orderedBy: (ORInt2Float) orderedBy
{
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^bool(ORInt i) { return ![[x at: i] bound]; }
                                 orderedBy: orderedBy];
   do {
      ORInt i = [select min];
      if (i == MAXINT) {
         return;
      }
      [self label: x[i]];
   } while (true);
}
-(void) labelHeuristic: (id<CPHeuristic>) h
{
   id<ORIntVarArray> av = [h allIntVars];
   id<ORSelect> select = [ORFactory selectRandom: _engine
                                           range: RANGE(_engine,[av low],[av up])
                                        suchThat: ^bool(ORInt i)    { return ![[av at: i] bound]; }
                                       orderedBy: ^ORFloat(ORInt i) {
                                          ORFloat rv = [h varOrdering:av[i]];
                                          return rv;
                                       }];
   id<ORIntVar>* last = malloc(sizeof(id<ORIntVar>));
   id<ORRandomStream> valStream = [ORCrFactory randomStream];
   [_trail trailClosure:^{
      free(last);
      [valStream release];
   }];
   
   *last = nil;
   id<ORInteger> failStamp = [ORFactory integer:self value:-1];
   do {
      id<ORIntVar> x = *last;
      if ([failStamp value] == [_search nbFailures] || (x == nil || [x bound])) {
         ORInt i = [select max];
         if (i == MAXINT)
            return;
         //NSLog(@"Chose variable: %d",i);
         x = av[i];
         *last = x;
      }/* else {
         NSLog(@"STAMP: %d  - %d",[failStamp value],[_search nbFailures]);
      }*/
      [failStamp setValue:[_search nbFailures]];
      ORFloat bestValue = - MAXFLOAT;
      ORLong bestRand = 0x7fffffffffffffff;
      ORInt low = [x min];
      ORInt up  = [x max];
      ORInt bestIndex = low - 1;
      for(ORInt v = low;v <= up;v++) {
        if ([x member:v]) {
          ORFloat vValue = [h valOrdering:v forVar:x];
          if (vValue > bestValue) {
            bestValue = vValue;
            bestIndex = v;
            bestRand  = [valStream next];
          } else if (vValue == bestValue) {
            ORLong rnd = [valStream next];
            if (rnd < bestRand) {
              bestIndex = v;
              bestRand = rnd;
            }
          }
        }
      }
      if (bestIndex != low - 1)  {
        [self try: ^{
          [self label: x with: bestIndex];
        } or: ^{
           [self diff:x with: bestIndex];
        }];
      }
      /*
      id<ORSelect> valSelect = [ORFactory select: _engine
                                           range:RANGE(_engine,[x min],[x max])
                                        suchThat:^bool(ORInt v)    { return [x member:v];}
                                       orderedBy:^ORFloat(ORInt v) { return [h valOrdering:v forVar:x];}];
      do {
         ORInt curVal = [valSelect max];
         if (curVal == MAXINT)
            break;
         [self try:^{
            [self label: x with: curVal];
         } or:^{
            [self diff: x with: curVal];
         }];
      } while(![x bound]);
      */
   } while (true);
}
-(void) label: (id<ORIntVar>) mx
{
   id<CPIntVar> x = (id<CPIntVar>) [mx dereference];
   while (![x bound]) {
      ORInt m = [x min];
      [_search try: ^() {
         [self labelImpl: x with: m];
      }
                or: ^() {
                   [self diffImpl: x with: m];
                }];
   }
}

-(void) label: (id<CPIntVar>) var with: (ORInt) val
{
   return [self labelImpl: (id<CPIntVar>) [var dereference] with: val];
}
-(void) diff: (id<CPIntVar>) var with: (ORInt) val
{
   [self diffImpl: (id<CPIntVar>) [var dereference] with: val];
}
-(void) lthen: (id<ORIntVar>) var with: (ORInt) val
{
   [self lthenImpl: (id<CPIntVar>) [var dereference] with: val];
}
-(void) gthen: (id<ORIntVar>) var with: (ORInt) val
{
   [self gthenImpl: (id<CPIntVar>) [var dereference] with: val];
}
-(void) restrict: (id<ORIntVar>) var to: (id<ORIntSet>) S
{
   [self restrictImpl: (id<CPIntVar>) [var dereference] to: S];
}
-(void) labelBV: (id<CPBitVar>) var at:(ORUInt) i with:(ORBool)val
{
   return [self labelBVImpl: (id<CPBitVar,CPBitVarNotifier>)[var dereference] at:i with: val];
}

-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat
{
   [_search repeat: body onRepeat: onRepeat until: nil];
}
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (ORVoid2Bool) isDone
{
   [_search repeat: body onRepeat: onRepeat until: isDone];
}
-(void) perform: (ORClosure) body onLimit: (ORClosure) onLimit;
{
   [_search perform: body onLimit: onLimit];
}
-(void) portfolio: (ORClosure) s1 then: (ORClosure) s2
{
   [_search portfolio: s1 then: s2];
}
-(void) once: (ORClosure) cl
{
   [_search once: cl];
}
-(void) limitSolutions: (ORInt) maxSolutions in: (ORClosure) cl
{
   [_engine clearStatus];
   [_search limitSolutions: maxSolutions in: cl];
}
-(void) limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl
{
   [_engine clearStatus];
   [_search limitCondition: condition in:cl];
}
-(void) limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl
{
   [_engine clearStatus];
   [_search limitDiscrepancies: maxDiscrepancies in: cl];
}
-(void) limitFailures: (ORInt) maxFailures in: (ORClosure) cl
{
   [_engine clearStatus];
   [_search limitFailures: maxFailures in: cl];
   
}

//- (void) encodeWithCoder:(NSCoder *)aCoder
//{
//   // The idea is that we only encode the solver and an empty _shell_ (no content) of the trail
//   // The decoding recreates the pool.
//   [aCoder encodeObject:_engine];
//   [aCoder encodeObject:_trail];
//}
//- (id) initWithCoder:(NSCoder *)aDecoder;
//{
//   self = [super init];
//   _engine = [[aDecoder decodeObject] retain];
//   _trail  = [[aDecoder decodeObject] retain];
//   _pool = [[NSAutoreleasePool alloc] init];
//   return self;
//}

-(void) addConstraintDuringSearch: (id<ORConstraint>) c annotation: (ORAnnotation) n
{
   // LDM: This is the true addition of the constraint into the solver during the search.
   ORStatus status = [_engine add: c];
   if (status == ORFailure)
      [_search fail];
}

-(id<CPHeuristic>) createPortfolio:(NSArray*)hs with:(id<ORVarArray>)vars
{
   assert(FALSE);
   return NULL;
}

-(id<CPHeuristic>) createFF: (id<ORVarArray>) rvars
{
   id<CPHeuristic> h = [[CPFirstFail alloc] initCPFirstFail:self restricted:rvars];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createWDeg:(id<ORVarArray>)rvars
{
   id<CPHeuristic> h = [[CPWDeg alloc] initCPWDeg:self restricted:rvars];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createDDeg:(id<ORVarArray>)rvars
{
   id<CPHeuristic> h = [[CPDDeg alloc] initCPDDeg:self restricted:rvars];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createIBS:(id<ORVarArray>)rvars
{
   id<CPHeuristic> h = [[CPIBS alloc] initCPIBS:self restricted:rvars];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createABS:(id<ORVarArray>)rvars
{
   id<CPHeuristic> h = [[CPABS alloc] initCPABS:self restricted:rvars];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createFF
{
   id<CPHeuristic> h = [[CPFirstFail alloc] initCPFirstFail:self restricted:nil];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createWDeg
{
   id<CPHeuristic> h = [[CPWDeg alloc] initCPWDeg:self restricted:nil];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createDDeg
{
   id<CPHeuristic> h = [[CPDDeg alloc] initCPDDeg:self restricted:nil];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createIBS
{
   id<CPHeuristic> h = [[CPIBS alloc] initCPIBS:self restricted:nil];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createABS
{
   id<CPHeuristic> h = [[CPABS alloc] initCPABS:self restricted:nil];
   [self addHeuristic:h];
   return h;
}
-(ORInt) intValue: (id<ORIntVar>) x
{
   // pvh: This needs to be fixed. I am using what works now until ldm provides the mapping
   x = [x dereference];
   return [x intValue];
}
-(ORBool) boolValue: (id<ORIntVar>) x
{
   // pvh: This needs to be fixed. I am using what works now until ldm provides the mapping
   x = [x dereference];
   return [x intValue];
}
-(ORFloat) floatValue: (id<ORFloatVar>) x
{
//   id<CPFloatVar> y = [[_model rootModel] lookup: x];
//   return y.value;
   @throw [[ORExecutionError alloc] initORExecutionError: "No CP Float Variables yet"];
   return 0.0;
}
-(ORBool) bound: (id<ORIntVar>) x
{
   x = [x dereference];
   return [x bound];
}
-(ORInt)  min: (id<ORIntVar>) x
{
   x = [x dereference];
   return [x min];
}
-(ORInt)  max: (id<ORIntVar>) x
{
   x = [x dereference];
   return [x max];
}
-(ORInt)  domsize: (id<ORIntVar>) x
{
   x = [x dereference];
   return [x domsize];
}
-(ORInt)  member: (ORInt) v in: (id<ORIntVar>) x
{
   x = [x dereference];
   return [x member: v];
}
@end

/******************************************************************************************/
/*                                   CPSolver                                             */
/******************************************************************************************/

@interface ORRTModel : NSObject<ORAddToModel>
-(ORRTModel*) init:(CPSolver*) solver;
-(void) addVariable: (id<ORVar>) var;
-(void) addObject: (id) object;
-(id<ORConstraint>) addConstraint: (id<ORConstraint>) cstr;
-(id<ORObjectiveFunction>) minimize: (id<ORIntVar>) x;
-(id<ORObjectiveFunction>) maximize: (id<ORIntVar>) x;
-(void) trackObject: (id) obj;
-(void) trackVariable: (id) obj;
-(void) trackConstraint: (id) obj;
@end

@implementation ORRTModel
{
   CPSolver* _solver;
   id<ORVisitor> _concretizer;
}
-(ORRTModel*)init:(CPSolver*)solver
{
   self = [super init];
   _solver = solver;
   _concretizer = [[ORCPConcretizer alloc] initORCPConcretizer: solver];
   return self;
}
-(void) dealloc
{
   [_concretizer release];
   [super dealloc];
}
-(void) addVariable: (id<ORVar>) var
{
   [_solver trackVariable:var];
}
-(void) addObject: (id) object
{
   [_solver trackObject: object];
}
-(id<ORConstraint>) addConstraint: (id<ORConstraint>) cstr
{
   [cstr visit: _concretizer];
   id<CPConstraint> c = [cstr dereference];
   [_solver addConstraintDuringSearch: c annotation: DomainConsistency];
   return cstr;
}
-(id<ORObjectiveFunction>) minimizeVar:(id<ORIntVar>) x
{
   @throw [[ORExecutionError alloc] initORExecutionError: "calls to minimizeVar: not allowed during search"];
}
-(id<ORObjectiveFunction>) maximizeVar:(id<ORIntVar>) x
{
   @throw [[ORExecutionError alloc] initORExecutionError: "calls to maximizeVar: not allowed during search"];
}
-(id<ORObjectiveFunction>) minimize:(id<ORExpr>) x
{
   @throw [[ORExecutionError alloc] initORExecutionError: "calls to minimize: not allowed during search"];
}
-(id<ORObjectiveFunction>) maximize:(id<ORExpr>) x
{
   @throw [[ORExecutionError alloc] initORExecutionError: "calls to maximize: not allowed during search"];
}
-(id<ORObjectiveFunction>) minimize: (id<ORVarArray>) var coef: (id<ORFloatArray>) coef
{
   @throw [[ORExecutionError alloc] initORExecutionError: "calls to minimize:coef: not allowed during search"];   
}
-(id<ORObjectiveFunction>) maximize: (id<ORVarArray>) var coef: (id<ORFloatArray>) coef
{
   @throw [[ORExecutionError alloc] initORExecutionError: "calls to maximize:coef: not allowed during search"];
}
-(void) trackObject: (id) obj
{
   [_solver trackObject:obj];
}
-(void) trackVariable: (id) obj
{
   [_solver trackVariable:obj];
}
-(void) trackConstraint:(id) obj
{
   [_solver trackConstraint:obj];
}
-(void) compiling:(id<ORConstraint>)cstr
{
}
-(NSSet*)compiledMap
{
   return NULL;
}
@end

@implementation CPSolver
-(id<CPProgram>) initCPSolver
{
   self = [super initCPCoreSolver];
   _trail = [ORFactory trail];
   _engine = [CPFactory engine: _trail];
   _tracer = [[DFSTracer alloc] initDFSTracer: _trail];
   ORControllerFactoryI* cFact = [[ORControllerFactoryI alloc] initORControllerFactoryI: self
                                                                    rootControllerClass: [ORDFSController class]
                                                                  nestedControllerClass: [ORDFSController class]];
   _search = [ORExplorerFactory explorer: _engine withTracer: _tracer ctrlFactory: cFact];
   [cFact release];
   return self;
}
-(void) dealloc
{
   [_trail release];
   [_engine release];
   [_search release];
   [_tracer release];
   [super dealloc];
}

-(void) add: (id<ORConstraint>) c
{
   // PVH: Need to flatten/concretize
   // PVH: Only used during search
   // LDM: DONE. Have not checked the variable creation/deallocation logic though. 
   id<ORAddToModel> trg = [[ORRTModel alloc] init:self];
   if ([[c class] conformsToProtocol:@protocol(ORRelation)])
      [ORFlatten flattenExpression:(id<ORExpr>) c into: trg annotation: DomainConsistency];
   else
      [ORFlatten flatten: c into:trg];
   [trg release];
}
-(void) add: (id<ORConstraint>) c annotation: (ORAnnotation) cons
{
   // PVH: Need to flatten/concretize
   // PVH: Only used during search
   // LDM: See above. 
   id<ORAddToModel> trg = [[ORRTModel alloc] init: self];
   if ([[c class] conformsToProtocol:@protocol(ORRelation)])
      [ORFlatten flattenExpression: (id<ORExpr>) c into: trg annotation: cons];
   else
      [ORFlatten flatten: c into: trg];
   [trg release];
}
-(void) labelImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce: ^ORStatus { return [var bind: val];}];
   if (status == ORFailure) {
      [_failLabel notifyWith:var andInt:val];
      [_search fail];
   }
   [_returnLabel notifyWith:var andInt:val];
   [ORConcurrency pumpEvents];
}
-(void) diffImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce:^ORStatus { return [var remove:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) lthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce:^ORStatus { return  [var updateMax:val-1];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) gthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce:^ORStatus { return [var updateMin:val+1];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) restrictImpl: (id<CPIntVar>) var to: (id<ORIntSet>) S
{
   ORStatus status = [_engine enforce:^ORStatus { return [var inside:S];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)var at:(ORUInt)i with:(ORBool)val
{
   ORStatus status = [_engine enforce:^ORStatus { return [[var domain] setBit:i to:val for:var];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];   
}
@end

/******************************************************************************************/
/*                                   CPSemanticSolver                                     */
/******************************************************************************************/

@implementation CPSemanticSolver
-(id<CPSemanticProgram>) initCPSemanticSolver
{
   self = [super initCPCoreSolver];
   _trail = [ORFactory trail];
   _engine = [CPFactory engine: _trail];
   _tracer = [[DFSTracer alloc] initDFSTracer: _trail];
   ORControllerFactoryI* cFact = [[ORControllerFactoryI alloc] initORControllerFactoryI: self
                                                                    rootControllerClass: [ORDFSController class]
                                                                  nestedControllerClass: [ORDFSController class]];
   _search = [ORExplorerFactory semanticExplorer: _engine withTracer: _tracer ctrlFactory: cFact];
   [cFact release];
   return self;
}

-(id<CPSemanticProgram>) initCPSemanticSolverDFS
{
   self = [super init];
   _trail = [ORFactory trail];
   _engine = [CPFactory engine: _trail];
   _tracer = [[SemTracer alloc] initSemTracer: _trail];
   ORControllerFactoryI* cFact = [[ORControllerFactoryI alloc] initORControllerFactoryI: self
                                                                    rootControllerClass: [ORSemDFSControllerCSP class]
                                                                  nestedControllerClass: [ORSemDFSControllerCSP class]];
   _search = [ORExplorerFactory semanticExplorer: _engine withTracer: _tracer ctrlFactory: cFact];
   [cFact release];
   return self;
}
-(id<CPSemanticProgram>) initCPSemanticSolver: (Class) ctrlClass
{
   self = [super initCPCoreSolver]; 
   _trail = [ORFactory trail];
   _engine = [CPFactory engine: _trail];
   _tracer = [[SemTracer alloc] initSemTracer: _trail];
   ORControllerFactoryI* cFact = [[ORControllerFactoryI alloc] initORControllerFactoryI: self
                                                                    rootControllerClass: [ORSemDFSControllerCSP class]
                                                                  nestedControllerClass: ctrlClass];
   _search = [ORExplorerFactory semanticExplorer: _engine withTracer: _tracer ctrlFactory: cFact];
   [cFact release];
   return self;
}
-(void) dealloc
{
   [_trail release];
   [_engine release];
   [_search release];
   [_tracer release];
   [super dealloc];
}
-(void) add: (id<ORConstraint>) c
{
   // PVH: Need to flatten/concretize
   // PVH: Only used during search
   ORStatus status = [_engine add: c];
   if (status == ORFailure)
      [_search fail];
}
-(void) add: (id<ORConstraint>) c annotation:(ORAnnotation) cons
{
   // PVH: Need to flatten/concretize
   // PVH: Only used during search
   ORStatus status = [_engine add: c];
   if (status == ORFailure)
      [_search fail];
}
-(void) labelImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce: ^ORStatus { return [var bind: val];}];
   if (status == ORFailure) {
      [_failLabel notifyWith:var andInt:val];
      [_search fail];
   }
   [_tracer addCommand: [CPSearchFactory equalc: var to: val]];
   [_returnLabel notifyWith:var andInt:val];
   [ORConcurrency pumpEvents];
}
-(void) diffImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce:^ORStatus { return [var remove:val];}];
   if (status == ORFailure)
      [_search fail];
   [_tracer addCommand: [CPSearchFactory notEqualc: var to: val]];
   [ORConcurrency pumpEvents];
}
-(void) lthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce:^ORStatus { return  [var updateMax:val-1];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) gthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce:^ORStatus { return [var updateMin:val+1];}];
   if (status == ORFailure)
      [_search fail];   
   [ORConcurrency pumpEvents];
}
-(void) restrictImpl: (id<CPIntVar>) var to: (id<ORIntSet>) S
{
   ORStatus status = [_engine enforce:^ORStatus { return [var inside:S];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)var at:(ORUInt)i with:(ORBool)val
{
   ORStatus status = [_engine enforce:^ORStatus { return [[var domain] setBit:i to:val for:var];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}

//- (void) encodeWithCoder:(NSCoder *)aCoder
//{
//   [super encodeWithCoder:aCoder];
//}
//- (id) initWithCoder:(NSCoder *)aDecoder;
//{
//   self = [super initWithCoder:aDecoder];
//   _tracer = [[SemTracer alloc] initSemTracer: _trail];
//   id<ORControllerFactory> cFact = [[ORControllerFactory alloc] initFactory:self
//                                                        rootControllerClass:[ORSemDFSControllerCSP class]
//                                                      nestedControllerClass:[ORSemDFSController class]];
//   _search = [[ORSemExplorerI alloc] initORExplorer: _engine withTracer: _tracer ctrlFactory:cFact];
//   [cFact release];
//   return self;
//}
//-(ORStatus)installCheckpoint:(id<ORCheckpoint>)cp
//{
//   return [_tracer restoreCheckpoint:cp inSolver:_engine];
//}
//-(ORStatus)installProblem:(id<ORProblem>)problem
//{
//   return [_tracer restoreProblem:problem inSolver:_engine];
//}
//-(id<ORCheckpoint>)captureCheckpoint
//{
//   return [_tracer captureCheckpoint];
//}
//-(NSData*)packCheckpoint:(id<ORCheckpoint>)cp
//{
//   id<ORCheckpoint> theCP = [_tracer captureCheckpoint];
//   NSData* thePack = [theCP packFromSolver:_engine];
//   [theCP release];
//   return thePack;
//}
@end


@implementation CPInformerPortal
-(CPInformerPortal*) initCPInformerPortal: (CPSolver*) cp
{
   self = [super init];
   _cp = cp;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(id<ORIdxIntInformer>) retLabel
{
   return [_cp retLabel];
}
-(id<ORIdxIntInformer>) failLabel
{
   return [_cp failLabel];
}
-(id<ORInformer>) propagateFail
{
   return [[_cp engine] propagateFail];
}
-(id<ORInformer>) propagateDone
{
   return [[_cp engine] propagateDone];
}
@end

@implementation CPSolverFactory 
+(id<CPProgram>) solver
{
   return [[CPSolver alloc] initCPSolver];
}
+(id<CPSemanticProgramDFS>) semanticSolverDFS
{
   return [[CPSemanticSolver alloc] initCPSemanticSolverDFS];
}
+(id<CPSemanticProgram>) semanticSolver: (Class) ctrlClass
{
   return [[CPSemanticSolver alloc] initCPSemanticSolver: ctrlClass];
}
@end

@implementation CPUtilities

+(ORInt) maxBound: (id<ORIdArray>) x
{
   ORInt low = [x low];
   ORInt up = [x up];
   ORInt M = -MAXINT;
   for(ORInt i = low; i <= up; i++) {
      id<CPIntVar> xi = [x[i] dereference];
      if ([xi bound] && [xi value] > M)
         M = [xi value];
   }
   return M;
}
@end

