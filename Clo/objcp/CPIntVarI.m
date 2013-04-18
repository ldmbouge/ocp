/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPUKernel.h>
#import "CPData.h"
#import "CPDom.h"
#import "CPIntVarI.h"
#import "CPEngineI.h"
#import "CPTrigger.h"
#import "CPBitDom.h"
#import "CPEngineI.h"
#import "CPEvent.h"

/*****************************************************************************************/
/*                        Constraint Network Handling                                    */
/*****************************************************************************************/

static void setUpNetwork(CPEventNetwork* net,id<ORTrail> t,ORInt low,ORInt sz) 
{
    net->_boundsEvt = makeTRId(t,nil);
    net->_bindEvt   = makeTRId(t,nil);
    net->_domEvt    = makeTRId(t,nil);
    net->_minEvt    = makeTRId(t,nil);
    net->_maxEvt    = makeTRId(t,nil);
    net->_ac5       = makeTRId(t, nil);
}

static void deallocNetwork(CPEventNetwork* net)
{
    freeList(net->_boundsEvt._val);
    freeList(net->_bindEvt._val);
    freeList(net->_domEvt._val);
    freeList(net->_minEvt._val);
    freeList(net->_maxEvt._val);
    freeList(net->_ac5._val);
}

static NSMutableSet* collectConstraints(CPEventNetwork* net,NSMutableSet* rv)
{
   collectList(net->_boundsEvt._val,rv);
   collectList(net->_bindEvt._val,rv);
   collectList(net->_domEvt._val,rv);
   collectList(net->_minEvt._val,rv);
   collectList(net->_maxEvt._val,rv);
   collectList(net->_ac5._val,rv);
   return rv;
}

/*****************************************************************************************/
/*                        CPIntVar                                                       */
/*****************************************************************************************/

@implementation CPIntVarI

#define TRACKLOSSES (_net._ac5._val != nil || _triggers != nil)

-(CPIntVarI*) initCPIntVarCore: (CPEngineI*)engine low: (ORInt) low up: (ORInt)up
{
   self = [super init];
   _vc = CPVCBare;
   _isBool = NO;
   _fdm  = engine;
   [_fdm trackVariable: self];
   setUpNetwork(&_net, [_fdm trail],low,up-low+1);
   _triggers = nil;
   _dom = nil;
   _recv = nil;
   return self;
}
-(void)dealloc
{
    if (_recv != nil)
        [_recv release];
    [_dom release];     
    deallocNetwork(&_net);
    if (_triggers != nil)
        [_triggers release];    
    [super dealloc];
}
-(enum CPVarClass)varClass
{
   return _vc;
}
-(CPLiterals*)findLiterals:(CPIntVarI*)ref
{
   return nil;
}
-(ORBool) isBool
{
   return _isBool;
}
-(CPEngineI*) engine
{
    return _fdm;
}
-(id<ORTracker>) tracker
{
   return _fdm;
}
-(void) addVar:(CPIntVarI*)var
{
   assert(FALSE); // [ldm] should never be called on real vars. Only on multicast
}
-(CPLiterals*)literals
{
   return nil;
}
-(NSMutableSet*)constraints
{
   NSMutableSet* rv = collectConstraints(&_net,[[NSMutableSet alloc] initWithCapacity:2]);
   if (_recv) {
      NSMutableSet* rc = [_recv constraints];
      [rv unionSet:rc];
      [rc release];
   }
   return rv;
}
-(CPBitDom*)flatDomain
{
   return newDomain((CPBitDom*)_dom, 1, 0);
}
-(id<CPIntVarNotifier>) delegate
{
    return _recv;
}
-(void) setDelegate:(id<CPIntVarNotifier,NSCoding>) d
{
   if (_recv != d) {
      if (_recv != nil) {
         @throw [[NSException alloc] initWithName:@"Internal Error"
                                           reason:@"Trying to set a delegate that already exists"
                                         userInfo:nil];
      }
      _recv = [d retain];
   }
}
-(CPIntVarI*)findAffine:(ORInt)scale shift:(ORInt)shift
{
   if (scale==1 && shift==0)
      return self;
   else return nil;
}
-(ORBool) isConstant
{
   return NO;
}
-(ORBool) isVariable
{
   return YES;
}
-(ORInt)mapValue:(ORInt)v
{
   return v;
}
-(ORBool) bound
{
   assert(_dom);
    return [_dom bound];
}
-(ORInt) min
{
   assert(_dom);
    return [_dom min];
}
-(ORInt) max 
{
   assert(_dom);
    return [_dom max];
}
-(ORInt) value
{
   assert(_dom);
   if ([_dom bound])
      return [_dom min];
   else {
      @throw [[ORExecutionError alloc] initORExecutionError: "The Integer Variable is not Bound"];
      return 0;
   }
}

-(ORInt) intValue
{
   assert(_dom);
   if ([_dom bound])
      return [_dom min];
   else {
      //@throw [[ORExecutionError alloc] initORExecutionError: "The Integer Variable is not Bound"];
      return 0;
   }
}

-(ORBounds) bounds
{
   assert(_dom);
   return domBounds((CPBoundsDom*)_dom);
}
-(ORInt)domsize
{
   assert(_dom);
    return [_dom domsize];
}
-(ORInt)countFrom:(ORInt)from to:(ORInt)to
{
   assert(_dom);
   return [_dom countFrom:from to:to];
}
-(ORBool)member:(ORInt)v
{
   assert(_dom);
    return [_dom member:v];
}
-(ORRange)around:(ORInt)v
{
   assert(_dom);
   ORInt low = [_dom findMax:v-1];
   ORInt up  = [_dom findMin:v+1];
   return (ORRange){low,up};
}
-(ORInt) shift
{
    return 0;
}
-(ORInt) scale
{
    return 1;
}
-(ORInt)literal
{
   return 0;
}
-(id<CPIntVar>)base
{
   return self;
}
-(NSString*)description
{
   id<CPDom> dom = [self domain];
   NSMutableString* s = [NSMutableString stringWithCapacity:64];
#if !defined(_NDEBUG)
   [s appendFormat:@"var<%d>=",_name];
#endif
   if ([dom domsize]==1)
      [s appendFormat:@"%d",[dom min]];
   else {
      [s appendFormat:@"(%d)[",[dom domsize]];
      __block ORInt lastIn;
      __block ORInt firstIn;
      __block bool seq;
      __block bool first = YES;
      [dom enumerateWithBlock:^(ORInt k) {
         if (first) {
            [s appendFormat:@"%d",k];
            first = NO;
            seq   = NO;
            lastIn  = firstIn = k;
         } else {
            if (lastIn + 1 == k) {
               lastIn = k;
               seq    = YES;
            } else {
               if (seq)
                  [s appendFormat:@"..%d,%d",lastIn,k];
               else
                  [s appendFormat:@",%d",k];
               firstIn = lastIn = k;
               seq = NO;
            }
         }
      }];
      if (seq)
         [s appendFormat:@"..%d]",lastIn];
      else [s appendFormat:@"]"];
   }
   [dom release];
   return s;
}
-(id<CPDom>)domain
{
    return [_dom retain];
}

