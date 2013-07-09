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
#import "ORLinear.h"

@protocol ORModel;
@protocol ORAddToModel;

@interface ORLinearizer : NSObject<ORVisitor> 
-(id)initORLinearizer:(id<ORLinear>)t model:(id<ORAddToModel>)model annotation:(ORAnnotation)n;
+(ORLinear*)linearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model annotation:(ORAnnotation)n;
+(ORLinear*)linearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model equalTo:(id<ORIntVar>)x annotation:(ORAnnotation)n;
+(ORLinear*)addToLinear:(id<ORLinear>)terms from:(id<ORExpr>)e  model:(id<ORAddToModel>)model annotation:(ORAnnotation)n;
@end

@interface ORNormalizer : NSObject<ORVisitor> {
   id<ORLinear>     _terms;
   id<ORAddToModel>   _model;
   ORAnnotation         _n;
}
+(ORLinear*)normalize:(id<ORExpr>)expr into: (id<ORAddToModel>)model annotation:(ORAnnotation)n;
-(id)initORNormalizer:(id<ORAddToModel>) model annotation:(ORAnnotation)n;
@end


@interface ORSubst   : NSObject<ORVisitor> {
   id<ORIntVar>      _rv;
   id<ORAddToModel> _model;
   ORAnnotation       _c;
}
-(id)initORSubst:(id<ORAddToModel>) model annotation:(ORAnnotation)c;
-(id)initORSubst:(id<ORAddToModel>) model annotation:(ORAnnotation)c by:(id<ORIntVar>)x;
-(id<ORIntVar>)result;
+(id<ORIntVar>) substituteIn:(id<ORAddToModel>) model expr:(ORExprI*)expr annotation:(ORAnnotation)c;
+(id<ORIntVar>) substituteIn:(id<ORAddToModel>) model expr:(ORExprI*)expr by:(id<ORIntVar>)x annotation:(ORAnnotation)c;
+(id<ORIntVar>)normSide:(ORLinear*)e for:(id<ORAddToModel>) model annotation:(ORAnnotation)c;
@end



