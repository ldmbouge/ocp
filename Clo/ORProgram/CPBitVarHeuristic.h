/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORProgram/CPHeuristic.h>

@protocol ORVarArray;
@protocol CPBitVarArray;
@protocol CPProgram;
@protocol CPBitVar;

@protocol CPBitVarHeuristic <CPHeuristic>
-(ORDouble) varOrdering: (id<CPBitVar>)x;
-(ORDouble) valOrdering: (ORInt) v forVar: (id<CPBitVar>) x;
-(void) initInternal: (id<ORVarArray>) t  and:(id<ORVarArray>)cv;
-(void) initHeuristic: (NSArray*)mvar concrete:(NSArray*)cvar oneSol:(ORBool)oneSol tracker:(id<ORTracker>)cp;
-(void) restart;
-(id<ORBitVarArray>) allBitVars;
-(id<CPProgram>)solver;
@end
