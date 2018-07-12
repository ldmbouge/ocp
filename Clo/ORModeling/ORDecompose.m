/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/
#import "ORDecompose.h"
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORLinear.h>
#import "ORExprI.h"
#import "ORRealLinear.h"
#import "ORFloatLinear.h"
#import "ORRationalLinear.h"
#import "ORDoubleLinear.h"
#import "ORVarI.h"
#import "ORRealDecompose.h"
#import "ORFloatDecompose.h"
#import "ORDoubleDecompose.h"
#import "ORRationalDecompose.h"

@interface ORIntNormalizer : ORVisitor<NSObject> {
   id<ORLinear>     _terms;
   id<ORAddToModel>   _model;
}
-(id)init:(id<ORAddToModel>) model;
-(id<ORLinear>)terms;
@end

@interface ORFloatNormalizer :  ORVisitor<NSObject> {
   id<ORFloatLinear>  _terms;
   id<ORAddToModel>   _model;
}
-(id)init:(id<ORAddToModel>) model;
-(id<ORFloatLinear>)terms;
@end

@interface ORRationalNormalizer :  ORVisitor<NSObject> {
   id<ORLinear>  _terms;
   id<ORAddToModel>   _model;
}
-(id)init:(id<ORAddToModel>) model;
-(id<ORLinear>)terms;
@end

@interface ORDoubleNormalizer :  ORVisitor<NSObject> {
   id<ORDoubleLinear>  _terms;
   id<ORAddToModel>   _model;
}
-(id)init:(id<ORAddToModel>) model;
-(id<ORDoubleLinear>)terms;
@end

@interface ORRealNormalizer : ORVisitor<NSObject> {
   id<ORRealLinear>  _terms;
   id<ORAddToModel>   _model;
}
-(id)init:(id<ORAddToModel>) model;
-(id<ORRealLinear>)terms;
@end

@interface ORIntLinearizer : ORVisitor<NSObject> {
   id<ORIntLinear>   _terms;
   id<ORAddToModel>  _model;
   id<ORIntVar>       _eqto;
}
-(id)init:(id<ORIntLinear>)t model:(id<ORAddToModel>)model equalTo:(id<ORIntVar>)x;
-(id)init:(id<ORIntLinear>)t model:(id<ORAddToModel>)model;
@end

@interface ORBoolLinearizer : ORIntLinearizer {
}
@end

@interface ORIntSubst   : ORVisitor<NSObject> {
   id<ORIntVar>        _rv;
   id<ORAddToModel> _model;
}
-(id)initORSubst:(id<ORAddToModel>) model;
-(id)initORSubst:(id<ORAddToModel>) model by:(id<ORIntVar>)x;
-(id<ORIntVar>)result;
@end


@implementation ORNormalizer
+(id<ORLinear>)normalize:(ORExprI*)rel into:(id<ORAddToModel>) model
{
   switch (rel.vtype) {
      case ORTBool:
      case ORTInt: {
         ORIntNormalizer* v = [[ORIntNormalizer alloc] init: model];
         [rel visit:v];
         id<ORLinear> rv = [v terms];
         [v release];
         return rv;
      }break;
      case ORTReal: {
         ORRealNormalizer* v = [[ORRealNormalizer alloc] init:model];
         [rel visit:v];
         ORRealLinear* rv = [v terms];
         [v release];
         return rv;
      }break;
      case ORTFloat: {
         ORFloatNormalizer* v = [[ORFloatNormalizer alloc] init:model];
         [rel visit:v];
         id<ORFloatLinear> rv = [v terms];
         [v release];
         return rv;
      }break;
      case ORTDouble: {
         ORDoubleNormalizer* v = [[ORDoubleNormalizer alloc] init:model];
         [rel visit:v];
         id<ORDoubleLinear> rv = [v terms];
         [v release];
         return rv;
      }break;
      case ORTRational: {
         ORRationalNormalizer* v = [[ORRationalNormalizer alloc] init:model];
         [rel visit:v];
         id<ORLinear> rv = [v terms];
         [v release];
         return rv;
      }break;
      default: {
         @throw [[ORExecutionError alloc] initORExecutionError:"Unexpected type in expression normalization"];
         return NULL;
      }break;
   }
}
+(id<ORIntLinear>)boolLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model
{
   ORIntLinear* rv = [[ORIntLinear alloc] initORLinear:4];
   ORBoolLinearizer* v = [[ORBoolLinearizer alloc] init:rv model: model];
   [e visit:v];
   [v release];
   return rv;
}

+(ORIntLinear*)intLinearFrom:(ORExprI*)e model:(id<ORAddToModel>)model equalTo:(id<ORIntVar>)x
{
   ORIntLinear* rv = [[ORIntLinear alloc] initORLinear:4];
   ORIntLinearizer* v = [[ORIntLinearizer alloc] init:rv model: model  equalTo:x];
   [e visit:v];
   [v release];
   return rv;
}
+(ORIntLinear*)intLinearFrom:(ORExprI*)e model:(id<ORAddToModel>)model
{
   //hzi : test useless ?
   if (e.vtype == ORTBool) {
      ORIntLinear* rv = [[ORIntLinear alloc] initORLinear:4];
      ORIntLinearizer* v = [[ORIntLinearizer alloc] init:rv model: model];
      [e visit:v];
      [v release];
      return rv;
   } else {
      ORIntLinear* rv = [[ORIntLinear alloc] initORLinear:4];
      ORIntLinearizer* v = [[ORIntLinearizer alloc] init:rv model: model];
      [e visit:v];
      [v release];
      return rv;
   }
}
+(ORIntLinear*)addToIntLinear:(id<ORIntLinear>)terms from:(ORExprI*)e  model:(id<ORAddToModel>)model
{
   ORIntLinearizer* v = [[ORIntLinearizer alloc] init:terms model: model];
   [e visit:v];
   [v release];
   return terms;
}

+(id<ORRealLinear>)realLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model
{
   ORRealLinear* rv = [[ORRealLinear alloc] initORRealLinear:4];
   ORRealLinearizer* v = [[ORRealLinearizer alloc] init: rv model: model];
   [e visit:v];
   [v release];
   return rv;
}
+(id<ORRealLinear>)realLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model equalTo:(id<ORRealVar>)x
{
   ORRealLinear* rv = [[ORRealLinear alloc] initORRealLinear:4];
   ORRealLinearizer* v = [[ORRealLinearizer alloc] init: rv model: model equalTo:x];
   [e visit:v];
   [v release];
   return rv;
}
+(id<ORRealLinear>)addToRealLinear:(id<ORRealLinear>)terms from:(id<ORExpr>)e  model:(id<ORAddToModel>)model
{
   ORRealLinearizer* v = [[ORRealLinearizer alloc] init: terms model: model];
   [e visit:v];
   [v release];
   return terms;
}

+(id<ORIntVar>) intVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr
{
   ORIntSubst* subst = [[ORIntSubst alloc] initORSubst: model];
   [expr visit:subst];
   id<ORIntVar> theVar = [subst result];
   [subst release];
   return theVar;
}
+(id<ORIntVar>) intVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr by:(id<ORIntVar>)x
{
   ORIntSubst* subst = [[ORIntSubst alloc] initORSubst: model by:x];
   [expr visit:subst];
   id<ORIntVar> theVar = [subst result];
   [subst release];
   //assert(theVar == x);
   return theVar;
}
+(id<ORIntVar>)intVarIn:(ORIntLinear*)e for:(id<ORAddToModel>)model
{
   if ([e size] == 0) {
      id<ORIntVar> xv = [ORFactory intVar: model domain: RANGE(model,[e min],[e max])];
      return xv;
   } else if ([e size] == 1) {
      return [e oneView:model];
   } /*else if ([e clausalForm]) {
      id<ORIntVar> cValue = [ORFactory intVar: model domain: RANGE(model,0,1)];
      [model addConstraint:[ORFactory clause:model over:[e variables:model] equal:cValue]];
      return cValue;
      } */ else {
         id<ORIntVar> xv = [ORFactory intVar: model domain: RANGE(model,[e min],[e max])];
         [e addTerm:xv by:-1];
         [e postEQZ: model];
         return xv;
      }
}
+(void)intVar:(id<ORIntVar>)var equal:(ORIntLinear*)e for:(id<ORAddToModel>) model
{
   if (e.size == 0) {
      [model addConstraint:[ORFactory equalc:model var:var to:0]];
   } else if (e.size == 1) {
      [e addTerm:var by:-1];
      [e postEQZ:model];
   } else if (e.clausalForm) {
      [model addConstraint:[ORFactory clause:model over:[e variables:model] equal:var]];
   } else {
      [e addTerm:var by:-1];
      [e postEQZ:model];
   }
}

+(id<ORRealVar>) realVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr
{
   ORRealSubst* subst = [[ORRealSubst alloc] initORSubst: model];
   [expr visit:subst];
   id<ORRealVar> theVar = [subst result];
   [subst release];
   return theVar;
}
+(id<ORRealVar>) realVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr by:(id<ORRealVar>)x
{
   ORRealSubst* subst = [[ORRealSubst alloc] initORSubst: model by:x];
   [expr visit:subst];
   id<ORRealVar> theVar = [subst result];
   [subst release];
   return theVar;
}
+(id<ORRealVar>) realVarIn:(id<ORRealLinear>)e for:(id<ORAddToModel>) model
{
   if ([e size] == 1 && [e coef:0]==1) {
      return (id)[e var:0];
   } else {
      id<ORRealVar> xv = [ORFactory realVar: model low:[e fmin] up:[e fmax]];
      [e addTerm:xv by:-1];
      [e postEQZ: model];
      return xv;
   }
}
@end

@implementation ORIntNormalizer
-(id)init:(id<ORAddToModel>) model
{
   self = [super init];
   _terms = nil;
   _model = model;
   return self;
}
-(id<ORLinear>)terms
{
   return _terms;
}
-(void) visitExprEqualI:(ORExprEqualI*)e
{
   id<TypeNormalizer> recVisit = vtype2Obj(e.left.vtype);
   _terms = [recVisit visitExprEqualI:_model left:[e left] right:[e right]];
   [recVisit release];
}
-(void) visitExprErrorI:(ORExprErrorOfI*)e
{
   id<TypeNormalizer> recVisit = vtype2Obj(e.left.vtype);
   _terms = [recVisit visitExprErrorI:_model left:[e left] right:[e right]];
   [recVisit release];
}
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
{
   id<TypeNormalizer> recVisit = vtype2Obj(e.left.vtype);
   _terms = [recVisit visitExprNEqualI:_model left:[e left] right:[e right]];
   [recVisit release];
}
-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   id<TypeNormalizer> recVisit = vtype2Obj(e.left.vtype);
   _terms = [recVisit visitExprLEqualI:_model left:[e left] right:[e right]];
   [recVisit release];
}
-(void) visitExprGEqualI:(ORExprLEqualI*)e
{
   id<TypeNormalizer> recVisit = vtype2Obj(e.left.vtype);
   _terms = [recVisit visitExprGEqualI:_model left:[e left] right:[e right]];
   [recVisit release];
}
-(void) visitExprLThenI:(ORExprLEqualI*)e
{
   id<TypeNormalizer> recVisit = vtype2Obj(e.left.vtype);
   _terms = [recVisit visitExprLThenI:_model left:[e left] right:[e right]];
   [recVisit release];
}
-(void) visitExprGThenI:(ORExprLEqualI*)e
{
   id<TypeNormalizer> recVisit = vtype2Obj(e.left.vtype);
   _terms = [recVisit visitExprGThenI:_model left:[e left] right:[e right]];
   [recVisit release];
}

struct CPVarPair {
   id<ORIntVar> lV;
   id<ORIntVar> rV;
   id<ORIntVar> boolVar;
};
-(struct CPVarPair) visitLogical:(ORExprI*)l right:(ORExprI*)r
{
   ORIntLinear* linLeft  = [ORNormalizer intLinearFrom:l model:_model];
   ORIntLinear* linRight = [ORNormalizer intLinearFrom:r model:_model];
   id<ORIntVar> lV = [ORNormalizer intVarIn:linLeft  for:_model];
   id<ORIntVar> rV = [ORNormalizer intVarIn:linRight for:_model];
   id<ORIntVar> final = [ORFactory intVar: _model value:1];
   return (struct CPVarPair){lV,rV,final};
}
-(void) visitExprNegateI:(ORExprNegateI*) e
{
   ORIntLinear* linLeft  = [ORNormalizer intLinearFrom:e model:_model];
   [linLeft addIndependent:-1];
   _terms = linLeft;
}
-(void) visitExprDisjunctI:(ORDisjunctI*)e
{
   ORIntLinear* linLeft  = [ORNormalizer intLinearFrom:[e left] model:_model];
   [ORNormalizer addToIntLinear:linLeft from:[e right] model:_model];
   _terms = linLeft;
}
-(void) visitExprConjunctI:(ORConjunctI*)e
{
   struct CPVarPair vars = [self visitLogical:[e left] right:[e right]];
   [_model addConstraint:[ORFactory model:_model boolean:vars.lV land:vars.rV equal:vars.boolVar]];
}
-(void) visitExprImplyI:(ORImplyI*)e
{
   ORIntLinear* linLeft  = [ORNormalizer intLinearFrom:[e left] model:_model];
   ORIntLinear* linRight = [ORNormalizer intLinearFrom:[e right] model:_model];
   if ([linLeft size] == 0) {  // the antecedent is a constant!
      if ([linLeft independent] == 0) { // the antecedent in A => B is false. false => B <=> !false OR B <=> true OR B <=> true
         ORIntLinear* lin = [[ORIntLinear alloc] initORLinear:2];
         [lin setIndependent:1];
         _terms = lin;
      } else { // the antecedent in A => B is true. true => B <=> !true OR B <=> false OR B <=> B  <=> B = 1
         id<ORIntVar> rV = [ORNormalizer intVarIn:linRight for:_model];
         [_model addConstraint:[ORFactory equalc:_model var:rV to:1]];
      }
      [linLeft release];
      [linRight release];
      return;
   }
   if ([linRight size] == 0) { // the consequent is a constant!
      if ([linRight independent] == 1) {  // consequent is true.  A => true <-> !A OR true <-> true
         ORIntLinear* lin = [[ORIntLinear alloc] initORLinear:2];
         [lin setIndependent:1];
         _terms = lin;
      } else { // else A => false <-> !A OR false <-> !A <-> A = 0
         id<ORIntVar> lV = [ORNormalizer intVarIn:linLeft  for:_model];
         [_model addConstraint:[ORFactory equalc:_model var:lV to:0]];
      }
      [linLeft release];
      [linRight release];
      return ;
   }
   id<ORIntVar> lV = [ORNormalizer intVarIn:linLeft  for:_model];
   id<ORIntVar> rV = [ORNormalizer intVarIn:linRight for:_model];
   //id<ORIntVar> final = [ORFactory intVar: _model value:1];
   //[_model addConstraint:[ORFactory model:_model boolean:lV imply:rV equal:final]];
   [_model addConstraint:[ORFactory model:_model boolean:lV imply:rV]];
   //   struct CPVarPair vars = [self visitLogical:[e left] right:[e right]];
   //   [_model addConstraint:[ORFactory model:_model boolean:vars.lV imply:vars.rV equal:vars.boolVar]];
}
@end


// ========================================================================================================================
// Rational Normalizer
// ========================================================================================================================

