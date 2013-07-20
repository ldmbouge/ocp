/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORProgram/CPHeuristic.h>

@interface CPBaseHeuristic : NSObject<CPHeuristic>
-(ORFloat) varOrdering: (id<CPIntVar>)x;
-(ORFloat) valOrdering: (ORInt) v forVar: (id<ORIntVar>) x;
-(void)initHeuristic:(NSArray*)mvar concrete:(NSArray*)cvar oneSol:(ORBool)oneSol;
-(void)initInternal:(id<ORVarArray>)t and:(id<ORVarArray>)cv;
-(void) restart;
-(id<ORIntVarArray>) allIntVars;
-(id<CPProgram>)solver;
-(ORBool)oneSol;
@end

@interface CPVirtualHeuristic: NSObject<CPHeuristic> 
-(CPVirtualHeuristic*)initWithBindings:(id<ORBindingArray>)bindings;
-(ORFloat) varOrdering: (id<CPIntVar>)x;
-(ORFloat) valOrdering: (ORInt) v forVar: (id<ORIntVar>) x;
-(void) initInternal: (id<CPIntVarArray>) t and:(id<ORVarArray>)cv;
-(void) initHeuristic: (NSArray*)mvar concrete:(NSArray*)cvar oneSol:(ORBool)oneSol;
-(void) restart;
-(id<ORIntVarArray>) allIntVars;
-(id<CPProgram>)solver;
@end