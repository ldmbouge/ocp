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
#import <ORModeling/ORLinear.h>
#import <objcp/CPData.h>

@protocol ORModel;
@protocol ORAddToModel;


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


