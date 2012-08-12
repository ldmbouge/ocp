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

@class CPEngineI;
// pvh: heuristics should use the solver and it should make the informer available
// pvh: This is too low level

@interface CPWDeg : CPBaseHeuristic<CPHeuristic> {
   id<CPVarArray>   _vars;
   id<CPVarArray>  _rvars;
   ORUInt*           _map; 
   id<CPSolver>             _cp;
   CPEngineI*     _solver;
   ORULong           _nbc;
   ORULong           _nbv;
   ORUInt*             _w;
   NSSet**            _cv;
   id*              _vOfC;
}
-(CPWDeg*)initCPWDeg:(id<CPSolver>)cp restricted:(id<CPVarArray>)rvars;
-(float)varOrdering:(id<ORIntVar>)x;
-(float)valOrdering:(int)v forVar:(id<ORIntVar>)x ;
-(void)initInternal:(id<CPVarArray>)t;
-(id<ORIntVarArray>)allIntVars;
@end
