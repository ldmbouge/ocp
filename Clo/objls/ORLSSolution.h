/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORSolution.h>
#import <objls/LSSolver.h>

@interface ORLSSolution : ORObject<ORSolution>
-(id) initORLSSolution: (id<ORModel>) model with: (id<LSProgram>) solver;
-(id<ORSnapshot>) value: (id) var;
-(ORInt) intValue: (id<ORIntVar>) var;
-(ORBool) boolValue: (id<ORIntVar>) var;
-(ORFloat) floatValue: (id<ORFloatVar>) var;
-(ORFloat) floatMin: (id<ORFloatVar>) var;
-(ORFloat) floatMax: (id<ORFloatVar>) var;
-(id<ORObjectiveValue>) objectiveValue;
@end
