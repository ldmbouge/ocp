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

@interface CPBitVarFirstFail : CPBaseHeuristic<CPHeuristic> {
   id<ORVarArray>  _vars;
   id<ORVarArray> _rvars;
   id<CPProgram>     _cp;
}
-(CPBitVarFirstFail*)initCPBitVarFirstFail:(id<CPCommonProgram>)cp restricted:(id<ORVarArray>)rvars;
-(ORFloat)varOrdering:(id<CPBitVar>)x;
-(ORFloat)valOrdering:(int)v forVar:(id<CPBitVar>)x ;
-(void)initInternal:(id<ORVarArray>)t;
-(id<CPVarArray>)allVars;
-(id<CPProgram>)solver;
@end
