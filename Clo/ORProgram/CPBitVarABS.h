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
#import <objcp/CPBitVar.h>

@class CPStatisticsMonitor;

#define ALPHA 8.0L

@interface CPBitVarABS : CPBaseHeuristic<CPHeuristic> {
   id<ORVarArray>   _vars;
   id<ORVarArray>  _rvars;
   id<CPCommonProgram>      _cp;
}
-(id)initCPBitVarABS:(id<CPCommonProgram>)cp restricted:(id<ORVarArray>)rvars;
-(ORFloat)varOrdering:(id<CPBitVar>)x;
-(ORFloat)valOrdering:(int)v forVar:(id<CPBitVar>)x;
-(void)initInternal:(id<ORVarArray>)t;
-(void) restart;
-(id<ORVarArray>)allBitVars;
-(id<CPCommonProgram>)solver;
@end
