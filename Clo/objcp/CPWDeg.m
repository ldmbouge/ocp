/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPWDeg.h"
#import "CPEngineI.h"
#import "ORFoundation/ORModel.h"
#import "CPIntVarI.h"

@implementation CPWDeg

-(CPWDeg*)initCPWDeg:(id<CPSolver>)cp restricted:(id<ORVarArray>)rvars
{
   self = [super init];
   [cp addHeuristic:self];
   _cp = cp;
   _solver  = (CPEngineI*)[cp engine];
   _vars = nil;
   _rvars = rvars;
   _w = 0;
   _cv = 0;
   return self;
}

-(void)dealloc
{
   if (_w) free(_w);
   if (_vOfC) {
      for(int k=0;k<_nbc;k++)
         [_vOfC[k] release];
      free(_vOfC);  
   }
   if (_cv) {
     for(int k=0;k<[_vars count];k++)
       [_cv[k] release];
     free(_cv);
   }
   free(_map);
   [super dealloc];
}

// pvh: not sure why this is needed
// pvh: why do we need vars and t and so on.
-(id<ORIntVarArray>)allIntVars
{
   return (id<ORIntVarArray>) (_rvars!=nil ? _rvars : _vars);
}

// pvh: see question below for the importance of _cv

-(float) varOrdering:(id<ORIntVar>)x
{
   __block float h = 0.0;
   NSSet* theConstraints = _cv[_map[[x getId]]];   
   for(id obj in theConstraints) {
      ORInt cid = [obj getId];
      assert(cid >=0 && cid < _nbc);
      h += ([obj nbUVars] - 1 > 0) * _w[cid];
   }
   return h / [x domsize];
}

-(float) valOrdering:(int) v forVar:(id<ORIntVar>)x
{
   return -v;   
}

// pvh: we should really use our arrays for consistency in the interfaces [ldm:done]
// pvh: why do we need _cv[k]: it seems that we should be able to get these directly from the variable [ldm:caching]

-(void)initInternal:(id<ORVarArray>)t
{
   ORUInt len = (ORUInt) [t count];
   _vars = t;
   _cv = malloc(sizeof(NSSet*)*len);
   memset(_cv,sizeof(NSSet*)*len,0);
   ORUInt maxID = 0;
   for(int k=0;k<len;k++) 
      maxID = max(maxID,[[t at:k] getId]);   
   _map = malloc(sizeof(ORUInt)*(maxID+1));
   ORInt low = [t low],up = [t up];
   for(int k=low;k <= up;k++) {
      //NSLog(@"Adding var with id: %d to dico of size: %ld",[t[k] getId],[_vars count]);
      _map[[_vars[k] getId]] = k - low;
      _cv[k - low] = [[_vars at:k] constraints];
   }
   _nbv = len;
   NSArray* allC = [_solver allConstraints];
   _nbc = (ORUInt)[allC count];
   _w   = malloc(sizeof(ORUInt)*_nbc);
   _vOfC = malloc(sizeof(id)*_nbc);
   for(ORUInt k=0;k < _nbc;k++) {
      _w[k] = 1;
      _vOfC[k] = [[allC objectAtIndex:k] allVars];
   }
   [[_solver propagateFail] wheneverNotifiedDo:^(int cID) {
      _w[cID]++;
   }];
   NSLog(@"WDeg ready...");
}

@end
