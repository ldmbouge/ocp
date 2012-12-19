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

static NSSet* collectConstraints(CPEventNetwork* net)
{
   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:2];
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
   _recv = self;
   return self;
}
-(void)dealloc
{
    //NSLog(@"CIVar::dealloc %d\n",_name);
    if (_recv != self) 
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

-(void) setId:(ORUInt)name
{
    _name = name;
}
-(ORUInt)getId
{
   return _name;
}
-(BOOL) isBool
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
-(NSSet*)constraints
{
   NSSet* rv = collectConstraints(&_net);
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
      if (_recv != self) {
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
-(BOOL) isConstant
{
   return NO;
}
-(BOOL) isVariable
{
   return YES;
}
-(bool)bound
{
    return [_dom bound];
}
-(ORInt) min
{
    return [_dom min];
}
-(ORInt) max 
{ 
    return [_dom max];
}
-(ORInt) value
{
   if ([_dom bound])
      return [_dom min];
   else {
      @throw [[ORExecutionError alloc] initORExecutionError: "The Integer Variable is not Bound"];
      return 0;
   }
}

-(ORBounds) bounds
{
   return domBounds((CPBoundsDom*)_dom);
}
-(ORInt)domsize
{
    return [_dom domsize];
}
-(ORInt)countFrom:(ORInt)from to:(ORInt)to
{
   return [_dom countFrom:from to:to];
}
-(bool)member:(ORInt)v
{
    return [_dom member:v];
}
-(ORRange)around:(ORInt)v
{
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
   NSString* dom = [_dom description];
#if !defined(_NDEBUG)
   return [NSString stringWithFormat:@"var<%d>=%@",_name,dom];
#else
   return [NSString stringWithFormat:@"%@",dom];
#endif
}
-(id<CPDom>)domain
{
    return _dom;
}

-(bool) tracksLoseEvt:(id<CPDom>)sender
{
    return _net._ac5._val != nil || _triggers != nil;
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
   id<CPEventNode> mList[5];
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
   [_fdm scheduleAC3:mList];
   if (_triggers != nil)
      [_triggers bindEvt:_fdm];
   return ORSuspend;
}
-(ORStatus) changeMinEvt: (ORInt) dsz sender:(id<CPDom>)sender
{
   id<CPEventNode> mList[5];
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
   [_fdm scheduleAC3:mList];
    if (dsz==1 && _triggers != nil)
        [_triggers bindEvt:_fdm];
   return ORSuspend;
}
-(ORStatus) changeMaxEvt: (ORInt) dsz sender:(id<CPDom>)sender
{
   id<CPEventNode> mList[5];
   ORUInt k = 0;
   mList[k] = _net._boundsEvt._val;
   k += mList[k] != NULL;
   mList[k] = _net._maxEvt._val;
   k += mList[k] != NULL;
   mList[k] = _net._domEvt._val;
   k += mList[k] != NULL;
   mList[k] = dsz==1 ? _net._bindEvt._val : NULL;
   k += mList[k] != NULL;
   mList[k] = NULL;
   [_fdm scheduleAC3:mList];
   if (dsz==1 && _triggers != nil)
      [_triggers bindEvt:_fdm];
   return ORSuspend;
}
-(ORStatus) loseValEvt: (ORInt) val sender:(id<CPDom>)sender
{
   id<CPEventNode> mList[5];
   ORUInt k = 0;
   mList[k] = _net._domEvt._val;
   k += mList[k] != NULL;
   mList[k] = NULL;
   [_fdm scheduleAC3:mList];
   if (_net._ac5._val) {
        [_fdm scheduleAC5:[[CPValueLossEvent alloc] initValueLoss:val notify:_net._ac5._val]];
   }
   if (_triggers != nil)
      [_triggers loseValEvt:val solver:_fdm];
   return ORSuspend;
}
-(ORStatus) updateMin: (ORInt) newMin
{
    return [_dom updateMin:newMin for:_recv];
}
-(ORStatus) updateMax: (ORInt) newMax
{
    return [_dom updateMax:newMax for:_recv];
}
-(ORStatus)updateMin:(ORInt) newMin andMax:(ORInt)newMax
{
   ORStatus s = [_dom updateMin:newMin for:_recv];
   if (s)   s = [_dom updateMax:newMax for:_recv];
   return s;
}

-(ORStatus) bind: (ORInt) val
{
    return [_dom bind:val for:_recv];
}
-(ORStatus) remove: (ORInt) val
{
    return [_dom remove:val for:_recv];
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
-(void)restoreDomain:(id<CPDom>)toRestore
{
   [_dom restoreDomain:toRestore];
}
-(void)restoreValue:(ORInt)toRestore
{
   [_dom restoreValue:toRestore];
}
-(void)restore:(id<ORSnapshot>)s
{
   [_dom restoreValue:[s intValue]];
}
-(id) snapshot
{
   assert(FALSE);
   return nil;
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
   id<CPIntVarNotifier> xDeg = [x delegate];
   if (xDeg == x) {
      CPIntVarMultiCast* mc = [[CPIntVarMultiCast alloc] initVarMC:2];
      [mc addVar: x];
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
   ORInt scale = [x scale];
   ORInt shift = [x shift];
   if (scale == 1) {
      CPIntShiftView* view = [[CPIntShiftView alloc] initIVarShiftView: x b: b+shift];
      return view;
   }
   else {
      CPIntView* view = [[CPIntView alloc] initIVarAViewFor: scale x: x b: b+shift];
      return view;
   }
}
+(CPIntVarI*) initCPIntView: (CPIntVarI*) x withScale: (ORInt) a
{
   ORInt scale = [x scale];
   ORInt shift = [x shift];
   ORInt nScale = a * scale;
   ORInt nShift = a * shift;   
   CPIntVarI* rv = [x->_recv findAffine:nScale shift:nShift];
   if (rv == nil)
      rv = [[CPIntView alloc] initIVarAViewFor: nScale x: x b: nShift];
   return rv;
}
+(CPIntVarI*) initCPIntView: (CPIntVarI*) x withScale: (ORInt) a andShift: (ORInt) b
{
   ORInt scale = [x scale];
   ORInt shift = [x shift];
   CPIntView* view = [[CPIntView alloc] initIVarAViewFor: a*scale x: x b: a*shift+b];
   return view;
}
+(CPIntVarI*) initCPNegateBoolView: (CPIntVarI*) x
{
   ORInt scale = [x scale];
   ORInt shift = [x shift];
   CPIntView* view = [[CPIntView alloc] initIVarAViewFor: (-1)*scale x: x b: (-1)*shift+1];
   view->_isBool = YES;
   return view;
}

- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_vc];
   [aCoder encodeObject:_dom];
   [aCoder encodeObject:_fdm];
   [aCoder encodeObject:_recv];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_vc];
   _dom = [[aDecoder decodeObject] retain];
   _fdm = [aDecoder decodeObject];
   ORInt low = [_dom imin];
   ORInt up  = [_dom imax];
   setUpNetwork(&_net, [_fdm trail],low,up-low+1);
   _triggers = nil;
   _recv = [[aDecoder decodeObject] retain];
   return self;
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
   _dom  = (CPBoundsDom*)[[x domain] retain];
   _b = b;
   return self;
}
-(void)dealloc
{
    [super dealloc];  // CPIntVar will already release the domain. We do _NOT_ have to do it again.
}
-(CPBitDom*)flatDomain
{
   return newDomain((CPBitDom*)_dom, 1, _b);
}
-(ORInt)min
{
    return [_dom min]+_b;
}
-(ORInt)max
{
    return [_dom max]+_b;
}
-(ORBounds)bounds
{
   ORBounds bnd;
   bnd = domBounds((CPBitDom*)_dom);
   bnd.min += _b;
   bnd.max += _b;
   return bnd;
}
-(bool)member: (ORInt) v
{
    return [_dom member:v-_b];
}
-(ORRange)around:(ORInt)v
{
   ORInt low = [_dom findMax:v - _b - 1];
   ORInt up  = [_dom findMin:v - _b + 1];
   return (ORRange){low + _b,up + _b};
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
    return [_dom updateMin: newMin-_b for: _recv];
}
-(ORStatus)updateMax: (ORInt) newMax
{
    return [_dom updateMax: newMax-_b for: _recv];
}
-(ORStatus)updateMin:(ORInt) newMin andMax:(ORInt)newMax
{
   ORStatus s = [_dom updateMin:newMin-_b for:_recv];
   if (s)   s = [_dom updateMax:newMax-_b for:_recv];
   return s;
}

-(ORStatus)bind: (ORInt) val
{
    return [_dom bind: val-_b for: _recv];
}
-(ORStatus) remove: (ORInt) val
{
    return [_dom remove: val-_b for: _recv];
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
   NSMutableString* s = [[NSMutableString stringWithCapacity:64] autorelease];
#if !defined(_NDEBUG)
   [s appendFormat:@"var<%d>=",_name];
#endif
    ORInt min = [_dom min] + _b;
    if ([_dom domsize]==1)
        [s appendFormat:@"%d",min];
    else {
        [s appendFormat:@"(%d)[%d",[_dom domsize],min];
        ORInt lastIn = min;
        ORInt frstIn = min;
        bool seq   = true;
        for(ORInt k=[_dom min]+1;k<=[_dom max];k++) {
            if ([_dom get:k]) {
                ORInt tk = k + _b;
                if (!seq) {
                    [s appendFormat:@",%d",tk];
                    frstIn = lastIn = tk;
                    seq = true;
                }
                lastIn = tk;
            } else {
                if (seq) {
                    if (frstIn != lastIn) {
                        if (frstIn + 1 == lastIn)
                            [s appendFormat:@",%d",lastIn];
                        else
                            [s appendFormat:@"..%d",lastIn];
                    }
                    seq = false;
                }
            }         
        }
        if (seq) {
            if (frstIn != lastIn) {
                if (frstIn + 1 == lastIn)
                    [s appendFormat:@",%d",lastIn];
                else
                    [s appendFormat:@"..%d",lastIn];
            }
        }
        [s appendFormat:@"]"];
    }
    return s;   
}
- (void)encodeWithCoder: (NSCoder *) aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_b];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
    self = [super initWithCoder:aDecoder];
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_b];
    return self;
}
-(id)snapshot
{
   return nil;
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
   _dom = (CPBoundsDom*)[[x domain] retain];
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
   return newDomain((CPBitDom*)_dom, _a, _b);
}

