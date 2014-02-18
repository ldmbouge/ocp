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

@protocol LSProgram
-(void)label:(id<ORIntVar>)x with:(ORInt)v;

-(ORInt)getVarViolations:(id<ORIntVar>)var;
-(ORInt)violations;
-(ORInt)deltaWhenAssign:(id<ORIntVar>)x to:(ORInt)v;
-(void)selectMax:(id<ORIntRange>)r orderedBy:(ORFloat(^)(ORInt))fun do:(void(^)(ORInt))block;
-(void)selectMin:(id<ORIntRange>)r orderedBy:(ORFloat(^)(ORInt))fun do:(void(^)(ORInt))block;
-(void)solve:(void(^)())block;
-(id<ORSolutionPool>) solutionPool;
@end


@interface LSSolver : ORGamma<ORASolver,ORGamma,LSProgram> {
   LSEngineI*          _engine;
   id<ORSolutionPool>    _pool;
}
-(id)initLSSolver;
-(void)dealloc;
-(void)label:(id<ORIntVar>)x with:(ORInt)v;
-(ORInt)getVarViolations:(id<ORIntVar>)var;
-(ORInt)violations;
-(ORInt)deltaWhenAssign:(id<ORIntVar>)x to:(ORInt)v;
-(void)solve:(void(^)())block;
-(id<ORSolutionPool>) solutionPool;
@end


@interface ORFactory (LS)
+(LSSolver*)createLSProgram:(id<ORModel>)m annotation:(id<ORAnnotation>)notes;
@end