/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPTypes.h"
#import "CPData.h"
#import "CPDom.h"
#import "CPIntVarI.h"
#import "CPEngineI.h"
#import "CPTrigger.h"
#import "ORTrail.h"
#import "CPBitDom.h"


/*****************************************************************************************/
/*                        Constraint Network Handling                                    */
/*****************************************************************************************/

static void setUpNetwork(CPEventNetwork* net,ORTrail* t,CPInt low,CPInt sz) 
{
    net->_boundsEvt = makeTRId(t,nil);
    net->_bindEvt   = makeTRId(t,nil);
    net->_domEvt    = makeTRId(t,nil);
    net->_minEvt    = makeTRId(t,nil);
    net->_maxEvt    = makeTRId(t,nil);
    net->_ac5       = makeTRId(t, nil);
}

static void freeList(VarEventNode* list)
{
    while (list) {
        VarEventNode* next = list->_node;
        [list release];
        list = next;
    }
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

static void collectList(VarEventNode* list,NSMutableSet* rv)
{
   while(list) {
      VarEventNode* next = list->_node;
      [rv addObject:list->_cstr];
      list = next;      
   }
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

@interface CPIntVarSnapshot : NSObject<ORSnapshot,NSCoding> {
   CPUInt    _name;
   union {
      CPInt _value;
      id<CPDom>   _dom;
   }              _rep;
   BOOL         _asDom;
}
-(CPIntVarSnapshot*)initCPIntVarSnapshot:(CPIntVarI*)v;
-(void)restoreInto:(NSArray*)av;
-(int)intValue; 
-(BOOL)boolValue;
@end

@implementation CPIntVarSnapshot
-(CPIntVarSnapshot*)initCPIntVarSnapshot:(CPIntVarI*)v
{
   self = [super init];
   _name = [v getId];
   _asDom = ![v bound];
   if (_asDom) {
      _rep._dom = [[v domain] copy];
   } else 
      _rep._value = [v min];
   return self;
}
-(void)dealloc
{
   if (_asDom)
      [_rep._dom release];
   [super dealloc];
}
-(void)restoreInto:(NSArray*)av
{
   CPIntVarI* theVar = [av objectAtIndex:_name];
   if (_asDom) {
      [theVar restoreDomain:_rep._dom];
   } else {
      [theVar restoreValue:_rep._value];
   }
}
-(int)intValue 
{
   return _asDom ? [_rep._dom min] : _rep._value;
}
-(BOOL)boolValue
{
   return _asDom ? [_rep._dom min] : _rep._value;
}
- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(CPUInt) at:&_name];
   [aCoder encodeValueOfObjCType:@encode(BOOL) at:&_asDom];
   if (_asDom) {
      [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_rep._value];
   } else {
      [aCoder encodeObject:_rep._dom];
   }
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(CPUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(BOOL) at:&_asDom];
   if (_asDom)
      [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_rep._value];
   else {
      _rep._dom = [[aDecoder decodeObject] retain];
   }
   return self;
}
@end
/*****************************************************************************************/
/*                        CPIntVar                                                       */
/*****************************************************************************************/

@implementation CPIntVarI

#define TRACKLOSSES (_net._ac5._val != nil || _triggers != nil)