#define TRACKSINTVAR (_net._ac5._val != nil || _triggers != nil)

-(ORBool) tracksLoseEvt:(id<CPDom>)sender
{
    return TRACKSINTVAR;
}
// nothing to do here
-(void) setTracksLoseEvt
{
}

// AC3 Closure Events

-(void)whenBindDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent(_fdm, &_net._bindEvt, todo, c, p);
}
-(void)whenChangeDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent(_fdm, &_net._domEvt, todo, c, p);
}
-(void) whenChangeMinDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent(_fdm, &_net._minEvt, todo, c, p);
}
-(void) whenChangeMaxDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c 
{
   hookupEvent(_fdm, &_net._maxEvt, todo, c, p);
}
-(void) whenChangeBoundsDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c 
{
   hookupEvent(_fdm,&_net._boundsEvt, todo, c,p);
}
-(void)whenBindDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenBindDo: todo priority: HIGHEST_PRIO onBehalf:c];
}
-(void)whenChangeDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c 
{
    [self whenChangeDo: todo priority: HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeMinDo: (ConstraintCallback) todo  onBehalf:(CPCoreConstraint*)c 
{
    [self whenChangeMinDo: todo priority: HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeMaxDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c 
{
    [self whenChangeMaxDo: todo priority: HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeBoundsDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c 
{
   [self whenChangeBoundsDo: todo priority: HIGHEST_PRIO onBehalf:c];
}

// Constraint-based Events
-(void) whenBindPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent(_fdm, &_net._bindEvt, nil, c, p);
}
-(void) whenChangePropagate:  (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent(_fdm, &_net._domEvt, nil, c, p);
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p 
{
   hookupEvent(_fdm, &_net._minEvt, nil, c, p);
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p 
{
   hookupEvent(_fdm, &_net._maxEvt, nil, c, p);
}
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c priority: (ORInt) p 
{
   hookupEvent(_fdm, &_net._boundsEvt, nil, c,p);
}

-(void) whenBindPropagate: (CPCoreConstraint*) c
{
    [self whenBindPropagate: c priority: c->_priority];
}
-(void) whenChangePropagate:  (CPCoreConstraint*) c  
{
    [self whenChangePropagate: c priority: c->_priority];
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c 
{    
    [self whenChangeMinPropagate: c priority: c->_priority];
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c 
{
    [self whenChangeMaxPropagate: c priority: c->_priority];
}
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c 
{
   [self whenChangeBoundsPropagate: c priority: c->_priority];
}
-(void) whenLoseValue: (CPCoreConstraint*) c do: (ConstraintIntCallBack) todo
{
   [_recv setTracksLoseEvt];
   hookupEvent2(_fdm, &_net._ac5, todo, c, HIGHEST_PRIO,self);
}
// AC5 Events
-(void) whenLoseValue: (CPCoreConstraint*) c do: (ConstraintIntCallBack) todo var:(id<CPIntVar>)x
{
   [_recv setTracksLoseEvt];
   hookupEvent2(_fdm, &_net._ac5, todo, c, HIGHEST_PRIO,x);
}

-(id<CPTrigger>) setLoseTrigger: (ORInt) value do: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
    [_recv setTracksLoseEvt];
    if (_triggers == nil)
        [self createTriggers];
    return [_triggers linkTrigger:[CPTriggerMap createTrigger: todo onBehalf:c] forValue:value];
}
-(void) watch: (ORInt) val with: (id<CPTrigger>) t;
{
    [_recv setTracksLoseEvt];
    if (_triggers == nil)
        [self createTriggers];
    [_triggers linkTrigger:t forValue:val];
}
-(id<CPTrigger>) setBindTrigger: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
    [_recv setTracksLoseEvt];
    if (_triggers == nil)
        [self createTriggers];
    return [_triggers linkBindTrigger:[CPTriggerMap createTrigger: todo onBehalf:c]];
}
-(void) createTriggers
{
    if (_triggers == nil) {
        ORInt low = [_dom imin];
        ORInt up = [_dom imax];
        _triggers = [CPTriggerMap triggerMapFrom:low to:up dense:(up-low+1)<256];    
    }
}

-(ORStatus) bindEvt:(id<CPDom>)sender
{
   ORStatus s = ORSuspend;//_recv==nil ? ORSuspend : [_recv bindEvt:sender];
   if (s==ORFailure) return s;
   id<CPEventNode> mList[6];
   ORUInt k = 0;
   mList[k] = _net._boundsEvt._val;
   k += mList[k] != NULL;
   mList[k] = _net._minEvt._val;
   k += mList[k] != NULL;
   mList[k] = _net._maxEvt._val;
   k += mList[k] != NULL;
   mList[k] = _net._domEvt._val;
   k += mList[k] != NULL;
   mList[k] = _net._bindEvt._val;
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleAC3(_fdm,mList);
   if (_triggers)
      [_triggers bindEvt:_fdm];
   return ORSuspend;
}
-(ORStatus) changeMinEvt: (ORInt) dsz sender:(id<CPDom>)sender
{
   ORStatus s = ORSuspend;//_recv==nil ? ORSuspend : [_recv changeMinEvt:dsz sender:sender];
   if (s==ORFailure) return s;
   id<CPEventNode> mList[6];
   ORUInt k = 0;
   mList[k] = _net._boundsEvt._val;
   k += mList[k] != NULL;
   mList[k] = _net._minEvt._val;
   k += mList[k] != NULL;
   mList[k] = _net._domEvt._val;
   k += mList[k] != NULL;
   mList[k] = dsz==1 ? _net._bindEvt._val : NULL;
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleAC3(_fdm,mList);
   if (_triggers && dsz==1)
        [_triggers bindEvt:_fdm];
   return ORSuspend;
}
-(ORStatus) changeMaxEvt: (ORInt) dsz sender:(id<CPDom>)sender
{
   ORStatus s = ORSuspend;//_recv==nil ? ORSuspend : [_recv changeMaxEvt:dsz sender:sender];
   if (s==ORFailure) return s;
   id<CPEventNode> mList[6];
   id<CPEventNode>* ptr = mList;
   *ptr  = _net._boundsEvt._val;
   ptr += *ptr != NULL;
   *ptr = _net._domEvt._val;
   ptr += *ptr != NULL;
   *ptr = _net._maxEvt._val;
   ptr += *ptr != NULL;
   *ptr = dsz==1 ? _net._bindEvt._val : NULL;
   ptr += *ptr != NULL;
   *ptr = NULL;
   scheduleAC3(_fdm,mList);
   if (_triggers && dsz==1)
      [_triggers bindEvt:_fdm];
   return ORSuspend;
}
-(ORStatus) loseValEvt: (ORInt) val sender:(id<CPDom>)sender
{
   if (!TRACKSINTVAR) return ORSuspend;
   ORStatus s = ORSuspend;//_recv==nil ? ORSuspend : [_recv loseValEvt:val sender:sender];
   if (s==ORFailure) return s;

   id<CPEventNode> mList[6];
   ORUInt k = 0;
   mList[k] = _net._domEvt._val;
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleAC3(_fdm,mList);
   if (_net._ac5._val) {
      [_fdm scheduleAC5:[CPValueLossEvent newValueLoss:val notify:_net._ac5._val]];
   }
   if (_triggers)
      [_triggers loseValEvt:val solver:_fdm];
   return ORSuspend;
}
-(ORStatus) updateMin: (ORInt) newMin
{
    return [_dom updateMin:newMin for:self];
}
-(ORStatus) updateMax: (ORInt) newMax
{
    return [_dom updateMax:newMax for:self];
}
-(ORStatus)updateMin:(ORInt) newMin andMax:(ORInt)newMax
{
   //ORStatus s = [_dom updateMin:newMin for:self];
   //if (s)   s = [_dom updateMax:newMax for:self];
   //return s;
   return [_dom updateMin:newMin andMax:newMax for:self];
}

-(ORStatus) bind: (ORInt) val
{
    return [_dom bind:val for:self];
}
-(ORStatus) remove: (ORInt) val
{
    return [_dom remove:val for:self];
}
-(ORStatus) inside:(ORIntSetI*) S
{
    ORInt m = [self min];
    ORInt M = [self max];
    for(ORInt i = m; i <= M; i++) {
        if ([self member: i] && ![S member: i])
            [self remove: i];
    }
    return ORSuspend;
}

-(id<ORIntVar>) dereference
{
   return (id<ORIntVar>)self;
}
-(CPIntVarI*) initCPExplicitIntVar: (id<CPEngine>)engine bounds:(id<ORIntRange>)b
{
   self = [self initCPIntVarCore: engine low: [b low] up: [b up]];
   _dom = [[CPBoundsDom alloc] initBoundsDomFor:[_fdm trail] low: [b low] up: [b up]];
   return self;
}

-(CPIntVarI*) initCPExplicitIntVar: (id<CPEngine>)engine low: (ORInt) low up: (ORInt) up
{
    self = [self initCPIntVarCore: engine low:low up:up];
    _dom = [[CPBitDom alloc] initBitDomFor:[_fdm trail] low:low up:up];
    return self;
}

-(CPIntVarI*) initCPIntVarView: (id<CPEngine>) engine low: (ORInt) low up: (ORInt) up for: (CPIntVarI*) x
{
   self = [self initCPIntVarCore:engine low: low up: up];
   _vc = CPVCAffine;
   id<CPIntVarNotifier> xDeg = [x delegate];
   if (xDeg == nil) {
      CPIntVarMultiCast* mc = [[CPIntVarMultiCast alloc] initVarMC:2 root:x];
      [mc addVar: self];
      [mc release]; // we no longer need the local ref. The addVar call has increased the retain count.
   }
   else {
      [xDeg addVar:self];
   }
   return self;
}


// ------------------------------------------------------------------------
// Cluster Constructors
// ------------------------------------------------------------------------

+(CPIntVarI*)    initCPIntVar: (id<CPEngine>)fdm bounds:(id<ORIntRange>)b
{
   CPIntVarI* x = [[CPIntVarI alloc] initCPExplicitIntVar: fdm bounds:b];
   x->_isBool = ([b low] == 0 && [b up] == 1);
   return x;
}

+(CPIntVarI*) initCPIntVar: (id<CPEngine>) fdm low: (ORInt) low up: (ORInt) up
{
   CPIntVarI* x = nil;
   ORLong sz = (ORLong)up - low + 1;
   if (low==0 && up==1)
      x = [[CPIntVarI alloc] initCPExplicitIntVar: fdm bounds: RANGE(fdm,0,1)];     // binary domain. Use bounds only.
   else if (sz >= 65536)
      x = [[CPIntVarI alloc] initCPExplicitIntVar: fdm bounds: RANGE(fdm,low,up)];  // large domain. Fall back to bounds only.
   else
      x = [[CPIntVarI alloc] initCPExplicitIntVar: fdm low: low up: up];            // Smallish domain. Use bit-vectors.
   x->_isBool = (low == 0 && up==1);
   return x;
}
+(CPIntVarI*) initCPBoolVar: (id<CPEngine>) fdm
{
   CPIntVarI* x = [[CPIntVarI alloc] initCPExplicitIntVar: fdm bounds: RANGE(fdm,0,1)];
   x->_isBool = YES;
   return x;
}

+(CPIntVarI*) initCPIntView: (CPIntVarI*) x withShift: (ORInt) b
{
   CPIntShiftView* view = [[CPIntShiftView alloc] initIVarShiftView: x b: b];
   return view;
}
+(CPIntVarI*) initCPFlipView: (CPIntVarI*)x
{
   CPIntVarI* rv = [x->_recv findAffine:-1 shift:0];
   if (rv==nil) {
      rv = [[CPIntFlipView alloc] initFlipViewFor:x];
   }
   return rv;
}
+(CPIntVarI*) initCPIntView: (CPIntVarI*) x withScale: (ORInt) a
{
   CPIntVarI* rv = [x->_recv findAffine:a shift:0];
   if (rv == nil)
      rv = [[CPIntView alloc] initIVarAViewFor: a x: x b: 0];
   return rv;
}
+(CPIntVarI*) initCPIntView: (CPIntVarI*) x withScale: (ORInt) a andShift: (ORInt) b
{
   CPIntVarI* rv = [x->_recv findAffine:a shift:b];
   if (rv==nil)
      rv = [[CPIntView alloc] initIVarAViewFor: a x: x b: b];
   return rv;
}
+(CPIntVarI*) initCPNegateBoolView: (CPIntVarI*) x
{
   CPIntVarI* rv = [x->_recv findAffine:-1 shift:1];
   if (rv==nil) {
      rv = [[CPIntView alloc] initIVarAViewFor: -1 x: x b: 1];
      rv->_isBool = YES;
   }
   return rv;
}
@end

// ---------------------------------------------------------------------
// Core View Class
// ---------------------------------------------------------------------

@implementation CPCoreIntVarI

-(CPCoreIntVarI*)initCPCoreIntVarI:(CPEngineI*)engine
{
   self = [super init];
   _vc = CPVCBare;
   _isBool = NO;
   _fdm  = engine;
   [_fdm trackVariable: self];
   _recv = nil;
   return self;
}
-(void)dealloc
{
   if (_recv != nil)
      [_recv release];
   [super dealloc];
}
-(enum CPVarClass)varClass
{
   return _vc;
}
-(id<CPDom>) domain
{
   return nil;
}

-(CPLiterals*)findLiterals:(CPIntVarI*)ref
{
   return nil;
}
-(ORBool) isBool
{
   return _isBool;
}
-(CPEngineI*) engine
{
   return _fdm;
}
-(id<ORTracker>) tracker
{
   return _fdm;
}
-(void) addVar:(CPIntVarI*)var
{
   assert(FALSE); // [ldm] should never be called on real vars. Only on multicast
}
-(CPLiterals*)literals
{
   return nil;
}
-(NSMutableSet*)constraints
{
   assert(NO);
   return NULL;
}
-(CPBitDom*)flatDomain
{
   assert(NO);
   return NULL;
}
-(id<CPIntVarNotifier>) delegate
{
   return _recv;
}
-(void) setDelegate:(id<CPIntVarNotifier,NSCoding>) d
{
   if (_recv != d) {
      if (_recv != nil) {
         @throw [[NSException alloc] initWithName:@"Internal Error"
                                           reason:@"Trying to set a delegate that already exists"
                                         userInfo:nil];
      }
      _recv = [d retain];
   }
}
-(CPCoreIntVarI*)findAffine:(ORInt)scale shift:(ORInt)shift
{
   if (scale==1 && shift==0)
      return self;
   else return nil;
}
-(ORBool) isConstant
{
   return NO;
}
-(ORBool) isVariable
{
   return YES;
}
-(ORBool) bound
{
   assert(NO);
}
-(ORInt)mapValue:(ORInt)v
{
   assert(NO);
   return v;
}
-(ORInt) min
{
   assert(NO);
}
-(ORInt) max
{
   assert(NO);
}
-(ORInt) value
{
   assert(NO);
}
-(ORInt) intValue
{
   assert(NO);
}
-(ORBounds) bounds
{
   assert(NO);
}
-(ORInt)domsize
{
   assert(NO);
}
-(ORInt)countFrom:(ORInt)from to:(ORInt)to
{
   assert(NO);
}
-(ORBool)member:(ORInt)v
{
   assert(NO);
}
-(ORRange)around:(ORInt)v
{
   assert(NO);
}
-(ORInt) shift
{
   return 0;
}
-(ORInt) scale
{
   return 1;
}
-(ORInt)literal
{
   return 0;
}
-(id<CPIntVar>)base
{
   return self;
}
-(NSString*)description
{
   id<CPDom> dom = [self domain];
   NSMutableString* s = [NSMutableString stringWithCapacity:64];
#if !defined(_NDEBUG)
   [s appendFormat:@"var<%d>=",_name];
#endif
   if ([dom domsize]==1)
      [s appendFormat:@"%d",[dom min]];
   else {
      [s appendFormat:@"(%d)[",[dom domsize]];
      __block ORInt lastIn;
      __block ORInt firstIn;
      __block bool seq;
      __block bool first = YES;
      [dom enumerateWithBlock:^(ORInt k) {
         if (first) {
            [s appendFormat:@"%d",k];
            first = NO;
            seq   = NO;
            lastIn  = firstIn = k;
         } else {
            if (lastIn + 1 == k) {
               lastIn = k;
               seq    = YES;
            } else {
               if (seq)
                  [s appendFormat:@"..%d,%d",lastIn,k];
               else
                  [s appendFormat:@",%d",k];
               firstIn = lastIn = k;
               seq = NO;
            }
         }
      }];
      if (seq)
         [s appendFormat:@"..%d]",lastIn];
      else [s appendFormat:@"]"];
   }
   [dom release];
   return s;
}

-(ORBool) tracksLoseEvt:(id<CPDom>)sender
{
   assert(NO);
}
// nothing to do here
-(void) setTracksLoseEvt
{
}

// AC3 Closure Events
-(ORStatus) bindEvt:(id<CPDom>)sender
{
   assert(NO);
}
-(ORStatus) changeMinEvt: (ORInt) dsz sender:(id<CPDom>)sender
{
   assert(NO);
}
-(ORStatus) changeMaxEvt: (ORInt) dsz sender:(id<CPDom>)sender
{
   assert(NO);
}
-(ORStatus) loseValEvt: (ORInt) val sender:(id<CPDom>)sender
{
   assert(NO);
}
-(ORStatus) updateMin: (ORInt) newMin
{
   assert(NO);
}
-(ORStatus) updateMax: (ORInt) newMax
{
   assert(NO);
}
-(ORStatus)updateMin:(ORInt) newMin andMax:(ORInt)newMax
{
   assert(NO);
}
-(ORStatus) bind: (ORInt) val
{
   assert(NO);
}
-(ORStatus) remove: (ORInt) val
{
   assert(NO);
}
-(ORStatus) inside:(ORIntSetI*) S
{
   assert(NO);
}

// ---------------------
// AC3 Closure Event
-(void) whenBindDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   assert(NO);
}
-(void) whenChangeDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   assert(NO);
}
-(void) whenChangeMinDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   assert(NO);
}
-(void) whenChangeMaxDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   assert(NO);
}
-(void) whenChangeBoundsDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   assert(NO);
}
-(void) whenBindDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenBindDo:todo priority:HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenChangeDo:todo priority:HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeMinDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenChangeMinDo:todo priority:HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeMaxDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenChangeMaxDo:todo priority:HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeBoundsDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenChangeBoundsDo:todo priority:HIGHEST_PRIO onBehalf:c];
}
// AC3 Constraint Event
-(void) whenBindPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   assert(NO);
}
-(void) whenChangePropagate:  (CPCoreConstraint*) c priority: (ORInt) p
{
   assert(NO);
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   assert(NO);
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   assert(NO);
}
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   assert(NO);
}
-(void) whenBindPropagate: (CPCoreConstraint*) c
{
   [self whenBindPropagate:c priority:HIGHEST_PRIO];
}
-(void) whenChangePropagate:  (CPCoreConstraint*) c
{
   [self whenChangePropagate:c priority:HIGHEST_PRIO];
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c
{
   [self whenChangeMinPropagate:c priority:HIGHEST_PRIO];
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c
{
   [self whenChangeMaxPropagate:c priority:HIGHEST_PRIO];
}
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c
{
   [self whenChangeBoundsPropagate:c priority:HIGHEST_PRIO];
}
-(void) whenLoseValue: (CPCoreConstraint*) c do: (ConstraintIntCallBack) todo
{
   assert(NO);
}
-(void) whenLoseValue: (CPCoreConstraint*) c do: (ConstraintIntCallBack) todo var:(id<CPIntVar>)x
{
   assert(NO);
}
-(id<CPTrigger>) setLoseTrigger: (ORInt) val do: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
   assert(NO);
}
-(id<CPTrigger>) setBindTrigger: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
   assert(NO);
}
-(void) watch:(ORInt) val with: (id<CPTrigger>) t
{
   assert(NO);
}

