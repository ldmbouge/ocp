//
//  ORFlatten.m
//  Clo
//
//  Created by Laurent Michel on 10/5/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import "ORFlatten.h"
#import "ORModelI.h"
#import "ORDecompose.h"

@interface ORFlattenObjects : NSObject<ORVisitor>
-(id)init:(id<ORINCModel>)m;
-(void) visitIntArray:(id<ORIntArray>)v;
-(void) visitIntMatrix:(id<ORIntMatrix>)v;
-(void) visitTrailableInt:(id<ORTrailableInt>)v;
-(void) visitIntSet:(id<ORIntSet>)v;
-(void) visitIntRange:(id<ORIntRange>)v;
-(void) visitIdArray: (id<ORIdArray>) v;
-(void) visitIdMatrix: (id<ORIdMatrix>) v;
-(void) visitTable:(id<ORTable>) v;
// Expressions
-(void) visitIntegerI: (id<ORInteger>) e;
-(void) visitExprPlusI: (id<ORExpr>) e;
-(void) visitExprMinusI: (id<ORExpr>) e;
-(void) visitExprMulI: (id<ORExpr>) e;
-(void) visitExprEqualI: (id<ORExpr>) e;
-(void) visitExprNEqualI: (id<ORExpr>) e;
-(void) visitExprLEqualI: (id<ORExpr>) e;
-(void) visitExprSumI: (id<ORExpr>) e;
-(void) visitExprAbsI:(id<ORExpr>) e;
-(void) visitExprCstSubI: (id<ORExpr>) e;
-(void) visitExprDisjunctI:(id<ORExpr>) e;
-(void) visitExprConjunctI: (id<ORExpr>) e;
-(void) visitExprImplyI: (id<ORExpr>) e;
-(void) visitExprAggOrI: (id<ORExpr>) e;
-(void) visitExprVarSubI: (id<ORExpr>) e;
// Constraints
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr;
-(void) visitMinimize: (id<ORObjectiveFunction>) v;
-(void) visitMaximize: (id<ORObjectiveFunction>) v;
@end

@interface ORFlattenConstraint : NSObject<ORVisitor>
-(id)init:(id<ORINCModel>)m;
-(void) visitRestrict:(id<ORRestrict>)cstr;
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr;
-(void) visitCardinality: (id<ORCardinality>) cstr;
-(void) visitPacking: (id<ORPacking>) cstr;
-(void) visitKnapsack:(id<ORKnapsack>) cstr;
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr;
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr;
-(void) visitEqualc: (id<OREqualc>)c;
-(void) visitNEqualc: (id<ORNEqualc>)c;
-(void) visitLEqualc: (id<ORLEqualc>)c;
-(void) visitEqual: (id<OREqual>)c;
-(void) visitNEqual: (id<ORNEqual>)c;
-(void) visitLEqual: (id<ORLEqual>)c;
-(void) visitPlus: (id<ORPlus>)c;
-(void) visitMult: (id<ORMult>)c;
-(void) visitAbs: (id<ORAbs>)c;
-(void) visitOr: (id<OROr>)c;
-(void) visitAnd:( id<ORAnd>)c;
-(void) visitImply: (id<ORImply>)c;
-(void) visitElementCst: (id<ORElementCst>)c;
-(void) visitElementVar: (id<ORElementVar>)c;
-(void) visitCircuit:(id<ORCircuit>) cstr;
-(void) visitNoCycle:(id<ORNoCycle>) cstr;
-(void) visitLexLeq:(id<ORLexLeq>) cstr;
@end


@interface ORFlattenObjective : NSObject<ORVisitor>
-(id)init:(id<ORINCModel>)m;
-(void) visitMinimize: (id<ORObjectiveFunction>) v;
-(void) visitMaximize: (id<ORObjectiveFunction>) v;
@end

@implementation ORBatchModel
-(ORBatchModel*)init:(ORModelI*)theModel
{
   self = [super init];
   _target = theModel;
   return self;
}
-(void)addVariable:(id<ORVar>)var
{
   [_target captureVariable: var];
}
-(void)addObject:(id)object
{
   [_target trackObject:object];
}
-(void)addConstraint:(id<ORConstraint>)cstr
{
   [_target add:cstr];
}
-(id<ORModel>)model
{
   return _target;
}
-(void)minimize:(id<ORIntVar>)x
{
   [_target minimize:x];
}
-(void)maximize:(id<ORIntVar>)x
{
   [_target maximize:x];
}
-(void) trackObject: (id) obj
{
   [_target trackObject:obj];
}
-(void) trackVariable: (id) obj
{
   [_target trackVariable:obj];
}
@end

