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

@class CPMonitor;

#define ALPHA 8.0L

@interface CPIBS : CPBaseHeuristic<CPHeuristic> {
   id<CPVarArray>   _vars;
   id<CP>             _cp;
   CPSolverI*     _solver;
   CPMonitor*    _monitor;
   CPUInt            _nbv;
   NSMutableDictionary*  _impacts;
}
-(id)initCPIBS:(id<CP>)cp;
-(float)varOrdering:(id<CPIntVar>)x;
-(float)valOrdering:(int)v forVar:(id<CPIntVar>)x;
-(void)initInternal:(id<CPVarArray>)t;
-(id<CPIntVarArray>)allIntVars;
-(void)initImpacts;
@end
