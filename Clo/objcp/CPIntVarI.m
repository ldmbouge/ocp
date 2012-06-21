/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/

#import "CPTypes.h"
#import "CPData.h"
#import "CPDom.h"
#import "CPIntVarI.h"
#import "CPSolverI.h"
#import "CPTrigger.h"
#import "CPTrail.h"
#import "CPBitDom.h"


/*****************************************************************************************/
/*                        Constraint Network Handling                                    */
/*****************************************************************************************/

static void setUpNetwork(CPEventNetwork* net,CPTrail* t,CPInt low,CPInt sz) 
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

@interface CPIntVarSnapshot : NSObject<CPSnapshot,NSCoding> {
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
      [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_rep._value];
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
      [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_rep._value];
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

BOOL bound(CPIntVarI* x)
{
   return ((CPBoundsDom*)x->_dom)->_sz._val == 1;
}

-(CPIntVarI*) initCPIntVarCore:(id<CP>)cp low: (CPInt) low up: (CPInt)up
{
    self = [super init];
    _cp = cp;
    _fdm  = (CPSolverI*) [cp solver];
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
-(CPSolverI*)solver
{
    return _fdm;
}
-(id<CP>) cp
{
    return _cp;
}
-(NSSet*)constraints
{
   NSSet* rv = collectConstraints(&_net);
   return rv;
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
-(CPInt) min
{
    return [_dom min];
}
-(CPInt) max 
{ 
    return [_dom max];
}
-(void) bounds:(CPBounds*) bnd
{
    *bnd = (CPBounds){[_dom min],[_dom max]};
}
-(CPInt)domsize
{
    return [_dom domsize];
}
-(CPInt)countFrom:(CPInt)from to:(CPInt)to
{
   return [_dom countFrom:from to:to];
}
-(bool)member:(CPInt)v
{
    return [_dom member:v];
}
-(CPRange)around:(CPInt)v
{
   CPInt low = [_dom findMax:v-1];
   CPInt up  = [_dom findMin:v+1];
   return (CPRange){low,up};
}
-(CPInt) shift
{
    return 0;
}
-(CPInt) scale
{
    return 1;
}
-(NSString*)description
{
    NSString* dom = [_dom description];
//   return [NSString stringWithFormat:@"var(%d)=%@",_name,dom];
    return [NSString stringWithFormat:@"%@",dom];
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

-(void)whenBindDo: (ConstraintCallback) todo priority: (CPInt) p onBehalf:(CPCoreConstraint*)c
{
    id evt = [[VarEventNode alloc] initVarEventNode:_net._bindEvt._val
                                            trigger:todo
                                               cstr:c
                                                 at:p];
    assignTRId(&_net._bindEvt, evt, [_fdm trail]); 
    [evt release];
}
-(void)whenChangeDo: (ConstraintCallback) todo priority: (CPInt) p onBehalf:(CPCoreConstraint*)c
{
    id evt = [[VarEventNode alloc] initVarEventNode:_net._domEvt._val
                                            trigger:todo
                                               cstr:c
                                                 at:p];
    assignTRId(&_net._domEvt, evt, [_fdm trail]);      
    [evt release];
}

-(void) whenChangeMinDo: (ConstraintCallback) todo priority: (CPInt) p onBehalf:(CPCoreConstraint*)c
{
    id evt = [[VarEventNode alloc] initVarEventNode:_net._minEvt._val
                                            trigger:todo
                                               cstr:c
                                                 at:p];
    assignTRId(&_net._minEvt, evt, [_fdm trail]);
    [evt release];
}
-(void) whenChangeMaxDo: (ConstraintCallback) todo priority: (CPInt) p onBehalf:(CPCoreConstraint*)c
{
    id evt = [[VarEventNode alloc] initVarEventNode:_net._maxEvt._val
                                            trigger:todo
                                               cstr:c
                                                 at:p];
    assignTRId(&_net._maxEvt, evt, [_fdm trail]);
    [evt release];
}
-(void) whenChangeBoundsDo: (ConstraintCallback) todo priority: (CPInt) p onBehalf:(CPCoreConstraint*)c
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
-(void) whenBindPropagate: (CPCoreConstraint*) c priority: (CPInt) p
{
    id evt = [[VarEventNode alloc] initVarEventNode:_net._bindEvt._val
                                            trigger:NULL
                                               cstr:c
                                                 at:p];
    assignTRId(&_net._bindEvt, evt, [_fdm trail]); 
    [evt release];
    
}
-(void) whenChangePropagate:  (CPCoreConstraint*) c priority: (CPInt) p
{
    id evt = [[VarEventNode alloc] initVarEventNode:_net._domEvt._val
                                            trigger:NULL
                                               cstr:c
                                                 at:p];
    assignTRId(&_net._domEvt, evt, [_fdm trail]);      
    [evt release];
    
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (CPInt) p
{
    id evt = [[VarEventNode alloc] initVarEventNode:_net._minEvt._val
                                            trigger:NULL
                                               cstr:c
                                                 at:p];
    assignTRId(&_net._minEvt, evt, [_fdm trail]);
    [evt release];
    
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (CPInt) p
{
    id evt = [[VarEventNode alloc] initVarEventNode:_net._maxEvt._val
                                            trigger:NULL
                                               cstr:c
                                                 at:p];
    assignTRId(&_net._maxEvt, evt, [_fdm trail]);
    [evt release];
}
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c priority: (CPInt) p
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


-(CPTrigger*) setLoseTrigger: (CPInt) value do: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
    [_recv setTracksLoseEvt];
    if (_triggers == nil)
        [self createTriggers];
    CPTrigger* trig = [CPIntVarI createTrigger: todo onBehalf:c];
    [_triggers linkTrigger:trig forValue:value];
    return trig;
}
-(void) watch: (CPInt) val with: (CPTrigger*) t;
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
    if (_net._boundsEvt._val) 
        [_fdm scheduleAC3:_net._boundsEvt._val];
    if (_net._minEvt._val) 
        [_fdm scheduleAC3:_net._minEvt._val];
    if (_net._maxEvt._val) 
        [_fdm scheduleAC3:_net._maxEvt._val];
    if (_net._domEvt._val) 
        [_fdm scheduleAC3:_net._domEvt._val];
    if (_net._bindEvt._val) 
        [_fdm scheduleAC3:_net._bindEvt._val];
    if (_triggers != nil)
        [_triggers bindEvt:_fdm];
}
-(void) changeMinEvt: (CPInt) dsz
{
    if (_net._boundsEvt._val) 
        [_fdm scheduleAC3:_net._boundsEvt._val];
    if (_net._minEvt._val) 
        [_fdm scheduleAC3:_net._minEvt._val];
    if (_net._domEvt._val) 
        [_fdm scheduleAC3:_net._domEvt._val];
    if (dsz==1 && _net._bindEvt._val) 
        [_fdm scheduleAC3:_net._bindEvt._val];
    if (dsz==1 && _triggers != nil)
        [_triggers bindEvt:_fdm];
}
-(void) changeMaxEvt: (CPInt) dsz
{
    if (_net._boundsEvt._val) 
        [_fdm scheduleAC3:_net._boundsEvt._val];
    if (_net._maxEvt._val) 
        [_fdm scheduleAC3:_net._maxEvt._val];
    if (_net._domEvt._val) 
        [_fdm scheduleAC3:_net._domEvt._val];
    if (dsz==1 && _net._bindEvt._val) 
        [_fdm scheduleAC3:_net._bindEvt._val];
    if (dsz==1 && _triggers != nil)
        [_triggers bindEvt:_fdm];
}
-(void) loseValEvt: (CPInt) val
{
    if (_net._domEvt._val) 
        [_fdm scheduleAC3:_net._domEvt._val];
    if (_net._ac5._val)
        [_fdm scheduleAC5:_net._ac5._val with:val];
    if (_triggers != nil)
        [_triggers loseValEvt:val solver:_fdm];
}
-(void) loseRangeEvt:(CPClosure) clo
{
    if (TRACKLOSSES)   
      clo();    
}

-(CPStatus) updateMin: (CPInt) newMin
{
    return [_dom updateMin:newMin for:_recv];
}

-(CPStatus) updateMax: (CPInt) newMax
{
    return [_dom updateMax:newMax for:_recv];
}
-(CPStatus)updateMin:(CPInt) newMin andMax:(CPInt)newMax
{
   CPStatus s = [_dom updateMin:newMin for:_recv];
   if (s)   s = [_dom updateMax:newMax for:_recv];
   return s;
}

-(CPStatus) bind: (CPInt) val
{
    return [_dom bind:val for:_recv];
}
-(CPStatus) remove: (CPInt) val
{
    return [_dom remove:val for:_recv];
}
-(CPStatus) inside:(CPIntSetI*) S
{
    CPInt m = [self min];
    CPInt M = [self max];
    for(CPInt i = m; i <= M; i++) {
        if ([self member: i] && ![S member: i])
            if ([self remove: i] == CPFailure)
                return CPFailure;
    }
    return CPSuspend;
}

-(id)snapshot
{
   return [[CPIntVarSnapshot alloc] initCPIntVarSnapshot:self];
}
-(void)restoreDomain:(id<CPDom>)toRestore
{
   [_dom restoreDomain:toRestore];
}
-(void)restoreValue:(CPInt)toRestore
{
   [_dom restoreValue:toRestore];
}


-(CPIntVarI*) initCPExplicitIntVar: (id<CP>) cp low: (CPInt) low up: (CPInt) up
{
    self = [self initCPIntVarCore: cp low:low up:up];
    _dom = [[CPBitDom alloc] initBitDomFor:[_fdm trail] low:low up:up];
    return self;
}

-(CPIntVarI*) initCPIntVarView: (id<CP>) cp low: (CPInt) low up: (CPInt) up for: (CPIntVarI*) x
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

+(CPIntVarI*) initCPIntVar: (id<CP>) fdm low: (CPInt) low up: (CPInt) up
{
    CPIntVarI* x = [[CPIntVarI alloc] initCPExplicitIntVar: fdm low: low up: up];
    return x;
}
+(CPIntVarI*) initCPBoolVar: (id<CP>) fdm
{
    CPIntVarI* x = [[CPIntVarI alloc] initCPExplicitIntVar: fdm low: 0 up: 1];
    return x;
}

+(CPIntVarI*) initCPIntView: (CPIntVarI*) x withShift: (CPInt) b
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
+(CPIntVarI*) initCPIntView: (CPIntVarI*) x withScale: (CPInt) a
{
    CPInt scale = [x scale];
    CPInt shift = [x shift];
    CPIntView* view = [[CPIntView alloc] initIVarAViewFor: a*scale x: x b: a*shift];
    return view;
}
+(CPIntVarI*) initCPIntView: (CPIntVarI*) x withScale: (CPInt) a andShift: (CPInt) b
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
   [aCoder encodeObject:_dom];
   [aCoder encodeObject:_fdm];
   [aCoder encodeObject:_cp];
   [aCoder encodeObject:_recv];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(CPUInt) at:&_name];
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
-(CPIntShiftView*)initIVarShiftView: (CPIntVarI*) x b: (CPInt) b
{
    self = [super initCPIntVarView:[x cp] low:[x min]+b up:[x max]+b for:x];
    _dom  = (CPBoundsDom*)[[x domain] retain];
    _b = b;
    return self;
}
-(void)dealloc
{
    [super dealloc];  // CPIntVar will already release the domain. We do _NOT_ have to do it again.
}
-(CPInt)min
{
    return [_dom min]+_b;
}
-(CPInt)max
{
    return [_dom max]+_b;
}
-(void)bounds: (CPBounds*) bnd
{
    CPBounds b = [_dom bounds];
    b.min += _b;
    b.max += _b;
    *bnd = b;
}
-(bool)member: (CPInt) v
{
    return [_dom member:v-_b];
}
-(CPRange)around:(CPInt)v
{
   CPInt low = [_dom findMax:v - _b - 1];
   CPInt up  = [_dom findMin:v - _b + 1];
   return (CPRange){low + _b,up + _b};
}
-(CPInt) shift
{
    return _b;
}
-(CPInt) scale
{
    return 1;
}
-(CPStatus)updateMin: (CPInt) newMin
{
    return [_dom updateMin: newMin-_b for: _recv];
}
-(CPStatus)updateMax: (CPInt) newMax
{
    return [_dom updateMax: newMax-_b for: _recv];
}
-(CPStatus)updateMin:(CPInt) newMin andMax:(CPInt)newMax
{
   CPStatus s = [_dom updateMin:newMin-_b for:_recv];
   if (s)   s = [_dom updateMax:newMax-_b for:_recv];
   return s;
}

-(CPStatus)bind: (CPInt) val
{
    return [_dom bind: val-_b for: _recv];
}
-(CPStatus) remove: (CPInt) val
{
    return [_dom remove: val-_b for: _recv];
}
// get the notification from the underlying domain; need to shift it for the network
-(void) loseValEvt: (CPInt)  val
{
    [super loseValEvt: val+_b];
}
-(NSString*) description
{
    CPInt min = [_dom min] + _b;
    NSMutableString* s = [[NSMutableString stringWithCapacity:80] autorelease];
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
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_b];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
    self = [super initWithCoder:aDecoder];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_b];
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
-(CPIntView*)initIVarAViewFor: (CPInt) a  x: (CPIntVarI*) x b: (CPInt) b
{
    CPInt vLow = a < 0 ? a * [x max] + b : a * [x min] + b;
    CPInt vUp  = a < 0 ? a * [x min] + b : a * [x max] + b;
    self = [super initCPIntVarView: [x cp] low:vLow up:vUp for:x];
    _dom = (CPBoundsDom*)[[x domain] retain];
    _a = a;
    _b = b;
    return self;
}
-(void)dealloc
{
    [super dealloc];
}

-(CPInt) min
{
    if (_a > 0)
        return _a * [_dom min] + _b;
    else return _a * [_dom max] + _b;
}
-(CPInt) max
{
    if (_a > 0)
        return _a * [_dom max] + _b;
    else return _a * [_dom min] + _b;   
}
-(void)bounds: (CPBounds*) bnd
{
    CPBounds b = [_dom bounds];
    *bnd = (CPBounds){
        _a > 0 ? b.min * _a + _b : b.max *  _a + _b,
        _a > 0 ? b.max * _a + _b : b.min * _a + _b
    };
}
-(bool)member: (CPInt) v
{
    CPInt r = (v - _b) % _a;
    if (r != 0) return NO;
    CPInt dv = (v - _b) / _a;
    return [_dom member:dv];
}
-(CPRange)around:(CPInt)v
{
   CPInt low = [_dom findMax:(v - _b - 1) / _a];
   CPInt up  = [_dom findMin:(v - _b + 1) / _a];
   return (CPRange){low * _a + _b,up * _a  + _b};
}

-(CPInt) shift
{
    return _b;
}
-(CPInt) scale
{
    return _a;
}
-(CPStatus) updateMin: (CPInt) newMin
{
    CPInt r = (newMin - _b) % _a;
    CPInt om = (newMin - _b)/_a;
    if (_a > 0)
        return [_dom updateMin:om + (r!=0) for:_recv];   
    else 
        return [_dom updateMax:om for:_recv]; 
}
-(CPStatus) updateMax: (CPInt) newMax
{
    CPInt r = (newMax - _b) % _a;
    CPInt om = (newMax - _b)/_a;
    if (_a > 0)
        return [_dom updateMax:om for:_recv];   
    else 
        return [_dom updateMin:om + (r!=0) for:_recv]; 
}
-(CPStatus)updateMin:(CPInt) newMin andMax:(CPInt)newMax
{
   CPStatus s;
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

-(CPStatus)bind: (CPInt) val
{
    CPInt r = (val - _b) % _a;
    if (r != 0) failNow(_fdm);
    CPInt ov = (val - _b) / _a; 
    return [_dom bind:ov for:_recv];
}
-(CPStatus)remove: (CPInt) val
{
    CPInt r = (val - _b) % _a;
    if (r != 0) return CPSuspend;
    CPInt ov = (val - _b) / _a; 
    return [_dom remove:ov for:_recv];
}
-(void) loseValEvt: (CPInt) val
{
    [super loseValEvt:_a * val+_b];
}
-(NSString*)description
{
    CPInt min = _a > 0 ? _a * [_dom min] + _b : _a * [_dom max] + _b;
    NSMutableString* s = [[NSMutableString stringWithCapacity:80] autorelease];
    if ([_dom domsize]==1)
        [s appendFormat:@"%d",min];
    else {
        [s appendFormat:@"(%d)[%d",[_dom domsize],min];
        __block CPInt lastIn = min;
        __block CPInt frstIn = min;
        __block bool seq   = true;
        void (^body)(CPInt) = ^(CPInt k) {
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
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_a];
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_b];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
    self = [super initWithCoder:aDecoder];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_a];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_b];
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

-(id)initVarMC:(CPInt)n 
{
   self = [super init];
   _mx  = n;
   _tab = malloc(sizeof(CPIntVarI*)*_mx);
   _loseRangeIMP = malloc(sizeof(IMP)*_mx);
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
      _loseRangeIMP = realloc(_loseRangeIMP,sizeof(IMP)*(_mx << 1));
      _loseValIMP = realloc(_loseValIMP,sizeof(IMP)*(_mx << 1));
      _mx <<= 1;
   }
   _tab[_nb] = v;  // DO NOT RETAIN. v will point to us because of the delegate
   [_tab[_nb] setDelegate:self];
   _tracksLoseEvt |= [_tab[_nb] tracksLoseEvt];    
   _loseRangeIMP[_nb] = [v methodForSelector:@selector(loseRangeEvt:)];
   _loseValIMP[_nb] = [v methodForSelector:@selector(loseValEvt:)];
   _nb++;
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
-(void) changeMinEvt:(CPInt)dsz
{
    for(CPInt i=0;i<_nb;i++)
        [_tab[i] changeMinEvt:dsz];
}
-(void) changeMaxEvt:(CPInt)dsz
{
    for(CPInt i=0;i<_nb;i++)
        [_tab[i] changeMaxEvt:dsz];
}
-(void) loseValEvt:(CPInt)val
{
    if (!_tracksLoseEvt) return;
    for(CPInt i=0;i<_nb;i++)
        //[_tab[i] loseValEvt:val];
       _loseValIMP[i](_tab[i],@selector(loseValEvt:),val);
}
-(void) loseRangeEvt:(CPClosure)doIt
{
    if (!_tracksLoseEvt) return;
    for(CPInt i=0;i<_nb;i++)
        //[_tab[i] loseRangeEvt:doIt];
       _loseRangeIMP[i](_tab[i],@selector(loseRangeEvt:),doIt);
}
- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_nb];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_mx];
   for(CPInt k=0;k<_nb;k++)
      [aCoder encodeObject:_tab[k]];
   [aCoder encodeValueOfObjCType:@encode(BOOL) at:&_tracksLoseEvt];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_nb];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_mx];
   _tab = malloc(sizeof(CPIntVarI*)*_mx);
   for(CPInt k=0;k<_nb;k++)
      _tab[k] = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(BOOL) at:&_tracksLoseEvt];   
   return self;
}
@end



