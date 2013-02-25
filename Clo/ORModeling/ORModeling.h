/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORModel.h>
#import <ORModeling/ORSolver.h>
#import <ORModeling/ORSolution.h>
#import <ORModeling/ORModelTransformation.h>


@protocol ORModelTransformation;

@protocol ORModel <ORTracker,ORObject,ORBasicModel,NSCoding,NSCopying>
-(NSString*)description;
-(id<ORConstraint>) add: (id<ORConstraint>) cstr;
-(id<ORConstraint>) add: (id<ORConstraint>) cstr annotation:(ORAnnotation)n;
-(void) optimize: (id<ORObjectiveFunction>) o;
-(void) minimize: (id<ORIntVar>) x;
-(void) maximize: (id<ORIntVar>) x;
-(void) applyOnVar:(void(^)(id<ORObject>))doVar
         onObjects:(void(^)(id<ORObject>))doObjs
     onConstraints:(void(^)(id<ORObject>))doCons
       onObjective:(void(^)(id<ORObject>))ofun;
-(id<ORObjectiveFunction>) objective;
-(id<ORIntVarArray>)intVars;
-(NSArray*) variables;
-(NSArray*) constraints;
-(NSArray*) objects;
-(id<ORSolution>) captureSolution;
-(id<ORSolutionPool>) solutions;
-(id<ORSolution>) bestSolution;
-(void) restore: (id<ORSolution>) s;
@end

@protocol ORAddToModel <ORTracker>
-(void) addVariable:(id<ORVar>) var;
-(void )addObject:(id) object;
-(void) addConstraint:(id<ORConstraint>) cstr;
-(void) minimize:(id<ORIntVar>) x;
-(void) maximize:(id<ORIntVar>) x;
@end

@interface ORFactory (ORModeling)
+(id<ORModel>) createModel;
+(id<ORModel>) cloneModel: (id<ORModel>)m;
+(id<ORAddToModel>) createBatchModel: (id<ORModel>) flatModel;
+(id<ORModelTransformation>) createFlattener;
+(id<ORModelTransformation>) createLPFlattener;
+(id<ORModelTransformation>) createLinearizer;
+(id<ORSolutionPool>) createSolutionPool;
@end

