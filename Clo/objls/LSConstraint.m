/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSConstraint.h"
#import "LSEngineI.h"
#import "LSAllDifferent.h"
#import "LSCardinality.h"
#import "LSSystem.h"
#import "LSLinear.h"
#import "LSBasic.h"

@implementation LSConstraint
-(id)init:(LSEngineI*)engine
{
   self = [super init];
   _engine = engine;
   return self;
}
-(void)post
{
   
}
-(id<LSIntVarArray>)variables
{
   return nil;
}
-(ORBool)isTrue
{
   return YES;
}
-(ORInt)getViolations
{
   return 0;
}
-(ORInt)getTrueViolations
{
   return max(0,[self getViolations]);
}
-(ORInt)getVarViolations:(id<LSIntVar>)var
{
   return 0;
}
-(id<LSIntVar>)violations
{
   return nil;
}
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var
{
   return nil;
}
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   return 0;
}
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   return 0;
}
@end

@implementation LSFactory (LSConstraint)
+(id<LSConstraint>)alldifferent:(id<LSEngine>)e over:(id<LSIntVarArray>)x
{
   LSAllDifferent* c = [[LSAllDifferent alloc] init:e vars:x];
   [e trackMutable:c];
   return c;
}
+(id<LSConstraint>)cardinality:(id<LSEngine>)e low:(id<ORIntArray>)lb vars:(id<LSIntVarArray>)x up:(id<ORIntArray>)ub
{
   LSCardinality* c = [[LSCardinality alloc] init:e low:lb vars:x up:ub];
   [e trackMutable:c];
   return c;
}
+(id<LSConstraint>) packing:(id<LSIntVarArray>)x weight: (id<ORIntArray>)weight capacity: (id<ORIntArray>)capacity;
{
   LSPacking* c = [[LSPacking alloc] init:x weight:weight cap:capacity];
   [[x[x.range.low] engine] trackMutable:c];
   return c;
}
+(id<LSConstraint>) packingOne: (id<LSIntVarArray>)x weight: (id<ORIntArray>)weight bin: (ORInt) bin capacity: (ORInt)capacity;
{
   LSPackingOne* c = [[LSPackingOne alloc] init:x weight:weight bin: bin cap:capacity];
//   LSPackingOneSat* c = [[LSPackingOneSat alloc] init:x weight:weight bin: bin cap:capacity];
   [[x[x.range.low] engine] trackMutable:c];
   return c;
}
+(id<LSConstraint>) meetAtmost:(id<LSIntVarArray>)x and: (id<LSIntVarArray>)y atmost: (ORInt) k
{
   LSMeetAtmost* c = [[LSMeetAtmost alloc] init:x and: y atmost: k];
//   LSMeetAtmostSat* c = [[LSMeetAtmostSat alloc] init:x and: y atmost: k];
   [[x[x.range.low] engine] trackMutable:c];
   return c;
}
+(id<LSConstraint>)system:(id<LSEngine>)e with:(NSArray*)ac
{
   LSSystem* c = [[LSSystem alloc] init:e with:ac];
   [e trackMutable:c];
   return c;
}
+(id<LSConstraint>) lrsystem:(id<LSEngine>)e with:(NSArray*)ac
{
   LSLRSystem* c = [[LSLRSystem alloc] init:e with:ac];
   [e trackMutable:c];
   return c;
}
+(id<LSConstraint>)linear:(id<LSEngine>)e coef:(id<ORIntArray>)coef vars:(id<LSIntVarArray>)x eq:(ORInt)cst
{
   LSLinear* c = [[LSLinear alloc] init:e coefs:coef vars:x type:LSTYEqual constant:cst];
   [e trackMutable:c];
   return c;
}
+(id<LSConstraint>) lEqual: (id<LSIntVar>)x to: (id<LSIntVar>) y plus:(ORInt)c
{
   LSLEqual* cstr = [[LSLEqual alloc] init:[x engine] x:x leq:y plus:c];
   [[x engine] trackMutable:cstr];
   return cstr;
}
+(id<LSConstraint>) nEqualc: (id<LSIntVar>)x to: (ORInt) c
{
   LSNEqualc* cstr = [[LSNEqualc alloc] init:[x engine] x:x neq:c];
   [[x engine] trackMutable:cstr];
   return cstr;
}
+(id<LSConstraint>) boolean:(id<LSIntVar>)x or:(id<LSIntVar>)y equal:(id<LSIntVar>)b;
{
   LSOr* o = [[LSOr alloc] init:[x engine] boolean:b equal:x or: y];
   [[x engine] trackMutable:o];
   return o;
}
@end