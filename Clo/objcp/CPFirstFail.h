/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import "CPHeuristic.h"
#import "CPBaseHeuristic.h"

@interface CPFirstFail : CPBaseHeuristic<CPHeuristic> {
   id<ORVarArray>  _vars;
   id<ORVarArray> _rvars;
   id<CPSolver>            _cp;
}
-(CPFirstFail*)initCPFirstFail:(id<CPSolver>)cp restricted:(id<ORVarArray>)rvars;
-(float)varOrdering:(id<ORIntVar>)x;
-(float)valOrdering:(int)v forVar:(id<ORIntVar>)x ;
-(void)initInternal:(id<ORVarArray>)t;
-(id<ORIntVarArray>)allIntVars;
@end
