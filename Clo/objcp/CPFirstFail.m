/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPFirstFail.h"
#import "CPEngineI.h"
#import "CPIntVarI.h"

@implementation CPFirstFail {
   CPEngineI*    _solver;
}
-(CPFirstFail*)initCPFirstFail:(id<CPSolver>)cp restricted:(id<CPVarArray>)rvars
{
   self = [super init];
   [cp addHeuristic:self];
   _cp = cp;
   _solver  = (CPEngineI*)[cp solver];
   _vars = nil;
   _rvars = rvars;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(id<ORIntVarArray>)allIntVars
{
   return (id<ORIntVarArray>) (_rvars!=nil ? _rvars : _vars);
}

-(float)varOrdering:(id<ORIntVar>)x
{
   return - [x domsize];
}
-(float)valOrdering:(int)v forVar:(id<ORIntVar>)x
{
   return -v;   
}
-(void)initInternal:(id<CPVarArray>)t
{
   _vars = t;
}
@end
