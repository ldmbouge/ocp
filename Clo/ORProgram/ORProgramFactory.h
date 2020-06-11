/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORModeling/ORModeling.h>

@protocol CPProgram;
@protocol CPCommonProgram;
@protocol LPProgram;
@protocol MIPProgram;
@protocol LPRelaxation;

PORTABLE_BEGIN

@interface ORFactory (Concretization)
/**
 * @brief The method takes a model and return a concrete program based on a CP technology solver.
 * @param model : an ORModel instance.
 */
+(id<CPProgram>) createCPProgram: (id<ORModel>) model;
+(id<CPProgram>) createCPMDDProgram: (id<ORModel>) model;
+(id<CPProgram>) createCPProgramBackjumpingDFS: (id<ORModel>) model;
+(id<CPProgram>) createCPSemanticProgramDFS: (id<ORModel>) model;
+(id<CPProgram>) createCPSemanticProgram: (id<ORModel>) model with: (id<ORSearchController>) ctrlProto;
+(id<CPProgram>) createCPParProgram:(id<ORModel>) model nb:(ORInt) k with: (id<ORSearchController>) ctrlProto;
+(id<CPProgram>) createCPProgram: (id<ORModel>) model withRelaxation: (id<ORRelaxation>) relaxation;

// With annotations
+(id<CPProgram>) createCPProgram: (id<ORModel>) model annotation: (id<ORAnnotation>) notes;
+(id<CPProgram>) createCPMDDProgram: (id<ORModel>) model annotation: (id<ORAnnotation>) notes;
+(id<CPProgram>) createCPAltMDDProgram: (id<ORModel>) model annotation: (id<ORAnnotation>) notes;
+(id<CPProgram>) createCPSemanticProgramDFS: (id<ORModel>) model annotation:(id<ORAnnotation>) notes;
+(id<CPProgram>) createCPSemanticProgram: (id<ORModel>) model annotation:(id<ORAnnotation>)notes with: (id<ORSearchController>) ctrlProto;
+(id<CPProgram>) createCPMultiStartProgram: (id<ORModel>) model nb: (ORInt) k annotation:(id<ORAnnotation>) notes;
+(id<CPProgram>) createCPParProgram:(id<ORModel>) model nb:(ORInt) k annotation:(id<ORAnnotation>)notes with: (id<ORSearchController>) ctrlProto;
+(id<CPProgram>) createCPProgram: (id<ORModel>) model withRelaxation: (id<ORRelaxation>) relaxation annotation:(id<ORAnnotation>) notes;
+(id<CPProgram>) createCPProgram: (id<ORModel>) model
                  withRelaxation: (id<ORRelaxation>) relaxation
                      annotation: (id<ORAnnotation>) notes
                            with: (id<ORSearchController>) ctrlProto;

// For extensions
+(void) createCPProgram: (id<ORModel>) model program: (id<CPCommonProgram>) cpprogram annotation:(id<ORAnnotation>)notes;

+(id<CPProgram>) createCPLinearizedProgram: (id<ORModel>)model annotation:(id<ORAnnotation>) notes;


+(id<LPProgram>) createLPProgram: (id<ORModel>) model;
+(id<LPRelaxation>) createLPRelaxation: (id<ORModel>) model;
+(id<MIPProgram>) createMIPProgram: (id<ORModel>) model;
+(id<ORRelaxation>) createLinearRelaxation: (id<ORModel>) model;

+(id<ORSolution>) solution: (id<ORModel>) m solver: (id<ORASolver>) solver;
+(id<ORSolution>) parameterizedSolution: (id<ORParameterizedModel>) m solver: (id<ORASolver>) solver;
+(id<ORSolutionPool>) createSolutionPool;
+(id<ORModel>)strengthen:(id<ORModel>)m0;
@end

@interface ORLinearRelaxation : ORObject<ORRelaxation>
-(ORLinearRelaxation*) initLinearRelaxation: (id<ORModel>) m;
-(ORDouble) objective;
-(ORDouble) lowerBound: (id<ORVar>) x;
-(ORDouble) upperBound: (id<ORVar>) x;
-(void) updateBounds:(id<ORVar>)var lower:(ORDouble)low  upper:(ORDouble)up;
-(void) updateLowerBound: (id<ORVar>) x with: (ORDouble) f;
-(void) updateUpperBound: (id<ORVar>) x with: (ORDouble) f;
-(void) close;
-(OROutcome) solve;
-(double)reducedCost:(id<ORVar>) x;
-(ORBool)triviallyRoundable:(id<ORVar>)x;
-(ORBool)trivialDownRoundable:(id<ORVar>)var;
-(ORBool)trivialUpRoundable:(id<ORVar>)var;
-(ORInt)nbLocks:(id<ORVar>)var;
-(ORBool)minLockDown:(id<ORVar>)var;
-(ORBool)inBasis:(id<ORVar>) x;
-(id)basis;
-(void)restoreBasis:(id)basis;
@end

@interface ORStrengthening : NSObject
-(id<ORModel>) apply:(id<ORModel>)m;
@end

PORTABLE_END

