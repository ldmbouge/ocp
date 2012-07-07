/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPDDeg.h"
#import "CPSolverI.h"
#import "CPIntVarI.h"

@implementation CPDDeg
-(id)initCPDDeg:(id<CP>)cp restricted:(id<CPVarArray>)rvars
{
   self = [super init];
   [cp addHeuristic:self];
   _cp = cp;
   _solver  = (CPSolverI*)[cp solver];
   _rvars = rvars;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(id<CPIntVarArray>)allIntVars
{
   return (id<CPIntVarArray>) (_rvars!=nil ? _rvars : _vars);
}
-(float)varOrdering:(id<CPIntVar>)x
{
   __block float h = 0.0;
   NSSet* theConstraints = _cv[_map[[x getId]]];   
   for(id obj in theConstraints) {
      h += ([obj nbUVars] - 1 > 0);
   }
   return h / [x domsize];
}
-(float)valOrdering:(int)v forVar:(id<CPIntVar>)x
{
   return -v;   
}
-(void)initInternal:(id<CPVarArray>)t
{
   _vars = t;
   CPLong len = [_vars count];
   CPUInt maxID = 0;
   for(int k=0;k<len;k++) 
      maxID = max(maxID,[[t at:k] getId]);   
   _cv = malloc(sizeof(NSSet*)*len);
   _map = malloc(sizeof(CPUInt)*(maxID+1));
   memset(_cv,sizeof(NSSet*)*len,0);
   memset(_map,sizeof(CPUInt)*(maxID+1),0);   
   CPInt low = [t low],up = [t up];
   for(int k=low;k <= up;k++) {
      _map[[[_vars at:k] getId]] = k - low;
      _cv[k-low] = [[_vars at:k] constraints];
   }
   _nbv = len;
}
@end
