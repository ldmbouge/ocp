/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/CPSolver.h>


@interface ORLPConcretizer  : ORVisitor<NSObject>
-(ORLPConcretizer*) initORLPConcretizer: (id<LPProgram>) solver;
-(void) dealloc;
@end

@interface ORLPRelaxationConcretizer  : ORVisitor<NSObject>
-(ORLPRelaxationConcretizer*) initORLPRelaxationConcretizer: (id<LPRelaxation>) solver;
-(void) dealloc;
@end