-(id<ORIntVar>) dereference
{
   return (id<ORIntVar>)self;
}
@end

// ---------------------------------------------------------------------
// Shift View Class
// ---------------------------------------------------------------------

@implementation CPIntShiftView
-(CPIntShiftView*)initIVarShiftView: (CPIntVarI*) x b: (ORInt) b
{
   self = [super initCPCoreIntVarI:[x engine]];
   _vc = CPVCShift;
   _x = x;
   _b = b;
   return self;
}
-(void)dealloc
{
    [super dealloc];
}
-(CPBitDom*)flatDomain
{
   return newDomain((CPBitDom*)[_x domain], 1, _b);
}
-(id<CPDom>)domain
{
   return [[CPAffineDom alloc] initAffineDom:[_x domain] scale:1 shift:_b];
}
-(ORInt)mapValue:(ORInt)v
{
   return [_x mapValue:v] + _b;
}
-(ORBool) bound
{
   return [_x bound];
}
-(ORInt) value
{
   assert([_x bound]);
   return [_x value] + _b;
}
-(ORInt) intValue
{
   assert([_x bound]);
   return [_x value] + _b;
}
-(ORInt)min
{
    return [_x min]+_b;
}
-(ORInt)max
{
    return [_x max]+_b;
}
-(ORBounds)bounds
{
   ORBounds bnd;
   bnd = domBounds((CPBitDom*)[_x domain]);
   bnd.min += _b;
   bnd.max += _b;
   return bnd;
}
-(ORBool)member: (ORInt) v
{
    return [_x member:v-_b];
}
-(ORInt) domsize
{
   return [_x domsize];
}
-(ORRange)around:(ORInt)v
{
   ORRange a = [_x around: v - _b];
   a.low += _b;
   a.up  += _b;
   return a;
}
-(ORInt) shift
{
    return _b;
}
-(ORInt) scale
{
    return 1;
}
-(ORStatus)updateMin: (ORInt) newMin
{
    return [_x updateMin: newMin-_b];
}
-(ORStatus)updateMax: (ORInt) newMax
{
    return [_x updateMax: newMax-_b];
}
-(ORStatus)updateMin:(ORInt) newMin andMax:(ORInt)newMax
{
   ORStatus s = [_x updateMin:newMin-_b];
   if (s)   s = [_x updateMax:newMax-_b];
   return s;
}
-(ORStatus)bind: (ORInt) val
{
    return [_x bind: val-_b];
}
-(ORStatus) remove: (ORInt) val
{
    return [_x remove: val-_b];
}
-(CPCoreIntVarI*)findAffine:(ORInt)scale shift:(ORInt)shift
{
   if (scale==1 && shift==_b)
      return self;
   else return nil;
}
//==================================================================================================
// TODO
-(void)whenBindDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   [_x whenBindDo:todo priority:p onBehalf:c ];
}
-(void)whenChangeDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c 
{
   [_x whenChangeDo:todo priority:p onBehalf:c ];
}
-(void) whenChangeMinDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c 
{
   [_x whenChangeMinDo:todo priority:p onBehalf:c];
}
-(void) whenChangeMaxDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c 
{
   [_x whenChangeMaxDo:todo priority:p onBehalf:c ];
}
-(void) whenChangeBoundsDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c 
{
   [_x whenChangeBoundsDo:todo priority:p onBehalf:c ];
}
-(void) whenBindPropagate: (CPCoreConstraint*) c priority: (ORInt) p 
{
   [_x whenBindPropagate:c priority:p];
}
-(void) whenChangePropagate:  (CPCoreConstraint*) c priority: (ORInt) p 
{
   [_x whenChangePropagate:c priority:p];
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p 
{
   [_x whenChangeMinPropagate:c priority:p];
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p 
{
   [_x whenChangeMaxPropagate:c priority:p];
}
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c priority: (ORInt) p 
{
   [_x whenChangeBoundsPropagate:c priority:p];
}
-(void) whenLoseValue: (CPCoreConstraint*) c do: (ConstraintIntCallBack) todo
{
   [_x whenLoseValue:c do:todo var:self];
}
-(void) whenLoseValue: (CPCoreConstraint*) c do: (ConstraintIntCallBack) todo var:(id<CPIntVar>)x
{
   [_x whenLoseValue:c do:todo var:self];
}
-(id<CPTrigger>) setLoseTrigger: (ORInt) value do: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
   return [_x setLoseTrigger:value - _b do:todo onBehalf:c];
}
-(void) watch: (ORInt) val with: (id<CPTrigger>) t;
{
   [_x watch:val - _b with:t];
}
-(id<CPTrigger>) setBindTrigger: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c 
{
   return [_x setBindTrigger:todo onBehalf:c];
}
// Events ==========================================================
-(ORStatus) bindEvt:(id<CPDom>)sender
{
   assert(NO);
}
-(ORStatus) changeMinEvt: (ORInt) dsz sender:(id<CPDom>)sender
{
   assert(NO);
}
-(ORStatus) changeMaxEvt: (ORInt) dsz sender:(id<CPDom>)sender
{
   assert(NO);
}
-(ORStatus) loseValEvt: (ORInt) val sender:(id<CPDom>)sender
{
   assert(NO);
   return [super loseValEvt: val+_b sender:sender];
}
@end

// ---------------------------------------------------------------------
// Affine View Class
// ---------------------------------------------------------------------

@implementation CPIntView
-(CPIntView*)initIVarAViewFor: (ORInt) a  x: (CPIntVarI*) x b: (ORInt) b
{
   ORInt vLow = a < 0 ? a * [x max] + b : a * [x min] + b;
   ORInt vUp  = a < 0 ? a * [x min] + b : a * [x max] + b;
   self = [super initCPCoreIntVarI:[x engine]];
   _vc = CPVCAffine;
   _x = x;
   _a = a;
   _b = b;
   return self;
}
-(void)dealloc
{
    [super dealloc];
}
-(CPBitDom*)flatDomain
{
   return newDomain((CPBitDom*)[_x domain], _a, _b);
}
-(id<CPDom>)domain
{
   return [[CPAffineDom alloc] initAffineDom:[_x domain] scale:_a shift:_b];
}
-(ORBool) bound
{
   return [_x bound];
}
-(ORInt)mapValue:(ORInt)v
{
   return _a * [_x mapValue:v] + _b;
}
-(ORInt) value
{
   assert([_x bound]);
   return _a * [_x value] + _b;
}
-(ORInt) intValue
{
   assert([_x bound]);
   return _a * [_x value] + _b;
}
-(ORInt) min
{
    if (_a > 0)
        return _a * [_x min] + _b;
    else return _a * [_x max] + _b;
}
-(ORInt) max
{
    if (_a > 0)
        return _a * [_x max] + _b;
    else return _a * [_x min] + _b;
}
-(ORBounds)bounds
{
   ORBounds b = bounds(_x);
   return (ORBounds){
      _a > 0 ? b.min * _a + _b : b.max * _a + _b,
      _a > 0 ? b.max * _a + _b : b.min * _a + _b
   };
}
-(ORBool)member: (ORInt) v
{
    ORInt r = (v - _b) % _a;
    if (r != 0) return NO;
    ORInt dv = (v - _b) / _a;
    return [_x member:dv];
}
-(ORInt) domsize
{
   return [_x domsize];
}
-(ORRange)around:(ORInt)v
{
   ORRange a = [_x around: (v - _b) / _a];
   return (ORRange){a.low * _a + _b,a.up * _a  + _b};
}

-(ORInt) shift
{
    return _b;
}
-(ORInt) scale
{
    return _a;
}
-(ORStatus) updateMin: (ORInt) newMin
{
   ORInt op = newMin - _b;
   ORInt mv = op % _a ? 1 : 0;   // multiplier value
   if (_a > 0) {
      ORInt ms = op > 0 ? +1 : 0;  // multiplier sign
      return [_x updateMin:op / _a + ms * mv];
   } else {
      ORInt ms = op > 0 ?  -1 : 0;
      return [_x updateMax:op / _a + ms * mv];
   }
}
-(ORStatus) updateMax: (ORInt) newMax
{
   ORInt op = newMax - _b;
   ORInt mv = op % _a ? 1 : 0;
   if (_a > 0) {
      ORInt ms = op > 0  ? 0 : -1;
      return [_x updateMax:op / _a + ms * mv];
   } else {
      ORInt ms = op < 0 ? +1 : 0;
      return [_x updateMin:op / _a + ms * mv];
   }
}
-(ORStatus)updateMin:(ORInt) newMin andMax:(ORInt)newMax
{
   ORStatus s = [self updateMin:newMin];
   if (s == ORFailure) return s;
   return [self updateMax:newMax];
}

-(ORStatus)bind: (ORInt) val
{
    ORInt r = (val - _b) % _a;
    if (r != 0)
       failNow();
    ORInt ov = (val - _b) / _a; 
    return [_x bind:ov];
}
-(ORStatus)remove: (ORInt) val
{
   ORInt ov;
   if (_a == -1)
      ov = _b - val;
   else if (_a== 1)
      ov = val - _b;
   else {
      ORInt r = (val - _b) % _a;
      if (r != 0) return ORSuspend;
      ov = (val - _b) / _a; 
   }
   return [_x remove:ov];
}
-(ORStatus) loseValEvt: (ORInt) val sender:(id<CPDom>)sender
{
   assert(NO);
   return [super loseValEvt:_a * val+_b sender:sender];
}
-(CPIntVarI*)findAffine:(ORInt)scale shift:(ORInt)shift
{
   if (scale == _a && shift == _b)
      return self;
   else return nil;
}
-(NSString*)description
{
   return [super description];
}
//==================================================================================================
// TODO
-(void)whenBindDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   [_x whenBindDo:todo priority:p onBehalf:c ];
}
-(void)whenChangeDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   [_x whenChangeDo:todo priority:p onBehalf:c ];
}
-(void) whenChangeMinDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   [_x whenChangeMinDo:todo priority:p onBehalf:c];
}
-(void) whenChangeMaxDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   [_x whenChangeMaxDo:todo priority:p onBehalf:c ];
}
-(void) whenChangeBoundsDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   [_x whenChangeBoundsDo:todo priority:p onBehalf:c ];
}
-(void) whenBindPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   [_x whenBindPropagate:c priority:p];
}
-(void) whenChangePropagate:  (CPCoreConstraint*) c priority: (ORInt) p
{
   [_x whenChangePropagate:c priority:p];
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   [_x whenChangeMinPropagate:c priority:p];
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   [_x whenChangeMaxPropagate:c priority:p];
}
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   [_x whenChangeBoundsPropagate:c priority:p];
}
-(void) whenLoseValue: (CPCoreConstraint*) c do: (ConstraintIntCallBack) todo
{
   [_x whenLoseValue:c do:todo var:self];
}
-(void) whenLoseValue: (CPCoreConstraint*) c do: (ConstraintIntCallBack) todo var:(id<CPIntVar>)x
{
   [_x whenLoseValue:c do:todo var:self];
}
-(id<CPTrigger>) setLoseTrigger: (ORInt) value do: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
   ORInt r = (value - _b) % _a;
   if (r != 0)
      return nil;
   ORInt ov = (value - _b) / _a;

   return [_x setLoseTrigger:ov do:todo onBehalf:c];
}
-(void) watch: (ORInt) val with: (id<CPTrigger>) t;
{
   ORInt r = (val - _b) % _a;
   if (r != 0)
      return;
   ORInt ov = (val - _b) / _a;
   [_x watch:ov with:t];
}
-(id<CPTrigger>) setBindTrigger: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
   return [_x setBindTrigger:todo onBehalf:c];
}
// Events ==========================================================
@end

