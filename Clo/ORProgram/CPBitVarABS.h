/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/CPProgram.h>
#import <ORProgram/CPBitVarHeuristic.h>
#import <ORProgram/CPBitVarBaseHeuristic.h>
#import <objcp/CPVar.h>

@class CPStatisticsMonitor;
@protocol CPBitVarArray;

#define ALPHA 8.0L

@interface CPBitVarABS : CPBitVarBaseHeuristic<CPBitVarHeuristic> {
   id<ORVarArray>   _vars;  // Model variables
   id<CPVarArray>    _cvs;  // concrete variables
   id<ORVarArray>  _rvars;
   id<CPCommonProgram>      _cp;
}
-(id)initCPBitVarABS:(id<CPCommonProgram>)cp restricted:(id<ORVarArray>)rvars;
-(ORDouble)varOrdering:(id<CPBitVar>)x;
-(ORDouble)valOrdering:(ORBool)v atIndex:(ORUInt)idx forVar:(id<CPBitVar>)x;
-(void)initInternal:(id<ORBitVarArray>)t and:(id<CPBitVarArray>)cvs;
-(void) restart;
-(id<CPBitVarArray>)allBitVars;
-(id<CPCommonProgram>)solver;
@end