-(CPIntVarI*) initCPIntVarCore: (CPSolverI*) cp low: (ORInt) low up: (ORInt)up
{
   self = [super init];
   _vc = CPVCBare;
   _isBool = NO;
   _cp = cp;
   _fdm  = (CPEngineI*) [cp engine];
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
-(void) setId:(CPUInt)name
{
    _name = name;
}
-(CPUInt)getId
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
-(id<CPSolver>) solver
{
    return _cp;
}
-(id<ORTracker>) tracker
{
   return _cp;
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

-(void) bounds:(CPBounds*) bnd
{
   *bnd = domBounds((CPBoundsDom*)_dom);
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
-(CPRange)around:(ORInt)v
{
   CPInt low = [_dom findMax:v-1];
   CPInt up  = [_dom findMin:v+1];
   return (CPRange){low,up};
}
-(ORInt) shift
{
    return 0;
}
-(ORInt) scale
{
    return 1;
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

-(bool) tracksLoseEvt
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
    id evt = [[VarEventNode alloc] initVarEventNode:_net._bindEvt._val
                                            trigger:todo
                                               cstr:c
                                                 at:p];
    assignTRId(&_net._bindEvt, evt, [_fdm trail]); 
    [evt release];
}
-(void)whenChangeDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
    id evt = [[VarEventNode alloc] initVarEventNode:_net._domEvt._val
                                            trigger:todo
                                               cstr:c
                                                 at:p];
    assignTRId(&_net._domEvt, evt, [_fdm trail]);      
    [evt release];
}

-(void) whenChangeMinDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
    id evt = [[VarEventNode alloc] initVarEventNode:_net._minEvt._val
                                            trigger:todo
                                               cstr:c
                                                 at:p];
    assignTRId(&_net._minEvt, evt, [_fdm trail]);
    [evt release];
}
-(void) whenChangeMaxDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
    id evt = [[VarEventNode alloc] initVarEventNode:_net._maxEvt._val
                                            trigger:todo
                                               cstr:c
                                                 at:p];
    assignTRId(&_net._maxEvt, evt, [_fdm trail]);
    [evt release];
}
-(void) whenChangeBoundsDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
    id evt = [[VarEventNode alloc] initVarEventNode:_net._boundsEvt._val
                                            trigger:todo
                                               cstr:c
                                                 at:p];
    assignTRId(&_net._boundsEvt, evt, [_fdm trail]);
    [evt release];
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
    id evt = [[VarEventNode alloc] initVarEventNode:_net._bindEvt._val
                                            trigger:NULL
                                               cstr:c
                                                 at:p];
    assignTRId(&_net._bindEvt, evt, [_fdm trail]); 
    [evt release];
    
}
-(void) whenChangePropagate:  (CPCoreConstraint*) c priority: (ORInt) p
{
    id evt = [[VarEventNode alloc] initVarEventNode:_net._domEvt._val
                                            trigger:NULL
                                               cstr:c
                                                 at:p];
    assignTRId(&_net._domEvt, evt, [_fdm trail]);      
    [evt release];
    
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   id evt = [[VarEventNode alloc] initVarEventNode:_net._minEvt._val
                                           trigger:NULL
                                              cstr:c
                                                at:p];
   assignTRId(&_net._minEvt, evt, [_fdm trail]);
   [evt release];    
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   id evt = [[VarEventNode alloc] initVarEventNode:_net._maxEvt._val
                                           trigger:NULL
                                              cstr:c
                                                at:p];
   assignTRId(&_net._maxEvt, evt, [_fdm trail]);
   [evt release];
}
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   id evt = [[VarEventNode alloc] initVarEventNode:_net._boundsEvt._val
                                           trigger:NULL
                                              cstr:c
                                                at:p];
   assignTRId(&_net._boundsEvt, evt, [_fdm trail]);
   [evt release];
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
   id evt = [[VarEventNode alloc] initVarEventNode: _net._ac5._val
                                           trigger:todo
                                              cstr: c
                                                at:HIGHEST_PRIO];
   assignTRId(&_net._ac5, evt, [_fdm trail]);
   [evt release];   
}


-(CPTrigger*) setLoseTrigger: (ORInt) value do: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
    [_recv setTracksLoseEvt];
    if (_triggers == nil)
        [self createTriggers];
    CPTrigger* trig = [CPIntVarI createTrigger: todo onBehalf:c];
    [_triggers linkTrigger:trig forValue:value];
    return trig;
}
-(void) watch: (ORInt) val with: (CPTrigger*) t;
{
    [_recv setTracksLoseEvt];
    if (_triggers == nil)
        [self createTriggers];
    [_triggers linkTrigger:t forValue:val];
}
-(CPTrigger*) setBindTrigger: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
    [_recv setTracksLoseEvt];
    if (_triggers == nil)
        [self createTriggers];
   CPTrigger* trig = [CPIntVarI createTrigger: todo onBehalf:c];
    [_triggers linkBindTrigger:trig];
    return trig;    
}
-(void) createTriggers
{
    if (_triggers == nil) {
        CPInt low = [_dom imin];
        CPInt up = [_dom imax];
        _triggers = [CPTriggerMap triggerMapFrom:low to:up dense:(up-low+1)<256];    
    }
}

