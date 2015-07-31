/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORConstraint.h>
#import <ORFoundation/ORFactory.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORModeling/ORFlatten.h>
#import <ORModeling/ORLPFlatten.h>
#import <ORModeling/ORMIPFlatten.h>
#import <ORModeling/ORLSFlatten.h>
#import <ORModeling/ORLinear.h>
#import <ORModeling/ORIntLinear.h>
#import <ORModeling/ORLinearize.h>
#import <ORModeling/ORMIPLinearize.h>

@protocol ORModelTransformation;

NS_ASSUME_NONNULL_BEGIN

@protocol ORModel <ORTracker,ORObject,ORBasicModel,NSCoding,NSCopying>
-(NSString*)description;
-(void) addVariable: (id<ORVar>) x;
-(id<ORConstraint>) add: (id<ORConstraint>) cstr;
-(void) optimize: (id<ORObjectiveFunction>) o;

-(id<ORObjectiveFunction>) minimizeVar: (id<ORVar>) x;
-(id<ORObjectiveFunction>) maximizeVar: (id<ORVar>) x;
-(id<ORObjectiveFunction>) minimize: (id<ORExpr>) e;
-(id<ORObjectiveFunction>) maximize: (id<ORExpr>) e;
-(id<ORObjectiveFunction>) minimize: (id<ORVarArray>) var coef: (id<ORFloatArray>) coef;
-(id<ORObjectiveFunction>) maximize: (id<ORVarArray>) var coef: (id<ORFloatArray>) coef;

-(void) applyOnVar:(void(^)(id<ORObject>))doVar
        onMutables:(void(^)(id<ORObject>))doMutables
      onImmutables:(void(^)(id<ORObject>))doImmutables
     onConstraints:(void(^)(id<ORObject>))doCons
       onObjective:(void(^)(id<ORObject>))ofun;
-(id<ORObjectiveFunction>) objective;
-(id<ORIntVarArray>)intVars;
-(ORUInt) nbObjects;
-(NSArray*) variables;
-(NSArray*) constraints;
-(NSArray*) mutables;
-(NSArray*) immutables;
// pvh: this should go
-(id<ORModel>) flatten:(__nullable id<ORAnnotation>)notes;
-(id<ORModel>) lsflatten:(__nullable id<ORAnnotation>)notes;
-(id<ORModel>) lpflatten:(__nullable id<ORAnnotation>)notes;
-(id<ORModel>) mipflatten:(__nullable id<ORAnnotation>)notes;
-(id<ORModel>) copy;
-(void) setSource: (id<ORModel>) src;
-(id<ORModel>) source;
-(id<ORModel>) rootModel;
-(id)inCache:(id)obj;
-(id) addToCache:(id)obj;
-(id)memoize:(id) obj;
-(id<ORModelMappings>) modelMappings;
-(id<ORTau>) tau;
-(id<ORLambda>) lambda;
@end

@protocol ORAddToModel <ORTracker>
-(id<ORVar>) addVariable:(id<ORVar>) var;
-(id) addMutable:(id) object;
-(id) addImmutable:(id) object;
-(id<ORConstraint>) addConstraint:(id<ORConstraint>) cstr;
-(id<ORTracker>)tracker;
-(id<ORObjectiveFunction>) minimizeVar:(id<ORVar>) x;
-(id<ORObjectiveFunction>) maximizeVar:(id<ORVar>) x;
-(id<ORObjectiveFunction>) minimize: (id<ORExpr>) e;
-(id<ORObjectiveFunction>) maximize: (id<ORExpr>) e;
-(id<ORObjectiveFunction>) minimize: (id<ORVarArray>) var coef: (id<ORFloatArray>) coef;
-(id<ORObjectiveFunction>) maximize: (id<ORVarArray>) var coef: (id<ORFloatArray>) coef;
-(id<ORModelMappings>) modelMappings;
-(void)setCurrent:(__nullable id<ORConstraint>)cstr;
@end

@interface ORFactory (ORModeling)
+(id<ORModel>) createModel;
+(id<ORModel>) createModel:(ORUInt)nbo mappings: (__nullable id<ORModelMappings>) mappings;
+(id<ORModel>) cloneModel: (id<ORModel>)m;
+(id<ORAddToModel>) createBatchModel: (id<ORModel>) flatModel source:(id<ORModel>)src annotation:(id<ORAnnotation>)notes;
+(id<ORModelTransformation>) createFlattener:(id<ORAddToModel>)into;
+(id<ORModelTransformation>) createLSFlattener:(id<ORAddToModel>)into;
+(id<ORModelTransformation>) createLPFlattener:(id<ORAddToModel>)into;
+(id<ORModelTransformation>) createMIPFlattener:(id<ORAddToModel>)into;
+(id<ORModelTransformation>) createLinearizer:(id<ORAddToModel>)into;
+(id<ORConstraintSet>) createConstraintSet;
+(id<OROrderedConstraintSet>) orderedConstraintSet: (id<ORTracker>) tracker range: (id<ORIntRange>)range with: (id<ORConstraint>(^)(ORInt index)) block;
@end

NS_ASSUME_NONNULL_END
