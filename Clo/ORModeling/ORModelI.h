/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORModeling/ORModeling.h>

@interface ORModelI : NSObject<ORModel>
-(ORModelI*)              initORModelI;
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
-(id<ORSolution>)solution;
-(void)restore:(id<ORSolution>)s;
-(void) visit: (id<ORVisitor>) visitor;
-(id) copyWithZone:(NSZone*)zone;
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;
@end

@interface ORBatchModel : NSObject<ORAddToModel>
-(ORBatchModel*)init: (ORModelI*) model;
-(void) addVariable: (id<ORVar>) var;
-(void) addObject:(id)object;
-(void) addConstraint: (id<ORConstraint>) cstr;
-(void) minimize: (id<ORIntVar>) x;
-(void) maximize: (id<ORIntVar>) x;
-(id<ORModel>) model;
-(void) trackObject: (id) obj;
-(void) trackVariable: (id) obj;
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
