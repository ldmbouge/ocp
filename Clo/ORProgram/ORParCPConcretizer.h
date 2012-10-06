/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORSolver.h>


@interface CPParConcretizerI : NSObject<ORSolverConcretizer>
-(CPConcretizerI*) initCPParConcretizerI: (id<CPSolver>) solver;
-(id<ORIntVar>) intVar: (id<ORIntVar>) v;
-(id<ORFloatVar>) floatVar: (id<ORFloatVar>) v;
-(id<ORIntVar>) affineVar:(id<ORIntVar>) v;
-(id<ORIdArray>) idArray: (id<ORIdArray>) a;
-(id<ORConstraint>) alldifferent: (id<ORAlldifferent>) cstr;
-(id<ORConstraint>) algebraicConstraint: (id<ORAlgebraicConstraint>) cstr;
-(id<ORConstraint>) binPacking: (id<ORBinPacking>) cstr;
@end


