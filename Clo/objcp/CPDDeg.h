/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPHeuristic.h>
#import <objcp/CPBaseHeuristic.h>

@interface CPDDeg : CPBaseHeuristic<CPHeuristic> {
   id<ORVarArray>  _vars;
   id<ORVarArray> _rvars;
   ORUInt*          _map; 
   id<CPSolver>      _cp;
   ORULong          _nbv;
   NSSet**           _cv;
}
-(id)initCPDDeg:(id<CPSolver>)cp restricted:(id<ORVarArray>)rvars;
-(float)varOrdering:(id<ORIntVar>)x;
-(float)valOrdering:(int)v forVar:(id<ORIntVar>)x;
-(void)initInternal:(id<ORVarArray>)t;
-(id<ORIntVarArray>)allIntVars;
-(id<CPSolver>)solver;
@end
