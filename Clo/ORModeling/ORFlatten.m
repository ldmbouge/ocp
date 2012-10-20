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
-(id)init:(ORModelI*)m;
-(void) visitIntArray:(id<ORIntArray>)v;
-(void) visitIntMatrix:(id<ORIntMatrix>)v;
-(void) visitTrailableInt:(id<ORTrailableInt>)v;
-(void) visitIntSet:(id<ORIntSet>)v;
-(void) visitIntRange:(id<ORIntRange>)v;
-(void) visitIdArray: (id<ORIdArray>) v;
-(void) visitIdMatrix: (id<ORIdMatrix>) v;
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
@end

@interface ORFlattenConstraint : NSObject<ORVisitor>
-(id)init:(ORModelI*)m;
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr;
-(void) visitCardinality: (id<ORCardinality>) cstr;
-(void) visitPacking: (id<ORPacking>) cstr;
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
@end


@implementation ORFlatten
-(id)initORFlatten
{
   self = [super init];
   return self;
}
-(id<ORModel>)apply:(id<ORModel>)m
{
   ORModelI* out = [ORFactory createModel];  
   [m applyOnVar:^(id<ORVar> x) {
      [out captureVariable:x];
   } onObjects:^(id<ORObject> x) {
      ORFlattenObjects* fo = [[ORFlattenObjects alloc] init:out];
      [x visit:fo];
      [fo release];
   } onConstraints:^(id<ORConstraint> c) {
      [self flatten:c into:out];
   } onObjective:^(id<ORObjective> o) {
      printf("We have an objective \n");
      [out optimize: o];
   }];
   return out;
}

-(void)flatten:(id<ORConstraint>)c into:(id<ORModel>)m
{
   ORFlattenConstraint* fc = [[ORFlattenConstraint alloc] init:m];
   [c visit:fc];
   [fc release];
}
@end

@implementation ORFlattenObjects {
   ORModelI* _theModel;
}
-(id)init:(ORModelI*)m
{
   self = [super init];
   _theModel = m;
   return self;
}
-(void) visitIntArray:(id<ORIntArray>)v
{
   [_theModel trackObject:v];
}
-(void) visitIntMatrix:(id<ORIntMatrix>)v
{
   [_theModel trackObject:v];
}
-(void) visitTrailableInt:(id<ORTrailableInt>)v
{
   [_theModel trackObject:v];
}
-(void) visitIntSet:(id<ORIntSet>)v
{
   [_theModel trackObject:v];
}
-(void) visitIntRange:(id<ORIntRange>)v
{
   [_theModel trackObject:v];
}
-(void) visitIdArray: (id<ORIdArray>) v
{
   [_theModel trackObject:v];
}
-(void) visitIdMatrix: (id<ORIdMatrix>) v
{
   [_theModel trackObject:v];
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
   ORModelI* _theModel;
}
-(id)init:(ORModelI*)m
{
   self = [super init];
   _theModel = m;
   return self;
}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
   [_theModel add:cstr];
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   [_theModel add:cstr];
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
   for(ORInt b = brlow; b <= brup; b++)
      [_theModel add: [Sum(tracker,i,IR,mult([itemSize at:i],[item[i] eqi: b])) eq: binSize[b]] /*note:RangeConsistency*/];
   ORInt s = 0;
   ORInt irlow = [IR low];
   ORInt irup = [IR up];
   for(ORInt i = irlow; i <= irup; i++)
      s += [itemSize at:i];
   [_theModel add: [Sum(tracker,b,BR,binSize[b]) eqi: s]];
                                             
   for(ORInt b = brlow; b <= brup; b++)
      [_theModel add: [ORFactory packOne: item itemSize: itemSize bin: b binSize: binSize[b]]];
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   id<ORExpr> theExpr = [cstr expr];
   ORLinear* terms = [ORNormalizer normalize:theExpr into: _theModel note:DomainConsistency];
   switch ([theExpr type]) {
      case ORRBad: assert(NO);
      case ORREq: {
         if ([terms size] != 0) {
            [terms postEQZ:_theModel note:DomainConsistency];
         }
      }break;
      case ORRNEq: {
         [terms postNEQZ:_theModel note:DomainConsistency];
      }break;
      case ORRLEq: {
         [terms postLEQZ: _theModel note:DomainConsistency];
      }break;
      default:
         assert(terms == nil);
         break;
   }
   [terms release];
}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr
{
   [_theModel add:cstr];   
}
-(void) visitEqualc: (id<OREqualc>)c
{
   [_theModel add:c];
}
-(void) visitNEqualc: (id<ORNEqualc>)c
{
   [_theModel add:c];
}
-(void) visitLEqualc: (id<ORLEqualc>)c
{
   [_theModel add:c];
}
-(void) visitEqual: (id<OREqual>)c
{
   [_theModel add:c];
}
-(void) visitNEqual: (id<ORNEqual>)c
{
   [_theModel add:c];
}
-(void) visitLEqual: (id<ORLEqual>)c
{
   [_theModel add:c];
}
-(void) visitPlus: (id<ORPlus>)c
{
   [_theModel add:c];
}
-(void) visitMult: (id<ORMult>)c
{
   [_theModel add:c];
}
-(void) visitAbs: (id<ORAbs>)c
{
   [_theModel add:c];
}
-(void) visitOr: (id<OROr>)c
{
   [_theModel add:c];
}
-(void) visitAnd:( id<ORAnd>)c
{
   [_theModel add:c];
}
-(void) visitImply: (id<ORImply>)c
{
   [_theModel add:c];
}
-(void) visitElementCst: (id<ORElementCst>)c
{
   [_theModel add:c];
}
-(void) visitElementVar: (id<ORElementVar>)c
{
   [_theModel add:c];
}
-(void) visitMinimize: (id<ORObjectiveFunction>) o
{
   [_theModel minimize: [o var]];
}
-(void) visitMaximize: (id<ORObjectiveFunction>) o
{
   [_theModel maximize: [o var]];
}
@end