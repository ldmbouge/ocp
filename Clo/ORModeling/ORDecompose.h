/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPTypes.h>
#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPData.h>

@protocol ORModel;
@protocol ORAddToModel;

@protocol ORLinear<NSObject>
-(void)setIndependent:(ORInt)idp;
-(void)addIndependent:(ORInt)idp;
-(void)addTerm:(id<ORIntVar>)x by:(ORInt)c;
-(void)addLinear:(id<ORLinear>)lts;
-(void)scaleBy:(ORInt)s;
-(ORInt)size;
-(id<ORIntVar>)var:(ORInt)k;
-(ORInt)coef:(ORInt)k;
-(ORInt)independent;
@end

@interface ORLinear : NSObject<ORLinear> {
   struct CPTerm {
      id<ORIntVar>  _var;
      ORInt        _coef;
   };
   struct CPTerm* _terms;
   ORInt             _nb;
   ORInt            _max;
   ORInt          _indep;
}
-(ORLinear*)initORLinear:(ORInt)mxs;
-(void)dealloc;
-(void)setIndependent:(ORInt)idp;
-(void)addIndependent:(ORInt)idp;
-(void)addTerm:(id<ORIntVar>)x by:(ORInt)c;
-(void)addLinear:(ORLinear*)lts;
-(void)scaleBy:(ORInt)s;
-(ORInt)independent;
-(NSString*)description;
-(id<ORIntVarArray>)scaledViews:(id<ORAddToModel>)model;
-(id<ORIntVar>)oneView:(id<ORAddToModel>)model;
-(ORInt)size;
-(ORInt)min;
-(ORInt)max;
-(void)postEQZ:(id<ORAddToModel>)model annotation:(ORAnnotation)cons;
-(void)postNEQZ:(id<ORAddToModel>)model annotation:(ORAnnotation)cons;
-(void)postLEQZ:(id<ORAddToModel>)model annotation:(ORAnnotation)cons;
@end

@interface ORNormalizer : NSObject<ORVisitor> {
   id<ORLinear>     _terms;
   id<ORAddToModel>   _model;
   ORAnnotation         _n;
}
+(ORLinear*)normalize:(id<ORExpr>)expr into: (id<ORAddToModel>)model annotation:(ORAnnotation)n;
-(id)initORNormalizer:(id<ORAddToModel>) model annotation:(ORAnnotation)n;
-(void) visitExprEqualI:(ORExprEqualI*)e;
-(void) visitExprNEqualI:(ORExprNotEqualI*)e;
-(void) visitExprLEqualI:(ORExprLEqualI*)e;
-(void) visitIntVar: (id<ORIntVar>) e;
-(void) visitIntegerI: (id<ORInteger>) e;
-(void) visitExprPlusI: (ORExprPlusI*) e;
-(void) visitExprMinusI: (ORExprMinusI*) e;
-(void) visitExprMulI: (ORExprMulI*) e;
-(void) visitExprModI: (ORExprModI*) e;
-(void) visitExprSumI: (ORExprSumI*) e;
-(void) visitExprProdI: (ORExprProdI*) e;
-(void) visitExprAggOrI: (ORExprAggOrI*) e;
-(void) visitExprAbsI:(ORExprAbsI*) e;
-(void) visitExprNegateI:(ORExprNegateI*)e;
-(void) visitExprCstSubI:(ORExprCstSubI*)e;
-(void) visitExprVarSubI:(ORExprVarSubI*)e;
-(void) visitExprDisjunctI:(ORDisjunctI*)e;
-(void) visitExprConjunctI:(ORConjunctI*)e;
-(void) visitExprImplyI:(ORImplyI*)e;
@end
