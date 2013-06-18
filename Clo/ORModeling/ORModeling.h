/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORConstraint.h>
#import <ORFoundation/ORFactory.h>
#import <ORModeling/ORSolution.h>
#import <ORModeling/ORModelTransformation.h>


@protocol ORModelTransformation;

@protocol ORModel <ORTracker,ORObject,ORBasicModel,NSCoding,NSCopying>
-(NSString*)description;
-(id<ORConstraint>) add: (id<ORConstraint>) cstr;
-(id<ORConstraint>) add: (id<ORConstraint>) cstr annotation:(ORAnnotation)n;
-(void) optimize: (id<ORObjectiveFunction>) o;

-(id<ORObjectiveFunction>) minimizeVar: (id<ORIntVar>) x;
-(id<ORObjectiveFunction>) maximizeVar: (id<ORIntVar>) x;
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
-(id<ORModel>) flatten;
-(id<ORModel>) lpflatten;
-(id<ORModel>) mipflatten;
-(id<ORModel>) copy;
-(void) setSource: (id<ORModel>) src;
-(id<ORModel>) source;
-(id<ORModel>) rootModel;
-(id)inCache:(id)obj;
-(id) addToCache:(id)obj;
-(id)memoize:(id) obj;
-(id<ORModelMappings>) mappings;
-(id<ORTau>) tau;
-(id<ORLambda>) lambda;
@end

@protocol ORAddToModel <ORTracker>
-(id<ORVar>) addVariable:(id<ORVar>) var;
-(id) addMutable:(id) object;
-(id) addImmutable:(id) object;
-(id<ORConstraint>) addConstraint:(id<ORConstraint>) cstr;
-(id<ORTracker>)tracker;
-(id<ORObjectiveFunction>) minimizeVar:(id<ORIntVar>) x;
-(id<ORObjectiveFunction>) maximizeVar:(id<ORIntVar>) x;
-(id<ORObjectiveFunction>) minimize: (id<ORExpr>) e;
-(id<ORObjectiveFunction>) maximize: (id<ORExpr>) e;
-(id<ORObjectiveFunction>) minimize: (id<ORVarArray>) var coef: (id<ORFloatArray>) coef;
-(id<ORObjectiveFunction>) maximize: (id<ORVarArray>) var coef: (id<ORFloatArray>) coef;
@end

@interface ORFactory (ORModeling)
+(id<ORModel>) createModel;
+(id<ORModel>) createModel:(ORUInt)nbo mappings: (id<ORModelMappings>) mappings;
+(id<ORModel>) cloneModel: (id<ORModel>)m;
+(id<ORAddToModel>) createBatchModel: (id<ORModel>) flatModel source:(id<ORModel>)src;
+(id<ORModelTransformation>) createFlattener:(id<ORAddToModel>)into;
+(id<ORModelTransformation>) createLPFlattener:(id<ORAddToModel>)into;
+(id<ORModelTransformation>) createMIPFlattener:(id<ORAddToModel>)into;
+(id<ORModelTransformation>) createLinearizer:(id<ORAddToModel>)into;
+(id<ORSolutionPool>) createSolutionPool;
+(id<ORConstraintSet>) createConstraintSet;
@end