@implementation ORRationalNormalizer
-(id)init:(id<ORAddToModel>) model
{
   self = [super init];
   _terms = nil;
   _model = model;
   return self;
}
-(id<ORLinear>)terms
{
   return _terms;
}
-(void) visitExprEqualI:(ORExprEqualI*)e
{
   id<TypeNormalizer> recVisit = vtype2Obj(e.left.vtype);
   _terms = [recVisit visitExprEqualI:_model left:[e left] right:[e right]];
   [recVisit release];
}
-(void) visitExprErrorOfI:(ORExprErrorOfI*)e
{
   id<TypeNormalizer> recVisit = vtype2Obj(e.left.vtype);
   _terms = [recVisit visitExprErrorOfI:_model left:[e left] right:[e right]];
   [recVisit release];
}
@end
// ========================================================================================================================
// Real Normalizer
// ========================================================================================================================

@implementation ORRealNormalizer
-(id)init:(id<ORAddToModel>) model
{
   self = [super init];
   _terms = nil;
   _model = model;
   return self;
}
-(id<ORRealLinear>)terms
{
   return _terms;
}
-(void) visitExprEqualI:(ORExprEqualI*)e
{
   bool lc = [[e left] isConstant];
   bool rc = [[e right] isConstant];
   if (lc && rc) {
      bool isOk = [[e left] doubleValue] == [[e right] doubleValue];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   } else if (lc || rc) {
      ORDouble c = lc ? [[e left] doubleValue] : [[e right] doubleValue];
      ORExprI* other = lc ? [e right] : [e left];
      ORRealLinear* lin  = [ORNormalizer realLinearFrom:other model:_model];
      [lin addIndependent: - c];
      _terms = lin;
   } else {
      bool lv = [[e left] isVariable];
      bool rv = [[e right] isVariable];
      if (lv || rv) {
         ORExprI* other = lv ? [e right] : [e left];
         ORExprI* var   = lv ? [e left] : [e right];
         id<ORRealVar> theVar = [ORNormalizer realVarIn:_model expr:var];
         ORRealLinear* lin  = [ORNormalizer realLinearFrom:other model:_model equalTo:theVar];
         [lin release];
         _terms = nil; // we already did the full rewrite. Nothing left todo  @ top-level.
      } else {
         ORRealLinear* linLeft = [ORNormalizer realLinearFrom:[e left] model:_model];
         ORRealLinearFlip* linRight = [[ORRealLinearFlip alloc] initORRealLinearFlip: linLeft];
         [ORNormalizer addToRealLinear:linRight from:[e right] model:_model];
         [linRight release];
         _terms = linLeft;
      }
   }
}
-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   ORRealLinear* linLeft = [ORNormalizer realLinearFrom:[e left] model:_model];
   id<ORRealLinear> linRight = [[ORRealLinearFlip alloc] initORRealLinearFlip: linLeft];
   [ORNormalizer addToRealLinear:linRight from:[e right] model:_model];
   [linRight release];
   _terms = linLeft;
}
-(void) visitExprGEqualI:(ORExprGEqualI*)e
{
   ORRealLinear* linLeft = [ORNormalizer realLinearFrom:[e left] model:_model];
   id<ORRealLinear> linRight = [[ORRealLinearFlip alloc] initORRealLinearFlip: linLeft];
   [ORNormalizer addToRealLinear:linRight from:[e right] model:_model];
   [linRight release];
   _terms = linLeft;
}
-(void) visitExprLThenI:(ORExprLEqualI*)e
{
   ORRealLinear* linLeft = [ORNormalizer realLinearFrom:[e left] model:_model];
   id<ORRealLinear> linRight = [[ORRealLinearFlip alloc] initORRealLinearFlip: linLeft];
   [ORNormalizer addToRealLinear:linRight from:[e right] model:_model];
   [linRight release];
   _terms = linLeft;
}
-(void) visitExprGThenI:(ORExprGEqualI*)e
{
   ORRealLinear* linLeft = [ORNormalizer realLinearFrom:[e left] model:_model];
   id<ORRealLinear> linRight = [[ORRealLinearFlip alloc] initORRealLinearFlip: linLeft];
   [ORNormalizer addToRealLinear:linRight from:[e right] model:_model];
   [linRight release];
   _terms = linLeft;
}

-(void) visitExprNEqualI:(ORExprNotEqualI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO Real normalization for !="];
}
-(void) visitExprDisjunctI:(ORDisjunctI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO Real normalization for ||"];
}
-(void) visitExprConjunctI:(ORConjunctI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO Real normalization for &&"];
}
-(void) visitExprImplyI:(ORImplyI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "NO Real normalization for =>"];
}
@end

