/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORProgram/CPHeuristic.h>
#import <ORProgram/CPBaseHeuristic.h>
#import <ORProgram/CPProgram.h>
#import <objcp/CPVar.h>

@protocol CPCommonProgram;

@interface CPDDeg : CPBaseHeuristic<CPHeuristic> {
   id<ORVarArray>  _vars;  // Model variables
   id<CPVarArray>   _cvs;  // concrete variables
   id<ORVarArray> _rvars;
   ORUInt*          _map; 
   id<CPCommonProgram>     _cp;
   ORULong          _nbv;
   NSSet* __strong*     _cv;
}
-(id)initCPDDeg:(id<CPCommonProgram>)cp restricted:(id<ORVarArray>)rvars;
-(ORFloat)varOrdering:(id<CPIntVar>)x;
-(ORFloat)valOrdering:(int)v forVar:(id<CPIntVar>)x;
-(void)initInternal:(id<ORVarArray>)t with:(id<ORVarArray>)cvs;
-(id<ORIntVarArray>)allIntVars;
-(id<CPProgram>)solver;
@end
