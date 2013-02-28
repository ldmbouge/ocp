/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORProgram/CPHeuristic.h>

@interface CPBaseHeuristic : NSObject 
-(void)initHeuristic:(NSMutableArray*)array;
-(void)initInternal:(id<ORVarArray>)t;
@end

@interface CPVirtualHeuristic: NSObject<CPHeuristic> 
-(CPVirtualHeuristic*)initWithBindings:(id<ORBindingArray>)bindings;
-(ORFloat) varOrdering: (id<ORIntVar>)x;
-(ORFloat) valOrdering: (ORInt) v forVar: (id<ORIntVar>) x;
-(void) initInternal: (id<CPIntVarArray>) t;
-(void) initHeuristic: (NSMutableArray*) array;
-(id<ORIntVarArray>) allIntVars;
-(id<CPCommonProgram>)solver;
@end