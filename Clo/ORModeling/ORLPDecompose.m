/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORModeling.h"
#import "ORLPDecompose.h"
#import "ORLinear.h"



@implementation ORLPNormalizer
{
   id<ORLinear>     _terms;
   id<ORAddToModel>   _model;
   ORAnnotation         _n;
}
+(ORLinear*) normalize: (ORExprI*) rel into: (id<ORAddToModel>) model annotation: (ORAnnotation) n
{
   ORLPNormalizer* v = [[ORLPNormalizer alloc] initORLPNormalizer: model annotation:n];
   [rel visit:v];
   ORLinear* rv = v->_terms;
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
      bool isOk = [[e left] min] == [[e right] min];
      if (!isOk)
         [_model addConstraint: [ORFactory fail:_model]];
   }
   else if (lc || rc) {
      ORInt c = lc ? [[e left] min] : [[e right] min];
      ORExprI* other = lc ? [e right] : [e left];
      ORLinear* lin  = [ORLPLinearizer linearFrom:other model:_model annotation:_n];
      [lin addIndependent: - c];
      _terms = lin;
   }
   else {
      ORLinear* linLeft = [ORLPLinearizer linearFrom:[e left] model:_model annotation:_n];
      ORLinearFlip* linRight = [[ORLinearFlip alloc] initORLinearFlip: linLeft];
      [ORLPLinearizer addToLinear: linRight from: [e right] model: _model annotation: _n];
      [linRight release];
      _terms = linLeft;
   }
}
-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   ORLinear* linLeft = [ORLPLinearizer linearFrom:[e left] model:_model annotation:_n];
   ORLinearFlip* linRight = [[ORLinearFlip alloc] initORLinearFlip: linLeft];
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
-(void) visitIntegerI: (id<ORInteger>) e   {}
-(void) visitExprPlusI: (ORExprPlusI*) e   {}
-(void) visitExprMinusI: (ORExprMinusI*) e {}
-(void) visitExprMulI: (ORExprMulI*) e     {}
-(void) visitExprModI: (ORExprModI*) e     {}
-(void) visitExprSumI: (ORExprSumI*) e     {}
-(void) visitExprProdI: (ORExprProdI*) e   {}
-(void) visitExprAggOrI: (ORExprAggOrI*) e {}
-(void) visitExprAbsI:(ORExprAbsI*) e      {}
-(void) visitExprNegateI:(ORExprNegateI*)e {}
-(void) visitExprCstSubI:(ORExprCstSubI*)e {}
-(void) visitExprVarSubI:(ORExprVarSubI*)e {}
@end

@implementation ORLPLinearizer
{
   id<ORLinear>        _terms;
   id<ORAddToModel>    _model;
   ORAnnotation        _n;
}
-(id) initORLPLinearizer: (id<ORLinear>) t model: (id<ORAddToModel>) model annotation: (ORAnnotation) n
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
-(void) visitAffineVar:(id<ORIntVar>)e
{
   [_terms addTerm:e by:1];
}
-(void) visitIntegerI: (id<ORInteger>) e
{
   [_terms addIndependent:[e value]];
}
-(void) visitExprPlusI: (ORExprPlusI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprMinusI: (ORExprMinusI*) e
{
   [[e left] visit:self];
   id<ORLinear> old = _terms;
   _terms = [[ORLinearFlip alloc] initORLinearFlip: _terms];
   [[e right] visit:self];
   [_terms release];
   _terms = old;
}
-(void) visitExprMulI: (ORExprMulI*) e
{
   BOOL cv = [[e left] isConstant] && [[e right] isVariable];
   BOOL vc = [[e left] isVariable] && [[e right] isConstant];
   if (cv || vc) {
      ORInt coef = cv ? [[e left] min] : [[e right] min];
      id       x = cv ? [e right] : [e left];
      [_terms addTerm:x by:coef];
   }
   else {
      assert(false);
   }
}
-(void) visitExprModI: (ORExprModI*) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO LP Linearization supported"];
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
-(void) visitExprAggOrI: (ORExprSumI*) e
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
+(ORLinear*) linearFrom: (ORExprI*) e model: (id<ORAddToModel>) model annotation: (ORAnnotation) cons
{
   ORLinear* rv = [[ORLinear alloc] initORLinear:4];
   ORLPLinearizer* v = [[ORLPLinearizer alloc] initORLPLinearizer:rv model: model annotation:cons];
   [e visit:v];
   [v release];
   return rv;
}
+(ORLinear*) addToLinear: (id<ORLinear>) terms from: (ORExprI*) e  model: (id<ORAddToModel>) model annotation: (ORAnnotation) cons
{
   ORLPLinearizer* v = [[ORLPLinearizer alloc] initORLPLinearizer:terms model: model annotation:cons];
   [e visit:v];
   [v release];
   return terms;
}
@end

