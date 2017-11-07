/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORProgram/CPWDeg.h>
#import <CPUKernel/CPEngine.h>
#import <objcp/CPVar.h>


@implementation CPWDeg {
   id<ORVarArray>   _vars;  // Model variables
   id<CPVarArray>    _cvs;  // concrete variables
   id<ORVarArray>  _rvars;
   ORUInt         _nbVars;
   ORUInt*           _map;
   id<CPCommonProgram>      _cp;
   id<CPEngine>   _solver;
   ORUInt            _nbc;
   ORUInt            _nbv;
   ORUInt*             _w;
   NSSet* __strong*   _cv;
   id*              _vOfC;
}
-(CPWDeg*)initCPWDeg:(id<CPCommonProgram>)cp restricted:(id<ORVarArray>)rvars
{
   self = [super init];
   _cp = cp;
   _solver  = [cp engine];
   _vars = nil;
   _rvars = rvars;
   _w = 0;
   _cv = 0;
   return self;
}
- (id)copyWithZone:(NSZone *)zone
{
   CPWDeg* cp = [[CPWDeg alloc] initCPWDeg:_cp restricted:_rvars];
   return cp;
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
     for(int k=0;k<_nbVars;k++)
       [_cv[k] release];
     free(_cv);
   }
   free(_map);
   [super dealloc];
}
-(id<CPCommonProgram>)solver
{
   return _cp;
}

// pvh: not sure why this is needed
// pvh: why do we need vars and t and so on.
-(id<ORIntVarArray>)allIntVars
{
   return (id<ORIntVarArray>) (_rvars!=nil ? _rvars : _vars);
}

// pvh: see question below for the importance of _cv

-(ORDouble) varOrdering:(id<CPIntVar>)x
{
   __block double h = 0.0;
   NSSet* theConstraints = _cv[_map[x.getId]];
   for(id obj in theConstraints) {
      ORInt cid = [obj getId];
      assert(cid >=0 && cid < _nbc);
      h += ([obj nbUVars] - 1 > 0) * _w[cid];
   }
   return h / [x domsize];
}

-(ORDouble) valOrdering:(int) v forVar:(id<CPIntVar>)x
{
   return -v;   
}

// pvh: we should really use our arrays for consistency in the interfaces [ldm:done]
// pvh: why do we need _cv[k]: it seems that we should be able to get these directly from the variable [ldm:caching]

-(void)initInternal:(id<ORVarArray>)t with:(id<CPVarArray>)cvs
{
   ORUInt len = (ORUInt) [t count];
   _vars = t;
   _cvs  = cvs;
   _nbVars = (ORUInt)[_cvs count];
   _cv = malloc(sizeof(NSSet*)*len);
   memset(_cv,sizeof(NSSet*)*len,0);
   ORUInt maxID = 0;
   for(int k=0;k<len;k++) 
      maxID = max(maxID,[[_cvs at:k] getId]);
   _map = malloc(sizeof(ORUInt)*(maxID+1));
   ORInt low = [_cvs low],up = [_cvs up];
   for(int k=low;k <= up;k++) {
      _map[_cvs[k].getId] = k - low;
      _cv[k - low] = [[_cvs[k] constraints] retain];
   }
   _nbv = len;
   NSArray* allC = [(id)_solver constraints];
   _nbc = (ORUInt)[allC count];
   _w   = malloc(sizeof(ORUInt)*_nbc);
   _vOfC = malloc(sizeof(id)*_nbc);
   for(ORUInt k=0;k < _nbc;k++) {
      _w[k] = 1;
      _vOfC[k] = [[allC[k] allVars] retain];
   }
   [[_solver propagateFail] wheneverNotifiedDo:^(int cID) {
      _w[cID]++;
   }];
   NSLog(@"WDeg ready...");
}

@end
