/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORIntLinear.h>

@protocol ORModel;
@protocol ORAddToModel;
@protocol ORRealLinear;
@class ORExprI;

@interface ORNormalizer : NSObject
+(id<ORLinear>)normalize:(id<ORExpr>)expr into: (id<ORAddToModel>)model;
// ------- Integer
+(id<ORIntLinear>)intLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model;
+(id<ORIntLinear>)intLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model equalTo:(id<ORIntVar>)x;
+(id<ORIntLinear>)addToIntLinear:(id<ORIntLinear>)terms from:(id<ORExpr>)e  model:(id<ORAddToModel>)model;
+(id<ORIntVar>) intVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr;
+(id<ORIntVar>) intVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr by:(id<ORIntVar>)x;
+(id<ORIntVar>) intVarIn:(id<ORIntLinear>)e for:(id<ORAddToModel>) model;
// ------ Float (double)
+(id<ORRealLinear>)floatLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model;
+(id<ORRealLinear>)floatLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model equalTo:(id<ORRealVar>)x;
+(id<ORRealLinear>)addToFloatLinear:(id<ORRealLinear>)terms from:(id<ORExpr>)e  model:(id<ORAddToModel>)model;
+(id<ORRealVar>) floatVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr;
+(id<ORRealVar>) floatVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr by:(id<ORRealVar>)x;
+(id<ORRealVar>) floatVarIn:(id<ORRealLinear>)e for:(id<ORAddToModel>) model;
@end
