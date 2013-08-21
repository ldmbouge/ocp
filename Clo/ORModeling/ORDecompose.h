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
#import "ORFloatLinear.h"

@protocol ORModel;
@protocol ORAddToModel;
@class ORExprI;

@interface ORNormalizer : NSObject
+(id<ORLinear>)normalize:(id<ORExpr>)expr into: (id<ORAddToModel>)model annotation:(ORAnnotation)n;
// ------- Integer
+(id<ORIntLinear>)intLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model annotation:(ORAnnotation)n;
+(id<ORIntLinear>)intLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model equalTo:(id<ORIntVar>)x annotation:(ORAnnotation)n;
+(id<ORIntLinear>)addToIntLinear:(id<ORIntLinear>)terms from:(id<ORExpr>)e  model:(id<ORAddToModel>)model annotation:(ORAnnotation)n;
+(id<ORIntVar>) intVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr annotation:(ORAnnotation)c;
+(id<ORIntVar>) intVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr by:(id<ORIntVar>)x annotation:(ORAnnotation)c;
+(id<ORIntVar>) intVarIn:(id<ORIntLinear>)e for:(id<ORAddToModel>) model annotation:(ORAnnotation)c;
// ------ Float (double)
+(id<ORFloatLinear>)floatLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model annotation:(ORAnnotation)n;
+(id<ORFloatLinear>)floatLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model equalTo:(id<ORFloatVar>)x annotation:(ORAnnotation)n;
+(id<ORFloatLinear>)addToFloatLinear:(id<ORFloatLinear>)terms from:(id<ORExpr>)e  model:(id<ORAddToModel>)model annotation:(ORAnnotation)n;
+(id<ORFloatVar>) floatVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr annotation:(ORAnnotation)c;
+(id<ORFloatVar>) floatVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr by:(id<ORFloatVar>)x annotation:(ORAnnotation)c;
+(id<ORFloatVar>) floatVarIn:(id<ORFloatLinear>)e for:(id<ORAddToModel>) model annotation:(ORAnnotation)c;
@end



