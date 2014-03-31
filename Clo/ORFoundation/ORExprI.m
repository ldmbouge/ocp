/************************************************************************
 Mozilla Public License
 
 Copyright (c)  2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORExpr.h>
#import "ORExprI.h"
#import "ORFactory.h"
#import "ORError.h"
#import "ORConstraint.h"
#import <ORFoundation/ORVisit.h>


@implementation NSNumber (Expressions)
-(id<ORExpr>) asExpression:(id<ORTracker>) tracker
{
   const char* tt = [self objCType];
   if (strcmp(tt,@encode(ORInt))==0 || strcmp(tt,@encode(ORUInt)) ==0 || strcmp(tt,@encode(ORLong)) ==0 || strcmp(tt,@encode(ORULong)) ==0)
      return [ORFactory integer:tracker value:[self intValue]];
   else if (strcmp(tt,@encode(float))==0 || strcmp(tt,@encode(double))==0)
      return [ORFactory float:tracker value:[self floatValue]];  
   else if (strcmp(tt,@encode(ORBool))==0 || strcmp(tt,@encode(ORBool))==0)
      return [ORFactory integer:tracker value:[self boolValue]];
   else {
      assert(NO);
   }
   return NULL;
}
-(id<ORExpr>) mul: (id<ORExpr>)  r
{
   return [[self asExpression:[r tracker]] mul:r];
}
-(id<ORExpr>)  plus: (id<ORExpr>)  r
{
   return [[self asExpression:[r tracker]] plus:r];
}
-(id<ORExpr>)  sub:(id<ORExpr>)  r
{
   if ([r conformsToProtocol:@protocol(ORExpr)])
      return [[self asExpression:[r tracker]] sub:r];
   else if ([r isKindOfClass:[NSNumber class]]) {
      return (id)[NSNumber numberWithInt:[self intValue] - [r intValue]];
   } else return NULL;
}
-(id<ORExpr>)  div:(id<ORExpr>)  r
{
   return [[self asExpression:[r tracker]] div:r];
}
-(id<ORExpr>)   mod: (id<ORExpr>)   e
{
   return [[self asExpression:[e tracker]] mod:e];
}
-(id<ORExpr>) min: (id<ORExpr>) e
{
   return [[self asExpression:[e tracker]] min:e];
}
-(id<ORExpr>) max: (id<ORExpr>) e
{
   return [[self asExpression:[e tracker]] max:e];
}
-(id<ORRelation>)   eq: (id<ORExpr>)   e
{
   return [[self asExpression:[e tracker]] eq:e];
}
-(id<ORRelation>)   neq: (id<ORExpr>)   e
{
   return [[self asExpression:[e tracker]] neq:e];
}
-(id<ORRelation>)   leq: (id<ORExpr>)   e
{
   return [[self asExpression:[e tracker]] leq:e];
}
-(id<ORRelation>)   geq: (id<ORExpr>)   e
{
   return [[self asExpression:[e tracker]] geq:e];
}
-(id<ORRelation>) lt: (id<ORExpr>) e
{
   return [[self asExpression:[e tracker]] lt:e];
}
-(id<ORRelation>) gt: (id<ORExpr>) e
{
   return [[self asExpression:[e tracker]] gt:e];
}
-(id<ORRelation>) and: (id<ORExpr>) e
{
   return [[self asExpression:[e tracker]] and:e];
}
-(id<ORRelation>) or: (id<ORExpr>) e
{
   return [[self asExpression:[e tracker]] or:e];
}
@end

@interface ORSweep : ORNOopVisit<NSObject> {
   NSMutableSet* _ms;
}
-(id)init;
-(NSSet*)doIt:(id<ORExpr>)e;
// Variables
-(void) visitIntVar: (id<ORIntVar>) v;
-(void) visitBitVar: (id<ORBitVar>) v;
-(void) visitFloatVar: (id<ORFloatVar>) v;
-(void) visitIntVarLitEQView:(id<ORIntVar>)v;
-(void) visitAffineVar:(id<ORIntVar>) v;
// Expressions
-(void) visitExprPlusI: (id<ORExpr>) e;
-(void) visitExprMinusI: (id<ORExpr>) e;
-(void) visitExprMulI: (id<ORExpr>) e;
-(void) visitExprDivI: (id<ORExpr>) e;
-(void) visitExprModI: (id<ORExpr>) e;
-(void) visitExprEqualI: (id<ORExpr>) e;
-(void) visitExprNEqualI: (id<ORExpr>) e;
-(void) visitExprLEqualI: (id<ORExpr>) e;
-(void) visitExprGEqualI: (id<ORExpr>) e;
-(void) visitExprSumI: (id<ORExpr>) e;
-(void) visitExprProdI: (id<ORExpr>) e;
-(void) visitExprAbsI:(id<ORExpr>) e;
-(void) visitExprSquareI:(id<ORExpr>) e;
-(void) visitExprNegateI:(id<ORExpr>)e;
-(void) visitExprCstSubI: (id<ORExpr>) e;
-(void) visitExprDisjunctI:(id<ORExpr>) e;
-(void) visitExprConjunctI: (id<ORExpr>) e;
-(void) visitExprImplyI: (id<ORExpr>) e;
-(void) visitExprAggOrI: (id<ORExpr>) e;
-(void) visitExprAggAndI: (id<ORExpr>) e;
-(void) visitExprAggMinI: (id<ORExpr>) e;
-(void) visitExprAggMaxI: (id<ORExpr>) e;
-(void) visitExprVarSubI: (id<ORExpr>) e;
// Bit
-(void) visitBitEqual:(id<ORBitEqual>)c;
-(void) visitBitOr:(id<ORBitOr>)c;
-(void) visitBitAnd:(id<ORBitAnd>)c;
-(void) visitBitNot:(id<ORBitNot>)c;
-(void) visitBitXor:(id<ORBitXor>)c;
-(void) visitBitShiftL:(id<ORBitShiftL>)c;
-(void) visitBitRotateL:(id<ORBitRotateL>)c;
-(void) visitBitSum:(id<ORBitSum>)cstr;
-(void) visitBitIf:(id<ORBitIf>)cstr;
@end

@implementation ORSweep
-(id)init
{
   self = [super init];
   _ms  = NULL;
   return self;
}
-(NSSet*)doIt:(id<ORExpr>)e
{
   _ms = [[[NSMutableSet alloc] initWithCapacity:8] autorelease];
   [e visit:self];
   return _ms;
}
// Variables
-(void) visitIntVar: (id<ORIntVar>) v
{
   [_ms addObject:v];
}
-(void) visitBitVar: (id<ORBitVar>) v
{
   [_ms addObject:v];
}
-(void) visitFloatVar: (id<ORFloatVar>) v
{
   [_ms addObject:v];
}
-(void) visitIntVarLitEQView:(id<ORIntVar>)v
{
   [_ms addObject:v];
}
-(void) visitAffineVar:(id<ORIntVar>) v
{
   [_ms addObject:v];
}
// Expressions
-(void) visitExprPlusI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprMinusI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprMulI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprDivI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprModI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprMinI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprMaxI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprEqualI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprNEqualI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprLEqualI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprGEqualI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprSumI: (ORExprSumI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprProdI: (ORExprProdI*) e
{
   [[e expr] visit:self];   
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
   [[e operand] visit:self];
}
-(void) visitExprSquareI:(ORExprSquareI*) e
{
   [[e operand] visit:self];
}
-(void) visitExprNegateI:(ORExprNegateI*)e
{
   [[e operand] visit:self];
}
-(void) visitExprCstSubI: (ORExprCstSubI*) e
{
   [[e index] visit:self];
}
-(void) visitExprCstFloatSubI: (ORExprCstFloatSubI*) e
{
   [[e index] visit:self];
}
-(void) visitExprDisjunctI:(ORDisjunctI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprConjunctI: (ORConjunctI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprImplyI: (ORImplyI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprAggOrI: (ORExprAggOrI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprAggAndI: (ORExprAggAndI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprAggMinI: (ORExprAggMinI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprAggMaxI: (ORExprAggMaxI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprVarSubI: (ORExprVarSubI*) e
{
   [[e index] visit:self];
   id<ORIntVarArray> a = [e array];
   [a enumerateWith:^(id obj, int idx) {
      [_ms addObject:obj];
   }];
}
// Bit
-(void) visitBitEqual:(id<ORBitEqual>)c
{
   [[c left] visit:self];
   [[c right] visit:self];
}
-(void) visitBitOr:(id<ORBitOr>)c
{
   [[c left] visit:self];
   [[c right] visit:self];
   [[c res] visit:self];
}
-(void) visitBitAnd:(id<ORBitAnd>)c
{
   [[c left] visit:self];
   [[c right] visit:self];
   [[c res] visit:self];
}
-(void) visitBitNot:(id<ORBitNot>)c
{
   [[c left] visit:self];
   [[c right] visit:self];
}
-(void) visitBitXor:(id<ORBitXor>)c
{
   [[c left] visit:self];
   [[c right] visit:self];
   [[c res] visit:self];
}
-(void) visitBitShiftL:(id<ORBitShiftL>)c
{
   [[c left] visit:self];
   [[c right] visit:self];
}
-(void) visitBitRotateL:(id<ORBitRotateL>)c
{
   [[c left] visit:self];
   [[c right] visit:self];
}
-(void) visitBitSum:(id<ORBitSum>)c
{
   [[c res] visit:self];
   [[c left] visit:self];
   [[c right] visit:self];
   [[c in] visit:self];
   [[c out] visit:self];
}
-(void) visitBitIf:(id<ORBitIf>)c
{
   [[c trueIf] visit:self];
   [[c res] visit:self];
   [[c equals] visit:self];
   [[c zeroIfXEquals] visit:self];
}
@end


@implementation ORExprI
-(id<ORTracker>) tracker
{
   return nil;
}
-(ORInt) min
{
   @throw [[ORExecutionError alloc] initORExecutionError: "min not defined on expression"];
   return 0;
}
-(ORInt) max
{
   @throw [[ORExecutionError alloc] initORExecutionError: "max not defined on expression"];
   return 0;
}
-(ORInt) intValue
{
   @throw [[ORExecutionError alloc] initORExecutionError: "intvalue not defined on expression"];
   return 0;
}
-(ORFloat) floatValue
{
   @throw [[ORExecutionError alloc] initORExecutionError: "floatValue not defined on expression"];
   return 0;
}
-(ORBool) isConstant
{
   return NO;
}
-(ORBool) isVariable
{
   return NO;
}
-(enum ORRelationType) type
{
   return ORRBad;
}
-(enum ORVType) vtype
{
   return ORTNA;
}
-(id<ORExpr>) abs
{
   return [ORFactory exprAbs:self track:[self tracker]];
}
-(id<ORExpr>) square
{
   return [ORFactory exprSquare:self track:[self tracker]];
}
-(id<ORExpr>) plus: (id) e
{
   return [self plus:e track:[self tracker]];
}
-(id<ORExpr>) sub: (id) e
{
   return [self sub:e track:[self tracker]];
}
-(id<ORExpr>) mul: (id) e
{
   return [self mul:e track:[self tracker]];
}
-(id<ORExpr>) div: (id) e
{
   return [self div:e track:[self tracker]];
}
-(id<ORExpr>) mod: (id) e
{
   return [self mod:e track:[self tracker]];
}
-(id<ORExpr>) min: (id) e
{
   return [self min:e track:[self tracker]];
}
-(id<ORExpr>) max: (id) e
{
   return [self max:e track:[self tracker]];
}
-(id<ORRelation>) eq: (id) e
{
   return [self eq:e track:[self tracker]];
}
-(id<ORRelation>) neq: (id) e
{
   return [self neq:e track:[self tracker]];
}
-(id<ORRelation>) leq: (id) e
{
   return [self leq:e track:[self tracker]];
}
-(id<ORRelation>) geq: (id) e
{
   return [self geq:e track:[self tracker]];
}
-(id<ORRelation>) lt: (id) e
{
   return [self lt:e track:[self tracker]];
}
-(id<ORRelation>) gt: (id) e
{
   return [self gt:e track:[self tracker]];
}
-(id<ORExpr>)neg
{
   return [ORFactory exprNegate:self track:[self tracker]];
}
-(id<ORExpr>)and:(id<ORRelation>)e
{
   if (e == NULL)
      return self;
   else
      return [self and:e track:[self tracker]];
}
-(id<ORExpr>) or: (id<ORRelation>)e
{
   if (e == NULL)
      return self;
   else
      return [self or:e track:[self tracker]];
}
-(id<ORExpr>) imply:(id<ORRelation>)e
{
   return [ORFactory expr:(id<ORRelation>)self imply:e track:[self tracker]];
}
-(id<ORExpr>) absTrack:(id<ORTracker>)t
{
   return [ORFactory exprAbs:self track:t];
}
-(id<ORExpr>) squareTrack:(id<ORTracker>)t
{
   return [ORFactory exprSquare:self track:t];
}
-(id<ORExpr>) plus: (id) e  track:(id<ORTracker>)t
{
   if ([e conformsToProtocol:@protocol(ORExpr)])
      return [ORFactory expr:self plus:e track:t];
   else if ([e isKindOfClass:[NSNumber class]])
      return [ORFactory expr:self plus:[e asExpression:t] track:t];
   else
      return NULL;   
}
-(id<ORExpr>) sub: (id) e  track:(id<ORTracker>)t
{
   if ([e conformsToProtocol:@protocol(ORExpr)])
      return [ORFactory expr:self sub:e track:t];
   else if ([e isKindOfClass:[NSNumber class]])
      return [ORFactory expr:self sub:[e asExpression:t] track:t];
   else
      return NULL;
}
-(id<ORExpr>) mul: (id) e  track:(id<ORTracker>)t
{
   if ([e conformsToProtocol:@protocol(ORExpr)])
      return [ORFactory expr:self mul:e track:t];
   else if ([e isKindOfClass:[NSNumber class]])
      return [ORFactory expr:self mul:[e asExpression:t] track:t];
   else
      return NULL;   
}
-(id<ORExpr>) div: (id) e  track:(id<ORTracker>)t
{
   if ([e conformsToProtocol:@protocol(ORExpr)])
      return [ORFactory expr:self div:e track:t];
   else if ([e isKindOfClass:[NSNumber class]])
      return [ORFactory expr:self div:[e asExpression:t] track:t];
   else
      return NULL;   
}
-(id<ORExpr>) mod: (id) e  track:(id<ORTracker>)t
{
   if ([e conformsToProtocol:@protocol(ORExpr)])
      return [ORFactory expr:self mod:e track:t];
   else if ([e isKindOfClass:[NSNumber class]])
      return [ORFactory expr:self mod:[e asExpression:t] track:t];
   else
      return NULL;
}
-(id<ORExpr>) min: (id) e  track:(id<ORTracker>)t
{
   if ([e conformsToProtocol:@protocol(ORExpr)])
      return [ORFactory expr:self min:e track:t];
   else if ([e isKindOfClass:[NSNumber class]])
      return [ORFactory expr:self min:[e asExpression:t] track:t];
   else
      return NULL;
}
-(id<ORExpr>) max: (id) e  track:(id<ORTracker>)t
{
   if ([e conformsToProtocol:@protocol(ORExpr)])
      return [ORFactory expr:self max:e track:t];
   else if ([e isKindOfClass:[NSNumber class]])
      return [ORFactory expr:self max:[e asExpression:t] track:t];
   else
      return NULL;
}
-(id<ORRelation>) eq: (id) e  track:(id<ORTracker>)t
{
   if ([e conformsToProtocol:@protocol(ORExpr)])
      return [ORFactory expr:self equal:e track:t];
   else if ([e isKindOfClass:[NSNumber class]])
      return [ORFactory expr:self equal:[e asExpression:t] track:t];
   else
      return NULL;   
}
-(id<ORRelation>) neq: (id) e  track:(id<ORTracker>)t
{
   if ([e conformsToProtocol:@protocol(ORExpr)])
      return [ORFactory expr:self neq:e track:t];
   else if ([e isKindOfClass:[NSNumber class]])
      return [ORFactory expr:self neq:[e asExpression:t] track:t];
   else
      return NULL;   
}
-(id<ORRelation>) leq: (id) e  track:(id<ORTracker>)t
{
   if ([e conformsToProtocol:@protocol(ORExpr)])
      return [ORFactory expr:self leq:e track:t];
   else if ([e isKindOfClass:[NSNumber class]])
      return [ORFactory expr:self leq:[e asExpression:t] track:t];
   else
      return NULL;
}
-(id<ORRelation>) geq: (id) e  track:(id<ORTracker>)t
{
   if ([e conformsToProtocol:@protocol(ORExpr)])
      return [ORFactory expr:self geq:e track:t];
   else if ([e isKindOfClass:[NSNumber class]])
      return [ORFactory expr:self geq:[e asExpression:t] track:t];
   else
      return NULL;   
}
-(id<ORRelation>) lt: (id) e  track:(id<ORTracker>)t
{
   id re = NULL;
   if ([e conformsToProtocol:@protocol(ORExpr)])
      re = e;
   else if ([e isKindOfClass:[NSNumber class]])
      re = [e asExpression:t];
   return [ORFactory expr:self leq:[re sub:[ORFactory integer:t value:1] track:t] track:t];
}
-(id<ORRelation>) gt: (id) e  track:(id<ORTracker>)t
{
   id re = NULL;
   if ([e conformsToProtocol:@protocol(ORExpr)])
      re = e;
   else if ([e isKindOfClass:[NSNumber class]])
      re = [e asExpression:t];
   return [ORFactory expr:self geq:[re plus:[ORFactory integer:t value:1]] track:t];
}
-(id<ORRelation>) negTrack:(id<ORTracker>)t
{
   return (id)[ORFactory exprNegate:self track:t];
}
-(id<ORRelation>) and: (id<ORExpr>) e  track:(id<ORTracker>)t
{
   if ([e conformsToProtocol:@protocol(ORExpr)])
      return (id)[ORFactory expr:(id)self and:(id)e track:t];
   else if ([e isKindOfClass:[NSNumber class]])
      return (id)[ORFactory expr:(id)self and:(id)[(id)e asExpression:t] track:t];
   else
      return NULL;
}
-(id<ORRelation>) or: (id<ORExpr>) e track:(id<ORTracker>)t
{
   return (id)[ORFactory expr:(id)self or:(id)e track:t];
}
-(id<ORRelation>) imply:(id<ORExpr>)e  track:(id<ORTracker>)t
{
   return (id)[ORFactory expr:(id)self imply:(id)e track:t];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{}
- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super init];
   return self;
}
- (void)visit:(ORVisitor*)visitor
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Visitor not found"];
}
-(NSSet*)allVars
{
   ORSweep* sweep = [[ORSweep alloc] init];
   NSSet* rv = [sweep doIt:self];
   [sweep release];
   return rv;
}
@end

// --------------------------------------------------------------------------------


@implementation ORExprBinaryI

-(id<ORExpr>) initORExprBinaryI: (id<ORExpr>) left and: (id<ORExpr>) right
{
   self = [super init];
   _left = left;
   _right = right;
   _tracker = [left tracker];
   if (!_tracker)
      _tracker = [right tracker];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(id<ORExpr>) left
{
   return _left;
}
-(id<ORExpr>) right
{
   return _right;
}
-(id<ORTracker>) tracker
{
   return _tracker;
}
-(ORBool) isConstant
{
   return [_left isConstant] && [_right isConstant];
}
-(enum ORVType) vtype
{
   ORVType rvt = [_right conformsToProtocol:@protocol(ORExpr)] ? [_right vtype] : ORTInt;
   ORVType lvt = [_left conformsToProtocol:@protocol(ORExpr)] ? [_left vtype] : ORTInt;
   return lubVType(lvt,rvt);
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_left];
   [aCoder encodeObject:_right];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _left  = [aDecoder decodeObject];
   _right = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORExprAbsI
-(id<ORExpr>) initORExprAbsI: (id<ORExpr>) op
{
   self = [super init];
   _op = op;
   return self;
}
-(id<ORTracker>) tracker
{
   return [_op tracker];
}
-(ORInt) min
{
   return 0;
}
-(ORInt) max
{
   ORInt opMax = [_op max];
   ORInt opMin = [_op min];
   if (opMin >=0)
      return opMax;
   else if (opMax < 0)
      return -opMax;
   else 
      return max(-opMin,opMax);
}
-(ORExprI*) operand
{
   return _op;
}
-(ORBool) isConstant
{
   return [_op isConstant];
}
-(enum ORVType) vtype
{
   return _op.vtype;
}
-(NSString *)description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"abs(%@)",[_op description]];
   return rv;   
}
-(void) visit:(ORVisitor*)visitor
{
   [visitor visitExprAbsI:self];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_op];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _op = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORExprSquareI
-(id<ORExpr>) initORExprSquareI: (id<ORExpr>) op
{
   self = [super init];
   _op = op;
   return self;
}
-(id<ORTracker>) tracker
{
   return [_op tracker];
}
-(ORInt) min
{
   ORInt min2 = _op.min * _op.min;
   if (_op.min >= 0)
      return min2;
   else return 0;
}
-(ORInt) max
{
   ORInt min2 = _op.min * _op.min;
   ORInt max2 = _op.max * _op.max;
   ORInt ub = max(min2, max2);
   return ub;
}
-(ORExprI*) operand
{
   return _op;
}
-(ORBool) isConstant
{
   return [_op isConstant];
}
-(enum ORVType) vtype
{
   return _op.vtype;
}
-(NSString *)description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"square(%@)",[_op description]];
   return rv;
}
-(void) visit:(ORVisitor*)visitor
{
   [visitor visitExprSquareI:self];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_op];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _op = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORExprNegateI
-(id<ORExpr>) initORNegateI: (id<ORExpr>) op
{
   self = [super init];
   _op = op;
   return self;
}
-(id<ORTracker>) tracker
{
   return [_op tracker];
}
-(ORInt) min
{
   return 0;
}
-(ORInt) max
{
   return 1;
}
-(ORExprI*) operand
{
   return _op;
}
-(ORBool) isConstant
{
   return [_op isConstant];
}
-(enum ORVType) vtype
{
   return _op.vtype;
}
-(NSString *)description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"neg(%@)",[_op description]];
   return rv;
}
-(void) visit:(ORVisitor*)visitor
{
   [visitor visitExprNegateI:self];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_op];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _op = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORExprCstSubI
-(id<ORExpr>) initORExprCstSubI: (id<ORIntArray>) array index:(id<ORExpr>) op
{
   self = [super init];
   _array = array;
   _index = op;
   return self;
}
-(id<ORTracker>) tracker
{
   return [_index tracker];
}
-(ORInt) min
{
   ORInt minOf = MAXINT;
   for(ORInt k=[_array low];k<=[_array up];k++)
      minOf = minOf <[_array at:k] ? minOf : [_array at:k];
   return minOf;
}
-(ORInt) max
{
   ORInt maxOf = MININT;
   for(ORInt k=[_array low];k<=[_array up];k++)
      maxOf = maxOf > [_array at:k] ? maxOf : [_array at:k];
   return maxOf;
}
-(NSString *)description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"%@[%@]",_array,_index];
   return rv;   
}
-(ORExprI*) index
{
   return  _index;
}
-(id<ORIntArray>)array
{
   return _array;
}
-(ORBool) isConstant
{
   return [_index isConstant];
}
-(enum ORVType) vtype
{
   return ORTInt;
}
-(void) visit:(ORVisitor*)visitor
{
   [visitor visitExprCstSubI:self];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_array];
   [aCoder encodeObject:_index];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _array = [aDecoder decodeObject];
   _index = [aDecoder decodeObject];
   return self;
}
@end


@implementation ORExprCstFloatSubI
-(id<ORExpr>) initORExprCstFloatSubI: (id<ORFloatArray>) array index:(id<ORExpr>) op
{
   self = [super init];
   _array = array;
   _index = op;
   return self;
}
-(id<ORTracker>) tracker
{
   return [_index tracker];
}
-(ORFloat) fmin
{
   ORFloat minOf = MAXINT;
   for(ORInt k=[_array low];k<=[_array up];k++)
      minOf = minOf <[_array at:k] ? minOf : [_array at:k];
   return minOf;
}
-(ORFloat) fmax
{
   ORFloat maxOf = MININT;
   for(ORInt k=[_array low];k<=[_array up];k++)
      maxOf = maxOf > [_array at:k] ? maxOf : [_array at:k];
   return maxOf;
}
-(NSString *)description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"%@[%@]",_array,_index];
   return rv;
}
-(ORExprI*) index
{
   return  _index;
}
-(id<ORFloatArray>)array
{
   return _array;
}
-(ORBool) isConstant
{
   return [_index isConstant];
}
-(enum ORVType) vtype
{
   return ORTInt;
}
-(void) visit:(ORVisitor*)visitor
{
   [visitor visitExprCstFloatSubI:self];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_array];
   [aCoder encodeObject:_index];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _array = [aDecoder decodeObject];
   _index = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORExprPlusI 
-(id<ORExpr>) initORExprPlusI: (id<ORExpr>) left and: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) min 
{
   return [_left min] + [_right min]; 
}
-(ORInt) max
{
   return [_left max] + [_right max]; 
}

-(void) visit:(ORVisitor*) visitor
{
   [visitor visitExprPlusI: self]; 
}
-(NSString*) description 
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"%@ + %@",[_left description],[_right description]];
   return rv;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end

@implementation ORExprMinusI 
-(id<ORExpr>) initORExprMinusI: (id<ORExpr>) left and: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) min 
{
   return [_left min] - [_right max]; 
}
-(ORInt) max
{
   return [_left max] - [_right min]; 
}

-(void) visit: (ORVisitor*) visitor
{
   [visitor visitExprMinusI: self]; 
}
-(NSString*) description 
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"(%@ - %@)",[_left description],[_right description]];
   return rv;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end

@implementation ORExprMulI
-(id<ORExpr>) initORExprMulI: (id<ORExpr>) left and: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) min 
{
   ORInt m1 = min([_left min] * [_right min],[_left min] * [_right max]);
   ORInt m2 = min([_left max] * [_right min],[_left max] * [_right max]);
   return min(m1,m2);
}
-(ORInt) max
{
   ORInt m1 = max([_left min] * [_right min],[_left min] * [_right max]);
   ORInt m2 = max([_left max] * [_right min],[_left max] * [_right max]);
   return max(m1,m2);
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitExprMulI: self]; 
}
-(NSString*) description 
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"(%@ * %@)",[_left description],[_right description]];
   return rv;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end

@implementation ORExprDivI
-(id<ORExpr>) initORExprDivI: (id<ORExpr>) left and: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) min
{
   ORInt m1 = min([_left min] / [_right min],[_left min] / [_right max]);
   ORInt m2 = min([_left max] / [_right min],[_left max] / [_right max]);
   return min(m1,m2);
}
-(ORInt) max
{
   ORInt m1 = max([_left min] / [_right min],[_left min] / [_right max]);
   ORInt m2 = max([_left max] / [_right min],[_left max] / [_right max]);
   return max(m1,m2);
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitExprDivI: self];
}
-(NSString*) description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"(%@ / %@)",[_left description],[_right description]];
   return rv;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end

@implementation ORExprModI
-(id<ORExpr>) initORExprModI: (id<ORExpr>) left mod: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(ORInt) min
{
   ORInt ub = max(abs([_right min]),abs([_right max])) - 1;
   if ([_left min] > 0)
      return 0;
   else
      return - ub;
}
-(ORInt) max
{
   ORInt ub = max(abs([_right min]),abs([_right max])) - 1;
   if ([_left max] < 0)
      return 0;
   else
      return ub;
}
-(NSString *)description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"(%@ mod %@)",[_left description],[_right description]];
   return rv;
}
-(void) visit: (ORVisitor*)visitor
{
   [visitor visitExprModI:self];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end


@implementation ORExprMinI
-(id<ORExpr>) initORExprMinI: (id<ORExpr>) left min: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(ORInt) min
{
   return min([_right min],[_left min]);
}
-(ORInt) max
{
   return min([_right max],[_left max]);
}
-(NSString *)description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"(%@ min %@)",[_left description],[_right description]];
   return rv;
}
-(void) visit: (ORVisitor*)visitor
{
   [visitor visitExprMinI:self];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end

@implementation ORExprMaxI
-(id<ORExpr>) initORExprMaxI: (id<ORExpr>) left max: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(ORInt) min
{
   return max([_right min],[_left min]);
}
-(ORInt) max
{
   return max([_right max],[_left max]);
}
-(NSString *)description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"(%@ max %@)",[_left description],[_right description]];
   return rv;
}
-(void) visit: (ORVisitor*)visitor
{
   [visitor visitExprMaxI:self];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end


@implementation ORExprEqualI 
-(id<ORExpr>) initORExprEqualI: (id<ORExpr>) left and: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) min 
{
   assert([self isConstant]);
   return [_left min] == [_right min];
}
-(ORInt) max 
{
   assert([self isConstant]);
   return [_left max] == [_right max];
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitExprEqualI: self]; 
}
-(NSString*) description 
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"%@ == %@",[_left description],[_right description]];
   return rv;
}
-(enum ORRelationType)type
{
   return ORREq;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end


@implementation ORExprNotEqualI
-(id<ORExpr>) initORExprNotEqualI: (id<ORExpr>) left and: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) min
{
   assert([self isConstant]);
   return [_left min] != [_right min];
}
-(ORInt) max
{
   assert([self isConstant]);
   return [_left max] != [_right max];
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitExprNEqualI: self];
}
-(NSString*) description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"%@ != %@",[_left description],[_right description]];
   return rv;
}
-(enum ORRelationType)type
{
   return ORRNEq;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end

@implementation ORExprLEqualI
-(id<ORExpr>) initORExprLEqualI: (id<ORExpr>) left and: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) min
{
   assert([self isConstant]);
   return [_left min] <= [_right min];
}
-(ORInt) max
{
   assert([self isConstant]);
   return [_left max] <= [_right max];
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitExprLEqualI: self];
}
-(NSString*) description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"%@ <= %@",[_left description],[_right description]];
   return rv;
}
-(enum ORRelationType)type
{
   return ORRLEq;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end

@implementation ORExprGEqualI
-(id<ORExpr>) initORExprGEqualI: (id<ORExpr>) left and: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) min
{
   assert([self isConstant]);
   return [_left min] >= [_right min];
}
-(ORInt) max
{
   assert([self isConstant]);
   return [_left max] >= [_right max];
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitExprGEqualI: self];
}
-(NSString*) description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"%@ >= %@",[_left description],[_right description]];
   return rv;
}
-(enum ORRelationType)type
{
   return ORRGEq;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end

@implementation ORDisjunctI
-(id<ORExpr>) initORDisjunctI: (id<ORExpr>) left or: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) min
{
   return [_left min] || [_right min];
}
-(ORInt) max
{
   return [_left max] || [_right max];
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitExprDisjunctI: self];
}
-(NSString*) description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"(%@ || %@)",[_left description],[_right description]];
   return rv;
}
-(enum ORRelationType)type
{
   return ORRDisj;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end

@implementation ORConjunctI
-(id<ORExpr>) initORConjunctI: (id<ORExpr>) left and: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) min
{
   return [_left min] && [_right min];
}
-(ORInt) max
{
   return [_left max] && [_right max];
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitExprConjunctI: self];
}
-(NSString*) description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"(%@ && %@)",[_left description],[_right description]];
   return rv;
}
-(enum ORRelationType)type
{
   return ORRConj;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end

@implementation ORImplyI
-(id<ORExpr>) initORImplyI: (id<ORExpr>) left imply: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) min
{
   return ![_left min] || [_right min];
}
-(ORInt) max
{
   return ![_left max] || [_right max];
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitExprImplyI: self];
}
-(NSString*) description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"(%@ => %@)",[_left description],[_right description]];
   return rv;
}
-(enum ORRelationType)type
{
   return ORRImply;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end

@implementation ORExprSumI
-(id<ORExpr>) init: (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e
{
   self = [super init];
   _e = [ORFactory integer: tracker value: 0];
   @autoreleasepool {
      if (f != NULL) {
         [S enumerateWithBlock:^(ORInt i) {
            if (f(i))
               _e = [_e plus:e(i)];
         }];
      } else {
         [S enumerateWithBlock:^(ORInt i) {
            _e = [_e plus:e(i)];
         }];
      }
   }
   return self;
}
-(id<ORExpr>) init: (id<ORTracker>) tracker over: (id<ORIntIterable>) S1 over: (id<ORIntIterable>) S2
          suchThat: (ORIntxInt2Bool) f
                of: (ORIntxInt2Expr) e
{
    self = [super init];
    _e = [ORFactory integer: tracker value: 0];
   @autoreleasepool {
      if (f!= NULL) {
         [S1 enumerateWithBlock:^(ORInt i) {
            [S2 enumerateWithBlock:^(ORInt j) {
               if (f(i,j))
                  _e = [_e plus:e(i,j)];
            }];
         }];
      }
      else {
         [S1 enumerateWithBlock:^(ORInt i) {
            [S2 enumerateWithBlock:^(ORInt j) {
               _e = [_e plus:e(i,j)];
            }];
         }];
      }
   }
   return self;
}
-(id<ORExpr>) init: (id<ORExpr>) e
{
   self = [super init];
   _e = e;
   return self;
}

-(void) dealloc
{   
   [super dealloc];
}
-(id<ORExpr>) expr
{
   return _e;
}
-(ORInt) min
{
   return [_e min];
}
-(ORInt) max
{
   return [_e max];
}
-(ORBool) isConstant
{
   return [_e isConstant];
}
-(enum ORVType) vtype
{
   return _e.vtype;
}
-(id<ORTracker>) tracker
{
   return [_e tracker];
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitExprSumI: self]; 
}
-(NSString *) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendString:@"("];
   [buf appendString:[_e description]];
   [buf appendString:@")"];
   return buf;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_e];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _e = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORExprProdI
-(id<ORExpr>) init: (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e
{
   self = [super init];
   _e = [ORFactory integer: tracker value: 1];
   if (f!=NULL) {
      [S enumerateWithBlock:^(ORInt i) {
         if (f(i))
            _e = [_e mul: e(i)];
      }];
   }
   else {
      [S enumerateWithBlock:^(ORInt i) {
         _e = [_e mul: e(i)];
      }];
   }
   return self;
}
-(id<ORExpr>) init: (id<ORExpr>) e
{
   self = [super init];
   _e = e;
   return self;
}

-(void) dealloc
{
   [super dealloc];
}
-(id<ORExpr>) expr
{
   return _e;
}
-(ORInt) min
{
   return [_e min];
}
-(ORInt) max
{
   return [_e max];
}
-(ORBool) isConstant
{
   return [_e isConstant];
}
-(enum ORVType) vtype
{
   return _e.vtype;
}
-(id<ORTracker>) tracker
{
   return [_e tracker];
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitExprProdI: self];
}
-(NSString *) description
{
   return [_e description];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_e];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _e = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORExprAggMinI
-(id<ORExpr>) init: (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e
{
   self = [super init];
   _e = [ORFactory integer: tracker value: FDMAXINT];
   if (f!=NULL) {
      [S enumerateWithBlock:^(ORInt i) {
         if (f(i))
            _e = [_e min: e(i)];
      }];
   }
   else {
      [S enumerateWithBlock:^(ORInt i) {
         _e = [_e min: e(i)];
      }];
   }
   return self;
}
-(id<ORExpr>) init: (id<ORExpr>) e
{
   self = [super init];
   _e = e;
   return self;
}

-(void) dealloc
{
   [super dealloc];
}
-(id<ORExpr>) expr
{
   return _e;
}
-(ORInt) min
{
   return [_e min];
}
-(ORInt) max
{
   return [_e max];
}
-(ORBool) isConstant
{
   return [_e isConstant];
}
-(enum ORVType) vtype
{
   return _e.vtype;
}
-(id<ORTracker>) tracker
{
   return [_e tracker];
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitExprAggMinI: self];
}
-(NSString *) description
{
   return [_e description];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_e];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _e = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORExprAggMaxI
-(id<ORExpr>) init: (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e
{
   self = [super init];
   _e = [ORFactory integer: tracker value: FDMININT];
   if (f!=NULL) {
      [S enumerateWithBlock:^(ORInt i) {
         if (f(i))
            _e = [_e max: e(i)];
      }];
   }
   else {
      [S enumerateWithBlock:^(ORInt i) {
         _e = [_e max: e(i)];
      }];
   }
   return self;
}
-(id<ORExpr>) init: (id<ORExpr>) e
{
   self = [super init];
   _e = e;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(id<ORExpr>) expr
{
   return _e;
}
-(ORInt) min
{
   return [_e min];
}
-(ORInt) max
{
   return [_e max];
}
-(ORBool) isConstant
{
   return [_e isConstant];
}
-(enum ORVType) vtype
{
   return _e.vtype;
}
-(id<ORTracker>) tracker
{
   return [_e tracker];
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitExprAggMaxI: self];
}
-(NSString *) description
{
   return [_e description];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_e];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _e = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORExprAggOrI
-(id<ORRelation>) init: (id<ORTracker>) cp over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Relation) e
{
   self = [super init];
   _e = [ORFactory integer: cp value: 0];
   if (f!=NULL) {
      [S enumerateWithBlock:^(ORInt i) {
         if (!f(i))
            _e = [_e or: e(i)];
      }];
   }
   else {
      [S enumerateWithBlock:^(ORInt i) {
         _e = [_e or: e(i)];
      }];
   }
   return self;
}
-(id<ORRelation>) init: (id<ORExpr>) e
{
   self = [super init];
   _e = e;
   return self;
}

-(void) dealloc
{
   [super dealloc];
}
-(id<ORExpr>) expr
{
   return _e;
}
-(ORInt) min
{
   return [_e min];
}
-(ORInt) max
{
   return [_e max];
}
-(ORBool) isConstant
{
   return [_e isConstant];
}
-(enum ORVType) vtype
{
   return _e.vtype;
}
-(id<ORTracker>) tracker
{
   return [_e tracker];
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitExprAggOrI: self];
}
-(NSString *) description
{
   return [_e description];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_e];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _e = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORExprAggAndI
-(id<ORRelation>) init: (id<ORTracker>) cp over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Relation) e
{
   self = [super init];
   _e = [ORFactory integer: cp value: 1];
   if (f!=NULL) {
      [S enumerateWithBlock:^(ORInt i) {
         if (!f(i))
            _e = [_e and: e(i)];
      }];
   }
   else {
      [S enumerateWithBlock:^(ORInt i) {
         _e = [_e and: e(i)];
      }];
   }
   return self;
}
-(id<ORRelation>) init: (id<ORExpr>) e
{
   self = [super init];
   _e = e;
   return self;
}

-(void) dealloc
{
   [super dealloc];
}
-(id<ORExpr>) expr
{
   return _e;
}
-(ORInt) min
{
   return [_e min];
}
-(ORInt) max
{
   return [_e max];
}
-(ORBool) isConstant
{
   return [_e isConstant];
}
-(enum ORVType) vtype
{
   return _e.vtype;
}
-(id<ORTracker>) tracker
{
   return [_e tracker];
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitExprAggAndI: self];
}
-(NSString *) description
{
   return [_e description];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_e];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _e = [aDecoder decodeObject];
   return self;
}
@end


@implementation ORExprVarSubI
-(id<ORExpr>) initORExprVarSubI: (id<ORIntVarArray>) array elt:(id<ORExpr>) op
{
   self = [super init];
   _array = array;
   _index = op;
   return self;
}
-(id<ORTracker>) tracker
{
   return [_index tracker];
}
-(ORInt) min
{
   ORInt minOf = MAXINT;
   for(ORInt k=[_array low];k<=[_array up];k++) {
      id<ORIntRange> d = [_array[k] domain];
      minOf = minOf < [d low] ? minOf : [d low];
   }
   return minOf;
}
-(ORInt) max
{
   ORInt maxOf = MININT;
   for(ORInt k=[_array low];k<=[_array up];k++) {
      id<ORIntRange> d = [_array[k] domain];
      maxOf = maxOf > [d up] ? maxOf : [d up];
   }
   return maxOf;
}
-(NSString *)description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"%@[%@]",_array,_index];
   return rv;
}
-(ORExprI*) index
{
   return  _index;
}
-(id<ORIntVarArray>)array
{
   return _array;
}
-(ORBool) isConstant
{
   return [_index isConstant];
}
-(enum ORVType) vtype
{
   return ORTInt;
}
-(void) visit:(ORVisitor*)visitor
{
   [visitor visitExprVarSubI:self];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_array];
   [aCoder encodeObject:_index];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _array = [aDecoder decodeObject];
   _index = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORExprMatrixVarSubI
-(id<ORExpr>)initORExprMatrixVarSubI:(id<ORIntVarMatrix>)m elt:(id<ORExpr>)i0 elt:(id<ORExpr>)i1
{
   self = [super init];
   _m = m;
   _i0 = i0;
   _i1 = i1;
   return self;
}
-(id<ORTracker>)tracker
{
   return [_i0 tracker];
}
-(ORInt) min
{
   assert([_m arity] == 2);
   __block ORInt minOf = FDMAXINT;
   [[_m range:0] enumerateWithBlock:^(ORInt i) {
      [[_m range:1] enumerateWithBlock:^(ORInt j) {
         id<ORIntRange> d = [[_m at:i :j] domain];
         minOf = minOf < [d low] ? minOf : [d low];
      }];
   }];
   return minOf;
}
-(ORInt) max
{
   assert([_m arity] == 2);
   __block ORInt maxOf = FDMININT;
   [[_m range:0] enumerateWithBlock:^(ORInt i) {
      [[_m range:1] enumerateWithBlock:^(ORInt j) {
         id<ORIntRange> d = [[_m at:i :j] domain];
         maxOf = maxOf > [d up] ? maxOf : [d up];
      }];
   }];
   return maxOf;
}
-(NSString *)description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"%@[%@,%@]",_m,_i0,_i1];
   return rv;   
}
-(ORExprI*) index0
{
   return _i0;
}
-(ORExprI*) index1
{
   return _i1;
}
-(id<ORIntVarMatrix>)matrix
{
   return _m;
}
-(ORBool) isConstant
{
   return NO;
}
-(enum ORVType) vtype
{
   return ORTInt;
}
-(void) visit:(ORVisitor*) v
{
   [v visitExprMatrixVarSubI:self];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_m];
   [aCoder encodeObject:_i0];
   [aCoder encodeObject:_i1];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _m = [aDecoder decodeObject];
   _i0 = [aDecoder decodeObject];
   _i1 = [aDecoder decodeObject];
   return self;
}
@end


id<ORExpr> __attribute__((overloadable)) mult(NSNumber* l,id<ORExpr> r)
{
   return [r mul: l];
}
id<ORExpr> __attribute__((overloadable)) mult(id<ORExpr> l,id<ORExpr> r)
{
   return [l mul: r];
}



