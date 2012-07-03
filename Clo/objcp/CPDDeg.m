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
-(id)initCPDDeg:(id<CP>)cp
{
   self = [super init];
   [cp addHeuristic:self];
   _cp = cp;
   _solver  = (CPSolverI*)[cp solver];
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(id<CPIntVarArray>)allIntVars
{
   return (id<CPIntVarArray>)_vars;
}
-(float)varOrdering:(id<CPIntVar>)x
{
   __block float h = 0.0;
   NSSet* theConstraints = _cv[[x getId]];   
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
   CPInt len = [_vars count];
   _cv = malloc(sizeof(NSSet*)*len);
   memset(_cv,sizeof(NSSet*)*len,0);
   CPInt low = [_vars low];
   CPInt up  = [_vars up];
   for(int k=low;k<= up;k++) {
      _cv[k-low] = [[_vars at:k] constraints];
   }
   _nbv = len;
}
@end
