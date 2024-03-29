/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/CPBitVarVSIDS.h>
#import <CPUKernel/CPEngine.h>
#import <objcp/CPBitVar.h>

@implementation CPBitVarVSIDS {
   id<CPEngine>    _engine;
   ORLong          _count;
   ORInt          _countMax;
   
}
-(CPBitVarVSIDS*)initCPBitVarVSIDS:(id<CPProgram>)cp restricted:(id<ORVarArray>)rvars
{
   self = [super init];
   _cp = cp;
   _engine  = [cp engine];
   _vars = nil;
   _rvars = rvars;
    _countMax = 32;
    _count = _countMax;
   return self;
}
- (id)copyWithZone:(NSZone *)zone
{
   CPBitVarVSIDS * cp = [[CPBitVarVSIDS alloc] initCPBitVarVSIDS:_cp restricted:_rvars];
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
-(id<ORVarArray>)allBitVars
{
   return (id<ORVarArray>) (_rvars!=nil ? _rvars : _cvs);
}

-(ORFloat)varOrdering:(id<CPBitVar>)x
{
   ORFloat rv = - (ORFloat)[x getVSIDSCount];
    // id<ORVarArray> vars = (_rvars!=nil ? _rvars : _cvs);
//    if (_count <= 0)
//    {
//        for (id<CPBitVar> var in vars)
//            [var reduceVSIDS];
////        _countMax <<= 1;
//        _count = _countMax;
//    }
//    else
//        _count--;
   return rv;
}
-(ORFloat)valOrdering:(ORUInt)v forVar:(id<CPBitVar>)x
{
   return [x getVSIDSActivity:v];
}
-(void)initInternal:(id<ORVarArray>)t and:(id<CPVarArray>)cv
{
   _vars = t;
   _cvs  = cv;
   NSLog(@"VSIDS ready...");
}

@end