@implementation CPIntFlipView
-(CPIntFlipView*)initFlipViewFor:(CPIntVarI*)x
{
   self = [super initCPCoreIntVarI:[x engine]];
   _vc = CPVCFlip;
   _x = x;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(CPBitDom*)flatDomain
{
   return newDomain((CPBitDom*)[_x domain], -1, 0);
}
-(id<CPDom>)domain
{
   return [[CPAffineDom alloc] initAffineDom:[_x domain] scale:-1 shift:0];
}
-(ORBool) bound
{
   return [_x bound];
}
-(ORInt)mapValue:(ORInt)v
{
   return - [_x mapValue:v];
}
-(ORInt) value
{
   assert([_x bound]);
   return - [_x value];
}
-(ORInt) intValue
{
   assert([_x bound]);
   return - [_x value];
}
-(ORInt) min
{
   return - [_x max];
}
-(ORInt) max
{
   return - [_x min];
}
-(ORBounds)bounds
{
   ORBounds b = [_x bounds];
   return (ORBounds){-b.max,-b.min};
}
-(ORBool)member:(ORInt)v
{
   return [_x member:-v];
}
-(ORInt) domsize
{
   return [_x domsize];
}
-(ORRange)around:(ORInt)v
{
   ORRange a = [_x around:-v];
   return (ORRange){-a.up,-a.low};
}
-(ORInt) shift
{
   return 0;
}
-(ORInt) scale
{
   return -1;
}
-(ORStatus)updateMin:(ORInt)newMin
{
   return [_x updateMax:-newMin];
}
-(ORStatus)updateMax:(ORInt)newMax
{
   return [_x updateMin:-newMax];
}
-(ORStatus)updateMin:(ORInt) newMin andMax:(ORInt)newMax
{
   ORStatus s = [_x updateMax:-newMin];
   if (s == ORFailure) return s;
   return [_x updateMin:-newMax];
}
-(ORStatus)bind:(ORInt)val
{
   return [_x bind:-val];
}
-(ORStatus)remove:(ORInt)val
{
   return [_x remove:-val];
}
-(ORStatus) loseValEvt:(ORInt)val sender:(id<CPDom>)sender
{
   assert(NO);
   return [super loseValEvt:-val sender:sender];
}
-(NSString*)description
{
   return [super description];
}
//==================================================================================================
// TODO
-(void)whenBindDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   [_x whenBindDo:todo priority:p onBehalf:c ];
}
-(void)whenChangeDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   [_x whenChangeDo:todo priority:p onBehalf:c ];
}
-(void) whenChangeMinDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   [_x whenChangeMinDo:todo priority:p onBehalf:c];
}
-(void) whenChangeMaxDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   [_x whenChangeMaxDo:todo priority:p onBehalf:c ];
}
-(void) whenChangeBoundsDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   [_x whenChangeBoundsDo:todo priority:p onBehalf:c ];
}
-(void) whenBindPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   [_x whenBindPropagate:c priority:p];
}
-(void) whenChangePropagate:  (CPCoreConstraint*) c priority: (ORInt) p
{
   [_x whenChangePropagate:c priority:p];
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   [_x whenChangeMinPropagate:c priority:p];
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   [_x whenChangeMaxPropagate:c priority:p];
}
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   [_x whenChangeBoundsPropagate:c priority:p];
}
-(void) whenLoseValue: (CPCoreConstraint*) c do: (ConstraintIntCallBack) todo
{
   [_x whenLoseValue:c do:todo var:self];
}
-(void) whenLoseValue: (CPCoreConstraint*) c do: (ConstraintIntCallBack) todo var:(id<CPIntVar>)x
{
   [_x whenLoseValue:c do:todo var:self];
}
-(id<CPTrigger>) setLoseTrigger: (ORInt) value do: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
   return [_x setLoseTrigger:-value do:todo onBehalf:c];
}
-(void) watch: (ORInt) val with: (id<CPTrigger>) t;
{
   [_x watch: - val with:t];
}
-(id<CPTrigger>) setBindTrigger: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
   return [_x setBindTrigger:todo onBehalf:c];
}
// Events ==========================================================
@end

