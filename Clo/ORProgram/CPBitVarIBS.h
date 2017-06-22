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
#import <ORProgram/ORProgram.h>
#import <ORProgram/CPProgram.h>
#import <objcp/CPVar.h>
#import <ORFoundation/ORFactory.h>
#import <ORFoundation/ORSetI.h>


@class CPStatisticsMonitor;

#define ALPHA 8.0L

@interface CPBitVarIBS : CPBitVarBaseHeuristic<CPBitVarHeuristic> {
   id<ORBitVarArray>   _vars;
   id<ORBitVarArray>  _rvars;
   id<CPBitVarArray>  _cvars;
   id<CPCommonProgram>   _cp;
}
-(id)initCPBitVarIBS:(id<CPCommonProgram>)cp restricted:(id<ORVarArray>)rvars;
-(ORDouble)varOrdering:(id<CPBitVar>)x;
-(ORDouble)valOrdering:(ORBool)v forVar:(id<CPBitVar>)x atIndex:(ORUInt)idx;
-(void)initInternal:(id<ORBitVarArray>)t and:(id<CPBitVarArray>)cvs;
-(id<CPBitVarArray>)allBitVars;
-(void)initImpacts;
-(id<CPProgram>)solver;
@end
