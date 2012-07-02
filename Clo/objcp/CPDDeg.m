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
   _vars = [[NSMutableArray alloc] initWithCapacity:32];
   return self;
}
-(void)dealloc
{
   [_vars release];
   [super dealloc];
}
-(id<CPIntVarArray>)allIntVars
{
   id<CPIntVarArray> rv = [CPFactory intVarArray:_cp range:(CPRange){0,[_vars count]-1} with:^id<CPIntVar>(CPInt i) {
      return (id<CPIntVar>)[_vars objectAtIndex:i];
   }];
   return rv;
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
-(void)initHeuristic:(id<CPIntVar>*)t length:(CPInt)len
{
   _cv = malloc(sizeof(NSSet*)*len);
   memset(_cv,sizeof(NSSet*)*len,0);
   for(int k=0;k<len;k++) {
      [_vars addObject:t[k]];
      _cv[k] = [t[k] constraints];
   }
   _nbv = len;
}
@end