-(void) bindEvt
{
   VarEventNode* mList[5];
   CPUInt k = 0;
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
}
-(void) changeMinEvt: (ORInt) dsz
{
   VarEventNode* mList[5];
   CPUInt k = 0;
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
}
-(void) changeMaxEvt: (ORInt) dsz
{
   VarEventNode* mList[5];
   CPUInt k = 0;
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
}
-(void) loseValEvt: (ORInt) val
{
   VarEventNode* mList[5];
   CPUInt k = 0;
   mList[k] = _net._domEvt._val;
   k += mList[k] != NULL;
   mList[k] = NULL;
   [_fdm scheduleAC3:mList];
    if (_net._ac5._val)
        [_fdm scheduleAC5:_net._ac5._val with:val];
    if (_triggers != nil)
        [_triggers loseValEvt:val solver:_fdm];
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
    CPInt m = [self min];
    CPInt M = [self max];
    for(CPInt i = m; i <= M; i++) {
        if ([self member: i] && ![S member: i])
            [self remove: i];
    }
    return ORSuspend;
}

-(id)snapshot
{
   return [[CPIntVarSnapshot alloc] initCPIntVarSnapshot:self];
}
-(void)restoreDomain:(id<CPDom>)toRestore
{
   [_dom restoreDomain:toRestore];
}
-(void)restoreValue:(ORInt)toRestore
{
   [_dom restoreValue:toRestore];
}

-(id<ORIntVar>) dereference
{
   return self;
}
-(CPIntVarI*) initCPExplicitIntVar: (id<CPSolver>) cp bounds:(id<ORIntRange>)b
{
   self = [self initCPIntVarCore: cp low: [b low] up: [b up]];
   _dom = [[CPBoundsDom alloc] initBoundsDomFor:[_fdm trail] low: [b low] up: [b up]];
   return self;
}

-(CPIntVarI*) initCPExplicitIntVar: (id<CPSolver>) cp low: (ORInt) low up: (ORInt) up
{
    self = [self initCPIntVarCore: cp low:low up:up];
    _dom = [[CPBitDom alloc] initBitDomFor:[_fdm trail] low:low up:up];
    return self;
}

