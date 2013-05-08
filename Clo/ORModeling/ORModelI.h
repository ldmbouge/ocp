/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORModeling/ORModeling.h>

@interface ORTau : NSObject<ORTau>
-(ORTau*) initORTau;
-(void) dealloc;
-(void) set: (id) value forKey: (id) key;
-(id) get: (id) key;
@end


@interface ORModelI : ORModelingObjectI<ORModel,ORAddToModel,NSCopying>
-(ORModelI*)              initORModelI;
-(ORModelI*)              initORModelI:(ORUInt)nb;
-(ORModelI*)              initORModelI:(ORUInt)nb tau: (id<ORTau>) tau;
-(void)                   dealloc;
-(NSString*)              description;
-(void)                   applyOnVar:(void(^)(id<ORObject>))doVar
                          onMutables:(void(^)(id<ORObject>))doMutables
                        onImmutables:(void(^)(id<ORObject>))doImmutables
                       onConstraints:(void(^)(id<ORObject>))doCons
                         onObjective:(void(^)(id<ORObject>))doObjective;
-(id<ORObjectiveFunction>)objective;
-(id<ORIntVarArray>)intVars;
-(NSArray*) variables;
-(NSArray*) constraints;
-(NSArray*) mutables;
-(void) visit: (id<ORVisitor>) visitor;
-(id) copyWithZone:(NSZone*)zone;
-(id<ORVar>) addVariable:(id<ORVar>) var;
-(id) addObject:(id) object;
-(id) addImmutable:(id) object;
-(ORUInt)nbObjects;
-(ORUInt)nbImmutables;
-(id<ORConstraint>) addConstraint:(id<ORConstraint>) cstr;
-(id<ORObjectiveFunction>) minimize:(id<ORExpr>) x;
-(id<ORObjectiveFunction>) maximize:(id<ORExpr>) x;
-(void) setSource:(id<ORModel>)src;
-(id<ORModel>)source;
-(id<ORModel>)flatten;
-(id<ORModel>)rootModel;
-(id)inCache:(id)obj;
-(id)addToCache:(id)obj;
-(id<ORTau>) tau;
@end

@interface ORBatchModel : NSObject<ORAddToModel>
-(ORBatchModel*)init: (id<ORModel>) model source:(id<ORModel>)src;
-(id<ORVar>) addVariable: (id<ORVar>) var;
-(id) addObject:(id)object;
-(id) addImmutable:(id)object;
-(id<ORConstraint>) addConstraint: (id<ORConstraint>) cstr;
-(id<ORObjectiveFunction>) minimizeVar: (id<ORIntVar>) x;
-(id<ORObjectiveFunction>) maximizeVar: (id<ORIntVar>) x;
-(id<ORObjectiveFunction>) minimize: (id<ORExpr>) e;
-(id<ORObjectiveFunction>) maximize: (id<ORExpr>) e;
-(id<ORObjectiveFunction>) minimize: (id<ORVarArray>) var coef: (id<ORFloatArray>) coef;
-(id<ORObjectiveFunction>) maximize: (id<ORVarArray>) var coef: (id<ORFloatArray>) coef;
-(id<ORModel>) model;
-(void) trackObject: (id) obj;
-(id) trackImmutable:(id)obj;
-(void) trackVariable: (id) obj;
@end

@interface ORBatchGroup : NSObject<ORAddToModel>
-(ORBatchGroup*)init: (id<ORAddToModel>) model group:(id<ORGroup>)group;
-(id<ORVar>) addVariable: (id<ORVar>) var;
-(id) addObject:(id)object;
-(id<ORConstraint>) addConstraint: (id<ORConstraint>) cstr;
-(id<ORObjectiveFunction>) minimize: (id<ORExpr>) e;
-(id<ORObjectiveFunction>) maximize: (id<ORExpr>) e;
-(id<ORAddToModel>) model;
-(void) trackObject: (id) obj;
-(void) trackVariable: (id) obj;
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
-(id<ORConstraint>) addConstraint:(id<ORConstraint>)c;
-(ORInt) size;
-(void)enumerateWith:(void(^)(id<ORConstraint>))block;
@end
