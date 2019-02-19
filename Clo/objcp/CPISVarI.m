/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "CPISVarI.h"
#import "CPEngineI.h"
#import "CPEvent.h"

typedef struct {
   TRId  _bindEvt[2];
   TRId  _changeEvt[2];
   TRId  _reqEvt[2];
   TRId  _excEvt[2];
} CPISVNetwork;


@implementation CPIntSetVarI {
   @public
   CPISVNetwork   _net;
}

static void setUpNetwork(CPISVNetwork* net,id<ORTrail> t)
{
   for(ORInt i =0 ; i < 2;i++) {
      net->_bindEvt[i]   = makeTRId(t,nil);
      net->_changeEvt[i] = makeTRId(t,nil);
      net->_reqEvt[i]    = makeTRId(t,nil);
      net->_excEvt[i]    = makeTRId(t,nil);
   }
}

static void deallocNetwork(CPISVNetwork* net)
{
   freeList(net->_bindEvt[0]);
   freeList(net->_changeEvt[0]);
   freeList(net->_reqEvt[0]);
   freeList(net->_excEvt[0]);
}

-(id)initWith:(CPEngineI*)engine set:(id<ORIntSet>)s
{
   self = [super init];
   _engine = engine;
   _card = [CPFactory intVar:(id)engine bounds:RANGE((id)engine, 0, [s size])];
   _pos  = [[CPTrailIntSet alloc] initWithSet:s trail:[_engine trail]];
   _req  = [[CPTrailIntSet alloc] initWithSet:nil trail:[_engine trail]];
   _exc  = [[CPTrailIntSet alloc] initWithSet:nil trail:[_engine trail]];
   _isb = makeTRInt([_engine trail], _pos.size == _req.size);
   [_engine trackVariable: self];
   setUpNetwork(&_net, [_engine trail]);
   return self;
}
-(void)dealloc
{
   [_pos release];
   [_req release];
   [_exc release];
   deallocNetwork(&_net);
   [super dealloc];
}
-(id<ORTracker>)tracker
{
   return (id)_engine;
}
-(id<CPEngine>)engine
{
   return (id)_engine;
}
-(id<OROSet>)constraints
{
   id<OROSet> rv = [ORFactory objectSet];
   return rv;
}
-(ORInt)degree
{
   __block ORUInt d = 0;
   [_net._bindEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr)   { d += [cstr nbVars] - 1;}];
   [_net._changeEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr) { d += [cstr nbVars] - 1;}];
   [_net._reqEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr)    { d += [cstr nbVars] - 1;}];
   [_net._excEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr)    { d += [cstr nbVars] - 1;}];
   return d;
}
-(enum CPVarClass)varClass
{
   return CPVCBare;
}

