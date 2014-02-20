/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPBitVarFirstFail.h"
#import "CPEngine.h"
#import "CPBitVar.h"

@implementation CPBitVarFirstFail {
   id<CPEngine>    _engine;
}
-(CPBitVarFirstFail*)initCPBitVarFirstFail:(id<CPProgram>)cp restricted:(id<ORVarArray>)rvars
{
   self = [super init];
   _cp = cp;
   _engine  = [cp engine];
   _vars = nil;
   _rvars = rvars;
   return self;
}
- (id)copyWithZone:(NSZone *)zone
{
   CPBitVarFirstFail * cp = [[CPBitVarFirstFail alloc] initCPBitVarFirstFail:_cp restricted:_rvars];
   return cp;
}
-(void)dealloc
{
   [super dealloc];
}
-(id<CPProgram>)solver
{
   return _cp;
}
-(id<CPVarArray>)allBitVars
{
   return (id<CPVarArray>) (_rvars!=nil ? _rvars : _cvs);
}

-(ORFloat)varOrdering:(id<CPBitVar>)x
{
   float rv = - [x domsize];
   return rv;
}
-(ORFloat)valOrdering:(ORUInt)v forVar:(id<CPBitVar>)x
{
   return -v;
}
-(void)initInternal:(id<ORVarArray>)t and:(id<CPVarArray>)cv
{
   _vars = t;
   _cvs  = cv;
   NSLog(@"FirstFail ready...");
}

@end