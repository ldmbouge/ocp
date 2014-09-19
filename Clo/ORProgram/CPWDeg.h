/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORProgram/CPHeuristic.h>
#import <ORProgram/CPBaseHeuristic.h>
#import <ORProgram/CPProgram.h>
#import <objcp/CPVar.h>

@class CPEngineI;
// pvh: heuristics should use the solver and it should make the informer available
// pvh: This is too low level

@interface CPWDeg : CPBaseHeuristic<CPHeuristic>
-(CPWDeg*)initCPWDeg:(id<CPCommonProgram>)cp restricted:(id<ORVarArray>)rvars;
-(ORFloat)varOrdering:(id<CPIntVar>)x;
-(ORFloat)valOrdering:(int)v forVar:(id<CPIntVar>)x ;
-(void)initInternal:(id<ORVarArray>)t with:(id<ORVarArray>)cvs;
-(id<CPIntVarArray>)allIntVars;
-(id<CPProgram>)solver;
@end