/*****************************************************************************************/
/*                        MultiCast Notifier                                             */
/*****************************************************************************************/

@implementation CPIntVarMultiCast

-(id)initVarMC:(ORInt)n root:(CPIntVarI*)root
{
   self = [super init];
   _mx  = n;
   _tab = malloc(sizeof(CPIntVarI*)*_mx);
   _loseValIMP   = malloc(sizeof(IMP)*_mx);
   _tracksLoseEvt = false;
   [root setDelegate:self];
//   _tab[0] = root;
//   _tracksLoseEvt |= [_tab[0] tracksLoseEvt:nil];
//   _loseValIMP[0] = (UBType)[root methodForSelector:@selector(loseValEvt:sender:)];
//   _nb  = 1;
   _nb = 0;
   return self;
}
-(ORInt)getId
{
   assert(FALSE);
   return 0;
}
-(void)setDelegate:(id<CPIntVarNotifier>)delegate
{}
-(void) dealloc
{
   //NSLog(@"multicast object %p dealloc'd\n",self);
   free(_tab);
   [super dealloc];
}
-(enum CPVarClass)varClass
{
   return CPVCLiterals;
}
-(void) addVar:(CPIntVarI*)v
{
   if (_nb >= _mx) {
      _tab = realloc(_tab,sizeof(CPIntVarI*)*(_mx<<1));
      _loseValIMP = realloc(_loseValIMP,sizeof(IMP)*(_mx << 1));
      _mx <<= 1;
   }
   _tab[_nb] = v;  // DO NOT RETAIN. v will point to us because of the delegate
   //[_tab[_nb] setDelegate:self];
   _tracksLoseEvt |= [_tab[_nb] tracksLoseEvt:nil];
   _loseValIMP[_nb] = (UBType)[v methodForSelector:@selector(loseValEvt:sender:)];
   id<ORTrail> theTrail = [[v engine] trail];
   ORInt toFix = _nb;
   [theTrail trailClosure:^{
      _tab[toFix] = NULL;
      _loseValIMP[toFix] = NULL;
      _nb = toFix;  // [ldm] This is critical (see comment below in bindEvt)
   }];
   _nb++;
   ORInt nbBare = 0;
   for(ORInt i=0;i<_nb;i++) {
      if (_tab[i] !=nil)
         nbBare += ([_tab[i] varClass] == CPVCBare);
   }
   assert(nbBare<=1);
}
-(NSMutableSet*)constraints
{
   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:8];
   for(ORInt i=0;i<_nb;i++) {
      NSMutableSet* ti = [_tab[i] constraints];
      [rv unionSet:ti];
      [ti release];
   }
   return rv;
}