@implementation ORFloatNormalizer
-(id)init:(id<ORAddToModel>) model
{
   self = [super init];
   _terms = nil;
   _model = model;
   return self;
}
-(id<ORFloatLinear>)terms
{
   return _terms;
}
-(void) visitExprEqualI:(ORExprEqualI*)e
{
   bool lc = [[e left] isConstant];
   bool rc = [[e right] isConstant];
   if (lc && rc) {
      bool isOk = [[e left] fmin] == [[e right] fmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   } else if (lc || rc) {
      ORFloat c = lc ? [[e left] fmin] : [[e right] fmin];
      ORExprI* other = lc ? [e right] : [e left];
      ORFloatLinear* lin  = [ORNormalizer floatLinearFrom:other model:_model];
      [lin addIndependent: - c];
      _terms = lin;
   } else {
      bool lv = [[e left] isVariable];
      bool rv = [[e right] isVariable];
      if (lv || rv) {
         id<ORFloatLinear> left  = [ORNormalizer floatLinearFrom:[e left] model:_model];
         ORFloatLinear* right  = [ORNormalizer floatLinearFrom:[e right] model:_model];
         id<ORVarArray> vars = [ORFactory floatVarArray:_model range:RANGE(_model,0,1)];
         vars[0] = [ORNormalizer floatVarIn:left for:_model];
         vars[1] = [ORNormalizer floatVarIn:right for:_model];
         id<ORFloatArray> coefs = [ORFactory floatArray:_model
                                                  range:RANGE(_model,0,1)
                                                   with:^ORFloat(ORInt i) {
                                                      return 1;
                                                   }];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs eq:0.f]];
         [right release];
         [left release];
      } else {
         //TODO: fix order of sides.
         ORFloatLinear* linLeft = [ORNormalizer floatLinearFrom:[e left] model:_model ];
         ORFloatLinearFlip* linRight = [[ORFloatLinearFlip alloc] initORFloatLinearFlip: linLeft];
         [ORNormalizer addToFloatLinear:linRight from:[e right] model:_model];
         [linRight release];
         [linRight release];
         _terms = linLeft;
      }
   }
}
-(void) visitExprGThenI:(ORExprGThenI*)e
{
   bool lc = [[e left] isConstant];
   bool rc = [[e right] isConstant];
   if (lc && rc) {
      bool isOk = [[e left] fmin] > [[e right] fmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
      return;
   }else {
      ORInt length = !lc + !rc;
      id<ORVarArray> vars = [ORFactory floatVarArray:_model range:RANGE(_model,0,length - 1)];
      id<ORFloatArray> coefs = [ORFactory floatArray:_model
                                               range:RANGE(_model,0,length - 1)
                                                with:^ORFloat(ORInt i) {
                                                   return 1;
                                                }];
      if(lc){
         ORFloatLinear* right  = [ORNormalizer floatLinearFrom:[e right] model:_model];
         vars[0] = [ORNormalizer floatVarIn:right for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs lt:[[e left] fmin]]];
         [right release];
      }else if(rc){
         id<ORFloatLinear> left  = [ORNormalizer floatLinearFrom:[e left] model:_model];
         vars[0] = [ORNormalizer floatVarIn:left for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs gt:[[e right] fmin]]];
         [left release];
      }else{
         id<ORFloatLinear> left  = [ORNormalizer floatLinearFrom:[e left] model:_model];
         ORFloatLinear* right  = [ORNormalizer floatLinearFrom:[e right] model:_model];
         vars[0] = [ORNormalizer floatVarIn:left for:_model];
         vars[1] = [ORNormalizer floatVarIn:right for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs gt:0.f]];
         [left release];
         [right release];
      }
   }
}
-(void) visitExprLThenI:(ORExprLThenI*)e
{
   bool lc = [[e left] isConstant];
   bool rc = [[e right] isConstant];
   if (lc && rc) {
      bool isOk = [[e left] fmin] < [[e right] fmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   }else {
      ORInt length = !lc + !rc;
      id<ORVarArray> vars = [ORFactory floatVarArray:_model range:RANGE(_model,0,length - 1)];
      id<ORFloatArray> coefs = [ORFactory floatArray:_model
                                               range:RANGE(_model,0,length - 1)
                                                with:^ORFloat(ORInt i) {
                                                   return 1;
                                                }];
      if(lc){
         ORFloatLinear* right  = [ORNormalizer floatLinearFrom:[e right] model:_model];
         vars[0] = [ORNormalizer floatVarIn:right for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs gt:[[e left] fmin]]];
         [right release];
      }else if(rc){
         id<ORFloatLinear> left  = [ORNormalizer floatLinearFrom:[e left] model:_model];
         vars[0] = [ORNormalizer floatVarIn:left for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs lt:[[e right] fmin]]];
         [left release];
      }else{
         id<ORFloatLinear> left  = [ORNormalizer floatLinearFrom:[e left] model:_model];
         ORFloatLinear* right  = [ORNormalizer floatLinearFrom:[e right] model:_model];
         vars[0] = [ORNormalizer floatVarIn:left for:_model];
         vars[1] = [ORNormalizer floatVarIn:right for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs lt:0.f]];
         [left release];
         [right release];
      }
   }
}
-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   bool lc = [[e left] isConstant];
   bool rc = [[e right] isConstant];
   if (lc && rc) {
      bool isOk = [[e left] fmin] <= [[e right] fmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   }else {
      ORInt length = !lc + !rc;
      id<ORVarArray> vars = [ORFactory floatVarArray:_model range:RANGE(_model,0,length - 1)];
      id<ORFloatArray> coefs = [ORFactory floatArray:_model
                                               range:RANGE(_model,0,length - 1)
                                                with:^ORFloat(ORInt i) {
                                                   return 1;
                                                }];
      if(lc){
         ORFloatLinear* right  = [ORNormalizer floatLinearFrom:[e right] model:_model];
         vars[0] = [ORNormalizer floatVarIn:right for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs geq:[[e left] fmin]]];
         [right release];
      }else if(rc){
         id<ORFloatLinear> left  = [ORNormalizer floatLinearFrom:[e left] model:_model];
         vars[0] = [ORNormalizer floatVarIn:left for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs leq:[[e right] fmin]]];
         [left release];
      }else{
         id<ORFloatLinear> left  = [ORNormalizer floatLinearFrom:[e left] model:_model];
         ORFloatLinear* right  = [ORNormalizer floatLinearFrom:[e right] model:_model];
         vars[0] = [ORNormalizer floatVarIn:left for:_model];
         vars[1] = [ORNormalizer floatVarIn:right for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs leq:0.f]];
         [left release];
         [right release];
      }
   }
}
-(void) visitExprGEqualI:(ORExprGEqualI*)e
{
   bool lc = [[e left] isConstant];
   bool rc = [[e right] isConstant];
   if (lc && rc) {
      bool isOk = [[e left] fmin] >= [[e right] fmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   }else {
      ORInt length = !lc + !rc;
      id<ORVarArray> vars = [ORFactory floatVarArray:_model range:RANGE(_model,0,length - 1)];
      id<ORFloatArray> coefs = [ORFactory floatArray:_model
                                               range:RANGE(_model,0,length - 1)
                                                with:^ORFloat(ORInt i) {
                                                   return 1;
                                                }];
      if(lc){
         ORFloatLinear* right  = [ORNormalizer floatLinearFrom:[e right] model:_model];
         vars[0] = [ORNormalizer floatVarIn:right for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs leq:[[e left] fmin]]];
         [right release];
      }else if(rc){
         id<ORFloatLinear> left  = [ORNormalizer floatLinearFrom:[e left] model:_model];
         vars[0] = [ORNormalizer floatVarIn:left for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs geq:[[e right] fmin]]];
         [left release];
      }else{
         id<ORFloatLinear> left  = [ORNormalizer floatLinearFrom:[e left] model:_model];
         ORFloatLinear* right  = [ORNormalizer floatLinearFrom:[e right] model:_model];
         vars[0] = [ORNormalizer floatVarIn:left for:_model];
         vars[1] = [ORNormalizer floatVarIn:right for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs geq:0.f]];
         [left release];
         [right release];
      }
   }
}
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
{
   ORFloatLinear* linLeft = [ORNormalizer floatLinearFrom:[e left] model:_model];
   ORFloatLinearFlip* linRight = [[ORFloatLinearFlip alloc] initORFloatLinearFlip: linLeft];
   [ORNormalizer addToFloatLinear:linRight from:[e right] model:_model];
   [linRight release];
   _terms = linLeft;
}
-(void) visitExprAssignI:(ORExprAssignI*)e
{
   bool lc = [[e left] isConstant];
   bool rc = [[e right] isConstant];
   if (lc && rc) {
      bool isOk = [[e left] fmin] == [[e right] fmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   } else if (lc || rc) {
      ORFloat c = lc ? [[e left] fmin] : [[e right] fmin];
      ORExprI* other = lc ? [e right] : [e left];
      ORFloatLinear* lin  = [ORNormalizer floatLinearFrom:other model:_model];
      id<ORFloatVar> x = [ORNormalizer floatVarIn:lin for:_model];
      [_model addConstraint:[ORFactory floatAssignC:_model var:x to:c]];
      [lin release];
   } else {
      bool lv = [[e left] isVariable];
      bool rv = [[e right] isVariable];
      if (lv || rv) {
         id<ORFloatLinear> left  = [ORNormalizer floatLinearFrom:[e left] model:_model];
         ORFloatLinear* right  = [ORNormalizer floatLinearFrom:[e right] model:_model];
         id<ORFloatVar> x = [ORNormalizer floatVarIn:left for:_model];
         id<ORFloatVar> y = [ORNormalizer floatVarIn:right for:_model];
         [_model addConstraint:[ORFactory floatAssign:_model var:x to:y]];
         [right release];
         [left release];
      } else {
         //should never append 
         ORFloatLinear* linLeft = [ORNormalizer floatLinearFrom:[e left] model:_model ];
         ORFloatLinearFlip* linRight = [[ORFloatLinearFlip alloc] initORFloatLinearFlip: linLeft];
         [ORNormalizer addToFloatLinear:linRight from:[e right] model:_model];
         [linRight release];
         [linRight release];
         _terms = linLeft;
      }
   }
}
@end


//------
@implementation ORDoubleNormalizer
-(id)init:(id<ORAddToModel>) model
{
   self = [super init];
   _terms = nil;
   _model = model;
   return self;
}
-(id<ORDoubleLinear>)terms
{
   return _terms;
}
-(void) visitExprEqualI:(ORExprEqualI*)e
{
   bool lc = [[e left] isConstant];
   bool rc = [[e right] isConstant];
   if (lc && rc) {
      bool isOk = [[e left] fmin] == [[e right] fmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   } else if (lc || rc) {
      ORDouble c = lc ? [[e left] fmin] : [[e right] fmin];
      ORExprI* other = lc ? [e right] : [e left];
      ORDoubleLinear* lin  = [ORNormalizer doubleLinearFrom:other model:_model];
      [lin addIndependent: - c];
      _terms = lin;
   } else {
      bool lv = [[e left] isVariable];
      bool rv = [[e right] isVariable];
      if (lv || rv) {
         id<ORDoubleLinear> left  = [ORNormalizer doubleLinearFrom:[e left] model:_model];
         ORDoubleLinear* right  = [ORNormalizer doubleLinearFrom:[e right] model:_model];
         id<ORVarArray> vars = [ORFactory doubleVarArray:_model range:RANGE(_model,0,1)];
         vars[0] = [ORNormalizer doubleVarIn:left for:_model];
         vars[1] = [ORNormalizer doubleVarIn:right for:_model];
         id<ORDoubleArray> coefs = [ORFactory doubleArray:_model
                                                    range:RANGE(_model,0,1)
                                                     with:^ORDouble(ORInt i) {
                                                        return 1;
                                                     }];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs eq:0.f]];
         [right release];
         [left release];
      } else {
         //TODO: fix order of sides.
         ORDoubleLinear* linLeft = [ORNormalizer doubleLinearFrom:[e left] model:_model ];
         ORDoubleLinearFlip* linRight = [[ORDoubleLinearFlip alloc] initORDoubleLinearFlip: linLeft];
         [ORNormalizer addToDoubleLinear:linRight from:[e right] model:_model];
         [linRight release];
         [linRight release];
         _terms = linLeft;
      }
   }
}
-(void) visitExprGThenI:(ORExprGThenI*)e
{
   bool lc = [[e left] isConstant];
   bool rc = [[e right] isConstant];
   if (lc && rc) {
      bool isOk = [[e left] fmin] > [[e right] fmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
      return;
   }else {
      ORInt length = !lc + !rc;
      id<ORVarArray> vars = [ORFactory doubleVarArray:_model range:RANGE(_model,0,length - 1)];
      id<ORDoubleArray> coefs = [ORFactory doubleArray:_model
                                                 range:RANGE(_model,0,length - 1)
                                                  with:^ORDouble(ORInt i) {
                                                     return 1;
                                                  }];
      if(lc){
         ORDoubleLinear* right  = [ORNormalizer doubleLinearFrom:[e right] model:_model];
         vars[0] = [ORNormalizer doubleVarIn:right for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs lt:[[e left] fmin]]];
         [right release];
      }else if(rc){
         id<ORDoubleLinear> left  = [ORNormalizer doubleLinearFrom:[e left] model:_model];
         vars[0] = [ORNormalizer doubleVarIn:left for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs gt:[[e right] fmin]]];
         [left release];
      }else{
         id<ORDoubleLinear> left  = [ORNormalizer doubleLinearFrom:[e left] model:_model];
         ORDoubleLinear* right  = [ORNormalizer doubleLinearFrom:[e right] model:_model];
         vars[0] = [ORNormalizer doubleVarIn:left for:_model];
         vars[1] = [ORNormalizer doubleVarIn:right for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs gt:0.f]];
         [left release];
         [right release];
      }
   }
}
-(void) visitExprLThenI:(ORExprLThenI*)e
{
   bool lc = [[e left] isConstant];
   bool rc = [[e right] isConstant];
   if (lc && rc) {
      bool isOk = [[e left] fmin] < [[e right] fmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   }else {
      ORInt length = !lc + !rc;
      id<ORVarArray> vars = [ORFactory doubleVarArray:_model range:RANGE(_model,0,length - 1)];
      id<ORDoubleArray> coefs = [ORFactory doubleArray:_model
                                                 range:RANGE(_model,0,length - 1)
                                                  with:^ORDouble(ORInt i) {
                                                     return 1;
                                                  }];
      if(lc){
         ORDoubleLinear* right  = [ORNormalizer doubleLinearFrom:[e right] model:_model];
         vars[0] = [ORNormalizer doubleVarIn:right for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs gt:[[e left] fmin]]];
         [right release];
      }else if(rc){
         id<ORDoubleLinear> left  = [ORNormalizer doubleLinearFrom:[e left] model:_model];
         vars[0] = [ORNormalizer doubleVarIn:left for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs lt:[[e right] fmin]]];
         [left release];
      }else{
         id<ORDoubleLinear> left  = [ORNormalizer doubleLinearFrom:[e left] model:_model];
         ORDoubleLinear* right  = [ORNormalizer doubleLinearFrom:[e right] model:_model];
         vars[0] = [ORNormalizer doubleVarIn:left for:_model];
         vars[1] = [ORNormalizer doubleVarIn:right for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs lt:0.f]];
         [left release];
         [right release];
      }
   }
}
-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   bool lc = [[e left] isConstant];
   bool rc = [[e right] isConstant];
   if (lc && rc) {
      bool isOk = [[e left] fmin] <= [[e right] fmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   }else {
      ORInt length = !lc + !rc;
      id<ORVarArray> vars = [ORFactory doubleVarArray:_model range:RANGE(_model,0,length - 1)];
      id<ORDoubleArray> coefs = [ORFactory doubleArray:_model
                                                 range:RANGE(_model,0,length - 1)
                                                  with:^ORDouble(ORInt i) {
                                                     return 1;
                                                  }];
      if(lc){
         ORDoubleLinear* right  = [ORNormalizer doubleLinearFrom:[e right] model:_model];
         vars[0] = [ORNormalizer doubleVarIn:right for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs geq:[[e left] fmin]]];
         [right release];
      }else if(rc){
         id<ORDoubleLinear> left  = [ORNormalizer doubleLinearFrom:[e left] model:_model];
         vars[0] = [ORNormalizer doubleVarIn:left for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs leq:[[e right] fmin]]];
         [left release];
      }else{
         id<ORDoubleLinear> left  = [ORNormalizer doubleLinearFrom:[e left] model:_model];
         ORDoubleLinear* right  = [ORNormalizer doubleLinearFrom:[e right] model:_model];
         vars[0] = [ORNormalizer doubleVarIn:left for:_model];
         vars[1] = [ORNormalizer doubleVarIn:right for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs leq:0.f]];
         [left release];
         [right release];
      }
   }
}
-(void) visitExprGEqualI:(ORExprGEqualI*)e
{
   bool lc = [[e left] isConstant];
   bool rc = [[e right] isConstant];
   if (lc && rc) {
      bool isOk = [[e left] fmin] >= [[e right] fmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   }else {
      ORInt length = !lc + !rc;
      id<ORVarArray> vars = [ORFactory doubleVarArray:_model range:RANGE(_model,0,length - 1)];
      id<ORDoubleArray> coefs = [ORFactory doubleArray:_model
                                                 range:RANGE(_model,0,length - 1)
                                                  with:^ORDouble(ORInt i) {
                                                     return 1;
                                                  }];
      if(lc){
         ORDoubleLinear* right  = [ORNormalizer doubleLinearFrom:[e right] model:_model];
         vars[0] = [ORNormalizer doubleVarIn:right for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs leq:[[e left] fmin]]];
         [right release];
      }else if(rc){
         id<ORDoubleLinear> left  = [ORNormalizer doubleLinearFrom:[e left] model:_model];
         vars[0] = [ORNormalizer doubleVarIn:left for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs geq:[[e right] fmin]]];
         [left release];
      }else{
         id<ORDoubleLinear> left  = [ORNormalizer doubleLinearFrom:[e left] model:_model];
         ORDoubleLinear* right  = [ORNormalizer doubleLinearFrom:[e right] model:_model];
         vars[0] = [ORNormalizer doubleVarIn:left for:_model];
         vars[1] = [ORNormalizer doubleVarIn:right for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs geq:0.f]];
         [left release];
         [right release];
      }
   }
}
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
{
   ORDoubleLinear* linLeft = [ORNormalizer doubleLinearFrom:[e left] model:_model];
   ORDoubleLinearFlip* linRight = [[ORDoubleLinearFlip alloc] initORDoubleLinearFlip: linLeft];
   [ORNormalizer addToDoubleLinear:linRight from:[e right] model:_model];
   [linRight release];
   _terms = linLeft;
}
-(void) visitExprAssignI:(ORExprAssignI*)e
{
   bool lc = [[e left] isConstant];
   bool rc = [[e right] isConstant];
   if (lc && rc) {
      bool isOk = [[e left] fmin] == [[e right] fmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   } else if (lc || rc) {
      ORDouble c = lc ? [[e left] fmin] : [[e right] fmin];
      ORExprI* other = lc ? [e right] : [e left];
      ORDoubleLinear* lin  = [ORNormalizer doubleLinearFrom:other model:_model];
      id<ORDoubleVar> x = [ORNormalizer doubleVarIn:lin for:_model];
      [_model addConstraint:[ORFactory doubleAssignC:_model var:x to:c]];
      [lin release];
   } else {
      bool lv = [[e left] isVariable];
      bool rv = [[e right] isVariable];
      if (lv || rv) {
         id<ORDoubleLinear> left  = [ORNormalizer doubleLinearFrom:[e left] model:_model];
         ORDoubleLinear* right  = [ORNormalizer doubleLinearFrom:[e right] model:_model];
         id<ORDoubleVar> x = [ORNormalizer doubleVarIn:left for:_model];
         id<ORDoubleVar> y = [ORNormalizer doubleVarIn:right for:_model];
         [_model addConstraint:[ORFactory doubleAssign:_model var:x to:y]];
         [right release];
         [left release];
      } else {
         //should never append
         ORDoubleLinear* linLeft = [ORNormalizer doubleLinearFrom:[e left] model:_model ];
         ORDoubleLinearFlip* linRight = [[ORDoubleLinearFlip alloc] initORDoubleLinearFlip: linLeft];
         [ORNormalizer addToDoubleLinear:linRight from:[e right] model:_model];
         [linRight release];
         [linRight release];
         _terms = linLeft;
      }
   }
}
@end




// ========================================================================================================================
// Bool Linearizer
// ========================================================================================================================
@implementation ORBoolLinearizer
-(void) visitExprDisjunctI:(ORDisjunctI*)e
{
   if (_eqto) {
      id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      [[e left] visit:self];
      [[e right] visit:self];
   }
}

@end

// ========================================================================================================================
// Int Linearizer
// ========================================================================================================================
@implementation ORIntLinearizer
-(id)init:(id<ORIntLinear>)t model:(id<ORAddToModel>)model equalTo:(id<ORIntVar>)x
{
   self = [super init];
   _terms = t;
   _model = model;
   _eqto  = x;
   return self;
}
-(id)init:(id<ORIntLinear>)t model:(id<ORAddToModel>)model
{
   self = [super init];
   _terms = t;
   _model = model;
   _eqto  = nil;
   return self;
}
-(void) visitIntVar: (id<ORIntVar>) e
{
   if (_eqto) {
      [_model addConstraint:[ORFactory equal:_model var:e to:_eqto plus:0]];
      [_terms addTerm:_eqto by:1];
      _eqto = nil;
   } else
      [_terms addTerm:e by:1];
}
-(void) visitAffineVar:(ORIntVarAffineI*)e
{
   if (_eqto) {
      [_model addConstraint:[ORFactory equal:_model var:e to:_eqto plus:0]];
      [_terms addTerm:_eqto by:1];
      _eqto = nil;
   } else
      [_terms addTerm:e by:1];
}
-(void) visitIntVarLitEQView:(id<ORIntVar>)e
{
   if (_eqto) {
      [_model addConstraint:[ORFactory equal:_model var:e to:_eqto plus:0]];
      [_terms addTerm:_eqto by:1];
      _eqto = nil;
   } else
      [_terms addTerm:e by:1];
}
-(void) visitIntegerI: (id<ORInteger>) e
{
   if (_eqto) {
      [_model addConstraint:[ORFactory equalc:_model var:_eqto to:[e value]]];
      [_terms addIndependent:[e value]];
      _eqto = nil;
   } else
      [_terms addIndependent:[e value]];
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
   assert(NO);
   if (_eqto) {
      [_model addConstraint:[ORFactory equalc:_model var:_eqto to:[e initialValue]]];
      [_terms addIndependent:[e initialValue]];
      _eqto = nil;
   } else
      [_terms addIndependent:[e initialValue]];
}
-(void) visitMutableDouble: (id<ORMutableInteger>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Linearizing an integer expression and encountering a MutableReal"];
}

-(void) visitDouble: (id<ORDoubleNumber>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Linearizing an integer expression and encountering a DoubleNumber"];
}

-(void) visitExprPlusI: (ORExprPlusI*) e
{
   if (_eqto) {
      id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      [[e left] visit:self];
      [[e right] visit:self];
   }
}
-(void) visitExprMinusI: (ORExprMinusI*) e
{
   if (_eqto) {
      id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      [[e left] visit:self];
      id<ORIntLinear> old = _terms;
      _terms = [[ORLinearFlip alloc] initORLinearFlip: _terms];
      [[e right] visit:self];
      [_terms release];
      _terms = old;
   }
}
-(void) visitExprMulI: (ORExprMulI*) e
{
   if (_eqto) {
      id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      BOOL cv = [[e left] isConstant] && [[e right] isVariable];
      BOOL vc = [[e left] isVariable] && [[e right] isConstant];
      if (cv || vc) {
         ORInt coef = cv ? [[e left] min] : [[e right] min];
         id       x = cv ? [e right] : [e left];
         [_terms addTerm:x by:coef];
      } else if ([[e left] isConstant]) {
         id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:[e right]];
         [_terms addTerm:alpha by:[[e left] min]];
      } else if ([[e right] isConstant]) {
         ORIntLinear* left = [ORNormalizer intLinearFrom:[e left] model:_model];
         [left scaleBy:[[e right] min]];
         [_terms addLinear:left];
      } else {
         id<ORIntVar> alpha =  [ORNormalizer intVarIn:_model expr:e];
         [_terms addTerm:alpha by:1];
      }
   }
}
-(void) visitExprDivI:(ORExprDivI *)e
{
   if (_eqto) {
      id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:e by:_eqto];
      [_terms addTerm:alpha by:1];
      _eqto = nil;
   } else {
      id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:e];
      [_terms addTerm:alpha by:1];
   }
}
-(void) visitExprModI: (ORExprModI*) e
{
   id<ORIntVar> alpha =  [ORNormalizer intVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprMinI: (ORExprMinI*) e
{
   id<ORIntVar> alpha =  [ORNormalizer intVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprMaxI: (ORExprMaxI*) e
{
   id<ORIntVar> alpha =  [ORNormalizer intVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
   id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprSquareI:(ORExprSquareI*) e
{
   id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprNegateI:(ORExprNegateI*) e
{
   id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprEqualI:(ORExprEqualI*)e
{
   id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
{
   id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprGEqualI:(ORExprGEqualI*)e
{
   id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprLThenI:(ORExprLThenI*)e
{
   id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprGThenI:(ORExprGThenI*)e
{
   id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprDisjunctI:(ORDisjunctI*)e
{
   id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprConjunctI:(ORConjunctI*)e
{
   id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprImplyI:(ORImplyI*)e
{
   id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprSumI: (ORExprSumI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprProdI: (ORExprProdI*) e
{
   [[e expr] visit:self];
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
   id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprCstDoubleSubI:(id<ORExpr>)e
{
   @throw [[ORExecutionError alloc] initORExecutionError:"Cannot take a Real-var within an integer context without a cast"];
}
-(void) visitExprCstLDoubleSubI:(id<ORExpr>)e
{
   @throw [[ORExecutionError alloc] initORExecutionError:"Cannot take a Real-var within an integer context without a cast"];
}
-(void) visitExprVarSubI:(ORExprVarSubI*)e
{
   id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
-(void) visitExprMatrixVarSubI:(ORExprMatrixVarSubI*)e
{
   id<ORIntVar> alpha = [ORNormalizer intVarIn:_model expr:e by:_eqto];
   [_terms addTerm:alpha by:1];
}
@end

// ========================================================================================================================
// Int Linearizer
// ========================================================================================================================

@implementation ORIntSubst

-(id)initORSubst:(id<ORAddToModel>) model
{
   self = [super init];
   _rv = nil;
   _model = model;
   return self;
}
-(id)initORSubst:(id<ORAddToModel>) model by:(id<ORIntVar>)x
{
   self = [super init];
   _rv  = x;
   _model = model;
   return self;
}
-(id<ORIntVar>)result
{
   return _rv;
}
-(void) visitIntVar: (id<ORIntVar>) e
{
   if (_rv)
      [_model addConstraint:[ORFactory equal:_model var:_rv to:e plus:0]];
   else
      _rv = e;
}
-(void) visitIntegerI: (id<ORInteger>) e
{
   if (!_rv)
      _rv = [ORFactory intVar:_model domain: RANGE(_model,[e value],[e value])];
   [_model addConstraint:[ORFactory equalc:_model var:_rv to:[e value]]];
}

-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
   assert(NO);
   if (!_rv)
      _rv = [ORFactory intVar:_model domain: RANGE(_model,[e initialValue],[e initialValue])];
   [_model addConstraint:[ORFactory equalc:_model var:_rv to:[e initialValue]]];
}
-(void) visitDouble: (id<ORDoubleNumber>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Linearizing an integer expression and encountering a Double"];
}
-(void) visitMutableDouble: (id<ORMutableDouble>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Linearizing an integer expression and encountering a Mutable Double"];
}
-(void) visitExprAssignI:(ORExprAssignI*)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Linearizing an integer Assignement expression"];
}
-(void) visitExprPlusI: (ORExprPlusI*) e
{
   id<ORIntLinear> terms = [ORNormalizer intLinearFrom:e model:_model];
   if (_rv==nil)
      _rv = [ORFactory intVar:_model domain: RANGE(_model,max([terms min],MININT),min([terms max],MAXINT))];
   [terms addTerm:_rv by:-1];
   [terms postEQZ:_model];
   [terms release];
}
-(void) visitExprMinusI: (ORExprMinusI*) e
{
   id<ORIntLinear> terms = [ORNormalizer intLinearFrom:e model:_model];
   if (_rv==nil)
      _rv = [ORFactory intVar:_model domain: RANGE(_model,max([terms min],MININT),min([terms max],MAXINT))];
   [terms addTerm:_rv by:-1];
   [terms postEQZ:_model];
   [terms release];
}
-(void) visitExprMulI: (ORExprMulI*) e
{
   id<ORIntLinear> lT = [ORNormalizer intLinearFrom:[e left] model:_model];
   id<ORIntLinear> rT = [ORNormalizer intLinearFrom:[e right] model:_model];
   id<ORIntVar> lV = [ORNormalizer intVarIn:lT for:_model];
   id<ORIntVar> rV = [ORNormalizer intVarIn:rT for:_model];
   ORLong llb = [[lV domain] low];
   ORLong lub = [[lV domain] up];
   ORLong rlb = [[rV domain] low];
   ORLong rub = [[rV domain] up];
   ORLong a = minOf(llb * rlb,llb * rub);
   ORLong b = minOf(lub * rlb,lub * rub);
   ORLong lb = minOf(a,b);
   ORLong c = maxOf(llb * rlb,llb * rub);
   ORLong d = maxOf(lub * rlb,lub * rub);
   ORLong ub = maxOf(c,d);
   if (_rv==nil)
      _rv = [ORFactory intVar:_model domain: RANGE(_model,bindDown(lb),bindUp(ub))];
   [_model addConstraint: [ORFactory mult:_model var:lV by:rV equal:_rv]];
   [lT release];
   [rT release];
}
static inline ORLong minSeq(ORLong v[4])  {
   ORLong min = MAXINT;
   for(int i=0;i<4;i++)
      min = min > v[i] ? v[i] : min;
   return min;
}
static inline ORLong maxSeq(ORLong v[4])  {
   ORLong mx = MININT;
   for(int i=0;i<4;i++)
      mx = mx < v[i] ? v[i] : mx;
   return mx;
}
-(void) visitExprDivI: (ORExprDivI*) e
{
   id<ORIntLinear> lT = [ORNormalizer intLinearFrom:[e left] model:_model];
   id<ORIntLinear> rT = [ORNormalizer intLinearFrom:[e right] model:_model];
   id<ORIntVar> lV = [ORNormalizer intVarIn:lT for:_model];
   id<ORIntVar> rV = [ORNormalizer intVarIn:rT for:_model];
   
   if ([lT size] == 0) {  // z ==  c / y
      id<ORIntVar> y = rV;
      ORInt c = [lT independent];
      ORLong yMin = y.min == 0 ? 1  : y.min;
      ORLong yMax = y.max == 0 ? -1 : y.max;
      ORLong vals[4] = {c/yMin,c/yMax,-c,c};
      int low = bindDown(minSeq(vals));
      int up  = bindUp(maxSeq(vals));
      if (_rv==nil)
         _rv = [ORFactory intVar:_model domain: RANGE(_model,bindDown(low),bindUp(up))];
      if(c)
         [_model addConstraint:[_rv neq:@(0)]];
      [_model addConstraint:[[_rv mul:y] eq:@(c)]];
   }
   else if ([rT size] == 0) { // z == x / c
      id<ORIntVar> x = lV;
      ORInt c = [rT independent];
      if (c==0)
         [_model addConstraint:[ORFactory fail:_model]];
      
      int xMin = x.min;
      int xMax = x.max;
      int low = c>0 ? xMin/c : xMax/c;
      int up  = c>0 ? xMax/c : xMin/c;
      id<ORIntVar> rem  = [ORFactory intVar:_model domain:RANGE(_model,-c+1,c-1)];
      id<ORIntVar> prod = [ORFactory intVar:_model domain:RANGE(_model,xMin,xMax)];
      id<ORIntVar> z    = _rv ? _rv : [ORFactory intVar:_model domain:RANGE(_model,low,up)];
      [_model addConstraint:[ORFactory mod:_model var:x modi:c equal:rem]];
      [_model addConstraint:[ORFactory mult:_model var:z by:[ORFactory intVar:_model value:c] equal:prod]];
      [_model addConstraint:[ORFactory equal3:_model var:x to:prod plus:rem]];
      _rv = z;
   }
   else {  // z = x / y
      id<ORIntVar> x = lV;
      id<ORIntVar> y = rV;
      ORLong v1Min = x.min;
      ORLong v1Max = x.max;
      ORLong yp = y.min == 0 ? 1  : y.min;
      ORLong ym = y.max == 0 ? -1 : y.max;
      
      ORLong mxvals[4] = { v1Min/yp,v1Min/ym,v1Max/yp,v1Max/ym};
      int low = bindDown(minSeq(mxvals));
      int up  = bindUp(maxSeq(mxvals));
      ORLong pxvals[4] = { low * y.min,low * y.max, up * y.min, up * y.max};
      int pxlow = bindDown(minSeq(pxvals));
      int pxup  = bindUp(maxSeq(pxvals));
      int rb = max((int)labs(yp),(int)labs(ym))-1;
      id<ORIntVar> rem  = [ORFactory intVar:_model domain:RANGE(_model,-rb,rb)];
      id<ORIntVar> prod = [ORFactory intVar:_model domain:RANGE(_model,pxlow,pxup)];
      id<ORIntVar> z    = _rv ? _rv : [ORFactory intVar:_model domain:RANGE(_model,low,up)];
      [_model addConstraint:[ORFactory mod:_model var:x mod:y equal:rem]];
      [_model addConstraint:[ORFactory notEqualc:_model var:y to:0]];
      [_model addConstraint:[ORFactory mult:_model var:z by:y equal:prod]];
      [_model addConstraint:[ORFactory equal3:_model var:x to:prod plus:rem]];
      _rv = z;
   }
   [lT release];
   [rT release];
}

-(void) visitExprModI:(ORExprModI *)e
{
   id<ORIntLinear> lT = [ORNormalizer intLinearFrom:[e left] model:_model];
   id<ORIntLinear> rT = [ORNormalizer intLinearFrom:[e right] model:_model];
   if ([rT size] == 0) {
      if (_rv==nil)
         _rv = [ORFactory intVar:_model domain: RANGE(_model,[e min],[e max])];
      id<ORIntVar> lV = [ORNormalizer intVarIn:lT for:_model];
      [_model addConstraint:[ORFactory mod:_model var:lV modi:[rT independent] equal:_rv]];
   } else {
      if (_rv==nil)
         _rv = [ORFactory intVar:_model domain: RANGE(_model,[e min],[e max])];
      id<ORIntVar> lV = [ORNormalizer intVarIn:lT for:_model];
      id<ORIntVar> rV = [ORNormalizer intVarIn:rT for:_model];
      [_model addConstraint:[ORFactory mod:_model var:lV mod:rV equal:_rv]];
   }
   [lT release];
   [rT release];
}

-(void) visitExprMinI:(ORExprMinI*)e
{
   id<ORIntLinear> lT = [ORNormalizer intLinearFrom:[e left] model:_model];
   id<ORIntLinear> rT = [ORNormalizer intLinearFrom:[e right] model:_model];
   id<ORIntVar> lV = [ORNormalizer intVarIn:lT for:_model];
   id<ORIntVar> rV = [ORNormalizer intVarIn:rT for:_model];
   ORLong llb = [[lV domain] low];
   ORLong lub = [[lV domain] up];
   ORLong rlb = [[rV domain] low];
   ORLong rub = [[rV domain] up];
   ORLong a = minOf(llb,rlb);
   ORLong d = minOf(lub,rub);
   if (_rv==nil)
      _rv = [ORFactory intVar:_model domain: RANGE(_model,bindDown(a),bindUp(d))];
   [_model addConstraint: [ORFactory min:_model var:lV land:rV equal:_rv]];
   [lT release];
   [rT release];
}

-(void) visitExprMaxI:(ORExprMaxI*)e
{
   id<ORIntLinear> lT = [ORNormalizer intLinearFrom:[e left] model:_model];
   id<ORIntLinear> rT = [ORNormalizer intLinearFrom:[e right] model:_model];
   id<ORIntVar> lV = [ORNormalizer intVarIn:lT for:_model];
   id<ORIntVar> rV = [ORNormalizer intVarIn:rT for:_model];
   ORLong llb = [[lV domain] low];
   ORLong lub = [[lV domain] up];
   ORLong rlb = [[rV domain] low];
   ORLong rub = [[rV domain] up];
   ORLong a = maxOf(llb,rlb);
   ORLong d = maxOf(lub,rub);
   if (_rv==nil)
      _rv = [ORFactory intVar:_model domain: RANGE(_model,bindDown(a),bindUp(d))];
   [_model addConstraint: [ORFactory max:_model var:lV land:rV equal:_rv]];
   [lT release];
   [rT release];
}

//hzi : move this
#if  USEVIEWS==1
#define OLDREIFY 0
#else
#define OLDREIFY 1
#endif

-(void) visitExprEqualI:(ORExprEqualI*)e
{
   ORExprI* left = [e left];
   ORExprI* right = [e right];
   id<TypeNormalizer> recVisit = vtype2Obj(left.vtype);
   if(_rv == nil) _rv = [ORFactory boolVar:_model];
   [recVisit reifyEQ:_model boolean:_rv left:left right:right];
   [recVisit release];
   
}
-(void) visitExprNEqualI:(ORExprNotEqualI*)e
{
   ORExprI* left = [e left];
   ORExprI* right = [e right];
   id<TypeNormalizer> recVisit = vtype2Obj(left.vtype);
   if(_rv == nil) _rv = [ORFactory boolVar:_model];
   [recVisit reifyNEQ:_model boolean:_rv left:left right:right];
   [recVisit release];
}
-(void) visitExprLEqualI:(ORExprLEqualI*)e
{
   ORExprI* left = [e left];
   ORExprI* right = [e right];
   id<TypeNormalizer> recVisit = vtype2Obj(left.vtype);
   if(_rv == nil) _rv = [ORFactory boolVar:_model];
   [recVisit reifyLEQ:_model boolean:_rv left:left right:right];
   [recVisit release];
}
-(void) visitExprGEqualI:(ORExprGEqualI*)e
{
   ORExprI* left = [e left];
   ORExprI* right = [e right];
   id<TypeNormalizer> recVisit = vtype2Obj(left.vtype);
   if(_rv == nil) _rv = [ORFactory boolVar:_model];
   [recVisit reifyGEQ:_model boolean:_rv left:left right:right];
   [recVisit release];
}

-(void) visitExprLThenI:(ORExprLThenI*)e
{
   ORExprI* left = [e left];
   ORExprI* right = [e right];
   id<TypeNormalizer> recVisit = vtype2Obj(left.vtype);
   if(_rv == nil) _rv = [ORFactory boolVar:_model];
   [recVisit reifyLT:_model boolean:_rv left:left right:right];
   [recVisit release];
}
-(void) visitExprGThenI:(ORExprGThenI*)e
{
   ORExprI* left = [e left];
   ORExprI* right = [e right];
   id<TypeNormalizer> recVisit = vtype2Obj(left.vtype);
   if(_rv == nil) _rv = [ORFactory boolVar:_model];
   [recVisit reifyGT:_model boolean:_rv left:left right:right];
   [recVisit release];
}
-(void) visitExprDisjunctI:(ORDisjunctI*)e
{
   id<ORIntLinear> linLeft  = [ORNormalizer intLinearFrom:[e left] model:_model];
   id<ORIntLinear> linRight = [ORNormalizer intLinearFrom:[e right] model:_model];
   if ([linLeft isZero] && [linRight isZero]) {
      assert(0);
   } else if ([linLeft isZero]) {
      id<ORIntVar> rV = [ORNormalizer intVarIn:linRight for:_model];
      if (_rv != nil)
         [_model addConstraint:[ORFactory equal:_model var:_rv to:rV plus:0]];
      else _rv = rV;
   } else if ([linRight isZero]) {
      id<ORIntVar> lV = [ORNormalizer intVarIn:linLeft  for:_model];
      if (_rv != nil)
         [_model addConstraint:[ORFactory equal:_model var:_rv to:lV plus:0]];
      else _rv = lV;
   } else {
      id<ORIntVar> lV = [ORNormalizer intVarIn:linLeft  for:_model];
      id<ORIntVar> rV = [ORNormalizer intVarIn:linRight for:_model];
      if (_rv==nil)
         _rv = [ORFactory intVar:_model domain:RANGE(_model,0,1)];
      [_model addConstraint:[ORFactory model:_model boolean:lV lor:rV equal:_rv]];
   }
   [linLeft release];
   [linRight release];
}
-(void) visitExprConjunctI:(ORConjunctI*)e
{
   id<ORIntLinear> linLeft  = [ORNormalizer intLinearFrom:[e left] model:_model];
   id<ORIntLinear> linRight = [ORNormalizer intLinearFrom:[e right] model:_model];
   id<ORIntVar> lV = [ORNormalizer intVarIn:linLeft  for:_model];
   id<ORIntVar> rV = [ORNormalizer intVarIn:linRight for:_model];
   if ([[lV domain] low] >= 1) {
      if (_rv)
         [_model addConstraint:[ORFactory equal:_model var:_rv to:rV plus:0]];
      else
         _rv = rV;
   } else if ([[rV domain] low] >= 1) {
      if (_rv)
         [_model addConstraint:[ORFactory equal:_model var:_rv to:lV plus:0]];
      else
         _rv = lV;
   } else {
      if (_rv==nil)
         _rv = [ORFactory intVar:_model domain:RANGE(_model,0,1)];
      [_model addConstraint:[ORFactory model:_model boolean:lV land:rV equal:_rv]];
   }
   [linLeft release];
   [linRight release];
}
-(void) visitExprImplyI:(ORImplyI*)e
{
   id<ORIntLinear> linLeft  = [ORNormalizer intLinearFrom:[e left] model:_model];
   id<ORIntLinear> linRight = [ORNormalizer intLinearFrom:[e right] model:_model];
   id<ORIntVar> lV = [ORNormalizer intVarIn:linLeft  for:_model];
   id<ORIntVar> rV = [ORNormalizer intVarIn:linRight for:_model];
   if (_rv==nil)
      _rv = [ORFactory intVar:_model domain:RANGE(_model,0,1)];
   [_model addConstraint:[ORFactory model:_model boolean:lV imply:rV equal:_rv]];
   [linLeft release];
   [linRight release];
}

-(void) visitExprAbsI:(ORExprAbsI *)e
{
   id<ORIntLinear> lT = [ORNormalizer intLinearFrom:[e operand] model:_model];
   id<ORIntVar> oV = [ORNormalizer intVarIn:lT for:_model];
   ORInt lb = [lT min];
   ORInt ub = [lT max];
   if (_rv == nil)
      _rv = [ORFactory intVar:_model domain:RANGE(_model,lb,ub)];
   [_model addConstraint:[ORFactory abs:_model var:oV equal:_rv]];
   [lT release];
}
-(void) visitExprSquareI:(ORExprSquareI *)e
{
   id<ORIntLinear> lT = [ORNormalizer intLinearFrom:[e operand] model:_model];
   id<ORIntVar> oV = [ORNormalizer intVarIn:lT for:_model];
   ORInt lb = [lT min];
   ORInt ub = [lT max];
   ORInt nlb = lb < 0 ? 0 : lb*lb;
   ORInt nub = max(lb*lb, ub*ub);
   if (_rv == nil)
      _rv = [ORFactory intVar:_model domain:RANGE(_model,nlb,nub)];
   [_model addConstraint:[ORFactory square:_model var:oV equal:_rv]];
   [lT release];
}
-(void) visitExprNegateI:(ORExprNegateI*)e
{
   id<ORIntLinear> lT = [ORNormalizer intLinearFrom:e.operand model:_model];
   if (_rv==nil) {  // NEG(E)  ->  produce y == NEG(E) ; return y.
      id<ORIntVar> oV = [ORNormalizer intVarIn:lT for:_model];
      _rv = [ORFactory intVar:_model var:oV scale:-1 shift:1];
   } else {  // x = NEG(e)  ==>  NOT(X) == e
      // x = NEG(a0 OR ... OR an)
      // a0 OR ... OR an OR x   (to make sure that when x=0, a0 OR ... an must be satisfied (classic clause)
      // NOT(X) OR NOT(ai)      (to make sure that when x=1, ai=0 must be true (so that the expression be false)
      // The second can be rewritten (for every i) as:  1 - x ≥ ai
      // Note that x=1  => 1-x = 0 =>  0 ≥ ai  and all the disjunct must be false.
      //           x=0  => 1-x = 1 =>  1 ≥ ai  no constraints on the ai
      //           ai=1 => 1-x ≥ 1 =>  x ≤ 0   and x must be zero. (ok, since the expression is true)
      //           ai=0 => 1-x ≥ 0 =>  x ≤ 1   and no impact on x.
      // This requires n+1 clauses, x appears in all of them, each ai appears in 2.
      id<ORIntVar> negRet = [ORFactory intVar:_model var:_rv scale:-1 shift:1];
      [ORNormalizer intVar:negRet equal:lT for:_model];
   }
   [lT release];
}
-(void) visitExprCstSubI:(ORExprCstSubI*)e
{
   id<ORIntLinear> lT = [ORNormalizer intLinearFrom:[e index] model:_model];
   id<ORIntVar> oV = [ORNormalizer intVarIn:lT for:_model];
   ORInt lb = [e min];
   ORInt ub = [e max];
   if (_rv == nil)
      _rv = [ORFactory intVar:_model domain: RANGE(_model,lb,ub)];
   [_model addConstraint:[ORFactory element:_model var:oV idxCstArray:[e array] equal:_rv]];
   [lT release];
}

-(void) visitExprVarSubI:(ORExprVarSubI*)e
{
   id<ORIntLinear> lT = [ORNormalizer intLinearFrom:[e index] model:_model];
   id<ORIntVar> oV = [ORNormalizer intVarIn:lT for:_model];
   ORInt lb = [e min];
   ORInt ub = [e max];
   if (_rv == nil)
      _rv = [ORFactory intVar:_model domain: RANGE(_model,lb,ub)];
   [_model addConstraint:[ORFactory element:_model var:oV idxVarArray: [e array] equal:_rv]];
   [lT release];
}

static void loopOverMatrix(id<ORIntVarMatrix> m,ORInt d,ORInt arity,id<ORTable> t,ORInt* idx)
{
   if (d == arity) {
      [t insertTuple:idx];
      idx[arity]++;
   } else {
      [[m range:d] enumerateWithBlock:^(ORInt k) {
         idx[d] = k;
         loopOverMatrix(m, d+1, arity, t, idx);
      }];
   }
}
-(void)visitExprMatrixVarSubI:(ORExprMatrixVarSubI*) e
{
   id<ORIntLinear> i0 = [ORNormalizer intLinearFrom:[e index0] model:_model];
   id<ORIntLinear> i1 = [ORNormalizer intLinearFrom:[e index1] model:_model];
   id<ORIntVar> v0 = [ORNormalizer intVarIn:i0 for:_model];
   id<ORIntVar> v1 = [ORNormalizer intVarIn:i1 for:_model];
   [i0 release];
   [i1 release];
   id<ORIntVarMatrix> m = [e matrix];
   ORInt lb = [e min];
   ORInt ub = [e max];
   if (_rv == nil)
      _rv = [ORFactory intVar:_model domain: RANGE(_model,lb,ub)];
   
   id<ORIntRange> fr = [ORFactory intRange:_model low:0 up:(ORInt)[m count]-1];
   id<ORIntVarArray> f = (id)[ORFactory idArray:_model range:fr with:^id(ORInt i) {
      return [m flat:i];
   }];
   id<ORTable> table = [ORFactory table:_model arity:[m arity]+1];
   ORInt k = [m arity]+1;
   ORInt idx[k];
   idx[k-1] = 0;
   loopOverMatrix(m,0,[m arity],table,idx);
   table = [_model memoize:table];
   id<ORIntVar> alpha = [ORFactory intVar:_model domain:fr];
   [_model addConstraint:[ORFactory tableConstraint:_model table:table on:v0 :v1 :alpha]];
   id<ORConstraint> fc = [ORFactory element:_model var:alpha idxVarArray:f equal:_rv];
   [_model addConstraint:fc];
   //[_model addConstraint:[ORFactory element:_model matrix:m elt:v0 elt:v1 equal:_rv]];
}
-(void) visitExprSumI: (ORExprSumI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprProdI: (ORExprProdI*) e
{
   [[e expr] visit:self];
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
@end

@implementation ORNormalizer(Rational)
+(ORRationalLinear*)rationalLinearFrom:(ORExprI*)e model:(id<ORAddToModel>)model equalTo:(id<ORRationalVar>)x
{
   ORRationalLinear* rv = [[ORRationalLinear alloc] initORRationalLinear:4];
   ORRationalLinearizer* v = [[ORRationalLinearizer alloc] init:rv model: model  equalTo:x];
   [e visit:v];
   [v release];
   return rv;
}
+(ORRationalLinear*)rationalLinearFrom:(ORExprI*)e model:(id<ORAddToModel>)model
{
   //hzi : test useless ?
   if (e.vtype == ORTBool) {
      ORRationalLinear* rv = [[ORRationalLinear alloc] initORRationalLinear:4];
      ORRationalLinearizer* v = [[ORRationalLinearizer alloc] init:rv model: model];
      [e visit:v];
      [v release];
      return rv;
   } else {
      ORRationalLinear* rv = [[ORRationalLinear alloc] initORRationalLinear:4];
      ORRationalLinearizer* v = [[ORRationalLinearizer alloc] init:rv model: model];
      [e visit:v];
      [v release];
      return rv;
   }
}
+(ORRationalLinear*)addToRationalLinear:(id<ORRationalLinear>)terms from:(ORExprI*)e  model:(id<ORAddToModel>)model
{
   ORRationalLinearizer* v = [[ORRationalLinearizer alloc] init:terms model: model];
   [e visit:v];
   [v release];
   return terms;
}
+(id<ORRationalVar>) rationalVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr
{
   ORRationalSubst* subst = [[ORRationalSubst alloc] initORRationalSubst: model];
   [expr visit:subst];
   id<ORRationalVar> theVar = [subst result];
   [subst release];
   return theVar;
}
+(id<ORRationalVar>) rationalVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr by:(id<ORRationalVar>)x
{
   ORRationalSubst* subst = [[ORRationalSubst alloc] initORRationalSubst: model by:x];
   [expr visit:subst];
   id<ORRationalVar> theVar = [subst result];
   [subst release];
   //assert(theVar == x);
   return theVar;
}
+(id<ORRationalVar>)rationalVarIn:(ORRationalLinear*)e for:(id<ORAddToModel>)model
{
   id<ORRationalRange> r = [ORFactory rationalRange:model low:[e qmin] up:[e qmax]];
   if ([e size] == 0) {
      id<ORRationalVar> xv = [ORFactory rationalVar: model domain:r];
      return xv;
   } else if ([e size] == 1) {
      return (id<ORRationalVar>)[e var:0];
   } else {
         id<ORRationalVar> xv = [ORFactory rationalVar: model domain:r];
         [e addTerm:xv by:-1];
         [e postEQZ: model];
         return xv;
      }
}
+(void)rationalVar:(id<ORRationalVar>)var equal:(ORRationalLinear*)e for:(id<ORAddToModel>) model
{
   if (e.size == 0) {
      ORRational* z = [ORRational rationalWith_d:0.0];
      [model addConstraint:[ORFactory rationalEqualc:model var:var eqc:z]];
      [z release];
   } else if (e.size == 1) {
      [e addTerm:var by:-1];
      [e postEQZ:model];
   } else {
      [e addTerm:var by:-1];
      [e postEQZ:model];
   }
}
@end

@implementation ORNormalizer(Float)
+(id<ORFloatLinear>)floatLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model
{
   ORFloatLinear* rv = [[ORFloatLinear alloc] initORFloatLinear:4 type:[e type]];
   ORFloatLinearizer* v = [[ORFloatLinearizer alloc] init: rv model: model];
   [e visit:v];
   [v release];
   return rv;
}
+(id<ORFloatLinear>)addToFloatLinear:(id<ORFloatLinear>)terms from:(id<ORExpr>)e  model:(id<ORAddToModel>)model
{
   ORFloatLinearizer* v = [[ORFloatLinearizer alloc] init: terms model: model];
   [e visit:v];
   [v release];
   return terms;
}
+(id<ORFloatVar>) floatVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr
{
   ORFloatSubst* subst = [[ORFloatSubst alloc] initORFloatSubst: model];
   [expr visit:subst];
   id<ORFloatVar> theVar = [subst result];
   [subst release];
   return theVar;
}
+(id<ORFloatVar>) floatVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr by:(id<ORFloatVar>)x
{
   ORFloatSubst* subst = [[ORFloatSubst alloc] initORFloatSubst: model];
   [expr visit:subst];
   id<ORFloatVar> theVar = [subst result];
   [subst release];
   return theVar;
}
+(id<ORFloatVar>) floatVarIn:(id<ORFloatLinear>)e for:(id<ORAddToModel>) model
{
   id<ORFloatRange> r = [ORFactory floatRange:model low:[e fmin] up:[e fmax]];
   if ([e size] == 0) {
      id<ORFloatVar> xv = [ORFactory floatVar: model domain: r];
      return xv;
   } else if ([e size] == 1 && [e coef:0] == 1) {
      return (id<ORFloatVar>)[e var:0];
   } else {
      id<ORFloatVar> xv = [ORFactory floatVar: model domain: r];
      [e addTerm:xv by:-1];
      [e postEQZ: model];
      return xv;
   }
}
+(void)floatVar:(id<ORFloatVar>)var equal:(ORFloatLinear*)e for:(id<ORAddToModel>) model
{
   if (e.size == 0) {
      [model addConstraint:[ORFactory floatEqualc:model var:var eqc:0.0f]];
   } else if (e.size == 1) {
      [e addTerm:var by:-1.f];
      [e postEQZ:model];
   } else {
      [e addTerm:var by:-1.f];
      [e postEQZ:model];
   }
}
@end


@implementation ORNormalizer(Double)
+(id<ORDoubleLinear>)doubleLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model
{
   ORDoubleLinear* rv = [[ORDoubleLinear alloc] initORDoubleLinear:4 type:[e type]];
   ORDoubleLinearizer* v = [[ORDoubleLinearizer alloc] init: rv model: model];
   [e visit:v];
   [v release];
   return rv;
}
+(id<ORDoubleLinear>)addToDoubleLinear:(id<ORDoubleLinear>)terms from:(id<ORExpr>)e  model:(id<ORAddToModel>)model
{
   ORDoubleLinearizer* v = [[ORDoubleLinearizer alloc] init: terms model: model];
   [e visit:v];
   [v release];
   return terms;
}
+(id<ORDoubleVar>) doubleVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr
{
   ORDoubleSubst* subst = [[ORDoubleSubst alloc] initORDoubleSubst: model];
   [expr visit:subst];
   id<ORDoubleVar> theVar = [subst result];
   [subst release];
   return theVar;
}
+(id<ORDoubleVar>) doubleVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr by:(id<ORDoubleVar>)x
{
   ORDoubleSubst* subst = [[ORDoubleSubst alloc] initORDoubleSubst: model];
   [expr visit:subst];
   id<ORDoubleVar> theVar = [subst result];
   [subst release];
   return theVar;
}
+(id<ORDoubleVar>) doubleVarIn:(id<ORDoubleLinear>)e for:(id<ORAddToModel>) model
{
   id<ORDoubleRange> r = [ORFactory doubleRange:model low:[e dmin] up:[e dmax]];
   if ([e size] == 0) {
      id<ORDoubleVar> xv = [ORFactory doubleVar: model domain: r];
      return xv;
   } else if ([e size] == 1 && [e coef:0] == 1) {
      return (id<ORDoubleVar>)[e var:0];
   } else {
      id<ORDoubleVar> xv = [ORFactory doubleVar: model domain: r];
      [e addTerm:xv by:-1];
      [e postEQZ: model];
      return xv;
   }
}
+(void)doubleVar:(id<ORDoubleVar>)var equal:(ORDoubleLinear*)e for:(id<ORAddToModel>) model
{
   if (e.size == 0) {
      [model addConstraint:[ORFactory doubleEqualc:model var:var eqc:0.0f]];
   } else if (e.size == 1) {
      [e addTerm:var by:-1];
      [e postEQZ:model];
   } else {
      [e addTerm:var by:-1];
      [e postEQZ:model];
   }
}
@end

@implementation ORVTypeHandler
//hzi should be use only by child
-(id) init:(ORVType)vtype
{
   self = [super init];
   _vtype = vtype;
   return self;
}

-(id) init
{
   self = [super init];
   _vtype = ORTNA;
   return self;
}
-(ORVType) value{
   return _vtype;
}
-(void) reifyEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*)right
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORVTypeHandler : unrecognized selector <reifyEQ>"];
}
-(void) reifyNEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*)right
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORVTypeHandler : unrecognized selector <reifyNEQ>"];
}
-(void) reifyLEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*)right
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORVTypeHandler : unrecognized selector <reifyLEQ>"];
}
-(void) reifyGEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*)right
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORVTypeHandler : unrecognized selector <reifyGEQ>"];
}
-(void) reifyLT:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*)right
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORVTypeHandler : unrecognized selector <reifyLT>"];
}
-(void) reifyGT:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*)right
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORVTypeHandler : unrecognized selector <reifyGT>"];
}
-(void) reifyEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv other:(ORExprI*)left constant:(ORExprI*)right
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORVTypeHandler : unrecognized selector <reifyEQc>"];
}
-(void) reifyNEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv other:(ORExprI*)left constant:(ORExprI*)right
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORVTypeHandler : unrecognized selector <reifyNEQc>"];
}
-(void) reifyLEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv other:(ORExprI*)left constant:(ORExprI*)right
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORVTypeHandler : unrecognized selector <reifyLEQc>"];
}
-(void) reifyGEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv other:(ORExprI*)left constant:(ORExprI*)right
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORVTypeHandler : unrecognized selector <reifyGEQc>"];
}
-(void) reifyLTc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv other:(ORExprI*)left constant:(ORExprI*)right
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORVTypeHandler : unrecognized selector <reifyLTc>"];
}
-(void) reifyGTc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv other:(ORExprI*)left constant:(ORExprI*)right
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORVTypeHandler : unrecognized selector <reifyGTc>"];
}
-(id<ORLinear>) visitExprGEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORVTypeHandler : unrecognized selector <visitExprGEqualI>"];
}
-(id<ORLinear>) visitExprLEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORVTypeHandler : unrecognized selector <visitExprLEqualI>"];
}
-(id<ORLinear>) visitExprGThenI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORVTypeHandler : unrecognized selector <visitExprGThenI>"];
}
-(id<ORLinear>) visitExprLThenI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORVTypeHandler : unrecognized selector <visitExprLThenI>"];
}
-(id<ORLinear>) visitExprEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORVTypeHandler : unrecognized selector <visitExprEqualI>"];
}
-(id<ORLinear>) visitExprErrorOfI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORVTypeHandler : unrecognized selector <visitExprErrorOfI>"];
}
-(id<ORLinear>) visitExprNEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORVTypeHandler : unrecognized selector <visitExprNEqualI>"];
}
@end

