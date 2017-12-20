/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORProgram/CPDDeg.h>
#import <CPUKernel/CPEngine.h>
#import <objcp/CPVar.h>


@implementation CPDDeg {
   id<CPEngine>    _solver;
}
-(id)initCPDDeg:(id<CPCommonProgram>)cp restricted:(id<ORVarArray>)rvars
{
   self = [super init];
   _cp = cp;
   _solver  = [cp engine];
   _rvars = rvars;
   return self;
}
- (id)copyWithZone:(NSZone *)zone
{
   CPDDeg* cp = [[CPDDeg alloc] initCPDDeg:_cp restricted:_rvars];
   return cp;
}
-(void)dealloc
{
   for(int k=0; k < _nbv;k++)
      [_cv[k] release];
   free(_cv);
   free(_map);
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
-(ORDouble)varOrdering: (id<CPIntVar>) ox
{
   id<CPIntVar> x = (id<CPIntVar>)ox;
   __block double h = 0.0;
   NSSet* theConstraints = _cv[_map[[x getId]]];   
   for(id obj in theConstraints) {
      h += ([obj nbUVars] - 1 > 0);
   }
   return h / [x domsize];
}
-(ORDouble)valOrdering:(int)v forVar:(id<CPIntVar>)x
{
   return -v;   
}
-(void)initInternal:(id<ORVarArray>) t with:(id<CPVarArray>)cvs
{
   _vars = t;
   _cvs  = cvs;
   ORUInt len = (ORUInt)[_vars count];
   ORUInt maxID = 0;
   for(int k=0;k<len;k++) 
      maxID = max(maxID,[t at:k].getId);
   _cv = malloc(sizeof(NSSet*)*len);
   _map = malloc(sizeof(ORUInt)*(maxID+1));
   memset(_cv,sizeof(NSSet*)*len,0);
   memset(_map,sizeof(ORUInt)*(maxID+1),0);   
   ORInt low = [t low],up = [t up];
   for(ORInt k=low;k <= up;k++) {
      _map[_cvs[k].getId] = k - low;
      _cv[k-low] = [[_cvs[k] constraints] retain];
   }
   _nbv = len;
   NSLog(@"DDeg ready...");
}
@end