-(CPLiterals*)findLiterals:(CPIntVarI*)ref
{
   for(ORUInt i=0;i < _nb;i++) {
      CPLiterals* found = [_tab[i] literals];
      if (found)
         return found;
   }
   CPLiterals* newLits = [[CPLiterals alloc] initCPLiterals:ref];
   if (_nb >= _mx) {
      _tab = realloc(_tab,sizeof(CPIntVarI*)*(_mx<<1));
      _loseValIMP = realloc(_loseValIMP,sizeof(IMP)*(_mx << 1));
      _mx <<= 1;
   }
   _tab[_nb] = newLits;
   _loseValIMP[_nb] = (UBType)[newLits methodForSelector:@selector(loseValEvt:sender:)];
   _tracksLoseEvt = YES;
   ORInt toFix = _nb;
   id<ORTrail> theTrail = [[ref engine] trail];
   [theTrail trailClosure:^{
      _tab[toFix] = NULL;
      _loseValIMP[toFix] = NULL;
   }];
   _nb++;
   return newLits;
}
-(CPLiterals*)literals
{
   return nil;
}
-(CPIntVarI*)findAffine:(ORInt)scale shift:(ORInt)shift
{
   for(ORUInt i=0;i < _nb;i++) {
      CPIntVarI* sel = [_tab[i] findAffine:scale shift:shift];
      if (sel)
         return sel;
   }
   return nil;
}