-(id<CPIntVar>)cardinality
{
   return _card;
}
-(ORBool)bound
{
   return _isb._val;
}
-(ORInt) domsize
{
   @throw [[ORExecutionError alloc] initORExecutionError:"domsize not supported on int set var"];
   return 0;
}
- (id<CPADom>)domain
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntSetVar: method domain not defined"];
}
- (void)subsumedBy:(id<CPVar>)x
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntSetVar: method subsumedBy not defined"];
}
-(void)subsumedByDomain:(id<CPADom>)dom
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntSetVar: method subsumedByDomain not defined"];
}
-(ORBool)sameDomain:(CPIntSetVarI*)x
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntSetVar: method sameDomain not defined"];
}
-(id<IntEnumerator>)required
{
   return [_req enumerator];
}
-(id<IntEnumerator>)possible
{
   return [_pos enumerator];
}
-(id<IntEnumerator>)excluded
{
   return [_exc enumerator];
}
-(ORInt)cardRequired
{
   return [_req size];
}
-(ORInt)cardPossible
{
   return [_pos size];
}
-(ORBool)isRequired:(ORInt)v
{
   return [_req member:v];
}
-(ORBool)isPossible:(ORInt)v
{
   return [_pos member:v];
}
-(ORBool)isExcluded:(ORInt)v
{
   return [_exc member:v];
}
-(void)require:(ORInt)v
{
   if ([_pos member:v]) {
      if (![_req member:v]) {
         [_req insert:v];
         [self requireEvt:v];
         if ([_card max] == [_req size]) {
            // loop over possibles that are not required and exclude them
            [_pos enumerateWithBlock:^(ORInt v) {
               if (![_req member:v]) {
                  [self internalExclude:v];
               }
            }];
         }
         [_card updateMin:_req.size andMax:_pos.size];
         if (_pos.size == _req.size) {
            assignTRInt(&_isb, YES, [_engine trail]);
            [self bindEvt];
         }
      }
   } else failNow();
}
-(void)exclude:(ORInt)v
{
   if (![_req member:v]) {
      if ([_pos member:v]) {
         [_pos delete:v];
         [_exc insert:v];
         [self excludeEvt:v];
         if (_card.min == _pos.size) {
            [_pos enumerateWithBlock:^(ORInt v) {
               if (![_req member:v]) {
                  [self internalRequire:v];
               }
            }];
         }
         [_card updateMin:_req.size andMax:_pos.size];
         if (_pos.size == _req.size) {
            assignTRInt(&_isb, YES, [_engine trail]);
            [self bindEvt];
         }
      }
   } else failNow();
}
-(void)internalExclude:(ORInt)v
{
   if (![_req member:v]) {
      if ([_pos member:v]) {
         [_pos delete:v];
         [_exc insert:v];
         [self changeEvt];
         [self excludeEvt:v];
      }
   } else failNow();
}
-(void)internalRequire:(ORInt)v
{
   if ([_pos member:v]) {
      if (![_req member:v]) {
         [_req insert:v];
         [self changeEvt];
         [self requireEvt:v];
      }
   } else failNow();
}
-(NSString*)description
{
   NSMutableString* buf = [NSMutableString stringWithCapacity:64];
   @autoreleasepool {
      [buf appendFormat:@"var:<set{int}>[%@] = ",_card];
      NSString* rd = [_req description];
      NSString* pd = [_pos description];
      NSString* xd = [_exc description];
      [buf appendFormat:@"R:%@, P:%@ , X: %@",rd,pd,xd];
   }
   return buf;
}
-(void)requireEvt:(ORInt)v
{
   [_engine scheduleValueClosure:[CPValueLossEvent newValueLoss:v notify:_net._reqEvt[0]]];
}
-(void)excludeEvt:(ORInt)v
{
   [_engine scheduleValueClosure:[CPValueLossEvent newValueLoss:v notify:_net._excEvt[0]]];
}
-(void)bindEvt
{
   id<CPClosureList> mList[2] = {_net._bindEvt[0],NULL};
   scheduleClosures(_engine,mList);
}
-(void)changeEvt
{
   id<CPClosureList> mList[2] = {_net._changeEvt[0],NULL};
   scheduleClosures(_engine,mList);
}

// notifications APIs
-(void)whenRequired:(id<CPConstraint>)c do:(ORIntClosure)todo
{
   hookupEvent((id)_engine, _net._reqEvt, todo, c, HIGHEST_PRIO);
}
-(void)whenExcluded:(id<CPConstraint>)c do:(ORIntClosure)todo
{
   hookupEvent((id)_engine, _net._excEvt, todo, c, HIGHEST_PRIO);
}
-(void)whenBound:(id<CPConstraint>)c do:(ORClosure)todo
{
   hookupEvent((id)_engine, _net._bindEvt, todo, c, HIGHEST_PRIO);
}
-(void)whenChange:(id<CPConstraint>)c do:(ORClosure)todo
{
   hookupEvent((id)_engine, _net._changeEvt, todo, c, HIGHEST_PRIO);
}
- (void)visit:(ORVisitor *)visitor
{
}

@end
