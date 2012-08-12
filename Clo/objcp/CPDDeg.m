/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPDDeg.h"
#import "CPEngineI.h"
#import "CPIntVarI.h"

@implementation CPDDeg {
   CPEngineI*    _solver;
}
-(id)initCPDDeg:(id<CPSolver>)cp restricted:(id<CPVarArray>)rvars
{
   self = [super init];
   [cp addHeuristic:self];
   _cp = cp;
   _solver  = (CPEngineI*)[cp solver];
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
   __block float h = 0.0;
   NSSet* theConstraints = _cv[_map[[x getId]]];   
   for(id obj in theConstraints) {
      h += ([obj nbUVars] - 1 > 0);
   }
   return h / [x domsize];
}
-(float)valOrdering:(int)v forVar:(id<ORIntVar>)x
{
   return -v;   
}
-(void)initInternal:(id<CPVarArray>)t
{
   _vars = t;
   ORLong len = [_vars count];
   ORUInt maxID = 0;
   for(int k=0;k<len;k++) 
      maxID = max(maxID,[[t at:k] getId]);   
   _cv = malloc(sizeof(NSSet*)*len);
   _map = malloc(sizeof(ORUInt)*(maxID+1));
   memset(_cv,sizeof(NSSet*)*len,0);
   memset(_map,sizeof(ORUInt)*(maxID+1),0);   
   ORInt low = [t low],up = [t up];
   for(ORInt k=low;k <= up;k++) {
      _map[[[_vars at:k] getId]] = k - low;
      _cv[k-low] = [[_vars at:k] constraints];
   }
   _nbv = len;
}
@end
