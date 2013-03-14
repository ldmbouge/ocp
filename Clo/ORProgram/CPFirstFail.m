/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPFirstFail.h"
#import "CPEngine.h"

@implementation CPFirstFail {
   id<CPEngine>    _engine;
}
-(CPFirstFail*)initCPFirstFail:(id<CPProgram>)cp restricted:(id<ORVarArray>)rvars
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
   CPFirstFail * cp = [[CPFirstFail alloc] initCPFirstFail:_cp restricted:_rvars];
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
-(id<CPIntVarArray>)allIntVars
{
   return (id<CPIntVarArray>) (_rvars!=nil ? _rvars : _vars);
}

-(ORFloat)varOrdering:(id<CPIntVar>)x
{
   float rv = - [x domsize];
   return rv;
}
-(ORFloat)valOrdering:(int)v forVar:(id<CPIntVar>)x
{
   return -v;   
}
-(void)initInternal:(id<ORVarArray>)t
{
   _vars = t;
   NSLog(@"FirstFail ready...");
}
@end
