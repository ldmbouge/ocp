/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/CPHeuristic.h>
#import <ORProgram/CPBaseHeuristic.h>
#import <ORProgram/ORProgramFactory.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/CPProgram.h>

@class CPStatisticsMonitor;
@protocol CPVarArray;


@interface CPFDS : CPBaseHeuristic<CPHeuristic,ORChoiceHeuristic> {
   id<ORVarArray>      _vars;  // Model variables
   id<CPVarArray>       _cvs;  // concrete variables
   id<ORVarArray>     _rvars;
   id<CPCommonProgram>   _cp;
}
-(id)initCPFDS:(id<CPCommonProgram>)cp restricted:(id<ORVarArray>)rvars;
-(ORDouble)varOrdering:(id<CPIntVar>)x;
-(ORDouble)valOrdering:(int)v forVar:(id<CPIntVar>)x;
-(void)initInternal:(id<ORVarArray>)t with:(id<ORVarArray>)cvs;
-(id<ORIntVarArray>)allIntVars;
-(id<CPProgram>)solver;
-(double)lastChoiceRating;
@end