-(ORInt) min
{
    if (_a > 0)
        return _a * [_dom min] + _b;
    else return _a * [_dom max] + _b;
}
-(ORInt) max
{
    if (_a > 0)
        return _a * [_dom max] + _b;
    else return _a * [_dom min] + _b;   
}
-(ORBounds)bounds
{
   ORBounds b = domBounds((CPBoundsDom*)_dom);
   return (ORBounds){
      _a > 0 ? b.min * _a + _b : b.max * _a + _b,
      _a > 0 ? b.max * _a + _b : b.min * _a + _b
   };
}
-(bool)member: (ORInt) v
{
    ORInt r = (v - _b) % _a;
    if (r != 0) return NO;
    ORInt dv = (v - _b) / _a;
    return [_dom member:dv];
}
-(ORRange)around:(ORInt)v
{
   ORInt low = [_dom findMax:(v - _b - 1) / _a];
   ORInt up  = [_dom findMin:(v - _b + 1) / _a];
   return (ORRange){low * _a + _b,up * _a  + _b};
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
    ORInt r = (newMin - _b) % _a;
    ORInt om = (newMin - _b)/_a;
    if (_a > 0)
        return [_dom updateMin:om + (r!=0) for:_recv];   
    else 
        return [_dom updateMax:om for:_recv]; 
}
-(ORStatus) updateMax: (ORInt) newMax
{
    ORInt r = (newMax - _b) % _a;
    ORInt om = (newMax - _b)/_a;
    if (_a > 0)
        return [_dom updateMax:om for:_recv];   
    else 
        return [_dom updateMin:om + (r!=0) for:_recv]; 
}
-(ORStatus)updateMin:(ORInt) newMin andMax:(ORInt)newMax
{
   ORStatus s;
   ORInt tMin = (newMin - _b) / _a;
   ORInt tMax = (newMax - _b) / _a;
   if (_a > 0) {      
      ORInt rMin = (newMin - _b) % _a;
      s = [_dom updateMin:tMin + (rMin != 0) for:_recv];
      if (s) s = [_dom updateMax:tMax for:_recv];
   } else {
      ORInt rMax = (newMax - _b) % _a;
      s = [_dom updateMax:tMin for:_recv];
      if (s) s = [_dom updateMin:tMax + (rMax!=0) for:_recv];      
   }
   return s;
}

