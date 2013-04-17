/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <CPUKernel/CPEngine.h>
#import <objcp/CPData.h>

@protocol CPBitVarArray;
@protocol CPProgram;

@protocol CPBitVarHeuristic <NSObject>
-(ORFloat) varOrdering: (id<ORBitVar>)x;
-(ORFloat) valOrdering: (ORInt) v forVar: (id<ORBitVar>) x;
-(void) initInternal: (id<CPBitVarArray>) t;
-(void) initHeuristic: (NSMutableArray*) array oneSol:(BOOL)oneSol;
-(void) restart;
-(id<ORBitVarArray>) allBitVars;
-(id<CPProgram>)solver;
@end
