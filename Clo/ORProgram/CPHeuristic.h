/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPEngine.h>
#import <objcp/CPData.h>

@protocol CPIntVarArray;

@protocol CPHeuristic <NSObject>
-(float) varOrdering: (id<CPIntVar>)x;
-(float) valOrdering: (ORInt) v forVar: (id<CPIntVar>) x;
-(void) initInternal: (id<ORVarArray>)t;
-(void) initHeuristic: (NSMutableArray*)array;
-(id<CPIntVarArray>) allIntVars;
-(id<CPSolver>)solver;
@end
