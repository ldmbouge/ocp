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
@protocol ORFloatLinear;
@protocol ORDoubleLinear;
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

@interface ORNormalizer(Float)
+(id<ORFloatLinear>)floatLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model;
+(id<ORFloatLinear>)addToFloatLinear:(id<ORFloatLinear>)terms from:(id<ORExpr>)e  model:(id<ORAddToModel>)model;
+(id<ORFloatVar>) floatVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr;
+(id<ORFloatVar>) floatVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr by:(id<ORFloatVar>)x;
+(id<ORFloatVar>) floatVarIn:(id<ORFloatLinear>)e for:(id<ORAddToModel>) model;
+(void)floatVar:(id<ORFloatVar>)var equal:(id<ORFloatLinear>)e for:(id<ORAddToModel>) model;
@end


@interface ORNormalizer(Double)
+(id<ORDoubleLinear>)doubleLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model;
+(id<ORDoubleLinear>)addToDoubleLinear:(id<ORDoubleLinear>)terms from:(id<ORExpr>)e  model:(id<ORAddToModel>)model;
+(id<ORDoubleVar>) doubleVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr;
+(id<ORDoubleVar>) doubleVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr by:(id<ORDoubleVar>)x;
+(id<ORDoubleVar>) doubleVarIn:(id<ORDoubleLinear>)e for:(id<ORAddToModel>) model;
+(void)doubleVar:(id<ORDoubleVar>)var equal:(id<ORDoubleLinear>)e for:(id<ORAddToModel>) model;

@end

@interface ORVTypeHandler : NSObject
-(ORVType) value;
+(ORVTypeHandler*) instance;
-(id<ORIntVar>) reifyEQ:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right;
-(id<ORIntVar>) reifyNEQ:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right;
-(id<ORIntVar>) reifyLEQ:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right;
-(id<ORIntVar>) reifyGEQ:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right;
@end

//hzi : use NSNumber work ? 
@interface ORTIntHandler : ORVTypeHandler<NSObject>
+(ORTIntHandler*) instance;
-(id<ORIntVar>) reifyEQc:(id<ORAddToModel>)_model other:(ORExprI*)theOther constant:(ORInt)c;
-(id<ORIntVar>) reifyNEQc:(id<ORAddToModel>)_model other:(ORExprI*)theOther constant:(ORInt)c;
-(id<ORIntVar>) reifyLEQc:(id<ORAddToModel>)_model other:(ORExprI*)theOther constant:(ORInt)c;
-(id<ORIntVar>) reifyGEQc:(id<ORAddToModel>)_model other:(ORExprI*)theOther constant:(ORInt)c;
@end

@interface ORTBoolHandler : ORVTypeHandler<NSObject>
+(ORTBoolHandler*) instance;
@end

@interface ORTFloatHandler : ORVTypeHandler<NSObject>
+(ORTFloatHandler*) instance;
@end

@interface ORTDoubleHandler : ORVTypeHandler<NSObject>
+(ORTDoubleHandler*) instance;
@end



static inline ORVTypeHandler* vtype2Object(ORVType type){
    switch(type){
        case  ORTBool    : return [ORTBoolHandler instance];
        case  ORTInt     : return [ORTIntHandler instance];
        case  ORTFloat   : return [ORTFloatHandler instance];
        default         : return [ORVTypeHandler instance];
    }
}

