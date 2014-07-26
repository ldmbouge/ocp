/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>

@class LSEngineI;
@protocol LSEngine;
@protocol LSConstraint;

@protocol LSProgram<ORGamma,ORTracker>
-(void)setHard:(NSArray*)hardCstrs;
-(void)setModelHard:(NSArray*)hardCstrs;
-(id<NSFastEnumeration>)modelHard;
-(id<ORSearchObjectiveFunction>) objective;

-(void)label:(id<ORIntVar>)x with:(ORInt)v;
-(void)swap:(id<ORIntVar>)x with:(id<ORIntVar>)y;

-(ORBool)isTrue;

-(ORInt)getViolations;
-(ORInt)getWeightedViolations;
-(ORInt)getUnweightedViolations;

-(ORInt)getVarViolations:(id<ORIntVar>)var;
-(ORInt)getVarWeightedViolations:(id<ORIntVar>)var;
-(ORInt)getVarUnweightedViolations:(id<ORIntVar>)var;

-(ORInt)getCstrViolations:(id<ORConstraint>)cstr;
-(ORInt)getVarViolations:(id<ORIntVar>)var forConstraint:(id<ORConstraint>)c;

-(ORInt)deltaWhenAssign:(id<ORIntVar>)x to:(ORInt)v;
-(ORInt)deltaWhenSwap:(id<ORIntVar>)x with:(id<ORIntVar>)y;
-(ORInt)deltaWhenAssign:(id<ORIntVar>)x to:(ORInt)v inConstraint:(id<ORConstraint>)c;
-(ORInt)weightedDeltaWhenAssign:(id<ORIntVar>)x to:(ORInt)v;
-(ORInt)unweightedDeltaWhenAssign:(id<ORIntVar>)x to:(ORInt)v;
-(ORBool)legalSwap:(id<ORIntVar>)x with:(id<ORIntVar>)y;

-(void)selectMax:(id<ORIntRange>)r orderedBy:(ORFloat(^)(ORInt))fun do:(void(^)(ORInt))block;
-(void)selectMin:(id<ORIntRange>)r orderedBy:(ORFloat(^)(ORInt))fun do:(void(^)(ORInt))block;
-(void)selectMax:(id<ORIntRange>)r suchThat:(ORBool(^)(ORInt))filter orderedBy:(ORFloat(^)(ORInt))fun do:(void(^)(ORInt))block;
-(void)selectMin:(id<ORIntRange>)r suchThat:(ORBool(^)(ORInt))filter orderedBy:(ORFloat(^)(ORInt))fun do:(void(^)(ORInt))block;
-(void)selectRandom:(id<ORIntRange>)r suchThat:(ORBool(^)(ORInt))filter do:(void(^)(ORInt))block;
-(void)sweep:(id<ORSelector>)sel with:(ORClosure)block;
-(void)solve:(ORClosure)block;

-(id<ORSolutionPool>) solutionPool;
-(id<ORSolution>)saveSolution;
-(void)setSource:(id<ORModel>)m;
-(void)setRoot:(id<LSConstraint>)sys;
-(id<LSEngine>)engine;

// accessors
-(ORInt)intValue:(id<ORIntVar>)x;

// Lagrangian multiplier
-(void) updateMultipliers;
-(void) resetMultipliers;
@end


@interface LSSolver : ORGamma<ORASolver,ORGamma,LSProgram> {
   LSEngineI*              _engine;
   id<ORModel>           _srcModel;
   id<ORSolutionPool>        _pool;
}
-(id)initLSSolver;
-(void)dealloc;
@end


@interface ORFactory (LS)
+(LSSolver*)createLSProgram:(id<ORModel>)m annotation:(id<ORAnnotation>)notes;
@end