@implementation ORTIntHandler
-(id) init
{
   self = [super init:ORTInt];
   return self;
}

-(void) reifyEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv other:(ORExprI*)theOther constant:(ORExprI*)c
{
   ORInt cv = [c min];
   id<ORIntLinear> linOther  = [ORNormalizer intLinearFrom:theOther model:_model];
   id<ORIntVar> theVar = [ORNormalizer intVarIn:linOther for:_model];
   [linOther release];
#if OLDREIFY==1
   [_model addConstraint: [ORFactory reify:_model boolean:rv with:theVar eqi:cv]];
#else
   if (rv != nil) {
      [_model addConstraint: [ORFactory reify:_model boolean:rv with:theVar eqi:cv]];
   } else {
      if (theVar.isBool && cv==1)
         rv = theVar;
      else if ([theVar.domain inRange:cv])
         [ORFactory reifyView:_model var:theVar eqi:cv];
      else
         [ORFactory intVar:_model value:0];
   }
#endif
}
-(void) reifyNEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv other:(ORExprI*)theOther constant:(ORExprI*)c
{
   ORInt cv = [c min];
   id<ORIntLinear> linOther  = [ORNormalizer intLinearFrom:theOther model:_model];
   id<ORIntVar> theVar = [ORNormalizer intVarIn:linOther for:_model];
   [_model addConstraint: [ORFactory reify:_model boolean:rv with:theVar neqi:cv]];
   [linOther release];
}
-(void) reifyLEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv other:(ORExprI*)theOther constant:(ORExprI*)c
{
   ORInt cv = [c min];
   id<ORIntLinear> linOther  = [ORNormalizer intLinearFrom:theOther model:_model];
   id<ORIntVar> theVar = [ORNormalizer intVarIn:linOther for:_model];
   if ([[theVar domain] up] <= cv) {
      [_model addConstraint:[ORFactory equalc:_model var:rv to:1]];
   } else {
      [_model addConstraint: [ORFactory reify:_model boolean:rv with:theVar leqi:cv]];
   }
   [linOther release];
}
-(void) reifyGEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv other:(ORExprI*)theOther constant:(ORExprI*)c
{
   ORInt cv = [c min];
   id<ORIntLinear> linOther  = [ORNormalizer intLinearFrom:theOther model:_model];
   id<ORIntVar> theVar = [ORNormalizer intVarIn:linOther for:_model];
   if ([[theVar domain] low] >= cv) {
      [_model addConstraint:[ORFactory equalc:_model var:rv to:1]];
   } else {
      [_model addConstraint: [ORFactory reify:_model boolean:rv with:theVar geqi:cv]];
   }
   [linOther release];
}
-(void) reifyLEQ:(id<ORAddToModel>)_model  boolean:(id<ORIntVar>)rv  left:(ORExprI*)left right:(ORExprI*)right
{
   if ([left isConstant]) {
      [self reifyGEQc:_model boolean:rv other:right constant:left];
   } else if ([right isConstant]) {
      [self reifyLEQc:_model boolean:rv other:left constant:right];
   } else{
      id<ORIntLinear> linLeft   = [ORNormalizer intLinearFrom:left model:_model];
      id<ORIntLinear> linRight  = [ORNormalizer intLinearFrom:right model:_model];
      id<ORIntVar> varLeft  = [ORNormalizer intVarIn:linLeft for:_model];
      id<ORIntVar> varRight = [ORNormalizer intVarIn:linRight for:_model];
      [_model addConstraint: [ORFactory reify:_model boolean:rv with:varLeft leq:varRight]];
      [linLeft release];
      [linRight release];
   }
}
-(void) reifyGEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*) right
{
   ORExprI* newleft  = right;
   ORExprI* newright = left;    // switch side and pretend it is ≤
   if ([newleft isConstant]) {
      [self reifyGEQc:_model boolean:rv other:newright constant:newleft];
   } else if ([newright isConstant]) {
      [self reifyLEQc:_model boolean:rv other:newleft constant:newright];
   } else
      [self reifyLEQ:_model boolean:rv left:newleft right:newright];
}
-(void) reifyEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*) right
{
   if ([left isConstant]) {
      [self reifyEQc:_model boolean:rv other:right constant:left];
   } else if ([right isConstant]) {
      [self reifyEQc:_model boolean:rv other:left constant:right];
   } else{
      id<ORIntLinear> linLeft   = [ORNormalizer intLinearFrom:left model:_model];
      id<ORIntLinear> linRight  = [ORNormalizer intLinearFrom:right model:_model];
      id<ORIntVar> varLeft  = [ORNormalizer intVarIn:linLeft for:_model];
      id<ORIntVar> varRight = [ORNormalizer intVarIn:linRight for:_model];
      [_model addConstraint: [ORFactory reify:_model boolean:rv with:varLeft eq:varRight]];
      [linLeft release];
      [linRight release];
   }
}
-(void) reifyNEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*) right
{
   if ([left isConstant]) {
      [self reifyNEQc:_model boolean:rv other:right constant:left];
   } else if ([right isConstant]) {
      [self reifyNEQc:_model boolean:rv other:left constant:right];
   } else{
      id<ORIntLinear> linLeft   = [ORNormalizer intLinearFrom:left model:_model];
      id<ORIntLinear> linRight  = [ORNormalizer intLinearFrom:right model:_model];
      id<ORIntVar> varLeft  = [ORNormalizer intVarIn:linLeft for:_model];
      id<ORIntVar> varRight = [ORNormalizer intVarIn:linRight for:_model];
      [_model addConstraint: [ORFactory reify:_model boolean:rv with:varLeft neq:varRight]];
      [linLeft release];
      [linRight release];
   }
}
-(id<ORLinear>) visitExprGEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   // a >= b
   ORIntLinear* linLeft = [ORNormalizer intLinearFrom:left model:_model];
   ORLinearFlip* linRight = [[ORLinearFlip alloc] initORLinearFlip: linLeft];
   [ORNormalizer addToIntLinear:linRight from:right model:_model];
   [linRight release];
   return linLeft;
}
-(id<ORLinear>) visitExprLEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   // a <= b  =>  -lin(a) + lin(b) <= 0
   ORIntLinear* linLeft = [ORNormalizer intLinearFrom:left model:_model];
   ORLinearFlip* linRight = [[ORLinearFlip alloc] initORLinearFlip: linLeft];
   [ORNormalizer addToIntLinear:linRight from:right model:_model];
   [linRight release];
   return linLeft;
}
-(id<ORLinear>) visitExprGThenI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   // a >= b
   ORIntLinear* linLeft = [ORNormalizer intLinearFrom:left model:_model];
   ORLinearFlip* linRight = [[ORLinearFlip alloc] initORLinearFlip: linLeft];
   [ORNormalizer addToIntLinear:linRight from:right model:_model];
   [linRight release];
   return linLeft;
}
-(id<ORLinear>) visitExprLThenI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   // a <= b  =>  -lin(a) + lin(b) <= 0
   ORIntLinear* linLeft = [ORNormalizer intLinearFrom:left model:_model];
   ORLinearFlip* linRight = [[ORLinearFlip alloc] initORLinearFlip: linLeft];
   [ORNormalizer addToIntLinear:linRight from:right model:_model];
   [linRight release];
   return linLeft;
}
-(id<ORLinear>) visitExprEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   ORIntLinear* lin = nil;
   bool lc = [left isConstant];
   bool rc = [right isConstant];
   if (lc && rc) {
      bool isOk = [left min] == [right min];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   } else if (lc || rc) {
      ORInt c = lc ? [left min] : [right min];
      ORExprI* other = lc ? right : left;
      lin  = [ORNormalizer intLinearFrom:other model:_model];
      [lin addIndependent: - c];
   } else {
      bool lv = [left isVariable];
      bool rv = [right isVariable];
      if (lv || rv) {
         ORExprI* other = lv ? right : left;
         ORExprI* var   = lv ? left : right;
         id<ORIntVar> theVar = [ORNormalizer intVarIn:_model expr:var];
         //            ORIntLinear* lin  = [ORNormalizer intLinearFrom:other model:_model equalTo:theVar];
         //            [lin release];
         //            _terms = nil; // we already did the full rewrite. Nothing left todo  @ top-level.
         lin  = [ORNormalizer intLinearFrom:other model:_model];
         [lin addTerm:theVar by:-1];
      } else {
         lin = [ORNormalizer intLinearFrom:left model:_model ];
         ORLinearFlip* linRight = [[ORLinearFlip alloc] initORLinearFlip: lin];
         [ORNormalizer addToIntLinear:linRight from:right model:_model];
         [linRight release];
      }
   }
   return lin;
}
-(id<ORLinear>) visitExprNEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   ORIntLinear* linLeft = [ORNormalizer intLinearFrom:left model:_model];
   ORLinearFlip* linRight = [[ORLinearFlip alloc] initORLinearFlip: linLeft];
   [ORNormalizer addToIntLinear:linRight from:right model:_model];
   [linRight release];
   return linLeft;
}
@end


