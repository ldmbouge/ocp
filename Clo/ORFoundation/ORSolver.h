/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORUtilities/ORUtilities.h>
#import <ORFoundation/ORTracker.h>
#import <ORFoundation/OREngine.h>
#import <ORFoundation/ORData.h>


@protocol ORObjectiveValue;
@protocol ORSolutionPool;
@protocol ORSearchObjectiveFunction;

// pvh: to reconsider the solution pool in this interface; not sure I like them here
@protocol ORASolver <NSObject,ORTracker,ORGamma>
-(void)               close;
-(id<OREngine>)       engine;
-(id) concretize: (id) o;
-(id<ORObjectiveValue>) objectiveValue;
-(id<ORSolutionPool>) solutionPool;
-(ORBool)ground;
@end

@protocol ORASearchSolver <ORASolver>
-(id<ORSearchObjectiveFunction>) objective;
@end
