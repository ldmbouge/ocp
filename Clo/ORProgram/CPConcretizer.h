/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModeling.h>
//#import <ORProgram/CPSolver.h>

@protocol CPCommonProgram;
@protocol ORAnnotation;

@interface ORCPConcretizer  : ORVisitor<NSObject>
-(ORCPConcretizer*) initORCPConcretizer:(id<CPCommonProgram>) solver
                             annotation:(id<ORAnnotation>)notes;
@end

@interface ORCPSearchConcretizer : ORVisitor<NSObject>
-(ORCPSearchConcretizer*) initORCPConcretizer: (id<CPEngine>) engine
                                        gamma:(id<ORGamma>)gamma;
@end