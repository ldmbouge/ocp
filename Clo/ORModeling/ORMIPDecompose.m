/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORModeling.h"
#import "ORMIPDecompose.h"
#import "ORFloatLinear.h"


@implementation ORMIPNormalizer
{
   id<ORFloatLinear>  _terms;
   id<ORAddToModel>   _model;
   ORAnnotation       _n;
}
+(ORFloatLinear*) normalize: (ORExprI*) rel into: (id<ORAddToModel>) model annotation: (ORAnnotation) n
{
   ORMIPNormalizer* v = [[ORMIPNormalizer alloc] initORMIPNormalizer: model annotation:n];
   [rel visit:v];
   ORFloatLinear* rv = v->_terms;
   [v release];
   return rv;
}
-(id) initORMIPNormalizer: (id<ORAddToModel>) model annotation: (ORAnnotation) n
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
      ORFloatLinear* lin  = [ORMIPLinearizer linearFrom: other model:_model annotation:_n];
      [lin addIndependent: - c];
      _terms = lin;
   }
   else {
      ORFloatLinear* linLeft = [ORMIPLinearizer linearFrom:[e left] model:_model annotation:_n];
      ORFloatLinearFlip* linRight = [[ORFloatLinearFlip alloc] initORFloatLinearFlip: linLeft];
      [ORMIPLinearizer addToLinear: linRight from: [e right] model: _model annotation: _n];
      [linRight release];
      _terms = linLeft;
   }
}
-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   ORFloatLinear* linLeft = [ORMIPLinearizer linearFrom:[e left] model:_model annotation:_n];
   ORFloatLinearFlip* linRight = [[ORFloatLinearFlip alloc] initORFloatLinearFlip: linLeft];
   [ORMIPLinearizer addToLinear:linRight from:[e right] model:_model annotation:_n];
   [linRight release];
   _terms = linLeft;
}
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO MIP Linearization supported"];
}
-(void) visitExprDisjunctI:(ORDisjunctI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO MIP Linearization supported"];
}
-(void) visitExprConjunctI:(ORConjunctI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO MIP Linearization supported"];
}
-(void) visitExprImplyI:(ORImplyI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO MIP Linearization supported"];
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
-(void) visitExprAbsI:(ORExprAbsI*) e      {}
-(void) visitExprNegateI:(ORExprNegateI*)e {}
-(void) visitExprCstSubI:(ORExprCstSubI*)e {}
-(void) visitExprVarSubI:(ORExprVarSubI*)e {}
@end

@implementation ORMIPLinearizer
{
   id<ORFloatLinear> _terms;
   id<ORAddToModel> _model;
   ORAnnotation _n;
}
-(id) initORMIPLinearizer: (id<ORFloatLinear>) t model: (id<ORAddToModel>) model annotation: (ORAnnotation) n
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
-(void) visitFloatVar:(id<ORFloatVar>)e
{
   [_terms addTerm:e by:1];
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
   [_terms addIndependent:[e initialValue]];
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
      [_terms addTerm:x by:coef];
   }
   else {
      @throw [[ORExecutionError alloc] initORExecutionError: "NO MIP Linearization supported"];
   }
}
-(void) visitExprDivI: (ORExprDivI*) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO MIP Linearization supported"];
}
-(void) visitExprModI: (ORExprModI*) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO MIP Linearization supported"];
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO MIP Linearization supported"];
}
-(void) visitExprNegateI:(ORExprNegateI*) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO MIP Linearization supported"];
}
-(void) visitExprEqualI:(ORExprEqualI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO MIP Linearization supported"];
}
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO MIP Linearization supported"];
}
-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO MIP Linearization supported"];
}
-(void) visitExprDisjunctI:(ORDisjunctI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO MIP Linearization supported"];
}
-(void) visitExprConjunctI:(ORConjunctI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO MIP Linearization supported"];
}
-(void) visitExprImplyI:(ORImplyI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO MIP Linearization supported"];
}
-(void) visitExprSumI: (ORExprSumI*) e
{
   [[e expr] visit: self];
}
-(void) visitExprProdI: (ORExprProdI*) e
{
   [[e expr] visit: self];
}
-(void) visitExprAggOrI: (ORExprSumI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprCstSubI:(ORExprCstSubI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO MIP Linearization supported"];
}
-(void) visitExprVarSubI:(ORExprVarSubI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO MIP Linearization supported"];
}
+(ORFloatLinear*) linearFrom: (ORExprI*) e model: (id<ORAddToModel>) model annotation: (ORAnnotation) cons
{
   ORFloatLinear* rv = [[ORFloatLinear alloc] initORFloatLinear:4];
   ORMIPLinearizer* v = [[ORMIPLinearizer alloc] initORMIPLinearizer:rv model: model annotation:cons];
   [e visit:v];
   [v release];
   return rv;
}
+(ORFloatLinear*) addToLinear: (id<ORFloatLinear>) terms from: (ORExprI*) e  model: (id<ORAddToModel>) model annotation: (ORAnnotation) cons
{
   ORMIPLinearizer* v = [[ORMIPLinearizer alloc] initORMIPLinearizer:terms model: model annotation:cons];
   [e visit:v];
   [v release];
   return terms;
}
@end

