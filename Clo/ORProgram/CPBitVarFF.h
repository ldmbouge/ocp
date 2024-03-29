/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPBitVarHeuristic.h"
#import <ORProgram/CPBitVarBaseHeuristic.h>
#import <ORProgram/CPProgram.h>
#import <objcp/CPVar.h>

@interface CPBitVarFF : CPBitVarBaseHeuristic<CPBitVarHeuristic> {
   id<ORVarArray>  _vars;  // Model variables
   id<ORVarArray>   _cvs;  // concrete variables
   id<ORVarArray> _rvars;
   id<CPProgram>     _cp;
}
-(CPBitVarFF*)initCPBitVarFF:(id<CPCommonProgram>)cp restricted:(id<ORVarArray>)rvars;
-(ORDouble)varOrdering:(id<CPBitVar>)x;
-(ORDouble)valOrdering:(ORUInt)v forVar:(id<CPBitVar>)x ;
-(void)initInternal:(id<ORVarArray>)t and:(id<CPVarArray>)cv;
-(id<ORVarArray>)allBitVars;
-(id<CPProgram>)solver;
@end
