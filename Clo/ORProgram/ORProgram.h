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
@end

__nonnull id<ORSTask> equal(__nonnull id<CPCommonProgram> solver,__nonnull id<ORIntVar> x,ORInt v);
__nonnull id<ORSTask> diff(__nonnull id<CPCommonProgram> solver,__nonnull id<ORIntVar> x,ORInt v);
__nonnull id<ORSTask> firstFail(__nonnull id<CPCommonProgram> solver,__nonnull id<ORIntVarArray> x);
__nonnull id<ORSTask> sequence(__nonnull id<CPCommonProgram> solver,NSArray* __nonnull s);
void* __nonnull alts(__nonnull id<CPCommonProgram> solver,NSArray* __nonnull s);
void* __nonnull selectAndBranch(__nonnull __unsafe_unretained id<CPCommonProgram> solver,
                                      void* __nullable(^ __nonnull varSel)(),
                                      ORInt(^ __nonnull valSel)(__nonnull id<ORIntVar>),
                                      void* __nonnull(^__nonnull branch)(__nonnull __unsafe_unretained id<ORIntVar>,ORInt));
