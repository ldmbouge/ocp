/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORProgram/CPFirstFail.h>
#import <CPUKernel/CPEngine.h>
#import <objcp/CPVar.h>

@implementation CPFirstFail
-(CPFirstFail*)initCPFirstFail:(id<CPProgram>)cp restricted:(id<ORVarArray>)rvars
{
   self = [super init];
   _cp = cp;
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
-(id<ORIntVarArray>)allIntVars
{
   return (id<ORIntVarArray>) (_rvars!=nil ? _rvars : _vars);
}

-(ORDouble)varOrdering:(id<CPIntVar>)x
{
   ORDouble rv = - [x domsize];
   return rv;
}
-(ORDouble)valOrdering:(int)v forVar:(id<CPIntVar>)x
{
   return -v;   
}
-(void)initInternal:(id<ORVarArray>)t with:(id<CPVarArray>)cv
{
   _vars = t;
   _cvs  = cv;
   NSLog(@"FirstFail ready...");
}
@end
