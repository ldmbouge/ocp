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
// ------- Bool
+(id<ORIntLinear>)boolLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model;
// ------- Integer
+(id<ORIntLinear>)intLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model;
+(id<ORIntLinear>)intLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model equalTo:(id<ORIntVar>)x;
+(id<ORIntLinear>)addToIntLinear:(id<ORIntLinear>)terms from:(id<ORExpr>)e  model:(id<ORAddToModel>)model;
+(id<ORIntVar>) intVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr;
+(id<ORIntVar>) intVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr by:(id<ORIntVar>)x;
+(id<ORIntVar>) intVarIn:(id<ORIntLinear>)e for:(id<ORAddToModel>) model;
+(void)intVar:(id<ORIntVar>)var equal:(id<ORIntLinear>)e for:(id<ORAddToModel>) model;
// ------ Real
+(id<ORRealLinear>)realLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model;
+(id<ORRealLinear>)realLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model equalTo:(id<ORRealVar>)x;
+(id<ORRealLinear>)addToRealLinear:(id<ORRealLinear>)terms from:(id<ORExpr>)e  model:(id<ORAddToModel>)model;
+(id<ORRealVar>) realVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr;
+(id<ORRealVar>) realVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr by:(id<ORRealVar>)x;
+(id<ORRealVar>) realVarIn:(id<ORRealLinear>)e for:(id<ORAddToModel>) model;
@end