-(ORStatus)bind: (ORInt) val
{
    ORInt r = (val - _b) % _a;
    if (r != 0)
       failNow();
    ORInt ov = (val - _b) / _a; 
    return [_dom bind:ov for:_recv];
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
   return [_dom remove:ov for:_recv];
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
   NSMutableString* s = [[NSMutableString stringWithCapacity:64] autorelease];
#if !defined(_NDEBUG)
   [s appendFormat:@"var<%d>=",_name];
#endif
   ORInt min = _a > 0 ? _a * [_dom min] + _b : _a * [_dom max] + _b;
    if ([_dom domsize]==1)
        [s appendFormat:@"%d",min];
    else {
        [s appendFormat:@"(%d)[%d",[_dom domsize],min];
        __block ORInt lastIn = min;
        __block ORInt frstIn = min;
        __block bool seq   = true;
        void (^body)(ORInt) = ^(ORInt k) {
            if ([_dom get:k]) {
                ORInt tk = _a * k + _b;
                if (!seq) {
                    [s appendFormat:@",%d",tk];
                    frstIn = lastIn = tk;
                    seq = true;
                }
                lastIn = tk;
            } else {
                if (seq) {
                    if (frstIn != lastIn) {
                        if (frstIn + 1 == lastIn)
                            [s appendFormat:@",%d",lastIn];
                        else
                            [s appendFormat:@"..%d",lastIn];
                    }
                    seq = false;
                }
            }
        };
        if (_a > 0) 
            for(ORInt k=[_dom min]+1;k<=[_dom max];k++) body(k);
        else 
            for(ORInt k=[_dom max]-1;k>=[_dom min];k--) body(k);
        if (seq) {
            if (frstIn != lastIn) {
                if (frstIn + 1 == lastIn)
                    [s appendFormat:@",%d",lastIn];
                else
                    [s appendFormat:@"..%d",lastIn];
            }
        }
        [s appendFormat:@"]"];
    }
    return s;   
}
- (void)encodeWithCoder: (NSCoder *) aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_a];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_b];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
    self = [super initWithCoder:aDecoder];
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_a];
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_b];
    return self;
}
-(id)snapshot
{
   return nil;
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
   _dom = [[CPBoundsDom alloc] initBoundsDomFor:[_fdm trail] low: [self minSecondary] up: [self maxSecondary]];
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
-(ORInt) minSecondary
{
   if (bound(_secondary))
      return minDom(_secondary)==_v;
   else return 0;
}
-(ORInt) maxSecondary
{
   if (bound(_secondary))
      return minDom(_secondary)==_v;
   else {
      ORBounds b = bounds(_secondary);
      if (_v < b.min || _v > b.max || ! memberBitDom(_secondary, _v))
         return 0;
      else return 1;
   }
}
-(bool)memberSecondary:(ORInt)val
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
-(ORInt) min
{
   return [super min];
}
-(ORInt) max
{
   return [super max];
}
-(ORBounds)bounds
{
   return [super bounds];
}
-(bool)member:(ORInt)v
{
   return [super member:v];
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
      ORStatus s = [_dom bind:1 for:_recv];
      if (s)
         return [_secondary bind:_v];
      else return s;
   } else return ORSuspend;
}
-(ORStatus)updateMax:(ORInt)newMax
{
   // newMax == 0 => x != v
   // newMax >= 1 => nothing
   if (newMax==0) {
      ORStatus s = [_dom bind:0 for:_recv];
      if (s)
         return [_secondary remove:_v];
      else return s;
   } else
      return ORSuspend;
}
-(ORStatus)updateMin:(ORInt) newMin andMax:(ORInt)newMax
{
   ORStatus ok = ORSuspend;
   if (newMin) {
      ok = [_dom bind:1 for:_recv];
      if (ok)
         ok = [_secondary bind:_v];
   }
   if (ok && newMax==0) {
      ok = [_dom bind:0 for:_recv];
      if (ok)
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
      ORStatus ok = [_dom bind:0 for:_recv];
      if (ok)
         return [_secondary remove:_v];
      return ok;
   } else {
      ORStatus ok = [_dom bind:1 for:_recv];
      if (ok)
         return [_secondary bind:_v];
      return ok;
   }
}
-(ORStatus)remove:(ORInt)val
{
   assert(val==0 || val==1);
   // val==0 -> bind to 1 -> x must be bound to _lit
   // val==1 -> bind to 0 -> x must loose _lit
   if (val==0) {
      ORStatus ok = [_dom bind:1 for:_recv];
      if (ok)
         return [_secondary bind:_v];
      return ok;
   } else {
      ORStatus ok = [_dom bind:0 for:_recv];
      if (ok)
         return [_secondary remove:_v];
      return ok;
   }
}
-(ORStatus)bindEvt:(id<CPDom>)sender
{
   if (sender==_dom) {
      ORStatus ok = [super bindEvt:sender];
      if (ok) {
         ORInt vv = [_dom min];
         if (vv)
            return [_secondary bind:_v];
         else return [_secondary remove:_v];
      }
      return ok;
   } else {
      // we were just told that x was bound to a value!
      ORInt xv = minDom(_secondary);
      return [_dom bind:xv==_v for:_recv];
   }
}