-(NSString*)description
{
   static const char* classes[] = {"Bare","Shift","Affine","EQLit","Literals","Flip","NEQLit"};
   NSMutableString* buf = [NSMutableString stringWithCapacity:64];
   [buf appendFormat:@"MC:<%d>[",_nb];
   for(ORUInt k=0;k<_nb;k++) {
      if (_tab[k] == nil)
         [buf appendFormat:@"nil %c",k < _nb -1 ? ',' : ']'];
      else
         [buf appendFormat:@"%d-%s %c",[_tab[k] getId],classes[[_tab[k] varClass]],k < _nb -1 ? ',' : ']'];
   }
   return buf;
}
-(void) setTracksLoseEvt
{
    _tracksLoseEvt = true;
}
-(ORBool) tracksLoseEvt:(id<CPDom>)sender
{
    return _tracksLoseEvt;
}
-(ORStatus)bindEvt:(id<CPDom>)sender
{
   // If _nb > 0 but the _tab entries are nil, this would inadvertently
   // set ok to ORFailure which is wrong. Hence it is critical to also
   // backtrack the size of the array in addVar.
   for(ORInt i=0;i<_nb;i++) {
       ORStatus ok = [_tab[i] bindEvt:sender];
      if (!ok) return ok;
   }
   return ORSuspend;
}
-(ORStatus) changeMinEvt:(ORInt)dsz sender:(id<CPDom>)sender
{
   for(ORInt i=0;i<_nb;i++) {
      ORStatus ok = [_tab[i] changeMinEvt:dsz sender:sender];
      if (!ok) return ok;
   }
   return ORSuspend;
}
-(ORStatus) changeMaxEvt:(ORInt)dsz sender:(id<CPDom>)sender
{
   for(ORInt i=0;i<_nb;i++) {
      ORStatus ok = [_tab[i] changeMaxEvt:dsz sender:sender];
      if (!ok) return ok;
   }
   return ORSuspend;
}
-(ORStatus) loseValEvt:(ORInt)val sender:(id<CPDom>)sender
{
   if (!_tracksLoseEvt) return ORSuspend;
   ORStatus ok;
   for(ORInt i=0;i<_nb;i++) {
      //ORStatus ok = [_tab[i] loseValEvt:val sender:sender];
      if (_loseValIMP[i])
         ok = _loseValIMP[i](_tab[i],@selector(loseValEvt:sender:),val,sender);
      if (!ok) return ok;
   }
   return ORSuspend;
}
@end

