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

@protocol CPIntVarArray;
@protocol CPProgram;

@protocol CPHeuristic <NSObject>
-(ORFloat) varOrdering: (id<ORIntVar>)x;
-(ORFloat) valOrdering: (ORInt) v forVar: (id<ORIntVar>) x;
-(void) initInternal: (id<CPIntVarArray>) t;
-(void) initHeuristic: (NSMutableArray*) array oneSol:(BOOL)oneSol;
-(void) restart;
-(id<ORIntVarArray>) allIntVars;
-(id<CPProgram>)solver;
@end
