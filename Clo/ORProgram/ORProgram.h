/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORData.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/CPProgram.h>
#import <ORProgram/LPProgram.h>
#import <ORProgram/ORProgramFactory.h>
#import <ORProgram/ORSolution.h>
#import <ORProgram/CPHeuristic.h>
#import <ORProgram/CPDDeg.h>
#import <ORProgram/CPDeg.h>
#import <ORProgram/CPWDeg.h>
#import <ORProgram/CPIBS.h>
#import <ORProgram/CPABS.h>
#import <ORProgram/CPFirstFail.h>
#import <ORProgram/CPConcretizer.h>
#import <ORProgram/CPMultiStartSolver.h>
#import <ORProgram/CPParallel.h>
#import <ORProgram/ORCPParSolver.h>


@interface ORGamma (Model)
-(void) initialize: (__nonnull id<ORModel>) model;
@end

@protocol ORSTask<NSObject>
-(void)execute;
-(__nonnull id<ORTracker>  __unsafe_unretained)tracker;
@end

void* __nonnull equal(__nonnull id<CPCommonProgram> solver,__nonnull id<ORIntVar> x,ORInt v);
void* __nonnull diff(__nonnull id<CPCommonProgram> solver,__nonnull id<ORIntVar> x,ORInt v);
void* __nonnull firstFail(__nonnull id<CPCommonProgram> solver,__nonnull id<ORIntVarArray> x);
void* __nonnull sequence(__nonnull id<CPCommonProgram> solver,int n,void* __nonnull*__nonnull s);
void* __nonnull alts(__nonnull id<CPCommonProgram> solver,int n,void*__nonnull* __nonnull s);
void* __nonnull whileDo(__nonnull __unsafe_unretained id<CPCommonProgram> solver,
                        bool(^__nonnull cond)(),
                        void* __nonnull (^__nonnull body)());

void* __nonnull forallDo(__nonnull __unsafe_unretained id<CPCommonProgram> solver,
                         __nonnull __unsafe_unretained id<ORIntRange> R,
                         void* __nonnull(^__nonnull body)(SInt)
                         );
void* __nonnull Do(__nonnull __unsafe_unretained id<CPCommonProgram> solver,void(^__nonnull body)());