-(ORStatus) loseValEvt:(ORInt)val sender:(id<CPDom>)sender
{
   if (sender == _dom) {
      // This notification is coming from the boolean domain. We lost val (0 or 1)
      ORStatus ok = [super loseValEvt:val sender:sender];
      if (ok) {
         if (val) // we lost 1, so 0 <-> x == v => x != v
            return [_secondary remove:_v];
         else     // we lost 0, so 1 <-> x == v => x == v
            return [_secondary bind:_v];
      }
      return ok;
   } else {
      // This notification must be coming from the discrete domain. We lost a value (maybe _v?)
      // This is our sole opportunity to "echo" the change on the boolean domain.
      if (val == _v) {
         return [_dom bind:0 for:_recv];
      } else return ORSuspend;
   }
}
-(ORStatus) changeMinEvt:(ORInt)dsz sender:(id<CPDom>)sender
{
   if (sender == _dom) {
      ORStatus ok = [super changeMinEvt:dsz sender:sender];
      if (ok) {
         if ([_dom bound]) {
            if ([_dom min]==1) // b==1 <-> x == v => x == v
               return [_secondary bind:_v];
            else               // b==0 <-> x == v => x != v
               return [_secondary remove:_v];
         }
      }
      return ok;
   } else {
      ORInt myMin = [self minSecondary];
      ORInt myMax = [self maxSecondary];
      if (myMin)
         return [_dom bind:myMin for:_recv];
      else if (myMax==0)
         return [_dom bind:myMax for:_recv];
      else return ORSuspend;
   }
}
-(ORStatus) changeMaxEvt:(ORInt)dsz sender:(id<CPDom>)sender
{
   if (sender == _dom) {
      ORStatus ok = [super changeMinEvt:dsz sender:sender];
      if (ok) {
         if ([_dom bound]) {
            if ([_dom min]==1) // b==1 <-> x == v => x == v
               return [_secondary bind:_v];
            else               // b==0 <-> x == v => x != v
               return [_secondary remove:_v];
         }
      }
      return ok;
   } else {
      ORInt myMin = [self minSecondary];
      ORInt myMax = [self maxSecondary];
      if (myMin)
         return [_dom bind:myMin for:_recv];
      else if (myMax==0)
         return [_dom bind:myMax for:_recv];
      else return ORSuspend;
   }
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
-(id) snapshot
{
   return nil;
}
- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_v];
   [aCoder encodeObject:_secondary];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super initWithCoder:aDecoder];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_v];
   _secondary = [aDecoder decodeObject];
   return self;
}
@end

