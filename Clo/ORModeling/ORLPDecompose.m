/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORModeling.h"
#import "ORLPDecompose.h"
#import "ORFloatLinear.h"


@implementation ORLPNormalizer
{
   id<ORFloatLinear>  _terms;
   id<ORAddToModel>   _model;
   ORAnnotation       _n;
}
+(ORFloatLinear*) normalize: (ORExprI*) rel into: (id<ORAddToModel>) model annotation: (ORAnnotation) n
{
   ORLPNormalizer* v = [[ORLPNormalizer alloc] initORLPNormalizer: model annotation:n];
   [rel visit: v];
   ORFloatLinear* rv = v->_terms;
   [v release];
   return rv;
}
-(id) initORLPNormalizer: (id<ORAddToModel>) model annotation: (ORAnnotation) n
{
   self = [super init];
   _terms = nil;
   _model = model;
   _n = n;
   return self;
}
-(void) visitExprEqualI: (ORExprEqualI*) e
{
   bool lc = [[e left] isConstant];
   bool rc = [[e right] isConstant];
   if (lc && rc) {
      bool isOk = [[e left] floatValue] == [[e right] floatValue];
      if (!isOk)
         [_model addConstraint: [ORFactory fail:_model]];
   }
   else if (lc || rc) {
      ORFloat c = lc ? [[e left] floatValue] : [[e right] floatValue];
      ORExprI* other = lc ? [e right] : [e left];
      ORFloatLinear* lin  = [ORLPLinearizer linearFrom:other model:_model annotation:_n];
      [lin addIndependent: - c];
      _terms = lin;
   }
   else {
      ORFloatLinear* linLeft = [ORLPLinearizer linearFrom:[e left] model:_model annotation:_n];
      ORFloatLinearFlip* linRight = [[ORFloatLinearFlip alloc] initORFloatLinearFlip: linLeft];
      [ORLPLinearizer addToLinear: linRight from: [e right] model: _model annotation: _n];
      [linRight release];
      _terms = linLeft;
   }
}
-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   ORFloatLinear* linLeft = [ORLPLinearizer linearFrom:[e left] model:_model annotation:_n];
   ORFloatLinearFlip* linRight = [[ORFloatLinearFlip alloc] initORFloatLinearFlip: linLeft];
   [ORLPLinearizer addToLinear:linRight from:[e right] model:_model annotation:_n];
   [linRight release];
   _terms = linLeft;
}
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
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
-(void) visitIntVar: (id<ORIntVar>) e      {}
-(void) visitFloatVar:(id<ORFloatVar>)e    {}
-(void) visitIntegerI: (id<ORInteger>) e   {}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e   {}
-(void) visitMutableFloatI: (id<ORMutableFloat>) e   {}
-(void) visitFloatI: (id<ORFloatNumber>) e {}
-(void) visitExprPlusI: (ORExprPlusI*) e   {}
-(void) visitExprMinusI: (ORExprMinusI*) e {}
-(void) visitExprMulI: (ORExprMulI*) e     {}
-(void) visitExprDivI: (ORExprDivI*) e     {}
-(void) visitExprModI: (ORExprModI*) e     {}
-(void) visitExprSumI: (ORExprSumI*) e     {}
-(void) visitExprProdI: (ORExprProdI*) e   {}
-(void) visitExprAggOrI: (ORExprAggOrI*) e {}
-(void) visitExprAggAndI: (ORExprAggAndI*) e {}
-(void) visitExprAbsI:(ORExprAbsI*) e      {}
-(void) visitExprNegateI:(ORExprNegateI*)e {}
-(void) visitExprCstSubI:(ORExprCstSubI*)e {}
-(void) visitExprVarSubI:(ORExprVarSubI*)e {}
@end

@implementation ORLPLinearizer
{
   id<ORFloatLinear>   _terms;
   id<ORAddToModel>    _model;
   ORAnnotation        _n;
}
-(id) initORLPLinearizer: (id<ORFloatLinear>) t model: (id<ORAddToModel>) model annotation: (ORAnnotation) n
{
   self = [super init];
   _terms = t;
   _model = model;
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
      @throw [[ORExecutionError alloc] initORExecutionError: "NO MIP Linearization supported"];
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
-(void) visitExprCstSubI:(ORExprCstSubI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO LP Linearization supported"];
}
-(void) visitExprVarSubI:(ORExprVarSubI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO LP Linearization supported"];
}
+(ORFloatLinear*) linearFrom: (ORExprI*) e model: (id<ORAddToModel>) model annotation: (ORAnnotation) cons
{
   ORFloatLinear* rv = [[ORFloatLinear alloc] initORFloatLinear:4];
   ORLPLinearizer* v = [[ORLPLinearizer alloc] initORLPLinearizer: rv model: model annotation:cons];
   [e visit:v];
   [v release];
   return rv;
}
+(ORFloatLinear*) addToLinear: (id<ORFloatLinear>) terms from: (ORExprI*) e  model: (id<ORAddToModel>) model annotation: (ORAnnotation) cons
{
   ORLPLinearizer* v = [[ORLPLinearizer alloc] initORLPLinearizer: terms model: model annotation:cons];
   [e visit:v];
   [v release];
   return terms;
}
@end

