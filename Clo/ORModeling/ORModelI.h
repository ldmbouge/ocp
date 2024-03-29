/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORFoundation/ORParameter.h>

@interface ORModelMappings : NSObject<ORModelMappings>
-(ORModelMappings*) initORModelMappings;
-(void) dealloc;
-(void) setTau: (id<ORTau>) tau;
-(void) setLambda: (id<ORLambda>) lambda;
-(id<ORTau>) tau;
-(id<ORLambda>) lambda;
@end

@interface ORTau : NSObject<ORTau>
-(ORTau*) initORTau;
-(void) dealloc;
-(void) set: (id) value forKey: (id) key;
-(id) get: (id) key;
-(id) copyWithZone: (NSZone*) zone;
@end

@interface ORLambda : NSObject<ORLambda>
-(ORLambda*) initORLambda;
-(void) dealloc;
-(void) set: (id) value forKey: (id) key;
-(id) get: (id) key;
-(id) copyWithZone: (NSZone*) zone;
@end

@interface ORModelI : ORObject<ORModel,ORAddToModel,NSCopying>
-(ORModelI*)              initORModelI;
-(ORModelI*)              initORModelI: (ORUInt) nb mappings: (id<ORModelMappings>) mappings;
-(void)                   dealloc;
-(NSString*)              description;
-(void)                   applyOnVar:(void(^)(id<ORObject>))doVar
                          onMutables:(void(^)(id<ORObject>))doMutables
                        onImmutables:(void(^)(id<ORObject>))doImmutables
                       onConstraints:(void(^)(id<ORObject>))doCons
                         onObjective:(void(^)(id<ORObject>))doObjective;
-(id<ORObjectiveFunction>)objective;
-(id<ORIntVarArray>)intVars;
-(id<ORRealVarArray>)realVars;
-(id<ORBitVarArray>)bitVars;
-(NSArray*) variables;
-(NSArray*) constraints;
-(NSArray*) mutables;
-(void) visit: (ORVisitor*) visitor;
-(id) copyWithZone:(NSZone*)zone;
-(id<ORVar>) addVariable:(id<ORVar>) var;
-(id) addMutable:(id) object;
-(id) addImmutable:(id) object;
-(ORUInt)nbObjects;
-(ORUInt)nbImmutables;
-(id<ORConstraint>) addConstraint:(id<ORConstraint>) cstr;
-(id<ORObjectiveFunction>) minimize:(id<ORExpr>) x;
-(id<ORObjectiveFunction>) maximize:(id<ORExpr>) x;
-(void) setSource:(id<ORModel>)src;
-(id<ORModel>)source;

-(id<ORModel>) relaxConstraints: (NSArray*) cstrs;
-(id<ORModel>) flatten:(id<ORAnnotation>)notes;
-(id<ORModel>) lsflatten:(id<ORAnnotation>)notes;
-(id<ORModel>) lpflatten:(id<ORAnnotation>)notes;
-(id<ORModel>) mipflatten:(id<ORAnnotation>)notes;

-(id<ORModel>)rootModel;
-(id)inCache:(id)obj;
-(id)addToCache:(id)obj;
-(id<ORModelMappings>) modelMappings;
@end

@interface ORBatchModel : NSObject<ORAddToModel>
-(ORBatchModel*)init: (id<ORModel>) model source:(id<ORModel>)src annotation:(id<ORAnnotation>)notes;
-(id<ORVar>) addVariable: (id<ORVar>) var;
-(id) addMutable:(id)object;
-(id) addImmutable:(id)object;
-(id<ORConstraint>) addConstraint: (id<ORConstraint>) cstr;
-(id<ORObjectiveFunction>) minimizeVar: (id<ORVar>) x;
-(id<ORObjectiveFunction>) maximizeVar: (id<ORVar>) x;
-(id<ORObjectiveFunction>) minimize: (id<ORExpr>) e;
-(id<ORObjectiveFunction>) maximize: (id<ORExpr>) e;
-(id<ORObjectiveFunction>) minimize: (id<ORVarArray>) var coef: (id<ORDoubleArray>) coef;
-(id<ORObjectiveFunction>) maximize: (id<ORVarArray>) var coef: (id<ORDoubleArray>) coef;
-(id<ORModel>) model;
-(id)inCache:(id)obj;
-(id)addToCache:(id)obj;
-(id) trackConstraintInGroup:(id)obj;
-(id) trackObjective:(id) obj;
-(id) trackMutable: (id) obj;
-(id) trackImmutable:(id)obj;
-(id) trackVariable: (id) obj;
-(id<ORModelMappings>) modelMappings;
-(void)setCurrent:(id<ORConstraint>)cstr;
@end

@interface ORParameterizedModelI : ORModelI<ORParameterizedModel>
-(ORParameterizedModelI*) initORParamModelI;
-(ORParameterizedModelI*) initORParamModelI: (ORUInt) nb mappings: (id<ORModelMappings>) mappings;
-(ORParameterizedModelI*) initWithModel: (id<ORModel>) src relax: (NSArray*)cstrs;
-(NSArray*) softConstraints;
-(NSArray*) hardConstraints;
-(NSArray*) parameters;
-(id<ORVarArray>) slacks;
-(void) addParameter: (id<ORParameter>)p;
-(id<ORWeightedVar>) parameterization: (id<ORVar>)x;
-(id<ORWeightedVar>) parameterizeVar: (id<ORVar>)x;
@end

@interface ORBatchGroup : NSObject<ORAddToModel>
-(ORBatchGroup*)init: (id<ORAddToModel>) model group:(id<ORGroup>)group;
-(id<ORVar>) addVariable: (id<ORVar>) var;
-(id) addMutable:(id)object;
-(id<ORConstraint>) addConstraint: (id<ORConstraint>) cstr;
-(id<ORObjectiveFunction>) minimize: (id<ORExpr>) e;
-(id<ORObjectiveFunction>) maximize: (id<ORExpr>) e;
-(id<ORAddToModel>) model;
-(id) trackConstraintInGroup:(id)obj;
-(id) trackObjective:(id) obj;
-(id) trackMutable: (id) obj;
-(id) trackVariable: (id) obj;
@end



@interface ORConstraintSetI : NSObject<ORConstraintSet> {
    NSMutableSet* _all;
}
-(id)init;
-(id<ORConstraint>) addConstraint:(id<ORConstraint>)c;
-(ORInt) size;
-(void)enumerateWith:(void(^)(id<ORConstraint>))block;
@end

@interface OROrderedConstraintSetI : NSObject<OROrderedConstraintSet> {
    NSMutableArray* _all;
}
-(id)init;
-(id<ORConstraint>) addConstraint:(id<ORConstraint>)c;
-(ORInt) size;
-(id<ORConstraint>) at:(ORInt)index;
//-(void)enumerateWith:(void(^)(id<ORConstraint>))block;
@end
