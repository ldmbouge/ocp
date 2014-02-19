/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>

@class LSEngineI;
@protocol LSEngine;
@protocol LSConstraint;

@protocol LSProgram<ORGamma>
-(void)label:(id<ORIntVar>)x with:(ORInt)v;

-(ORInt)getVarViolations:(id<ORIntVar>)var;
-(ORInt)violations;
-(ORInt)deltaWhenAssign:(id<ORIntVar>)x to:(ORInt)v;
-(void)selectMax:(id<ORIntRange>)r orderedBy:(ORFloat(^)(ORInt))fun do:(void(^)(ORInt))block;
-(void)selectMin:(id<ORIntRange>)r orderedBy:(ORFloat(^)(ORInt))fun do:(void(^)(ORInt))block;
-(void)solve:(void(^)())block;
-(id<ORSolutionPool>) solutionPool;
-(void)setSource:(id<ORModel>)m;
-(void)setRoot:(id<LSConstraint>)sys;
-(id<LSEngine>)engine;
@end


@interface LSSolver : ORGamma<ORASolver,ORGamma,LSProgram> {
   LSEngineI*              _engine;
   id<ORModel>           _srcModel;
   id<ORSolutionPool>        _pool;
}
-(id)initLSSolver;
-(void)dealloc;
-(void)label:(id<ORIntVar>)x with:(ORInt)v;
-(ORInt)getVarViolations:(id<ORIntVar>)var;
-(ORInt)violations;
-(ORInt)deltaWhenAssign:(id<ORIntVar>)x to:(ORInt)v;
-(void)solve:(void(^)())block;
-(id<ORSolutionPool>) solutionPool;
-(void)setSource:(id<ORModel>)m;
-(id<LSEngine>)engine;
-(void)setRoot:(id<LSConstraint>)sys;
@end


@interface ORFactory (LS)
+(LSSolver*)createLSProgram:(id<ORModel>)m annotation:(id<ORAnnotation>)notes;
@end