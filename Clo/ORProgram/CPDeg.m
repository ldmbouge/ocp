/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPDeg.h"
#import "CPEngineI.h"

@implementation CPDeg {
   CPEngineI*    _solver;
}
-(id)initCPDeg:(id<CPCommonProgram>)cp restricted:(id<ORVarArray>)rvars
{
   self = [super init];
   _cp = cp;
   _solver  = (CPEngineI*)[cp engine];
   _rvars = rvars;
   return self;
}
- (id)copyWithZone:(NSZone *)zone
{
   CPDeg* cp = [[CPDeg alloc] initCPDeg:_cp restricted:_rvars];
   return cp;
}
-(void)dealloc
{
   [super dealloc];
}
-(id<CPCommonProgram>)solver
{
   return _cp;
}
-(id<ORIntVarArray>) allIntVars
{
   return (id<ORIntVarArray>) (_rvars!=nil ? _rvars : _vars);
}
-(ORFloat)varOrdering: (id<CPIntVar>)x
{
   float h = _cv[_map[x.getId]];
   return h / [x domsize];
}
-(ORFloat)valOrdering:(int)v forVar:(id<CPIntVar>)x
{
   return v;
}
-(void)initInternal:(id<ORVarArray>) t with:(id<CPVarArray>)cvs
{
   _vars = t;
   _cvs  = cvs;
   ORUInt len = (ORUInt)[_vars count];
   ORUInt maxID = 0;
   for(int k=0;k<len;k++)
      maxID = max(maxID,t[k].getId);
   _cv = malloc(sizeof(ORInt)*len);
   _map = malloc(sizeof(ORUInt)*(maxID+1));
   memset(_cv,sizeof(NSSet*)*len,0);
   memset(_map,sizeof(ORUInt)*(maxID+1),0);
   ORInt low = [t low],up = [t up];
   for(ORInt k=low;k <= up;k++) {
      _map[_cvs[k].getId] = k - low;
      _cv[k - low] = [_cvs[k] degree];
   }
   _nbv = len;
   NSLog(@"Deg ready...");
}
@end