@implementation ORTBoolHandler
-(id) init
{
   self = [super init:ORTBool];
   return self;
}
@end

@implementation ORTRationalHandler
-(id) init
{
   self = [super init:ORTInt];
   return self;
}
-(id<ORRationalLinear>) visitExprEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   ORRationalLinear* lin = nil;
   bool lc = [left isConstant];
   bool rc = [right isConstant];
   if (lc && rc) {
      bool isOk = [[left qmin] eq: [right qmin]];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   } else if (lc || rc) {
      ORRational* c = [[ORRational alloc] init];
      if(lc){
         c = [left qmin];
      } else {
         c = [right qmin];
      }
      ORExprI* other = lc ? right : left;
      lin  = [ORNormalizer rationalLinearFrom:other model:_model];
      [lin addIndependent:[c neg]];
      [c release];
   } else {
      bool lv = [left isVariable];
      bool rv = [right isVariable];
      if (lv || rv) {
         ORExprI* other = lv ? right : left;
         ORExprI* var   = lv ? left : right;
         id<ORRationalVar> theVar = [ORNormalizer rationalVarIn:_model expr:var];
         lin  = [ORNormalizer rationalLinearFrom:other model:_model];
         [lin addTerm:theVar by:-1];
      } else {
         lin = [ORNormalizer rationalLinearFrom:left model:_model ];
         ORRationalLinearFlip* linRight = [[ORRationalLinearFlip alloc] initORRationalLinearFlip: lin];
         [ORNormalizer addToRationalLinear:linRight from:right model:_model];
         [linRight release];
      }
   }
   return lin;
}
@end


