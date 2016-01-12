/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>

@protocol CPIntVarArray;
@protocol CPProgram;
@protocol CPIntVar;

@protocol CPHeuristic <NSObject>
-(ORDouble) varOrdering: (id<CPIntVar>)x;
-(ORDouble) valOrdering: (ORInt) v forVar: (id<CPIntVar>) x;
-(void) initInternal: (id<ORVarArray>) t  with:(id<ORVarArray>)cv;
-(void) initHeuristic: (NSArray*)mvar concrete:(NSArray*)cvar oneSol:(ORBool)oneSol;
-(void) restart;
-(id<ORIntVarArray>) allIntVars;
-(id<CPProgram>)solver;
@end
