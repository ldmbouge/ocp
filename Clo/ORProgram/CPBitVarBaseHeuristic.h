/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORProgram/CPHeuristic.h>

@interface CPBitVarBaseHeuristic : NSObject<CPHeuristic>
-(ORFloat) varOrdering: (id<ORBitVar>)x;
-(ORFloat) valOrdering: (ORInt) v forVar: (id<ORBitVar>) x;
-(void)initHeuristic:(NSMutableArray*)array oneSol:(ORBool)oneSol;
-(void)initInternal:(id<ORVarArray>)t;
-(void) restart;
-(id<ORBitVarArray>) allBitVars;
-(id<CPProgram>)solver;
-(ORBool)oneSol;
@end

@interface CPBitVarVirtualHeuristic: NSObject<CPHeuristic>
-(CPBitVarVirtualHeuristic*)initWithBindings:(id<ORBindingArray>)bindings;
-(ORFloat) varOrdering: (id<ORBitVar>)x;
-(ORFloat) valOrdering: (ORInt) v forVar: (id<ORBitVar>) x;
-(void) initInternal: (id<CPBitVarArray>) t;
-(void) initHeuristic: (NSMutableArray*) array oneSol:(ORBool)oneSol;
-(void) restart;
-(id<ORBitVarArray>) allBitVars;
-(id<CPProgram>)solver;
@end