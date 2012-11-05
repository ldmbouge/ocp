/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORProgram/CPProgram.h>
#import <ORProgram/CPHeuristic.h>
#import <ORProgram/CPBaseHeuristic.h>

@class CPStatisticsMonitor;
@protocol CPIntVarArray;

#define ALPHA 8.0L

@interface CPABS : CPBaseHeuristic<CPHeuristic> {
   id<ORVarArray>   _vars;
   id<ORVarArray>  _rvars;
   id<CPProgram>      _cp;
}
-(id)initCPABS:(id<CPProgram>)cp restricted:(id<ORVarArray>)rvars;
-(float)varOrdering:(id<CPIntVar>)x;
-(float)valOrdering:(int)v forVar:(id<CPIntVar>)x;
-(void)initInternal:(id<ORVarArray>)t;
-(id<CPIntVarArray>)allIntVars;
-(id<CPProgram>)solver;
@end
