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
   NSMutableArray* _vars;
   id<CP>            _cp;
   CPSolverI*    _solver;
   CPUInt       _nbv;
   NSSet**           _cv;
}
-(id)initCPDDeg:(id<CP>)cp;
-(float)varOrdering:(id<CPIntVar>)x;
-(float)valOrdering:(int)v forVar:(id<CPIntVar>)x;
-(void)initHeuristic:(id<CPIntVar>*)t length:(CPInt)len;
-(id<CPIntVarArray>)allIntVars;
@end
