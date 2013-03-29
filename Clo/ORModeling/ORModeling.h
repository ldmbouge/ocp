/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORModel.h>
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
         onObjects:(void(^)(id<ORObject>))doObjs
     onConstraints:(void(^)(id<ORObject>))doCons
       onObjective:(void(^)(id<ORObject>))ofun;
-(id<ORObjectiveFunction>) objective;
-(id<ORIntVarArray>)intVars;
-(NSArray*) variables;
-(NSArray*) constraints;
-(NSArray*) objects;
-(NSDictionary*) cMap;
-(id<ORSolution>) captureSolution;
-(id<ORSolutionPool>) solutions;
-(id<ORSolution>) bestSolution;
-(void) restore: (id<ORSolution>) s;
-(id<ORModel>)flatten;
-(id<ORModel>)copy;
-(void) setSource:(id<ORModel>)src;
-(id<ORModel>)source;
-(id<ORModel>)rootModel;
-(void)map:(id)key toObject:(id)object;
-(id)lookup:(id)key;
@end

@protocol ORAddToModel <ORTracker>
-(void) addVariable:(id<ORVar>) var;
-(void )addObject:(id) object;
-(id<ORConstraint>) addConstraint:(id<ORConstraint>) cstr;

-(id<ORObjectiveFunction>) minimizeVar:(id<ORIntVar>) x;
-(id<ORObjectiveFunction>) maximizeVar:(id<ORIntVar>) x;
-(id<ORObjectiveFunction>) minimize: (id<ORExpr>) e;
-(id<ORObjectiveFunction>) maximize: (id<ORExpr>) e;
-(id<ORObjectiveFunction>) minimize: (id<ORVarArray>) var coef: (id<ORFloatArray>) coef;
-(id<ORObjectiveFunction>) maximize: (id<ORVarArray>) var coef: (id<ORFloatArray>) coef;
-(void) compiling:(id<ORConstraint>)cstr;
-(NSSet*)compiledMap;

@end

@interface ORFactory (ORModeling)
+(id<ORModel>) createModel;
+(id<ORModel>) cloneModel: (id<ORModel>)m;
+(id<ORAddToModel>) createBatchModel: (id<ORModel>) flatModel source:(id<ORModel>)src;
+(id<ORModelTransformation>) createFlattener;
+(id<ORModelTransformation>) createLPFlattener;
+(id<ORModelTransformation>) createMIPFlattener;
+(id<ORModelTransformation>) createLinearizer;
+(id<ORSolutionPool>) createSolutionPool;
+(id<ORConstraintSet>) createConstraintSet;
@end