-(CPIntVarI*) initCPIntVarView: (id<CPSolver>) cp low: (ORInt) low up: (ORInt) up for: (CPIntVarI*) x
{
   self = [self initCPIntVarCore: cp low: low up: up];
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

+(CPIntVarI*)    initCPIntVar: (id<CPSolver>)fdm bounds:(id<ORIntRange>)b
{
   CPIntVarI* x = [[CPIntVarI alloc] initCPExplicitIntVar: fdm bounds:b];
   x->_isBool = ([b low] == 0 && [b up] == 1);
   return x;
}

+(CPIntVarI*) initCPIntVar: (id<CPSolver>) fdm low: (ORInt) low up: (ORInt) up
{
   CPIntVarI* x = nil;
   if (low==0 && up==1)
      x = [[CPIntVarI alloc] initCPExplicitIntVar: fdm bounds: RANGE(fdm,0,1)];
   else
      x = [[CPIntVarI alloc] initCPExplicitIntVar: fdm low: low up: up];
   x->_isBool = (low == 0 && up==1);
   return x;
}
+(CPIntVarI*) initCPBoolVar: (id<CPSolver>) fdm
{
   CPIntVarI* x = [[CPIntVarI alloc] initCPExplicitIntVar: fdm bounds: RANGE(fdm,0,1)];
   x->_isBool = YES;
   return x;
}

+(CPIntVarI*) initCPIntView: (CPIntVarI*) x withShift: (ORInt) b
{
   CPInt scale = [x scale];
   CPInt shift = [x shift];
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
   CPInt scale = [x scale];
   CPInt shift = [x shift];
   CPInt nScale = a * scale;
   CPInt nShift = a * shift;   
   CPIntVarI* rv = [x->_recv findAffine:nScale shift:nShift];
   if (rv == nil)
      rv = [[CPIntView alloc] initIVarAViewFor: nScale x: x b: nShift];
   return rv;
}
+(CPIntVarI*) initCPIntView: (CPIntVarI*) x withScale: (ORInt) a andShift: (ORInt) b
{
   CPInt scale = [x scale];
   CPInt shift = [x shift];
   CPIntView* view = [[CPIntView alloc] initIVarAViewFor: a*scale x: x b: a*shift+b];
   return view;
}
+(CPIntVarI*) initCPNegateBoolView: (CPIntVarI*) x
{
   CPInt scale = [x scale];
   CPInt shift = [x shift];
   CPIntView* view = [[CPIntView alloc] initIVarAViewFor: (-1)*scale x: x b: (-1)*shift+1];
   view->_isBool = YES;
   return view;
}
+(CPTrigger*) createTrigger: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
   CPTrigger* trig = malloc(sizeof(CPTrigger));
   trig->_cb = [todo copy];
   trig->_cstr = c;
   return trig;
}
- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(CPUInt) at:&_name];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_vc];
   [aCoder encodeObject:_dom];
   [aCoder encodeObject:_fdm];
   [aCoder encodeObject:_cp];
   [aCoder encodeObject:_recv];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(CPUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_vc];
   _dom = [[aDecoder decodeObject] retain];
   _fdm = [aDecoder decodeObject];
   _cp  = [aDecoder decodeObject];
   CPInt low = [_dom imin];
   CPInt up  = [_dom imax];
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
   self = [super initCPIntVarView:[x solver] low:[x min]+b up:[x max]+b for:x];
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
-(void)bounds: (CPBounds*) bnd
{
   *bnd = domBounds((CPBitDom*)_dom);
   bnd->min += _b;
   bnd->max += _b;
}
-(bool)member: (ORInt) v
{
    return [_dom member:v-_b];
}
-(CPRange)around:(ORInt)v
{
   CPInt low = [_dom findMax:v - _b - 1];
   CPInt up  = [_dom findMin:v - _b + 1];
   return (CPRange){low + _b,up + _b};
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
-(void) loseValEvt: (ORInt)  val
{
    [super loseValEvt: val+_b];
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
    CPInt min = [_dom min] + _b;
    if ([_dom domsize]==1)
        [s appendFormat:@"%d",min];
    else {
        [s appendFormat:@"(%d)[%d",[_dom domsize],min];
        CPInt lastIn = min;
        CPInt frstIn = min;
        bool seq   = true;
        for(CPInt k=[_dom min]+1;k<=[_dom max];k++) {
            if ([_dom get:k]) {
                CPInt tk = k + _b;
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
   CPInt vLow = a < 0 ? a * [x max] + b : a * [x min] + b;
   CPInt vUp  = a < 0 ? a * [x min] + b : a * [x max] + b;
   self = [super initCPIntVarView: [x solver] low:vLow up:vUp for:x];
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
-(void)bounds: (CPBounds*) bnd
{
   CPBounds b = domBounds((CPBoundsDom*)_dom);
    *bnd = (CPBounds){
        _a > 0 ? b.min * _a + _b : b.max * _a + _b,
        _a > 0 ? b.max * _a + _b : b.min * _a + _b
    };
}
-(bool)member: (ORInt) v
{
    CPInt r = (v - _b) % _a;
    if (r != 0) return NO;
    CPInt dv = (v - _b) / _a;
    return [_dom member:dv];
}
-(CPRange)around:(ORInt)v
{
   CPInt low = [_dom findMax:(v - _b - 1) / _a];
   CPInt up  = [_dom findMin:(v - _b + 1) / _a];
   return (CPRange){low * _a + _b,up * _a  + _b};
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
    CPInt r = (newMin - _b) % _a;
    CPInt om = (newMin - _b)/_a;
    if (_a > 0)
        return [_dom updateMin:om + (r!=0) for:_recv];   
    else 
        return [_dom updateMax:om for:_recv]; 
}
-(ORStatus) updateMax: (ORInt) newMax
{
    CPInt r = (newMax - _b) % _a;
    CPInt om = (newMax - _b)/_a;
    if (_a > 0)
        return [_dom updateMax:om for:_recv];   
    else 
        return [_dom updateMin:om + (r!=0) for:_recv]; 
}
-(ORStatus)updateMin:(ORInt) newMin andMax:(ORInt)newMax
{
   ORStatus s;
   CPInt tMin = (newMin - _b) / _a;
   CPInt tMax = (newMax - _b) / _a;
   if (_a > 0) {      
      CPInt rMin = (newMin - _b) % _a;
      s = [_dom updateMin:tMin + (rMin != 0) for:_recv];
      if (s) s = [_dom updateMax:tMax for:_recv];
   } else {
      CPInt rMax = (newMax - _b) % _a;
      s = [_dom updateMax:tMin for:_recv];
      if (s) s = [_dom updateMin:tMax + (rMax!=0) for:_recv];      
   }
   return s;
}

-(ORStatus)bind: (ORInt) val
{
    CPInt r = (val - _b) % _a;
    if (r != 0)
       failNow();
    CPInt ov = (val - _b) / _a; 
    return [_dom bind:ov for:_recv];
}
-(ORStatus)remove: (ORInt) val
{
   CPInt ov;
   if (_a == -1)
      ov = _b - val;
   else if (_a== 1)
      ov = val - _b;
   else {
      CPInt r = (val - _b) % _a;
      if (r != 0) return ORSuspend;
      ov = (val - _b) / _a; 
   }
   return [_dom remove:ov for:_recv];
}
-(void) loseValEvt: (ORInt) val
{
    [super loseValEvt:_a * val+_b];
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
   CPInt min = _a > 0 ? _a * [_dom min] + _b : _a * [_dom max] + _b;
    if ([_dom domsize]==1)
        [s appendFormat:@"%d",min];
    else {
        [s appendFormat:@"(%d)[%d",[_dom domsize],min];
        __block CPInt lastIn = min;
        __block CPInt frstIn = min;
        __block bool seq   = true;
        void (^body)(ORInt) = ^(CPInt k) {
            if ([_dom get:k]) {
                CPInt tk = _a * k + _b;
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
            for(CPInt k=[_dom min]+1;k<=[_dom max];k++) body(k);
        else 
            for(CPInt k=[_dom max]-1;k>=[_dom min];k--) body(k);
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
-(void) dealloc
{
   //NSLog(@"multicast object %p dealloc'd\n",self);
   free(_tab);
   [super dealloc];
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
   _tracksLoseEvt |= [_tab[_nb] tracksLoseEvt];    
   _loseValIMP[_nb] = [v methodForSelector:@selector(loseValEvt:)];
   ORTrail* theTrail = [[v solver] trail];
   CPInt toFix = _nb;
   [theTrail trailClosure:^{
      _tab[toFix] = nil;
      _loseValIMP[toFix] = nil;
   }];
   _nb++;
}
-(CPIntVarI*)findAffine:(ORInt)scale shift:(ORInt)shift
{
   for(CPUInt i=0;i < _nb;i++) {
      CPIntVarI* sel = [_tab[i] findAffine:scale shift:shift];
      if (sel)
         return sel;
   }
   return nil;
}

-(NSString*)description
{
   static const char* classes[] = {"Bare","Shift","Affine"};
   NSMutableString* buf = [NSMutableString stringWithCapacity:64];
   [buf appendFormat:@"MC:<%d>[",_nb];
   for(CPUInt k=0;k<_nb;k++) {
      [buf appendFormat:@"%d-%s %c",[_tab[k] getId],classes[_tab[k]->_vc],k < _nb -1 ? ',' : ']'];
   }
   return buf;
}
-(void) setTracksLoseEvt
{
    _tracksLoseEvt = true;
}
-(bool) tracksLoseEvt
{
    return _tracksLoseEvt;
}
-(void)bindEvt
{
    for(CPInt i=0;i<_nb;i++)
        [_tab[i] bindEvt];
}
-(void) changeMinEvt:(ORInt)dsz
{
    for(CPInt i=0;i<_nb;i++)
        [_tab[i] changeMinEvt:dsz];
}
-(void) changeMaxEvt:(ORInt)dsz
{
    for(CPInt i=0;i<_nb;i++)
        [_tab[i] changeMaxEvt:dsz];
}
-(void) loseValEvt:(ORInt)val
{
    if (!_tracksLoseEvt) return;
    for(CPInt i=0;i<_nb;i++)
        //[_tab[i] loseValEvt:val];
       _loseValIMP[i](_tab[i],@selector(loseValEvt:),val);
}
- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_nb];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_mx];
   for(CPInt k=0;k<_nb;k++)
      [aCoder encodeObject:_tab[k]];
   [aCoder encodeValueOfObjCType:@encode(BOOL) at:&_tracksLoseEvt];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_nb];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_mx];
   _tab = malloc(sizeof(CPIntVarI*)*_mx);
   _loseValIMP   = malloc(sizeof(IMP)*_mx);
   for(CPInt k=0;k<_nb;k++) {
      _tab[k] = [aDecoder decodeObject];
      _loseValIMP[k] = [_tab[k] methodForSelector:@selector(loseValEvt:)];
   }
   [aDecoder decodeValueOfObjCType:@encode(BOOL) at:&_tracksLoseEvt];
   return self;
}
@end