@implementation ORTFloatHandler
-(id) init
{
   self = [super init:ORTFloat];
   return self;
}

-(void) reifyEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>) rv other:(ORExprI*)theOther constant:(ORExprI*)ce
{
   ORFloat c = [ce fmin];
   id<ORFloatLinear> linOther  = [ORNormalizer floatLinearFrom:theOther model:_model];
   id<ORFloatVar> theVar = [ORNormalizer floatVarIn:linOther for:_model];
   [_model addConstraint: [ORFactory floatReify:_model boolean:rv with:theVar eqi:c]];
   [linOther release];
}
-(void) reifyNEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>) rv other:(ORExprI*)theOther constant:(ORExprI*)ce
{
   ORFloat c = [ce fmin];
   id<ORFloatLinear> linOther  = [ORNormalizer floatLinearFrom:theOther model:_model];
   id<ORFloatVar> theVar = [ORNormalizer floatVarIn:linOther for:_model];
   [_model addConstraint: [ORFactory floatReify:_model boolean:rv with:theVar neqi:c]];
   [linOther release];
}
-(void) reifyLEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>) rv other:(ORExprI*)theOther constant:(ORExprI*)ce
{
   ORFloat c = [ce fmin];
   id<ORFloatLinear> linOther  = [ORNormalizer floatLinearFrom:theOther model:_model];
   id<ORFloatVar> theVar = [ORNormalizer floatVarIn:linOther for:_model];
   if ([[theVar domain] up] <= c) {
      [_model addConstraint:[ORFactory equalc:_model var:rv to:1]];
   } else {
      [_model addConstraint: [ORFactory floatReify:_model boolean:rv with:theVar leqi:c]];
   }
   [linOther release];
}
-(void) reifyGEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>) rv other:(ORExprI*)theOther constant:(ORExprI*)ce
{
   ORFloat c = [ce fmin];
   id<ORFloatLinear> linOther  = [ORNormalizer floatLinearFrom:theOther model:_model];
   id<ORFloatVar> theVar = [ORNormalizer floatVarIn:linOther for:_model];
   if ([[theVar domain] low] >= c) {
      [_model addConstraint:[ORFactory equalc:_model var:rv to:1]];
   } else {
      [_model addConstraint: [ORFactory floatReify:_model boolean:rv with:theVar geqi:c]];
   }
   [linOther release];
}
-(void) reifyLTc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>) rv other:(ORExprI*)theOther constant:(ORExprI*)ce
{
   ORFloat c = [ce fmin];
   id<ORFloatLinear> linOther  = [ORNormalizer floatLinearFrom:theOther model:_model];
   id<ORFloatVar> theVar = [ORNormalizer floatVarIn:linOther for:_model];
   if ([[theVar domain] up] < c) {
      [_model addConstraint:[ORFactory equalc:_model var:rv to:1]];
   } else {
      [_model addConstraint: [ORFactory floatReify:_model boolean:rv with:theVar lti:c]];
   }
   [linOther release];
}
-(void) reifyGTc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>) rv other:(ORExprI*)theOther constant:(ORExprI*)ce
{
   ORFloat c = [ce fmin];
   id<ORFloatLinear> linOther  = [ORNormalizer floatLinearFrom:theOther model:_model];
   id<ORFloatVar> theVar = [ORNormalizer floatVarIn:linOther for:_model];
   if ([[theVar domain] low] > c) {
      [_model addConstraint:[ORFactory equalc:_model var:rv to:1]];
   } else {
      [_model addConstraint: [ORFactory floatReify:_model boolean:rv with:theVar gti:c]];
   }
   [linOther release];
}
-(void) reifyLT:(id<ORAddToModel>)_model boolean:(id<ORIntVar>) rv left:(ORExprI*)left right:(ORExprI*)right
{
   if ([left isConstant]) {
      [self reifyGTc:_model boolean:rv other:right constant:left];
   } else if ([right isConstant]) {
      [self reifyLTc:_model boolean:rv other:left constant:right];
   } else{
      id<ORFloatLinear> linLeft   = [ORNormalizer floatLinearFrom:left model:_model];
      id<ORFloatLinear> linRight  = [ORNormalizer floatLinearFrom:right model:_model];
      id<ORFloatVar> varLeft  = [ORNormalizer floatVarIn:linLeft for:_model];
      id<ORFloatVar> varRight = [ORNormalizer floatVarIn:linRight for:_model];
      [_model addConstraint: [ORFactory floatReify:_model boolean:rv with:varLeft lt:varRight]];
      [linLeft release];
      [linRight release];
   }
}
-(void) reifyGT:(id<ORAddToModel>)_model boolean:(id<ORIntVar>) rv left:(ORExprI*)left right:(ORExprI*) right
{
   if ([left isConstant]) {
      [self reifyLTc:_model boolean:rv other:right constant:left];
   } else if ([right isConstant]) {
      [self reifyGTc:_model boolean:rv other:left constant:right];
   } else{
      id<ORFloatLinear> linLeft   = [ORNormalizer floatLinearFrom:left model:_model];
      id<ORFloatLinear> linRight  = [ORNormalizer floatLinearFrom:right model:_model];
      id<ORFloatVar> varLeft  = [ORNormalizer floatVarIn:linLeft for:_model];
      id<ORFloatVar> varRight = [ORNormalizer floatVarIn:linRight for:_model];
      [_model addConstraint: [ORFactory floatReify:_model boolean:rv with:varLeft gt:varRight]];
      [linLeft release];
      [linRight release];
   }
}
-(void) reifyLEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>) rv left:(ORExprI*)left right:(ORExprI*)right
{
   if ([left isConstant]) {
      [self reifyGEQc:_model boolean:rv other:right constant:left];
   } else if ([right isConstant]) {
      [self reifyLEQc:_model boolean:rv other:left constant:right];
   } else{
      id<ORFloatLinear> linLeft   = [ORNormalizer floatLinearFrom:left model:_model];
      id<ORFloatLinear> linRight  = [ORNormalizer floatLinearFrom:right model:_model];
      id<ORFloatVar> varLeft  = [ORNormalizer floatVarIn:linLeft for:_model];
      id<ORFloatVar> varRight = [ORNormalizer floatVarIn:linRight for:_model];
      [_model addConstraint: [ORFactory floatReify:_model boolean:rv with:varLeft leq:varRight]];
      [linLeft release];
      [linRight release];
   }
}
-(void) reifyGEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>) rv left:(ORExprI*)left right:(ORExprI*) right
{
   ORExprI* newleft  = right;
   ORExprI* newright = left;    // switch side and pretend it is ≤
   if ([newleft isConstant]) {
      [self reifyGEQc:_model boolean:rv other:newright constant:newleft];
   } else if ([newright isConstant]) {
      [self reifyLEQc:_model boolean:rv  other:newleft constant:newright];
   } else
      [self reifyLEQ:_model boolean:rv  left:newleft right:newright];
}

