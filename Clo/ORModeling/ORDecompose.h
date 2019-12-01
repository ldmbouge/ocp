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
+(id<ORFloatLinear>)floatLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model equalTo:(id<ORFloatVar>)x;
+(id<ORFloatLinear>)floatLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model setTo:(id<ORFloatVar>)x;
+(id<ORFloatLinear>)addToFloatLinear:(id<ORFloatLinear>)terms from:(id<ORExpr>)e  model:(id<ORAddToModel>)model;
+(id<ORFloatVar>) floatVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr;
+(id<ORFloatVar>) floatVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr by:(id<ORFloatVar>)x;
+(id<ORFloatVar>) floatVarIn:(id<ORFloatLinear>)e for:(id<ORAddToModel>) model;
+(void)floatVar:(id<ORFloatVar>)var equal:(id<ORFloatLinear>)e for:(id<ORAddToModel>) model;
@end


@interface ORNormalizer(Double)
+(id<ORDoubleLinear>)doubleLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model;
+(id<ORDoubleLinear>)doubleLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model equalTo:(id<ORDoubleVar>)x;
+(id<ORDoubleLinear>)doubleLinearFrom:(id<ORExpr>)e  model:(id<ORAddToModel>)model setTo:(id<ORDoubleVar>)x;
+(id<ORDoubleLinear>)addToDoubleLinear:(id<ORDoubleLinear>)terms from:(id<ORExpr>)e  model:(id<ORAddToModel>)model;
+(id<ORDoubleVar>) doubleVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr;
+(id<ORDoubleVar>) doubleVarIn:(id<ORAddToModel>) model expr:(ORExprI*)expr by:(id<ORDoubleVar>)x;
+(id<ORDoubleVar>) doubleVarIn:(id<ORDoubleLinear>)e for:(id<ORAddToModel>) model;
+(void)doubleVar:(id<ORDoubleVar>)var equal:(id<ORDoubleLinear>)e for:(id<ORAddToModel>) model;

@end

@protocol TypeNormalizer <NSObject>
-(ORVType) value;
-(void) reifyEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*)right;
-(void) reifyAssign:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*)right;
-(void) reifyNEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv  left:(ORExprI*)left right:(ORExprI*)right;
-(void) reifyLEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*)right;
-(void) reifyGEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*)right;
-(void) reifyLT:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*)right;
-(void) reifyGT:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*)right;
-(void) reifyEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv other:(ORExprI*)theOther constant:(ORExprI*)c;
-(void) reifyAssignc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv other:(ORExprI*)theOther constant:(ORExprI*)c;
-(void) reifyNEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv other:(ORExprI*)theOther constant:(ORExprI*)c;
-(void) reifyLEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv  other:(ORExprI*)theOther constant:(ORExprI*)c;
-(void) reifyGEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv other:(ORExprI*)theOther constant:(ORExprI*)c;
-(void) reifyLTc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv  other:(ORExprI*)theOther constant:(ORExprI*)c;
-(void) reifyGTc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv other:(ORExprI*)theOther constant:(ORExprI*)c;
-(id<ORLinear>) visitExprGEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right;
-(id<ORLinear>) visitExprLEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right;
-(id<ORLinear>) visitExprGThenI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right;
-(id<ORLinear>) visitExprLThenI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right;
-(id<ORLinear>) visitExprEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right;
-(id<ORLinear>) visitExprAssignI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right;
-(id<ORLinear>) visitExprNEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right;
@end

@interface ORVTypeHandler : NSObject<TypeNormalizer>
{
   ORVType _vtype;
}
-(id) init:(ORVType)vtype;
-(ORVType) value;
-(void) reifyEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*)right;
-(void) reifyAssign:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*)right;
-(void) reifyNEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv  left:(ORExprI*)left right:(ORExprI*)right;
-(void) reifyLEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*)right;
-(void) reifyGEQ:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*)right;
-(void) reifyLT:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*)right;
-(void) reifyGT:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv left:(ORExprI*)left right:(ORExprI*)right;
-(void) reifyEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv other:(ORExprI*)theOther constant:(ORExprI*)c;
-(void) reifyAssignc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv other:(ORExprI*)theOther constant:(ORExprI*)c;
-(void) reifyNEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv other:(ORExprI*)theOther constant:(ORExprI*)c;
-(void) reifyLEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv  other:(ORExprI*)theOther constant:(ORExprI*)c;
-(void) reifyGEQc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv other:(ORExprI*)theOther constant:(ORExprI*)c;
-(void) reifyLTc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv  other:(ORExprI*)theOther constant:(ORExprI*)c;
-(void) reifyGTc:(id<ORAddToModel>)_model boolean:(id<ORIntVar>)rv other:(ORExprI*)theOther constant:(ORExprI*)c;
-(id<ORLinear>) visitExprGEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right;
-(id<ORLinear>) visitExprLEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right;
-(id<ORLinear>) visitExprGThenI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right;
-(id<ORLinear>) visitExprLThenI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right;
-(id<ORLinear>) visitExprEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right;
-(id<ORLinear>) visitExprAssignI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right;
-(id<ORLinear>) visitExprNEqualI:(id<ORAddToModel>)_model left:(ORExprI*)left right:(ORExprI*)right;
@end

@interface ORTIntHandler : ORVTypeHandler<NSObject>
-(id) init;
@end

@interface ORTBoolHandler : ORTIntHandler<NSObject>
-(id) init;
@end

@interface ORTFloatHandler : ORVTypeHandler<NSObject>
-(id) init;
@end

@interface ORTDoubleHandler : ORVTypeHandler<NSObject>
-(id) init;
@end


@interface ORTRealHandler : ORVTypeHandler<NSObject>
-(id) init;
@end

//TODO should have other ORType
static inline ORVTypeHandler* vtype2Obj(ORVType type){
   switch(type){
      case  ORTBool    : return [[ORTBoolHandler alloc] init];
      case  ORTInt     : return [[ORTIntHandler alloc] init];
      case  ORTFloat   : return [[ORTFloatHandler alloc] init];
      case  ORTDouble   : return [[ORTDoubleHandler alloc] init];
      case  ORTReal   : return [[ORTRealHandler alloc] init];
      default         : return [[ORVTypeHandler alloc] init];
   }
}