@implementation CPLiterals
-(id)initCPLiterals:(CPIntVarI*)ref
{
   self = [super init];
   _nb  = [[ref domain] imax] - [[ref domain] imin] + 1;
   _ofs = [[ref domain] imin];
   _ref = ref;
   _pos = malloc(sizeof(CPIntVarI*)*_nb);
   for(ORInt i=0;i<_nb;i++)
      _pos[i] = nil;
   _tracksLoseEvt = NO;
   return self;
}
-(void)dealloc
{
   free(_pos);
   [super dealloc];
}
-(ORInt)getId
{
   return 0;
}
-(NSMutableSet*)constraints
{
   assert(FALSE);
   return nil;
}
-(void)setDelegate:(id<CPIntVarNotifier>)delegate
{}
-(void) addVar:(CPIntVarI*)var
{}
-(enum CPVarClass)varClass
{
   return CPVCLiterals;
}
-(CPLiterals*)findLiterals:(CPIntVarI*)ref
{
   return self;
}
-(CPLiterals*)literals
{
   return self;
}
-(void) setTracksLoseEvt
{
   _tracksLoseEvt = YES;
}
-(ORBool) tracksLoseEvt:(id<CPDom>)sender
{
   return _tracksLoseEvt;
}
-(CPIntVarI*)findAffine:(ORInt)scale shift:(ORInt)shift
{
   return nil;
}
-(void)addPositive:(CPIntVarI*)x forValue:(ORInt)value
{
   assert(_pos[value - _ofs] == 0);
   _pos[value - _ofs] = x;
}
-(id<CPIntVar>)positiveForValue:(ORInt)value
{
   return _pos[value - _ofs];
}

-(ORStatus) bindEvt:(id<CPDom>)sender
{
   return [_pos[[sender min] - _ofs] bindEvt:sender];
}
-(ORStatus) changeMinEvt:(ORInt)dsz sender:(id<CPDom>)sender
{
   ORInt min = [_ref min];
   for(ORInt i=_ofs;i <min;i++) {
      ORStatus ok = [_pos[i - _ofs] changeMinEvt:dsz sender:sender];
      if (!ok) return ok;
   }
   if (dsz==1)
      return [_pos[[sender min] - _ofs] bindEvt:sender];
   else
      return ORSuspend;
}
-(ORStatus) changeMaxEvt:(ORInt)dsz sender:(id<CPDom>)sender
{
   ORInt max = [_ref max];
   for(ORInt i = max+1;i<_ofs+_nb;i++) {
      ORStatus ok = [_pos[i - _ofs] changeMaxEvt:dsz sender:sender];
      if (!ok) return ok;
   }
   if (dsz==1)
      return [_pos[[sender min] - _ofs] bindEvt:sender];
   else
      return ORSuspend;
}
-(ORStatus) loseValEvt:(ORInt)val sender:(id<CPDom>)sender
{
   return [_pos[val - _ofs] loseValEvt:val sender:sender];
}
@end