-(void) reifyEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*) right
{
   if ([left isConstant]) {
      [self reifyEQc:_model boolean:rv other:right constant:left];
   } else if ([right isConstant]) {
      [self reifyEQc:_model boolean:rv other:left constant:right];
   } else{
      id<ORFloatLinear> linLeft   = [ORNormalizer floatLinearFrom:left model:_model];
      id<ORFloatLinear> linRight  = [ORNormalizer floatLinearFrom:right model:_model];
      id<ORFloatVar> varLeft  = [ORNormalizer floatVarIn:linLeft for:_model];
      id<ORFloatVar> varRight = [ORNormalizer floatVarIn:linRight for:_model];
      [_model addConstraint: [ORFactory floatReify:_model boolean:rv with:varLeft eq:varRight]];
      [linLeft release];
      [linRight release];
   }
}
-(void) reifyNEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*) right
{
   if ([left isConstant]) {
      [self reifyNEQc:_model boolean:rv other:right constant:left];
   } else if ([right isConstant]) {
      [self reifyNEQc:_model boolean:rv other:left constant:right];
   } else{
      id<ORFloatLinear> linLeft   = [ORNormalizer floatLinearFrom:left model:_model];
      id<ORFloatLinear> linRight  = [ORNormalizer floatLinearFrom:right model:_model];
      id<ORFloatVar> varLeft  = [ORNormalizer floatVarIn:linLeft for:_model];
      id<ORFloatVar> varRight = [ORNormalizer floatVarIn:linRight for:_model];
      [_model addConstraint: [ORFactory floatReify:_model boolean:rv with:varLeft neq:varRight]];
      [linLeft release];
      [linRight release];
   }
}
-(id<ORLinear>) visitExprGEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   bool lc = [left isConstant];
   bool rc = [right isConstant];
   if (lc && rc) {
      bool isOk = [left fmin] >= [right fmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   }else {
      ORInt length = !lc + !rc;
      id<ORVarArray> vars = [ORFactory floatVarArray:_model range:RANGE(_model,0,length - 1)];
      id<ORFloatArray> coefs = [ORFactory floatArray:_model
                                               range:RANGE(_model,0,length - 1)
                                                with:^ORFloat(ORInt i) {
                                                   return 1;
                                                }];
      if(lc){
         ORFloatLinear* linRight  = [ORNormalizer floatLinearFrom:right model:_model];
         vars[0] = [ORNormalizer floatVarIn:linRight for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs leq:[left fmin]]];
         [linRight release];
      }else if(rc){
         id<ORFloatLinear> linLeft  = [ORNormalizer floatLinearFrom:left model:_model];
         vars[0] = [ORNormalizer floatVarIn:linLeft for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs geq:[right fmin]]];
         [linLeft release];
      }else{
         id<ORFloatLinear> linLeft  = [ORNormalizer floatLinearFrom:left model:_model];
         ORFloatLinear* linRight  = [ORNormalizer floatLinearFrom:right model:_model];
         vars[0] = [ORNormalizer floatVarIn:linLeft for:_model];
         vars[1] = [ORNormalizer floatVarIn:linRight for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs geq:0.f]];
         [linLeft release];
         [linRight release];
      }
   }
   return nil;
}
-(id<ORLinear>) visitExprLEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   bool lc = [left isConstant];
   bool rc = [right isConstant];
   if (lc && rc) {
      bool isOk = [left fmin] <= [right fmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   }else {
      ORInt length = !lc + !rc;
      id<ORVarArray> vars = [ORFactory floatVarArray:_model range:RANGE(_model,0,length - 1)];
      id<ORFloatArray> coefs = [ORFactory floatArray:_model
                                               range:RANGE(_model,0,length - 1)
                                                with:^ORFloat(ORInt i) {
                                                   return 1;
                                                }];
      if(lc){
         ORFloatLinear* linRight  = [ORNormalizer floatLinearFrom:right model:_model];
         vars[0] = [ORNormalizer floatVarIn:linRight for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs geq:[left fmin]]];
         [linRight release];
      }else if(rc){
         id<ORFloatLinear> linLeft  = [ORNormalizer floatLinearFrom:left model:_model];
         vars[0] = [ORNormalizer floatVarIn:linLeft for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs leq:[right fmin]]];
         [linLeft release];
      }else{
         id<ORFloatLinear> linLeft  = [ORNormalizer floatLinearFrom:left model:_model];
         ORFloatLinear* linRight  = [ORNormalizer floatLinearFrom:right model:_model];
         vars[0] = [ORNormalizer floatVarIn:linLeft for:_model];
         vars[1] = [ORNormalizer floatVarIn:linRight for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs leq:0.f]];
         [linLeft release];
         [linRight release];
      }
   }
   return nil;
}
-(id<ORLinear>) visitExprGThenI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   bool lc = [left isConstant];
   bool rc = [right isConstant];
   if (lc && rc) {
      bool isOk = [left fmin] > [right fmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
      return nil;
   }else {
      ORInt length = !lc + !rc;
      id<ORVarArray> vars = [ORFactory floatVarArray:_model range:RANGE(_model,0,length - 1)];
      id<ORFloatArray> coefs = [ORFactory floatArray:_model
                                               range:RANGE(_model,0,length - 1)
                                                with:^ORFloat(ORInt i) {
                                                   return 1;
                                                }];
      if(lc){
         ORFloatLinear* linright  = [ORNormalizer floatLinearFrom:right model:_model];
         vars[0] = [ORNormalizer floatVarIn:linright for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs lt:[left fmin]]];
         [linright release];
      }else if(rc){
         id<ORFloatLinear> linleft  = [ORNormalizer floatLinearFrom:left model:_model];
         vars[0] = [ORNormalizer floatVarIn:linleft for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs gt:[right fmin]]];
         [linleft release];
      }else{
         id<ORFloatLinear> linleft  = [ORNormalizer floatLinearFrom:left model:_model];
         ORFloatLinear* linright  = [ORNormalizer floatLinearFrom:right model:_model];
         vars[0] = [ORNormalizer floatVarIn:linleft for:_model];
         vars[1] = [ORNormalizer floatVarIn:linright for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs gt:0.f]];
         [linleft release];
         [linright release];
      }
   }
   return nil;
}
-(id<ORLinear>) visitExprLThenI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   bool lc = [left isConstant];
   bool rc = [right isConstant];
   if (lc && rc) {
      bool isOk = [left fmin] < [right fmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   }else {
      ORInt length = !lc + !rc;
      id<ORVarArray> vars = [ORFactory floatVarArray:_model range:RANGE(_model,0,length - 1)];
      id<ORFloatArray> coefs = [ORFactory floatArray:_model
                                               range:RANGE(_model,0,length - 1)
                                                with:^ORFloat(ORInt i) {
                                                   return 1;
                                                }];
      if(lc){
         ORFloatLinear* linright  = [ORNormalizer floatLinearFrom:right model:_model];
         vars[0] = [ORNormalizer floatVarIn:linright for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs gt:[left fmin]]];
         [linright release];
      }else if(rc){
         id<ORFloatLinear> linleft  = [ORNormalizer floatLinearFrom:left model:_model];
         vars[0] = [ORNormalizer floatVarIn:linleft for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs lt:[right fmin]]];
         [linleft release];
      }else{
         id<ORFloatLinear> linleft  = [ORNormalizer floatLinearFrom:left model:_model];
         ORFloatLinear* linright  = [ORNormalizer floatLinearFrom:right model:_model];
         vars[0] = [ORNormalizer floatVarIn:linleft for:_model];
         vars[1] = [ORNormalizer floatVarIn:linright for:_model];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs lt:0.f]];
         [linleft release];
         [linright release];
      }
   }
   return nil;
}

-(id<ORLinear>) visitExprEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   bool lc = [left isConstant];
   bool rc = [right isConstant];
   if (lc && rc) {
      bool isOk = [left fmin] == [right fmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   } else if (lc || rc) {
      ORFloat c = lc ? [left fmin] : [right fmin];
      ORExprI* other = lc ? right : left;
      ORFloatLinear* lin  = [ORNormalizer floatLinearFrom:other model:_model];
      [lin addIndependent: - c];
      return lin;
   } else {
      bool lv = [left isVariable];
      bool rv = [right isVariable];
      if (lv || rv) {
         id<ORFloatLinear> linLeft  = [ORNormalizer floatLinearFrom:left model:_model];
         ORFloatLinear* linRight  = [ORNormalizer floatLinearFrom:right model:_model];
         id<ORVarArray> vars = [ORFactory floatVarArray:_model range:RANGE(_model,0,1)];
         vars[0] = [ORNormalizer floatVarIn:linLeft for:_model];
         vars[1] = [ORNormalizer floatVarIn:linRight for:_model];
         id<ORFloatArray> coefs = [ORFactory floatArray:_model
                                                  range:RANGE(_model,0,1)
                                                   with:^ORFloat(ORInt i) {
                                                      return 1;
                                                   }];
         [_model addConstraint:[ORFactory floatSum:_model array:vars coef:coefs eq:0.f]];
         [linLeft release];
         [linRight release];
      } else {
         //TODO: fix order of sides.
         ORFloatLinear* linLeft = [ORNormalizer floatLinearFrom:left model:_model ];
         ORFloatLinearFlip* linRight = [[ORFloatLinearFlip alloc] initORFloatLinearFlip: linLeft];
         [ORNormalizer addToFloatLinear:linRight from:right model:_model];
         [linRight release];
         return linLeft;
      }
   }
   return nil;
}
-(id<ORLinear>) visitExprNEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   ORFloatLinear* linLeft = [ORNormalizer floatLinearFrom:left model:_model];
   ORFloatLinearFlip* linRight = [[ORFloatLinearFlip alloc] initORFloatLinearFlip: linLeft];
   [ORNormalizer addToFloatLinear:linRight from:right model:_model];
   [linRight release];
   return linLeft;
}
@end



@implementation ORTDoubleHandler
-(id) init
{
   self = [super init:ORTDouble];
   return self;
}

