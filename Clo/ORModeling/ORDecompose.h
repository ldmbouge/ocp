/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPTypes.h>
#import <objcp/CPData.h>
#import <objcp/CPConstraintI.h>

@protocol ORModel;

@protocol ORLinear<NSObject>
-(void)setIndependent:(ORInt)idp;
-(void)addIndependent:(ORInt)idp;
-(void)addTerm:(id<ORIntVar>)x by:(ORInt)c;
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
-(ORInt)independent;
-(NSString*)description;
-(id<ORIntVarArray>)scaledViews:(id<ORModel>)model;
-(id<ORIntVar>)oneView:(id<ORModel>)model;
-(ORInt)size;
-(ORInt)min;
-(ORInt)max;
-(void)postEQZ:(id<ORModel>)model note:(ORAnnotation)cons;
-(void)postNEQZ:(id<ORModel>)model note:(ORAnnotation)cons;
-(void)postLEQZ:(id<ORModel>)model note:(ORAnnotation)cons;
@end

@interface ORNormalizer : NSObject<ORVisitor> {
   id<ORLinear>  _terms;
   id<ORModel>   _model;
   ORAnnotation _n;
}
+(ORLinear*)normalize:(id<ORExpr>)expr into: (id<ORModel>)model note:(ORAnnotation)n;
-(id)initORNormalizer:(id<ORModel>) model note:(ORAnnotation)n;
-(void) visitExprEqualI:(ORExprEqualI*)e;
-(void) visitExprNEqualI:(ORExprNotEqualI*)e;
-(void) visitExprLEqualI:(ORExprLEqualI*)e;
-(void) visitIntVar: (id<ORIntVar>) e;
-(void) visitIntegerI: (id<ORInteger>) e;
-(void) visitExprPlusI: (ORExprPlusI*) e;
-(void) visitExprMinusI: (ORExprMinusI*) e;
-(void) visitExprMulI: (ORExprMulI*) e;
-(void) visitExprSumI: (ORExprSumI*) e;
-(void) visitExprAggOrI: (ORExprAggOrI*) e;
-(void) visitExprAbsI:(ORExprAbsI*) e;
-(void) visitExprCstSubI:(ORExprCstSubI*)e;
-(void) visitExprVarSubI:(ORExprVarSubI*)e;
-(void) visitExprDisjunctI:(ORDisjunctI*)e;
-(void) visitExprConjunctI:(ORConjunctI*)e;
-(void) visitExprImplyI:(ORImplyI*)e;
@end