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

@protocol ORModelTransformation;

@protocol ORModel <ORTracker,ORObject,NSCoding>
-(NSString*)description;
-(void) add: (id<ORConstraint>) cstr;
-(void) optimize: (id<ORObjectiveFunction>) o;
-(void) minimize: (id<ORIntVar>) x;
-(void) maximize: (id<ORIntVar>) x;
-(void) instantiate: (id<ORSolver>) solver;
-(void) applyOnVar:(void(^)(id<ORObject>))doVar
         onObjects:(void(^)(id<ORObject>))doObjs
     onConstraints:(void(^)(id<ORObject>))doCons
       onObjective:(void(^)(id<ORObject>))ofun;
-(id<ORObjectiveFunction>) objective;
-(NSArray*) variables;
-(NSArray*) constraints;
@end


@interface ORFactory (ORModeling)
+(id<ORModel>) createModel;
+(id<ORModelTransformation>)createFlattener;
+(id<ORModelTransformation>)createLinearizer;
+(id<ORIntVarArray>) binarizeIntVar: (id<ORIntVar>)x tracker: (id<ORTracker>) tracker;
@end