-(void) reifyEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>) rv other:(ORExprI*)theOther constant:(ORExprI*)ce
{
   ORDouble c = [ce dmin];
   id<ORDoubleLinear> linOther  = [ORNormalizer doubleLinearFrom:theOther model:_model];
   id<ORDoubleVar> theVar = [ORNormalizer doubleVarIn:linOther for:_model];
   [_model addConstraint: [ORFactory doubleReify:_model boolean:rv with:theVar eqi:c]];
   [linOther release];
}
-(void) reifyNEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>) rv other:(ORExprI*)theOther constant:(ORExprI*)ce
{
   ORDouble c = [ce dmin];
   id<ORDoubleLinear> linOther  = [ORNormalizer doubleLinearFrom:theOther model:_model];
   id<ORDoubleVar> theVar = [ORNormalizer doubleVarIn:linOther for:_model];
   [_model addConstraint: [ORFactory doubleReify:_model boolean:rv with:theVar neqi:c]];
   [linOther release];
}
-(void) reifyLEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>) rv other:(ORExprI*)theOther constant:(ORExprI*)ce
{
   ORDouble c = [ce dmin];
   id<ORDoubleLinear> linOther  = [ORNormalizer doubleLinearFrom:theOther model:_model];
   id<ORDoubleVar> theVar = [ORNormalizer doubleVarIn:linOther for:_model];
   if ([[theVar domain] up] <= c) {
      [_model addConstraint:[ORFactory equalc:_model var:rv to:1]];
   } else {
      [_model addConstraint: [ORFactory doubleReify:_model boolean:rv with:theVar leqi:c]];
   }
   [linOther release];
}
-(void) reifyGEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>) rv other:(ORExprI*)theOther constant:(ORExprI*)ce
{
   ORDouble c = [ce dmin];
   id<ORDoubleLinear> linOther  = [ORNormalizer doubleLinearFrom:theOther model:_model];
   id<ORDoubleVar> theVar = [ORNormalizer doubleVarIn:linOther for:_model];
   if ([[theVar domain] low] >= c) {
      [_model addConstraint:[ORFactory equalc:_model var:rv to:1]];
   } else {
      [_model addConstraint: [ORFactory doubleReify:_model boolean:rv with:theVar geqi:c]];
   }
   [linOther release];
}
-(void) reifyLTc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>) rv other:(ORExprI*)theOther constant:(ORExprI*)ce
{
   ORDouble c = [ce dmin];
   id<ORDoubleLinear> linOther  = [ORNormalizer doubleLinearFrom:theOther model:_model];
   id<ORDoubleVar> theVar = [ORNormalizer doubleVarIn:linOther for:_model];
   if ([[theVar domain] up] < c) {
      [_model addConstraint:[ORFactory equalc:_model var:rv to:1]];
   } else {
      [_model addConstraint: [ORFactory doubleReify:_model boolean:rv with:theVar lti:c]];
   }
   [linOther release];
}
-(void) reifyGTc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>) rv other:(ORExprI*)theOther constant:(ORExprI*)ce
{
   ORDouble c = [ce dmin];
   id<ORDoubleLinear> linOther  = [ORNormalizer doubleLinearFrom:theOther model:_model];
   id<ORDoubleVar> theVar = [ORNormalizer doubleVarIn:linOther for:_model];
   if ([[theVar domain] low] > c) {
      [_model addConstraint:[ORFactory equalc:_model var:rv to:1]];
   } else {
      [_model addConstraint: [ORFactory doubleReify:_model boolean:rv with:theVar gti:c]];
   }
   [linOther release];
}
-(void) reifyLT:(id<ORAddToModel>)_model boolean:(id<ORIntVar>) rv left:(ORExprI*)left right:(ORExprI*)right
{
   if ([left isConstant]) {
      [self reifyGTc:_model boolean:rv other:right constant:left];
   } else if ([right isConstant]) {
      [self reifyLTc:_model boolean:rv other:left constant:right];
   } else{
      id<ORDoubleLinear> linLeft   = [ORNormalizer doubleLinearFrom:left model:_model];
      id<ORDoubleLinear> linRight  = [ORNormalizer doubleLinearFrom:right model:_model];
      id<ORDoubleVar> varLeft  = [ORNormalizer doubleVarIn:linLeft for:_model];
      id<ORDoubleVar> varRight = [ORNormalizer doubleVarIn:linRight for:_model];
      [_model addConstraint: [ORFactory doubleReify:_model boolean:rv with:varLeft lt:varRight]];
      [linLeft release];
      [linRight release];
   }
}
-(void) reifyGT:(id<ORAddToModel>)_model boolean:(id<ORIntVar>) rv left:(ORExprI*)left right:(ORExprI*) right
{
   if ([left isConstant]) {
      [self reifyLTc:_model boolean:rv other:right constant:left];
   } else if ([right isConstant]) {
      [self reifyGTc:_model boolean:rv other:left constant:right];
   } else{
      id<ORDoubleLinear> linLeft   = [ORNormalizer doubleLinearFrom:left model:_model];
      id<ORDoubleLinear> linRight  = [ORNormalizer doubleLinearFrom:right model:_model];
      id<ORDoubleVar> varLeft  = [ORNormalizer doubleVarIn:linLeft for:_model];
      id<ORDoubleVar> varRight = [ORNormalizer doubleVarIn:linRight for:_model];
      [_model addConstraint: [ORFactory doubleReify:_model boolean:rv with:varLeft gt:varRight]];
      [linLeft release];
      [linRight release];
   }
}
-(void) reifyLEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>) rv left:(ORExprI*)left right:(ORExprI*)right
{
   if ([left isConstant]) {
      [self reifyGEQc:_model boolean:rv other:right constant:left];
   } else if ([right isConstant]) {
      [self reifyLEQc:_model boolean:rv other:left constant:right];
   } else{
      id<ORDoubleLinear> linLeft   = [ORNormalizer doubleLinearFrom:left model:_model];
      id<ORDoubleLinear> linRight  = [ORNormalizer doubleLinearFrom:right model:_model];
      id<ORDoubleVar> varLeft  = [ORNormalizer doubleVarIn:linLeft for:_model];
      id<ORDoubleVar> varRight = [ORNormalizer doubleVarIn:linRight for:_model];
      [_model addConstraint: [ORFactory doubleReify:_model boolean:rv with:varLeft leq:varRight]];
      [linLeft release];
      [linRight release];
   }
}
-(void) reifyGEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>) rv left:(ORExprI*)left right:(ORExprI*) right
{
   ORExprI* newleft  = right;
   ORExprI* newright = left;    // switch side and pretend it is ≤
   if ([newleft isConstant]) {
      [self reifyGEQc:_model boolean:rv other:newright constant:newleft];
   } else if ([newright isConstant]) {
      [self reifyLEQc:_model boolean:rv  other:newleft constant:newright];
   } else
      [self reifyLEQ:_model boolean:rv  left:newleft right:newright];
}

-(void) reifyEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*) right
{
   if ([left isConstant]) {
      [self reifyEQc:_model boolean:rv other:right constant:left];
   } else if ([right isConstant]) {
      [self reifyEQc:_model boolean:rv other:left constant:right];
   } else{
      id<ORDoubleLinear> linLeft   = [ORNormalizer doubleLinearFrom:left model:_model];
      id<ORDoubleLinear> linRight  = [ORNormalizer doubleLinearFrom:right model:_model];
      id<ORDoubleVar> varLeft  = [ORNormalizer doubleVarIn:linLeft for:_model];
      id<ORDoubleVar> varRight = [ORNormalizer doubleVarIn:linRight for:_model];
      [_model addConstraint: [ORFactory doubleReify:_model boolean:rv with:varLeft eq:varRight]];
      [linLeft release];
      [linRight release];
   }
}
-(void) reifyNEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*) right
{
   if ([left isConstant]) {
      [self reifyNEQc:_model boolean:rv other:right constant:left];
   } else if ([right isConstant]) {
      [self reifyNEQc:_model boolean:rv other:left constant:right];
   } else{
      id<ORDoubleLinear> linLeft   = [ORNormalizer doubleLinearFrom:left model:_model];
      id<ORDoubleLinear> linRight  = [ORNormalizer doubleLinearFrom:right model:_model];
      id<ORDoubleVar> varLeft  = [ORNormalizer doubleVarIn:linLeft for:_model];
      id<ORDoubleVar> varRight = [ORNormalizer doubleVarIn:linRight for:_model];
      [_model addConstraint: [ORFactory doubleReify:_model boolean:rv with:varLeft neq:varRight]];
      [linLeft release];
      [linRight release];
   }
}
-(id<ORLinear>) visitExprGEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   bool lc = [left isConstant];
   bool rc = [right isConstant];
   if (lc && rc) {
      bool isOk = [left dmin] >= [right dmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   }else {
      ORInt length = !lc + !rc;
      id<ORVarArray> vars = [ORFactory doubleVarArray:_model range:RANGE(_model,0,length - 1)];
      id<ORDoubleArray> coefs = [ORFactory doubleArray:_model
                                               range:RANGE(_model,0,length - 1)
                                                with:^ORDouble(ORInt i) {
                                                   return 1;
                                                }];
      if(lc){
         ORDoubleLinear* linRight  = [ORNormalizer doubleLinearFrom:right model:_model];
         vars[0] = [ORNormalizer doubleVarIn:linRight for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs leq:[left dmin]]];
         [linRight release];
      }else if(rc){
         id<ORDoubleLinear> linLeft  = [ORNormalizer doubleLinearFrom:left model:_model];
         vars[0] = [ORNormalizer doubleVarIn:linLeft for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs geq:[right dmin]]];
         [linLeft release];
      }else{
         id<ORDoubleLinear> linLeft  = [ORNormalizer doubleLinearFrom:left model:_model];
         ORDoubleLinear* linRight  = [ORNormalizer doubleLinearFrom:right model:_model];
         vars[0] = [ORNormalizer doubleVarIn:linLeft for:_model];
         vars[1] = [ORNormalizer doubleVarIn:linRight for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs geq:0.f]];
         [linLeft release];
         [linRight release];
      }
   }
   return nil;
}
-(id<ORLinear>) visitExprLEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   bool lc = [left isConstant];
   bool rc = [right isConstant];
   if (lc && rc) {
      bool isOk = [left dmin] <= [right dmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   }else {
      ORInt length = !lc + !rc;
      id<ORVarArray> vars = [ORFactory doubleVarArray:_model range:RANGE(_model,0,length - 1)];
      id<ORDoubleArray> coefs = [ORFactory doubleArray:_model
                                               range:RANGE(_model,0,length - 1)
                                                with:^ORDouble(ORInt i) {
                                                   return 1;
                                                }];
      if(lc){
         ORDoubleLinear* linRight  = [ORNormalizer doubleLinearFrom:right model:_model];
         vars[0] = [ORNormalizer doubleVarIn:linRight for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs geq:[left dmin]]];
         [linRight release];
      }else if(rc){
         id<ORDoubleLinear> linLeft  = [ORNormalizer doubleLinearFrom:left model:_model];
         vars[0] = [ORNormalizer doubleVarIn:linLeft for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs leq:[right dmin]]];
         [linLeft release];
      }else{
         id<ORDoubleLinear> linLeft  = [ORNormalizer doubleLinearFrom:left model:_model];
         ORDoubleLinear* linRight  = [ORNormalizer doubleLinearFrom:right model:_model];
         vars[0] = [ORNormalizer doubleVarIn:linLeft for:_model];
         vars[1] = [ORNormalizer doubleVarIn:linRight for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs leq:0.f]];
         [linLeft release];
         [linRight release];
      }
   }
   return nil;
}
-(id<ORLinear>) visitExprGThenI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   bool lc = [left isConstant];
   bool rc = [right isConstant];
   if (lc && rc) {
      bool isOk = [left dmin] > [right dmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
      return nil;
   }else {
      ORInt length = !lc + !rc;
      id<ORVarArray> vars = [ORFactory doubleVarArray:_model range:RANGE(_model,0,length - 1)];
      id<ORDoubleArray> coefs = [ORFactory doubleArray:_model
                                               range:RANGE(_model,0,length - 1)
                                                with:^ORDouble(ORInt i) {
                                                   return 1;
                                                }];
      if(lc){
         ORDoubleLinear* linright  = [ORNormalizer doubleLinearFrom:right model:_model];
         vars[0] = [ORNormalizer doubleVarIn:linright for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs lt:[left dmin]]];
         [linright release];
      }else if(rc){
         id<ORDoubleLinear> linleft  = [ORNormalizer doubleLinearFrom:left model:_model];
         vars[0] = [ORNormalizer doubleVarIn:linleft for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs gt:[right dmin]]];
         [linleft release];
      }else{
         id<ORDoubleLinear> linleft  = [ORNormalizer doubleLinearFrom:left model:_model];
         ORDoubleLinear* linright  = [ORNormalizer doubleLinearFrom:right model:_model];
         vars[0] = [ORNormalizer doubleVarIn:linleft for:_model];
         vars[1] = [ORNormalizer doubleVarIn:linright for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs gt:0.0]];
         [linleft release];
         [linright release];
      }
   }
   return nil;
}
-(id<ORLinear>) visitExprLThenI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   bool lc = [left isConstant];
   bool rc = [right isConstant];
   if (lc && rc) {
      bool isOk = [left dmin] < [right dmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   }else {
      ORInt length = !lc + !rc;
      id<ORVarArray> vars = [ORFactory doubleVarArray:_model range:RANGE(_model,0,length - 1)];
      id<ORDoubleArray> coefs = [ORFactory doubleArray:_model
                                               range:RANGE(_model,0,length - 1)
                                                with:^ORDouble(ORInt i) {
                                                   return 1;
                                                }];
      if(lc){
         ORDoubleLinear* linright  = [ORNormalizer doubleLinearFrom:right model:_model];
         vars[0] = [ORNormalizer doubleVarIn:linright for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs gt:[left dmin]]];
         [linright release];
      }else if(rc){
         id<ORDoubleLinear> linleft  = [ORNormalizer doubleLinearFrom:left model:_model];
         vars[0] = [ORNormalizer doubleVarIn:linleft for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs lt:[right dmin]]];
         [linleft release];
      }else{
         id<ORDoubleLinear> linleft  = [ORNormalizer doubleLinearFrom:left model:_model];
         ORDoubleLinear* linright  = [ORNormalizer doubleLinearFrom:right model:_model];
         vars[0] = [ORNormalizer doubleVarIn:linleft for:_model];
         vars[1] = [ORNormalizer doubleVarIn:linright for:_model];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs lt:0.0]];
         [linleft release];
         [linright release];
      }
   }
   return nil;
}

-(id<ORLinear>) visitExprEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   bool lc = [left isConstant];
   bool rc = [right isConstant];
   if (lc && rc) {
      bool isOk = [left dmin] == [right dmin];
      if (!isOk)
         [_model addConstraint:[ORFactory fail:_model]];
   } else if (lc || rc) {
      ORDouble c = lc ? [left dmin] : [right dmin];
      ORExprI* other = lc ? right : left;
      ORDoubleLinear* lin  = [ORNormalizer doubleLinearFrom:other model:_model];
      [lin addIndependent: - c];
      return lin;
   } else {
      bool lv = [left isVariable];
      bool rv = [right isVariable];
      if (lv || rv) {
         id<ORDoubleLinear> linLeft  = [ORNormalizer doubleLinearFrom:left model:_model];
         ORDoubleLinear* linRight  = [ORNormalizer doubleLinearFrom:right model:_model];
         id<ORVarArray> vars = [ORFactory doubleVarArray:_model range:RANGE(_model,0,1)];
         vars[0] = [ORNormalizer doubleVarIn:linLeft for:_model];
         vars[1] = [ORNormalizer doubleVarIn:linRight for:_model];
         id<ORDoubleArray> coefs = [ORFactory doubleArray:_model
                                                  range:RANGE(_model,0,1)
                                                   with:^ORDouble(ORInt i) {
                                                      return 1;
                                                   }];
         [_model addConstraint:[ORFactory doubleSum:_model array:vars coef:coefs eq:0.0]];
         [linLeft release];
         [linRight release];
      } else {
         //TODO: fix order of sides.
         ORDoubleLinear* linLeft = [ORNormalizer doubleLinearFrom:left model:_model ];
         ORDoubleLinearFlip* linRight = [[ORDoubleLinearFlip alloc] initORDoubleLinearFlip: linLeft];
         [ORNormalizer addToDoubleLinear:linRight from:right model:_model];
         [linRight release];
         return linLeft;
      }
   }
   return nil;
}
-(id<ORLinear>) visitExprNEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right
{
   ORDoubleLinear* linLeft = [ORNormalizer doubleLinearFrom:left model:_model];
   ORDoubleLinearFlip* linRight = [[ORDoubleLinearFlip alloc] initORDoubleLinearFlip: linLeft];
   [ORNormalizer addToDoubleLinear:linRight from:right model:_model];
   [linRight release];
   return linLeft;
}
@end

//------