@implementation ORFlatten
-(id)initORFlatten
{
   self = [super init];
   return self;
}
-(void)apply:(id<ORModel>)m into:(id<ORINCModel>)batch
{
   [m applyOnVar:^(id<ORVar> x) {
      [batch addVariable:x];
   } onObjects:^(id<ORObject> x) {
      ORFlattenObjects* fo = [[ORFlattenObjects alloc] init:batch];
      [x visit:fo];
      [fo release];
   } onConstraints:^(id<ORConstraint> c) {
      [self flatten:c into:batch];
   } onObjective:^(id<ORObjective> o) {
      ORFlattenObjective* fo = [[ORFlattenObjective alloc] init:batch];
      [o visit:fo];
      [fo release];
   }];
}

-(void)flatten:(id<ORConstraint>)c into:(id<ORINCModel>)m
{
   ORFlattenConstraint* fc = [[ORFlattenConstraint alloc] init:m];
   [c visit:fc];
   [fc release];
}
+(void)flattenExpression:(id<ORExpr>)expr into:(id<ORINCModel>)model
{
   ORLinear* terms = [ORNormalizer normalize:expr into: model note:DomainConsistency];
   switch ([expr type]) {
      case ORRBad: assert(NO);
      case ORREq: {
         if ([terms size] != 0) {
            [terms postEQZ:model note:DomainConsistency];
         }
      }break;
      case ORRNEq: {
         [terms postNEQZ:model note:DomainConsistency];
      }break;
      case ORRLEq: {
         [terms postLEQZ:model note:DomainConsistency];
      }break;
      default:
         assert(terms == nil);
         break;
   }
   [terms release];
}
@end

@implementation ORFlattenObjects {
   id<ORINCModel> _theModel;
}
-(id)init:(id<ORINCModel>)m
{
   self = [super init];
   _theModel = m;
   return self;
}
-(void) visitIntArray:(id<ORIntArray>)v
{
   [_theModel addObject:v];
}
-(void) visitIntMatrix:(id<ORIntMatrix>)v
{
   [_theModel addObject:v];
}
-(void) visitTrailableInt:(id<ORTrailableInt>)v
{
   [_theModel addObject:v];
}
-(void) visitIntSet:(id<ORIntSet>)v
{
   [_theModel addObject:v];
}
-(void) visitIntRange:(id<ORIntRange>)v
{
   [_theModel addObject:v];
}
-(void) visitIdArray: (id<ORIdArray>) v
{
   [_theModel addObject:v];
}
-(void) visitIdMatrix: (id<ORIdMatrix>) v
{
   [_theModel addObject:v];
}
-(void) visitTable:(id<ORTable>) v
{
   [_theModel addObject:v];
}

-(void) visitIntegerI: (id<ORInteger>) e {}
-(void) visitExprPlusI: (id<ORExpr>) e {}
-(void) visitExprMinusI: (id<ORExpr>) e {}
-(void) visitExprMulI: (id<ORExpr>) e   {}
-(void) visitExprEqualI: (id<ORExpr>) e {}
-(void) visitExprNEqualI: (id<ORExpr>) e {}
-(void) visitExprLEqualI: (id<ORExpr>) e {}
-(void) visitExprSumI: (id<ORExpr>) e    {}
-(void) visitExprAbsI:(id<ORExpr>) e     {}
-(void) visitExprCstSubI: (id<ORExpr>) e {}
-(void) visitExprDisjunctI:(id<ORExpr>) e   {}
-(void) visitExprConjunctI: (id<ORExpr>) e  {}
-(void) visitExprImplyI: (id<ORExpr>) e     {}
-(void) visitExprAggOrI: (id<ORExpr>) e     {}
-(void) visitExprVarSubI: (id<ORExpr>) e    {}
-(void) visitMinimize: (id<ORObjectiveFunction>) v {}
-(void) visitMaximize: (id<ORObjectiveFunction>) v {}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr {}
@end

