/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORModeling/ORModeling.h>

@interface ORModelI : ORModelingObjectI<ORModel,ORAddToModel,NSCopying>
-(ORModelI*)              initORModelI;
-(ORModelI*)              initORModelI:(ORULong)nb;
-(void)                   dealloc;
-(NSString*)              description;
-(void)                   setId: (ORUInt) name;
-(void)                  captureVariable:(id<ORVar>)x;
-(void)                   applyOnVar:(void(^)(id<ORObject>))doVar
                           onObjects:(void(^)(id<ORObject>))doObjs
                       onConstraints:(void(^)(id<ORObject>))doCons
                         onObjective:(void(^)(id<ORObject>))doObjective;
-(id<ORObjectiveFunction>)objective;
-(id<ORIntVarArray>)intVars;
-(NSArray*) variables;
-(NSArray*) constraints;
-(NSArray*) objects;
-(NSDictionary*) cMap;
-(NSSet*) constraintsFor:(id<ORConstraint>)c;
-(void) mappedConstraints:(id<ORConstraint>)c toSet:(NSSet*)soc;
-(id<ORSolution>) captureSolution;
-(void)restore:(id<ORSolution>)s;
-(void) visit: (id<ORVisitor>) visitor;
-(id) copyWithZone:(NSZone*)zone;
-(void) addVariable:(id<ORVar>) var;
-(void) addObject:(id) object;
-(void) addConstraint:(id<ORConstraint>) cstr;
-(id<ORObjectiveFunction>) minimize:(id<ORExpr>) x;
-(id<ORObjectiveFunction>) maximize:(id<ORExpr>) x;
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;
-(void) setSource:(id<ORModel>)src;
-(id<ORModel>)original;
-(id<ORModel>)source;
-(id<ORModel>)flatten;
-(id<ORModel>)rootModel;
-(void)map:(id)key toObject:(id)object;
-(id)lookup:(id)key;
@end

@interface ORBatchModel : NSObject<ORAddToModel>
-(ORBatchModel*)init: (id<ORModel>) model source:(id<ORModel>)src;
-(void) addVariable: (id<ORVar>) var;
-(void) addObject:(id)object;
-(void) addConstraint: (id<ORConstraint>) cstr;
-(id<ORObjectiveFunction>) minimizeVar: (id<ORIntVar>) x;
-(id<ORObjectiveFunction>) maximizeVar: (id<ORIntVar>) x;
-(id<ORObjectiveFunction>) minimize: (id<ORExpr>) e;
-(id<ORObjectiveFunction>) maximize: (id<ORExpr>) e;
-(id<ORObjectiveFunction>) minimize: (id<ORIntVarArray>) var coef: (id<ORIntArray>) coef;
-(id<ORObjectiveFunction>) maximize: (id<ORIntVarArray>) var coef: (id<ORIntArray>) coef;
-(id<ORModel>) model;
-(void) trackObject: (id) obj;
-(void) trackVariable: (id) obj;
-(void) compiling:(id<ORConstraint>)cstr;
-(NSSet*)compiledMap;
@end

@interface ORBatchGroup : NSObject<ORAddToModel>
-(ORBatchGroup*)init: (id<ORAddToModel>) model group:(id<ORGroup>)group;
-(void) addVariable: (id<ORVar>) var;
-(void) addObject:(id)object;
-(void) addConstraint: (id<ORConstraint>) cstr;
//-(id<ORObjectiveFunction>) minimize: (id<ORIntVar>) x;
//-(id<ORObjectiveFunction>) maximize: (id<ORIntVar>) x;
-(id<ORObjectiveFunction>) minimize: (id<ORExpr>) e;
-(id<ORObjectiveFunction>) maximize: (id<ORExpr>) e;
-(id<ORAddToModel>) model;
-(void) trackObject: (id) obj;
-(void) trackVariable: (id) obj;
-(void) compiling:(id<ORConstraint>)cstr;
@end

@interface ORSolutionI : NSObject<ORSolution>
-(ORSolutionI*) initSolution: (id<ORModel>) model;
-(ORInt) intValue: (id) var;
-(BOOL) boolValue: (id) var;
-(id<ORSnapshot>) value:(id)var;
-(NSUInteger) count;
-(BOOL)isEqual:(id)object;
-(NSUInteger)hash;
-(id<ORObjectiveValue>)objectiveValue;
@end

@interface ORSolutionPoolI : NSObject<ORSolutionPool> {
    NSMutableSet* _all;
    id<ORSolutionInformer> _solutionAddedInformer;
}
-(id)init;
-(void)addSolution:(id<ORSolution>)s;
-(void)enumerateWith:(void(^)(id<ORSolution>))block;
-(id<ORInformer>)solutionAdded;
-(id<ORSolution>)best;
@end

@interface ORConstraintSetI : NSObject<ORConstraintSet> {
    NSMutableSet* _all;
}
-(id)init;
-(void)addConstraint:(id<ORConstraint>)c;
-(ORInt) size;
-(void)enumerateWith:(void(^)(id<ORConstraint>))block;
@end
