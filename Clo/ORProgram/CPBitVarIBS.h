/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/CPHeuristic.h>
#import <ORProgram/CPBaseHeuristic.h>
#import <ORProgram/ORProgramFactory.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/CPProgram.h>
#import <objcp/CPVar.h>

@class CPStatisticsMonitor;

#define ALPHA 8.0L

@interface CPBitVarIBS : CPBaseHeuristic<CPHeuristic> {
   id<ORVarArray>   _vars;
   id<ORVarArray>  _rvars;
   id<CPCommonProgram>   _cp;
}
-(id)initCPBitVarIBS:(id<CPCommonProgram>)cp restricted:(id<ORVarArray>)rvars;
-(ORFloat)varOrdering:(id<CPBitVar>)x;
-(ORFloat)valOrdering:(int)v forVar:(id<CPBitVar>)x;
-(void)initInternal:(id<ORVarArray>)t;
-(id<CPBitVarArray>)allBitVars;
-(void)initImpacts;
-(id<CPProgram>)solver;
@end
