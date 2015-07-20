/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>

NS_ASSUME_NONNULL_BEGIN

@interface ORFactory (Concretization)
/**
 * @brief The method takes a model and return a concrete program based on a CP technology solver.
 * @param model : an ORModel instance.
 */
+(id<CPProgram>) createCPProgram: (id<ORModel>) model;
+(id<CPProgram>) createCPSemanticProgramDFS: (id<ORModel>) model;
+(id<CPProgram>) createCPSemanticProgram: (id<ORModel>) model with: (Class) ctrlClass;
+(id<CPProgram>) createCPParProgram:(id<ORModel>) model nb:(ORInt) k with: (Class) ctrlClass;
+(id<CPProgram>) createCPProgram: (id<ORModel>) model withRelaxation: (id<ORRelaxation>) relaxation;

// With annotations
+(id<CPProgram>) createCPProgram: (id<ORModel>) model annotation: (id<ORAnnotation>) notes;
+(id<CPProgram>) createCPSemanticProgramDFS: (id<ORModel>) model annotation:(id<ORAnnotation>) notes;
+(id<CPProgram>) createCPSemanticProgram: (id<ORModel>) model annotation:(id<ORAnnotation>)notes with: (Class) ctrlClass;
+(id<CPProgram>) createCPMultiStartProgram: (id<ORModel>) model nb: (ORInt) k annotation:(id<ORAnnotation>) notes;
+(id<CPProgram>) createCPParProgram:(id<ORModel>) model nb:(ORInt) k annotation:(id<ORAnnotation>)notes with: (Class) ctrlClass;
+(id<CPProgram>) createCPProgram: (id<ORModel>) model withRelaxation: (id<ORRelaxation>) relaxation annotation:(id<ORAnnotation>) notes;

// For extensioms
+(void) createCPProgram: (id<ORModel>) model program: (id<CPCommonProgram>) cpprogram annotation:(id<ORAnnotation>)notes;

+(id<CPProgram>) createCPLinearizedProgram: (id<ORModel>)model annotation:(id<ORAnnotation>) notes;


+(id<LPProgram>) createLPProgram: (id<ORModel>) model;
+(id<LPRelaxation>) createLPRelaxation: (id<ORModel>) model;
+(id<MIPProgram>) createMIPProgram: (id<ORModel>) model;
+(id<ORRelaxation>) createLinearRelaxation: (id<ORModel>) model;

+(id<ORSolution>) solution: (id<ORModel>) m solver: (id<ORASolver>) solver;
+(id<ORSolutionPool>) createSolutionPool;
@end

@interface ORLinearRelaxation : NSObject<ORRelaxation>
-(ORLinearRelaxation*) initLinearRelaxation: (id<ORModel>) m;
-(ORFloat) objective;
-(ORFloat) lowerBound: (id<ORVar>) x;
-(ORFloat) upperBound: (id<ORVar>) x;
-(void) updateLowerBound: (id<ORVar>) x with: (ORFloat) f;
-(void) updateUpperBound: (id<ORVar>) x with: (ORFloat) f;
-(void) close;
-(OROutcome) solve;
@end

NS_ASSUME_NONNULL_END

