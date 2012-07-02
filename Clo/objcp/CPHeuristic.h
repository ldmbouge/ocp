/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPSolver.h>
#import <objcp/CPData.h>
#import <objcp/CPArray.h>

@protocol CPHeuristic <NSObject>
-(float)varOrdering:(id<CPIntVar>)x;
-(float)valOrdering:(int)v forVar:(id<CPIntVar>)x;
-(void)initHeuristic:(id<CPIntVar>*)t length:(CPInt)l;
-(void)initHeuristic:(NSMutableArray*)array;
-(id<CPIntVarArray>)allIntVars;
@end
