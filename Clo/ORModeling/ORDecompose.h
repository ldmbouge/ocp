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
#import "ORIntLinear.h"

@protocol ORModel;
@protocol ORAddToModel;

@interface ORNormalizer : NSObject
+(id<ORLinear>)normalize:(id<ORExpr>)expr into: (id<ORAddToModel>)model annotation:(ORAnnotation)n;
+(id<ORIntLinear>)intLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model annotation:(ORAnnotation)n;
+(id<ORIntLinear>)intLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model equalTo:(id<ORIntVar>)x annotation:(ORAnnotation)n;
+(id<ORIntLinear>)addToIntLinear:(id<ORIntLinear>)terms from:(id<ORExpr>)e  model:(id<ORAddToModel>)model annotation:(ORAnnotation)n;
+(id<ORIntVar>) substituteIn:(id<ORAddToModel>) model expr:(ORExprI*)expr annotation:(ORAnnotation)c;
+(id<ORIntVar>) substituteIn:(id<ORAddToModel>) model expr:(ORExprI*)expr by:(id<ORIntVar>)x annotation:(ORAnnotation)c;
+(id<ORIntVar>)normSide:(id<ORIntLinear>)e for:(id<ORAddToModel>) model annotation:(ORAnnotation)c;
@end



