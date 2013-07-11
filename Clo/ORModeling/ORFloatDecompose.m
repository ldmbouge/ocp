/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORModeling.h"
#import "ORFloatDecompose.h"
#import "ORFloatLinear.h"

@implementation ORFloatLinearizer
{
   id<ORFloatLinear>   _terms;
   id<ORAddToModel>    _model;
   ORAnnotation        _n;
   id<ORFloatVar>      _x;
}
-(id) init: (id<ORFloatLinear>) t model: (id<ORAddToModel>) model annotation: (ORAnnotation) n
{
   self = [super init];
   _terms = t;
   _model = model;
   _n     = n;
   return self;
}
-(id) init: (id<ORFloatLinear>) t model: (id<ORAddToModel>) model equalTo:(id<ORFloatVar>)x annotation: (ORAnnotation) n
{
   self = [super init];
   _terms = t;
   _model = model;
   _x     = x;
   _n     = n;
   return self;
}

-(void) visitIntVar: (id<ORIntVar>) e
{
   [_terms addTerm:e by:1];
}
-(void) visitFloatVar:(id<ORFloatVar>) e
{
   [_terms addTerm: e by: 1];
}
-(void) visitAffineVar:(id<ORIntVar>)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO MIP Linearization supported"];
}
-(void) visitIntegerI: (id<ORInteger>) e
{
   [_terms addIndependent:[e value]];
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
   [_terms addIndependent:[e initialValue]];
}
-(void) visitMutableFloatI: (id<ORMutableFloat>) e
{
   [_terms addIndependent:[e initialValue]];
}
-(void) visitFloatI: (id<ORFloatNumber>) e
{
   [_terms addIndependent:[e floatValue]];
}
-(void) visitExprPlusI: (ORExprPlusI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprMinusI: (ORExprMinusI*) e
{
   [[e left] visit:self];
   id<ORFloatLinear> old = _terms;
   _terms = [[ORFloatLinearFlip alloc] initORFloatLinearFlip: _terms];
   [[e right] visit:self];
   [_terms release];
   _terms = old;
}
-(void) visitExprMulI: (ORExprMulI*) e
{
   BOOL cv = [[e left] isConstant] && [[e right] isVariable];
   BOOL vc = [[e left] isVariable] && [[e right] isConstant];
   if (cv || vc) {
      ORFloat coef = cv ? [[e left] floatValue] : [[e right] floatValue];
      id       x = cv ? [e right] : [e left];
      [_terms addTerm: x by: coef];
   }
   else {
      @throw [[ORExecutionError alloc] initORExecutionError: "NO LP Linearization supported"];
   }
}
-(void) visitExprDivI: (ORExprDivI*) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO LP Linearization supported for div"];  
}
-(void) visitExprModI: (ORExprModI*) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO LP Linearization supported for mod"];
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO LP Linearization supported"];
}
-(void) visitExprSquareI:(ORExprSquareI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO LP Linearization supported"];
}
-(void) visitExprNegateI:(ORExprNegateI*) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO LP Linearization supported"];
}
-(void) visitExprEqualI:(ORExprEqualI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO LP Linearization supported"];
}
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO LP Linearization supported"];
}
-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO LP Linearization supported"];
}
-(void) visitExprDisjunctI:(ORDisjunctI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO LP Linearization supported"];
}
-(void) visitExprConjunctI:(ORConjunctI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO LP Linearization supported"];
}
-(void) visitExprImplyI:(ORImplyI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO LP Linearization supported"];
}
-(void) visitExprSumI: (ORExprSumI*) e
{
   [[e expr] visit: self];
}
-(void) visitExprProdI: (ORExprProdI*) e
{
   [[e expr] visit: self];
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
-(void) visitExprCstSubI:(ORExprCstSubI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO LP Linearization supported"];
}
-(void) visitExprVarSubI:(ORExprVarSubI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO LP Linearization supported"];
}
@end
