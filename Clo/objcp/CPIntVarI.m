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
    //NSLog(@"CIVar::dealloc %d\n",_name);
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
-(ORBool) bound
{
   assert(_dom);
    return [_dom bound];
//   return sizeCPDom((CPBitDom*)_dom) == 1;
}
-(ORInt) min
{
   assert(_dom);
   return [_dom min];
   //return minCPDom((CPBitDom*)_dom);
}
-(ORInt) max 
{
   assert(_dom);
   return [_dom max];
   //return maxCPDom((CPBitDom*)_dom);
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
   if ([dom isKindOfClass:[CPBoundsDom class]]) {
      if ([dom domsize]==1)
         [s appendFormat:@"%d",[dom min]];
      else {
         [s appendFormat:@"(%d)[",[dom domsize]];
         [s appendFormat:@"%d .. %d]",[dom min],[dom max]];
      };
   } else {
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
   hookupEvent(_fdm,&_net._boundsEvt, todo, c, p);
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
   hookupEvent(_fdm, &_net._boundsEvt, nil, c, p);
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

// AC5 Events
-(void) whenLoseValue: (CPCoreConstraint*) c do: (ConstraintIntCallBack) todo 
{
   [_recv setTracksLoseEvt];
   hookupEvent(_fdm, &_net._ac5, todo, c, HIGHEST_PRIO);
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
   ORStatus s = _recv==nil ? ORSuspend : [_recv bindEvt:sender];
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
   ORStatus s = _recv==nil ? ORSuspend : [_recv changeMinEvt:dsz sender:sender];
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
   ORStatus s = _recv==nil ? ORSuspend : [_recv changeMaxEvt:dsz sender:sender];
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
   ORStatus s = ORSuspend;
   if (_recv !=nil) {
      s = [_recv loseValEvt:val sender:sender];
      if (s==ORFailure) return s;
   }
   if (_net._domEvt._val != NULL) {
      id<CPEventNode> mList[2];
      mList[0] = _net._domEvt._val;
      mList[1] = NULL;
      scheduleAC3(_fdm,mList);
   }
   if (_net._ac5._val)
      [_fdm scheduleAC5:[CPValueLossEvent newValueLoss:val notify:_net._ac5._val]];
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

//-(id<ORIntVar>) dereference
//{
//   @throw [[ORExecutionError alloc] initORExecutionError: "Dereferencing is totally obsolete"];
//   return (id<ORIntVar>)self;
//}
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
// Shift View Class
// ---------------------------------------------------------------------

@implementation CPIntShiftView
-(CPIntShiftView*)initIVarShiftView: (CPIntVarI*) x b: (ORInt) b
{
   self = [super initCPIntVarView:[x engine] low:[x min]+b up:[x max]+b for:x];
   _vc = CPVCShift;
   //_dom  = (CPBoundsDom*)[[x domain] retain];
   _dom = nil;
   _x = x;
   _b = b;
   return self;
}
-(void)dealloc
{
    [super dealloc];  // CPIntVar will already release the domain. We do _NOT_ have to do it again.
}
-(CPBitDom*)flatDomain
{
   return newDomain((CPBitDom*)[_x domain], 1, _b);
}
-(id<CPDom>)domain
{
   return [[CPAffineDom alloc] initAffineDom:[_x domain] scale:1 shift:_b];
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
//   ORInt low = [_dom findMax:v - _b - 1];
//   ORInt up  = [_dom findMin:v - _b + 1];
//   return (ORRange){low + _b,up + _b};
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
// get the notification from the underlying domain; need to shift it for the network
-(ORStatus) loseValEvt: (ORInt)  val sender:(id<CPDom>)sender
{
   return [super loseValEvt: val+_b sender:sender];
}
-(CPIntVarI*)findAffine:(ORInt)scale shift:(ORInt)shift
{
   if (scale==1 && shift==_b)
      return self;
   else return nil;
}
-(NSString*) description
{
   return [super description];
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
   self = [super initCPIntVarView: [x engine] low:vLow up:vUp for:x];
   _vc = CPVCAffine;
   //_dom = (CPBoundsDom*)[[x domain] retain];
   _dom = nil;
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
   return memberDom(_x, dv);
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
-(void) whenChangeMinDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   if (_a<0)
      hookupEvent(_fdm, &_net._maxEvt, todo, c, p);
   else
      hookupEvent(_fdm, &_net._minEvt, todo, c, p);
}
-(void) whenChangeMaxDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   if (_a<0)
      hookupEvent(_fdm, &_net._minEvt, todo, c, p);
   else
      hookupEvent(_fdm, &_net._maxEvt, todo, c, p);
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   if (_a<0)
      hookupEvent(_fdm, &_net._maxEvt, nil, c, p);
   else
      hookupEvent(_fdm, &_net._minEvt, nil, c, p);
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   if (_a<0)
      hookupEvent(_fdm, &_net._minEvt, nil, c, p);
   else
      hookupEvent(_fdm, &_net._maxEvt, nil, c, p);
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
/*
   ORStatus s;
   ORInt tMin = (newMin - _b) / _a;
   ORInt tMax = (newMax - _b) / _a;
   if (_a > 0) {      
      ORInt rMin = (newMin - _b) % _a;
      s = [_dom updateMin:tMin + (rMin != 0) for:self];
      if (s) s = [_dom updateMax:tMax for:self];
   } else {
      ORInt rMax = (newMax - _b) % _a;
      s = [_dom updateMax:tMin for:self];
      if (s) s = [_dom updateMin:tMax + (rMax!=0) for:self];
   }
   return s;
 */
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
@end

@implementation CPIntFlipView
-(CPIntFlipView*)initFlipViewFor:(CPIntVarI*)x
{
   self = [super initCPIntVarView: [x engine] low:-[x max] up:-[x min] for:x];
   _vc = CPVCFlip;
   //_dom = (CPBoundsDom*)[[x domain] retain];
   _dom = nil;
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
-(void) whenChangeMinDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent(_fdm, &_net._maxEvt, todo, c, p);
}
-(void) whenChangeMaxDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent(_fdm, &_net._minEvt, todo, c, p);
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent(_fdm, &_net._maxEvt, nil, c, p);
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent(_fdm, &_net._minEvt, nil, c, p);
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
   return [super loseValEvt:-val sender:sender];
}
-(NSString*)description
{
   return [super description];
}
@end

@implementation CPEQLitView

-(CPEQLitView*)initEQLitViewFor:(CPIntVarI*)x equal:(ORInt)v
{
   assert(x->_vc == CPVCBare);
   self = [self initCPIntVarCore:[x engine] low: 0 up: 1];
   _isBool = YES;
   _secondary = x;
   _v = v;
   _vc = CPVCEQLiteral;
   return self;
}

-(void)dealloc
{
   [super dealloc];
}
-(CPBitDom*)flatDomain
{
   return [[CPBitDom alloc] initBitDomFor:[_fdm trail] low:0 up:1];
}
-(CPBitDom*)domain
{
   return [[CPBitDom alloc] initBitDomFor:[_fdm trail] low:[self min] up:[self max]];
}
-(ORBool) bound
{
   if (bound(_secondary)) {
      return TRUE;
   } else {
      if (memberDom(_secondary, _v))
         return FALSE;
      else return TRUE;
   }
}
-(ORInt) value
{
   assert([_secondary bound]);
   return [_secondary value]==_v;
}
-(ORInt) intValue
{
   assert([_secondary bound]);
   return [_secondary value]==_v;
}
-(ORInt) min
{
   ORBounds sb = bounds(_secondary);
   if (sb.min == sb.max)
      return sb.min==_v;
   else return 0;
}
-(ORInt) max
{
   ORBounds sb = bounds(_secondary);
   if (sb.min == sb.max)
      return sb.min==_v;
   else
      return memberDom(_secondary, _v);
}
-(ORBool)member:(ORInt)val
{
   ORInt lb = [_secondary min];
   ORInt ub = [_secondary max];
   // [ldm] v should be a boolean (0,1)
   // Case 1: lit IN    D(x)         => 0 IN D(self) AND 1 in D(self) : always say yes.
   // Case 2: lit NOTIN D(x)         => 0 in D(self) AND 1 NOTIN D(self).
   // Case 3: lit IN D(x) & |D(x)|=1 => 1 in D(self) AND 0 NOTIN D(self).
   if (lb == ub && lb == _v) {
      return val;
   } else {
      if (_v < lb || _v > ub || !memberBitDom(_secondary, _v))
         return !val;
      else {
         return YES;
      }
   }
}
-(ORBounds)bounds
{
   ORBounds sb = bounds(_secondary);
   ORBool b  = sb.min == sb.max;
   if (b) {
      ORBool bToV = sb.min == _v;
      return (ORBounds){bToV,bToV};
   } else
      return (ORBounds){0,memberDom(_secondary, _v)};
}
-(ORInt) domsize
{
   if (bound(_secondary)) {
      return 1;
   } else {
      if (memberDom(_secondary, _v))
         return 2;
      else return 1;
   }
}

-(ORRange)around:(ORInt)v
{
   return (ORRange){0,1};
}
-(ORInt) shift
{
   return 0;
}
-(ORInt) scale
{
   return 1;
}
-(ORStatus)updateMin:(ORInt)newMin
{
   // newMin>=1 => x==v
   // newMin==0 => nothing
   if (newMin) {
      return [_secondary bind:_v];
   } else
      return ORSuspend;
}
-(ORStatus)updateMax:(ORInt)newMax
{
   // newMax == 0 => x != v
   // newMax >= 1 => nothing
   if (newMax==0) {
      return [_secondary remove:_v];
   } else
      return ORSuspend;
}
-(ORStatus)updateMin:(ORInt) newMin andMax:(ORInt)newMax
{
   ORStatus ok = ORSuspend;
   if (newMin) {
      ok = [_secondary bind:_v];
   }
   if (ok && newMax==0) {
      ok = [_secondary remove:_v];
   }
   return ok;
}
-(ORStatus)bind:(ORInt)val
{
   assert(val==0 || val==1);
   // self=0 => x must loose _lit
   // self=1 => x must be bound to _lit
   if (val==0) {
      return [_secondary remove:_v];
   } else {
      return [_secondary bind:_v];
   }
}
-(ORStatus)remove:(ORInt)val
{
   assert(val==0 || val==1);
   // val==0 -> bind to 1 -> x must be bound to _lit
   // val==1 -> bind to 0 -> x must loose _lit
   if (val==0) {
      return [_secondary bind:_v];
   } else {
      return [_secondary remove:_v];
   }
}
-(ORStatus)bindEvt:(id<CPDom>)sender
{
   assert(bound(_secondary));
//   ORInt boundTo = minDom(_secondary);
   return [super bindEvt:sender];
}

-(ORStatus) loseValEvt:(ORInt)val sender:(id<CPDom>)sender
{
   if (val == _v) {
      // We lost the value being watched. So the boolean lost TRUE
      return [super loseValEvt:TRUE sender:sender];
   } else {
      // We lost some other value. So we may have bound(_seconday) && minDom(_secondary)==_v      
      if (bound(_secondary) && minDom(_secondary) == _v) {
         return [super loseValEvt:FALSE sender:sender];
      } else return ORSuspend;
   }
}
-(ORStatus) changeMinEvt:(ORInt)dsz sender:(id<CPDom>)sender
{
   ORInt myMin = [self min];
   ORInt myMax = [self max];
   if (myMin)
      return [super bindEvt:sender];
   else if (myMax==0)
      return [super bindEvt:sender];
   else return ORSuspend;
}
-(ORStatus) changeMaxEvt:(ORInt)dsz sender:(id<CPDom>)sender
{
   ORInt myMin = [self min];
   ORInt myMax = [self max];
   if (myMin)
      return [super bindEvt:sender];
   else if (myMax==0)
      return [super bindEvt:sender];
   else return ORSuspend;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   if ([self bound])
      [buf appendFormat:@"var<%d>+=%d (LIT=%d)",_name,[self min],_v];
   else
      [buf appendFormat:@"var<%d>+={0,1} (LIT=%d)",_name,_v];
   return buf;
}
@end

/*****************************************************************************************/
/*                        MultiCast Notifier                                             */
/*****************************************************************************************/

@implementation CPIntVarMultiCast

-(id)initVarMC:(ORInt)n root:(CPIntVarI*)root
{
   self = [super init];
   _mx  = n;
   _tab = malloc(sizeof(id<CPIntVarNotifier>)*_mx);
   _loseValIMP   = malloc(sizeof(UBType)*_mx);
   _minIMP   = malloc(sizeof(UBType)*_mx);
   _maxIMP   = malloc(sizeof(UBType)*_mx);
   _tracksLoseEvt = false;
   [root setDelegate:self];
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
   /*
    for(ORInt i=0;i<_nb;i++) {
      if ([_tab[i] isKindOfClass:[CPLiterals class]])
         [_tab[i] release];
   }
    */
   free(_tab);
   free(_minIMP);
   free(_maxIMP);
   free(_loseValIMP);
   [super dealloc];
}
-(enum CPVarClass)varClass
{
   return CPVCLiterals;
}
-(void) addVar:(CPIntVarI*)v
{
   if (_nb >= _mx) {
      _tab = realloc(_tab,sizeof(id<CPIntVarNotifier>)*(_mx<<1));
      _loseValIMP = realloc(_loseValIMP,sizeof(UBType)*(_mx << 1));
      _minIMP     = realloc(_minIMP,sizeof(UBType)*(_mx << 1));
      _maxIMP     = realloc(_maxIMP,sizeof(UBType)*(_mx << 1));
      _mx <<= 1;
   }
   _tab[_nb] = v;  // DO NOT RETAIN. v will point to us because of the delegate
   _tracksLoseEvt |= [_tab[_nb] tracksLoseEvt:nil];
   _loseValIMP[_nb] = (UBType)[v methodForSelector:@selector(loseValEvt:sender:)];
   _minIMP[_nb] = (UBType)[v methodForSelector:@selector(changeMinEvt:sender:)];
   _maxIMP[_nb] = (UBType)[v methodForSelector:@selector(changeMaxEvt:sender:)];
   id<ORTrail> theTrail = [[v engine] trail];
   ORInt toFix = _nb;
   __block CPIntVarMultiCast* me = self;
   [theTrail trailClosure:^{
      me->_tab[toFix] = NULL;
      me->_loseValIMP[toFix] = NULL;
      me->_minIMP[toFix] = NULL;
      me->_maxIMP[toFix] = NULL;
      me->_nb = toFix;  // [ldm] This is critical (see comment below in bindEvt)
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
      _tab = realloc(_tab,sizeof(id<CPIntVarNotifier>)*(_mx<<1));
      _loseValIMP = realloc(_loseValIMP,sizeof(UBType)*(_mx << 1));
      _minIMP = realloc(_minIMP,sizeof(UBType)*(_mx << 1));
      _maxIMP = realloc(_maxIMP,sizeof(UBType)*(_mx << 1));
      _mx <<= 1;
   }
   _tab[_nb] = newLits;
   _loseValIMP[_nb] = (UBType)[newLits methodForSelector:@selector(loseValEvt:sender:)];
   _minIMP[_nb] = (UBType)[newLits methodForSelector:@selector(changeMinEvt:sender:)];
   _maxIMP[_nb] = (UBType)[newLits methodForSelector:@selector(changeMaxEvt:sender:)];
   _tracksLoseEvt = YES;
   ORInt toFix = _nb;
   id<ORTrail> theTrail = [[ref engine] trail];
   __block CPIntVarMultiCast* me = self;
   [theTrail trailClosure:^{
      me->_tab[toFix] = NULL;
      me->_loseValIMP[toFix] = NULL;
      me->_minIMP[toFix] = NULL;
      me->_maxIMP[toFix] = NULL;
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
   SEL ms = @selector(changeMinEvt:sender:);
   for(ORInt i=0;i<_nb;i++) {
      //ORStatus ok = [_tab[i] changeMinEvt:dsz sender:sender];
      assert(_minIMP[i]);
      ORStatus ok = _minIMP[i](_tab[i],ms,dsz,sender);
      if (!ok) return ok;
   }
   return ORSuspend;
}
-(ORStatus) changeMaxEvt:(ORInt)dsz sender:(id<CPDom>)sender
{
   SEL ms = @selector(changeMaxEvt:sender:);
   for(ORInt i=0;i<_nb;i++) {
      //ORStatus ok = [_tab[i] changeMaxEvt:dsz sender:sender];
      assert(_maxIMP[i]);
      ORStatus ok = _maxIMP[i](_tab[i],ms,dsz,sender);
      if (!ok) return ok;
   }
   return ORSuspend;
}
-(ORStatus) loseValEvt:(ORInt)val sender:(id<CPDom>)sender
{
   if (!_tracksLoseEvt) return ORSuspend;
   ORStatus ok = ORSuspend;
   for(ORInt i=0;i<_nb;i++) {
      //ORStatus ok = [_tab[i] loseValEvt:val sender:sender];
      if (_loseValIMP[i])
         ok = _loseValIMP[i](_tab[i],@selector(loseValEvt:sender:),val,sender);
      if (ok == ORFailure) return ok;
   }
   return ORSuspend;
}
@end

@implementation CPLiterals
-(id)initCPLiterals:(CPIntVarI*)ref
{
   self = [super init];
   id<CPDom> rd = [ref domain];
   _nb  = [rd imax] - [rd imin] + 1;
   _ofs = [rd imin];
   [rd release];
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
