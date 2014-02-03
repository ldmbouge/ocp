/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>

@class MIPSolverI;
@protocol ORModel;
@protocol ORFloatParam;

@protocol ORMIPSolution <ORSolution>
-(id<ORObjectiveValue>) objectiveValue;
@end

@protocol ORMIPSolutionPool <ORSolutionPool>
-(void) addSolution: (id<ORMIPSolution>) s;
-(void) enumerateWith: (void(^)(id<ORMIPSolution>)) block;
-(id<ORInformer>) solutionAdded;
-(id<ORMIPSolution>) best;
-(void) emptyPool;
@end


@protocol MIPProgram <ORASolver>
-(MIPSolverI*) solver;
-(void) setGamma: (id*) gamma;
-(void) setModelMappings: (id<ORModelMappings>) mappings;
-(id*)  gamma;
-(void) solve;
-(ORFloat) floatValue: (id<ORFloatVar>) v;
-(void) setFloatVar: (id<ORFloatVar>)v value:(ORFloat)val;
-(ORInt) intValue: (id<ORIntVar>) v;
-(void) setIntVar: (id<ORIntVar>)v value:(ORInt)val;
-(ORFloat) paramFloatValue: (id<ORFloatParam>)p;
-(ORFloat) paramFloat: (id<ORFloatParam>)p setValue: (ORFloat)val;
-(id<ORObjectiveValue>) objectiveValue;
-(id<ORMIPSolutionPool>) solutionPool;
-(id<ORMIPSolution>) captureSolution;
@end