/*****************************************************************************************/
/*                        MultiCast Notifier                                             */
/*****************************************************************************************/

@implementation CPIntVarMultiCast

-(id)initVarMC:(ORInt)n 
{
   self = [super init];
   _mx  = n;
   _tab = malloc(sizeof(CPIntVarI*)*_mx);
   _loseValIMP   = malloc(sizeof(IMP)*_mx);
   _tracksLoseEvt = false;
   _nb  = 0;
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
   [_tab[_nb] setDelegate:self];
   _tracksLoseEvt |= [_tab[_nb] tracksLoseEvt:nil];
   _loseValIMP[_nb] = (UBType)[v methodForSelector:@selector(loseValEvt:sender:)];
   id<ORTrail> theTrail = [[v engine] trail];
   ORInt toFix = _nb;
   [theTrail trailClosure:^{
      _tab[toFix] = nil;
      _loseValIMP[toFix] = nil;
   }];
   _nb++;
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
      _tab[toFix] = nil;
      _loseValIMP[toFix] = nil;
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
   static const char* classes[] = {"Bare","Shift","Affine","EQLit","Literals","NEQLit"};
   NSMutableString* buf = [NSMutableString stringWithCapacity:64];
   [buf appendFormat:@"MC:<%d>[",_nb];
   for(ORUInt k=0;k<_nb;k++) {
      [buf appendFormat:@"%d-%s %c",[_tab[k] getId],classes[[_tab[k] varClass]],k < _nb -1 ? ',' : ']'];
   }
   return buf;
}
-(void) setTracksLoseEvt
{
    _tracksLoseEvt = true;
}
-(bool) tracksLoseEvt:(id<CPDom>)sender
{
    return _tracksLoseEvt;
}
-(ORStatus)bindEvt:(id<CPDom>)sender
{
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
- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_nb];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_mx];
   for(ORInt k=0;k<_nb;k++)
      [aCoder encodeObject:_tab[k]];
   [aCoder encodeValueOfObjCType:@encode(BOOL) at:&_tracksLoseEvt];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_nb];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_mx];
   _tab = malloc(sizeof(id<CPIntVarNotifier>)*_mx);
   _loseValIMP   = malloc(sizeof(IMP)*_mx);
   for(ORInt k=0;k<_nb;k++) {
      _tab[k] = [aDecoder decodeObject];
      _loseValIMP[k] = (UBType)[(id)_tab[k] methodForSelector:@selector(loseValEvt:sender:)];
   }
   [aDecoder decodeValueOfObjCType:@encode(BOOL) at:&_tracksLoseEvt];
   return self;
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
-(bool) tracksLoseEvt:(id<CPDom>)sender
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

- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeObject:_ref];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_nb];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_ofs];
   [aCoder encodeValueOfObjCType:@encode(BOOL) at:&_tracksLoseEvt];
   for(ORInt k=0;k<_nb;k++)
      [aCoder encodeObject:_pos[k]];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   _ref = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_nb];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_ofs];
   [aDecoder decodeValueOfObjCType:@encode(BOOL) at:&_tracksLoseEvt];
   _pos = malloc(sizeof(CPIntVarI*)*_nb);
   for(ORInt k=0;k<_nb;k++) {
      _pos[k] = [aDecoder decodeObject];
   }
   return self;
}
@end