@implementation ORFlattenConstraint {
   id<ORINCModel> _theModel;
}
-(id)init:(id<ORINCModel>)m
{
   self = [super init];
   _theModel = m;
   return self;
}
-(void) visitRestrict:(id<ORRestrict>)cstr
{
   [_theModel addConstraint:cstr];
}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
   [_theModel addConstraint:cstr];
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   [_theModel addConstraint:cstr];
}
-(void) visitPacking: (id<ORPacking>) cstr
{
   id<ORIntVarArray> item = [cstr item];
   id<ORIntVarArray> binSize = [cstr binSize];
   id<ORIntArray>    itemSize = [cstr itemSize];
   id<ORIntRange> BR = [binSize range];
   id<ORIntRange> IR = [item range];
   id<ORTracker> tracker = [item tracker];
   ORInt brlow = [BR low];
   ORInt brup = [BR up];
   for(ORInt b = brlow; b <= brup; b++) /*note:RangeConsistency*/
      [ORFlatten flattenExpression: [Sum(tracker,i,IR,mult([itemSize at:i],[item[i] eqi: b])) eq: binSize[b]] into: _theModel];
   ORInt s = 0;
   ORInt irlow = [IR low];
   ORInt irup = [IR up];
   for(ORInt i = irlow; i <= irup; i++)
      s += [itemSize at:i];
   [ORFlatten flattenExpression: [Sum(tracker,b,BR,binSize[b]) eqi: s] into: _theModel];
                                             
   for(ORInt b = brlow; b <= brup; b++)
      [_theModel addConstraint: [ORFactory packOne: item itemSize: itemSize bin: b binSize: binSize[b]]];
}
-(void) visitKnapsack:(id<ORKnapsack>) cstr
{
   [_theModel addConstraint:cstr];
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   [ORFlatten flattenExpression:[cstr expr] into:_theModel];
}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr
{
   [_theModel addConstraint:cstr];   
}
-(void) visitEqualc: (id<OREqualc>)c
{
   [_theModel addConstraint:c];
}
-(void) visitNEqualc: (id<ORNEqualc>)c
{
   [_theModel addConstraint:c];
}
-(void) visitLEqualc: (id<ORLEqualc>)c
{
   [_theModel addConstraint:c];
}
-(void) visitEqual: (id<OREqual>)c
{
   [_theModel addConstraint:c];
}
-(void) visitNEqual: (id<ORNEqual>)c
{
   [_theModel addConstraint:c];
}
-(void) visitLEqual: (id<ORLEqual>)c
{
   [_theModel addConstraint:c];
}
-(void) visitPlus: (id<ORPlus>)c
{
   [_theModel addConstraint:c];
}
-(void) visitMult: (id<ORMult>)c
{
   [_theModel addConstraint:c];
}
-(void) visitAbs: (id<ORAbs>)c
{
   [_theModel addConstraint:c];
}
-(void) visitOr: (id<OROr>)c
{
   [_theModel addConstraint:c];
}
-(void) visitAnd:( id<ORAnd>)c
{
   [_theModel addConstraint:c];
}
-(void) visitImply: (id<ORImply>)c
{
   [_theModel addConstraint:c];
}
-(void) visitElementCst: (id<ORElementCst>)c
{
   [_theModel addConstraint:c];
}
-(void) visitElementVar: (id<ORElementVar>)c
{
   [_theModel addConstraint:c];
}
-(void) visitCircuit:(id<ORCircuit>) c
{
   [_theModel addConstraint:c];
}
-(void) visitNoCycle:(id<ORNoCycle>) c
{
   [_theModel addConstraint:c];
}
-(void) visitLexLeq:(id<ORLexLeq>) c
{
   [_theModel addConstraint:c];
}
@end

@implementation ORFlattenObjective {
   id<ORINCModel> _theModel;
}
-(id)init:(id<ORINCModel>)m
{
   self = [super init];
   _theModel = m;
   return self;
}
-(void) visitMinimize: (id<ORObjectiveFunction>) v
{
   [_theModel minimize:[v var]];
}
-(void) visitMaximize: (id<ORObjectiveFunction>) v
{
   [_theModel maximize:[v var]];
}
@end