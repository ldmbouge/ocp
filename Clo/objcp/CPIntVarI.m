/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

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

typedef struct  {
   TRId         _boundsEvt[2];
   TRId           _bindEvt[2];
   TRId            _domEvt[2];
   TRId            _minEvt[2];
   TRId            _maxEvt[2];
   TRId _valueClosureQueue[2];
} CPEventNetwork;

/*****************************************************************************************/
/*                        CPIntVarSnapshot                                               */
/*****************************************************************************************/

@interface CPIntVarSnapshot : NSObject {
   ORUInt    _name;
   ORInt     _value;
   ORBool    _bound;
}
-(CPIntVarSnapshot*) initCPIntVarSnapshot: (CPIntVar*) v name: (ORInt) name;
-(int) intValue;
-(ORBool) boolValue;
-(NSString*) description;
-(ORBool)isEqual: (id) object;
-(NSUInteger) hash;
-(ORUInt)getId;
@end

@implementation CPIntVarSnapshot
-(CPIntVarSnapshot*) initCPIntVarSnapshot: (CPIntVar*) v name: (ORInt) name
{
   self = [super init];
   _name = name;
   if ([v bound]) {
      _bound = TRUE;
      _value = [v value];
   }
   else {
      _value = 0;
      _bound = FALSE;
   }
   return self;
}
-(ORUInt)getId
{
   return _name;
}
-(ORBool) bound
{
   return _bound;
}
-(ORInt) intValue
{
   return _value;
}
-(ORDouble) doubleValue
{
   return _value;
}
-(ORBool) boolValue
{
   return _value;
}
-(ORBool)isEqual: (id) object
{
   if ([object isKindOfClass:[self class]]) {
      CPIntVarSnapshot* other = object;
      if (_name == other->_name) {
         return _value == other->_value && _bound == other->_bound;
      }
      else
         return NO;
   } else
      return NO;
}
-(NSUInteger) hash
{
   return (_name << 16) + _value;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   if (_bound)
      [buf appendFormat:@"int(%d) : %d",_name,_value];
   else
      [buf appendFormat:@"int(%d) : NA",_name];
   return buf;
}
- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_value];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_bound];
}
- (id) initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_value];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_bound];
   return self;
}
@end

/*****************************************************************************************/
/*                        Constraint Network Handling                                    */
/*****************************************************************************************/

static void setUpNetwork(CPEventNetwork* net,id<ORTrail> t,ORInt low,ORInt sz) 
{
   for(ORInt i =0 ; i < 2;i++) {
      net->_boundsEvt[i] = makeTRId(t,nil);
      net->_bindEvt[i]   = makeTRId(t,nil);
      net->_domEvt[i]    = makeTRId(t,nil);
      net->_minEvt[i]    = makeTRId(t,nil);
      net->_maxEvt[i]    = makeTRId(t,nil);
      net->_valueClosureQueue[i]       = makeTRId(t, nil);
   }
}

static void deallocNetwork(CPEventNetwork* net)
{
    freeList(net->_boundsEvt[0]);
    freeList(net->_bindEvt[0]);
    freeList(net->_domEvt[0]);
    freeList(net->_minEvt[0]);
    freeList(net->_maxEvt[0]);
    freeList(net->_valueClosureQueue[0]);
}

static NSMutableSet* collectConstraints(CPEventNetwork* net,NSMutableSet* rv)
{
   collectList(net->_boundsEvt[0],rv);
   collectList(net->_bindEvt[0],rv);
   collectList(net->_domEvt[0],rv);
   collectList(net->_minEvt[0],rv);
   collectList(net->_maxEvt[0],rv);
   collectList(net->_valueClosureQueue[0],rv);
   return rv;
}

/*****************************************************************************************/
/*                        CPIntVar                                                       */
/*****************************************************************************************/

@implementation CPIntVar
-(CPIntVar*) initCPIntVar: (CPEngineI*) engine
{
   self = [super init];
   _fdm  = engine;
   _isBool = NO;
   [_fdm trackVariable: self];
   _recv = nil;
   return self;
}
-(id<ORTracker>) tracker
{
   return _fdm;
}
-(id<CPEngine>) engine
{
   return _fdm;
}
-(enum CPVarClass) varClass
{
   return _vc;
}
-(id) takeSnapshot: (ORInt) id
{
   return [[CPIntVarSnapshot alloc] initCPIntVarSnapshot: self name: id];
}
-(ORInt)degree
{
   return 0;
}
-(ORInt) value
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method value not defined"];
   return 0;
}
-(ORInt) min
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method min not defined"];
   return 0;
}
-(ORInt) max
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method max not defined"];
   return 0;
}
-(ORRange) around: (ORInt) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method around not defined"];
   return (ORRange){0,0};
}
-(id<CPDom>) domain
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method domain not defined"];
   return NULL;
}
-(CPBitDom*) flatDomain
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method flatDomain not defined"];
   return NULL;
}
-(ORDouble) doubleMin
{
   return [self min];
}
-(ORDouble) doubleMax
{
   return [self max];
}
-(ORDouble) doubleValue
{
   return [self value];
}

-(ORInt) domsize
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method domsize  not defined"];
   return 0;
}
-(ORBounds) bounds
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method bounds not defined"];
   return (ORBounds){0,0};
}
-(ORBool) member: (ORInt) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method member not defined"];
   return FALSE;
}
-(ORBool) isBool
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method isBool not defined"];
   return FALSE;
}
-(id<ORIntVar>) base
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method base not defined"];
   return 0;
}
-(ORBool) bound
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method bound not defined"];
   return 0;
}
-(ORInt) countFrom: (ORInt) from to: (ORInt) to
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method countFrom not defined"];
   return 0;
}
-(void) bind:(ORInt) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method bind not defined"];
}
-(void) remove: (ORInt) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method remove not defined"];
}
-(void) inside: (id<ORIntSet>) S
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method inside not defined"];
}
-(void) updateMin: (ORInt) newMin
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method updateMin not defined"];
}
-(void) updateMax: (ORInt) newMax
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method updateMax not defined"];
}
-(ORBounds) updateMin: (ORInt) newMin andMax: (ORInt) newMax
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method updateMin not defined"];
}
-(NSMutableSet*) constraints
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method constraint not defined"];
   return NULL;
}
-(CPMultiCast*) delegate
{
   return _recv;
}
-(void) setDelegate: (CPMultiCast*) d
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
-(CPIntVar*) findAffine:(ORInt)scale shift:(ORInt)shift
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method findAffine not defined"];
   return NULL;
}
-(void) setTracksLoseEvt
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method setTracksLoseEvt not defined"];
}
-(ORBool) tracksLoseEvt
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method trackLoseEvt not defined"];
}
-(void) bindEvt: (id<CPDom>) sender
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method bindEvt not defined"];
}
-(void) domEvt: (id<CPDom>)sender
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method domEvt not defined" ];
}
-(void) changeMinEvt:(ORInt) dsz sender: (id<CPDom>)sender
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method changeMinEvt not defined"];
}
-(void) changeMaxEvt:(ORInt) dsz sender: (id<CPDom>)sender
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method changeMaxEvt not defined"];
}
-(void) loseValEvt: (ORInt) val sender: (id<CPDom>)sender
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method loseValEvt not defined"];
}


-(void) whenBindDo: (ORClosure) todo priority: (ORInt) p onBehalf: (CPCoreConstraint*)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method whenBindDo not defined"];   
}
-(void) whenChangeDo: (ORClosure) todo priority: (ORInt) p onBehalf: (CPCoreConstraint*)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method whenChangeDo not defined"];   
}
-(void) whenChangeMinDo: (ORClosure) todo priority: (ORInt) p onBehalf: (CPCoreConstraint*)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method whenChangeMinDo not defined"];   
}
-(void) whenChangeMaxDo: (ORClosure) todo priority: (ORInt) p onBehalf: (CPCoreConstraint*)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method whenChangeMaxDo not defined"];   
}
-(void) whenChangeBoundsDo: (ORClosure) todo priority: (ORInt) p onBehalf: (CPCoreConstraint*)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method whenChangeBoundsDo not defined"];
}
-(void) whenLoseValue: (CPCoreConstraint*)c do: (ORIntClosure) todo
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method whenLoseValue not defined"];   
}
-(id<CPTrigger>) setLoseTrigger: (ORInt) val do: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method whenLoseTrigger not defined"];  
   return NULL;
}
-(id<CPTrigger>) setBindTrigger: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method whenBindTrigger not defined"];  
   return NULL;
}
-(void) watch: (ORInt) val with: (id<CPTrigger>) t
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method watch not defined"];     
}
-(void) createTriggers
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method createTriggers not defined"];
}

-(void) whenBindDo: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenBindDo: todo priority: HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeDo: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenChangeDo: todo priority: HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeMinDo: (ORClosure) todo  onBehalf:(CPCoreConstraint*)c
{
   [self whenChangeMinDo: todo priority: HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeMaxDo: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenChangeMaxDo: todo priority: HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeBoundsDo: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenChangeBoundsDo: todo priority: HIGHEST_PRIO onBehalf:c];
}

-(void) whenBindPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntBase: method whenBindPropagate not defined"];
}
-(void) whenChangePropagate:  (CPCoreConstraint*) c priority: (ORInt) p
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method whenChangePropagate not defined"];
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method whenChangeMinPropagate not defined"];
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method whenChangeMaxPropagate not defined"];
}
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPIntVar: method whenChaneBoundsPropagate not defined"];
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

@end

/*****************************************************************************************/
/*                        CPIntVarI                                                      */
/*****************************************************************************************/

@implementation CPIntVarCst
-(CPIntVarCst*) initCPIntVarCst: (CPEngineI*) engine value: (ORInt) value;
{
   self = [super initCPIntVar: engine];
   _vc = CPVCCst;
   _value = value;
   return self;
}
-(void) dealloc
{
   if (_recv != nil)
      [_recv release];
   [super dealloc];
}
-(ORBool) isBool
{
   return _isBool;
}
-(NSMutableSet*) constraints
{
   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:2];
   return rv;
}
// PVH: I hate these guys; pollute the interface
-(CPIntVar*) findAffine: (ORInt) scale shift: (ORInt) shift
{
   if (scale==1 && shift==0)
      return self;
   else
      return nil;
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
   return TRUE;
}
-(ORInt) min
{
   return _value;
}
-(ORInt) max
{
   return _value;
}
-(ORInt) value
{
   return _value;
}
-(ORDouble) doubleMin
{
   return _value;
}
-(ORDouble) doubleMax
{
   return _value;
}
-(ORDouble) doubleValue
{
   return _value; 
}
-(ORInt) intValue
{
   return _value; 
}
-(ORBounds) bounds
{
   return (ORBounds){_value,_value};
}
-(ORInt) domsize
{
   return 1;
}
-(ORInt) countFrom:(ORInt)from to:(ORInt)to
{
   return (_value >= from && _value <= to);
}
-(ORBool) member:(ORInt)v
{
   return _value == v;
}
// PVH: No idea what the semantics is
-(ORRange) around: (ORInt) v
{
   return (ORRange){_value-1,_value+1};
}
-(ORInt) literal
{
   return 0;
}
-(id<CPIntVar>) base
{
   return self;
}
-(NSString*) description
{
   NSMutableString* s = [NSMutableString stringWithCapacity:64];
#if !defined(_NDEBUG)
   [s appendFormat:@"var<%d>=",_name];
#endif
   [s appendFormat:@"%d",_value];
   return s;
}

-(ORBool) tracksLoseEvt
{
   return NO;
}
-(void) setTracksLoseEvt
{
}

// AC3 Closure Events

-(void)whenBindDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
}
-(void)whenChangeDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
}
-(void) whenChangeMinDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
}
-(void) whenChangeMaxDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
}
-(void) whenChangeBoundsDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
}

// Constraint-based Events

-(void) whenBindPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
}
-(void) whenChangePropagate:  (CPCoreConstraint*) c priority: (ORInt) p
{
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
}
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
}

// ValueClosure Events
-(void) whenLoseValue: (CPCoreConstraint*) c do: (ORIntClosure) todo
{
}

-(id<CPTrigger>) setLoseTrigger: (ORInt) value do: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
{
   return NULL;
}
-(void) watch: (ORInt) val with: (id<CPTrigger>) t;
{
}
-(id<CPTrigger>) setBindTrigger: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
{
   return NULL;
}
-(void) createTriggers
{
}

-(void) bindEvt:(id<CPDom>) sender
{
}
-(void) domEvt: (id<CPDom>)sender
{
}
-(void) changeMinEvt: (ORInt) dsz sender:(id<CPDom>)sender
{
}

-(void) changeMaxEvt: (ORInt) dsz sender:(id<CPDom>)sender
{
}

-(void) loseValEvt: (ORInt) val sender:(id<CPDom>)sender
{
}
-(void) updateMin: (ORInt) newMin
{
   if (newMin > _value)
      failNow();
}
-(void) updateMax: (ORInt) newMax
{
   if (newMax < _value)
      failNow();
}
-(ORBounds) updateMin:(ORInt) newMin andMax:(ORInt)newMax
{
   if (newMin > _value)
      failNow();
   if (newMax < _value)
      failNow();
   return (ORBounds){_value,_value};
}
-(void) bind: (ORInt) val
{
   if (_value != val)
      failNow();
}
-(void) remove: (ORInt) val
{
   if (_value == val)
      failNow();
}
-(void) inside:(ORIntSetI*) S
{
   if (![S member: _value])
      failNow();
}
@end

/*****************************************************************************************/
/*                        CPIntVarI                                                      */
/*****************************************************************************************/

@implementation CPIntVarI {
   @public
   CPEventNetwork  _net;
}

#define TRACKLOSSES (_net._valueClosureQueue._val != nil || _triggers != nil)

-(CPIntVar*) initCPIntVarCore: (CPEngineI*)engine low: (ORInt) low up: (ORInt)up
{
   self = [super initCPIntVar: engine];
   _vc = CPVCBare;
   setUpNetwork(&_net, [_fdm trail],low,up-low+1);
   _triggers = nil;
   _dom = nil;
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
-(ORBool) isBool
{
   return _isBool;
}
-(ORInt)degree
{
   __block ORUInt d = 0;
   [_net._bindEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr)   { d += [cstr nbVars] - 1;}];
   [_net._boundsEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr) { d += [cstr nbVars] - 1;}];
   [_net._domEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr)    { d += [cstr nbVars] - 1;}];
   [_net._maxEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr)    { d += [cstr nbVars] - 1;}];
   [_net._minEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr)    { d += [cstr nbVars] - 1;}];
   return d;
}
-(NSMutableSet*) constraints
{
   NSMutableSet* rv = collectConstraints(&_net,[[[NSMutableSet alloc] initWithCapacity:2] autorelease]);
   return rv;
}
-(CPBitDom*) flatDomain
{
   return newDomain((CPBitDom*)_dom, 1, 0);
}
-(CPIntVar*) findAffine:(ORInt)scale shift:(ORInt)shift
{
   if (scale==1 && shift==0)
      return self;
   else
      return nil;
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
   assert(_dom);
   if ([_dom bound])
      return [_dom min];
   else {
      @throw [[ORExecutionError alloc] initORExecutionError: "The Integer Variable is not Bound"];
      return 0;
   }
}
-(ORDouble) doubleMin
{
   return [_dom min];
}
-(ORDouble) doubleMax
{
   return [_dom max];
}
-(ORDouble) doubleValue
{
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
-(ORBool)member:(ORInt)v
{
    return [_dom member:v];
}
-(ORRange)around:(ORInt)v
{
   ORInt low = [_dom findMax:v-1];
   ORInt up  = [_dom findMin:v+1];
   return (ORRange){low,up};
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
   if ([dom isMemberOfClass:[CPBoundsDom class]]) {
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

#define TRACKSINTVAR (_net._valueClosureQueue._val != nil || _triggers != nil || _recv)

-(ORBool) tracksLoseEvt
{
  //return TRACKSINTVAR;
   if (_net._valueClosureQueue[0] != nil || _triggers != nil)
      return YES;
   else if (_recv && [_recv tracksLoseEvt])
      return YES;
   else
      return NO;
}
// nothing to do here
-(void) setTracksLoseEvt
{
}

BOOL tracksLoseEvt(id<CPIntVarNotifier> x)
{
   switch(((CPIntVar*)x)->_vc) {
      case CPVCBare: {
         CPIntVarI* y = (CPIntVarI*)x;
         if (y->_net._valueClosureQueue[0] != nil || y->_triggers != nil)
            return YES;
         else if (y->_recv && [y->_recv tracksLoseEvt])
            return YES;
         else
            return NO;
      }
      default: return [x tracksLoseEvt];
   }
}

// AC3 Closure Events

-(void)whenBindDo: (ORClosure) todo priority: (ORInt) p onBehalf: (CPCoreConstraint*)c
{
   hookupEvent(_fdm, _net._bindEvt, todo, c, p);
}
-(void)whenChangeDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent(_fdm, _net._domEvt, todo, c, p);
}
-(void) whenChangeMinDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent(_fdm, _net._minEvt, todo, c, p);
}
-(void) whenChangeMaxDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent(_fdm, _net._maxEvt, todo, c, p);
}
-(void) whenChangeBoundsDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent(_fdm, _net._boundsEvt, todo, c, p);
}

// Constraint-based Events
-(void) whenBindPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent(_fdm, _net._bindEvt, nil, c, p);
}
-(void) whenChangePropagate:  (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent(_fdm, _net._domEvt, nil, c, p);
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent(_fdm, _net._minEvt, nil, c, p);
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent(_fdm, _net._maxEvt, nil, c, p);
}
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent(_fdm, _net._boundsEvt, nil, c, p);
}


// ValueClosure Events
-(void) whenLoseValue: (CPCoreConstraint*) c do: (ORIntClosure) todo 
{
   [_recv setTracksLoseEvt];
   hookupEvent(_fdm, _net._valueClosureQueue, todo, c, HIGHEST_PRIO);
}

-(id<CPTrigger>) setLoseTrigger: (ORInt) value do: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
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
-(id<CPTrigger>) setBindTrigger: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
{
    [_recv setTracksLoseEvt];
    if (_triggers == nil)
        [self createTriggers];
    return [_triggers linkBindTrigger:[CPTriggerMap createTrigger: todo onBehalf:c]];
}
-(void) createTriggers
{
    if (_triggers == nil) {
       id<CPDom> d = [self domain];
       ORInt low = [d imin];
       ORInt up = [d imax];
       [d release];
       _triggers = [CPTriggerMap triggerMapFrom:low to:up dense:(up-low+1)<256];
    }
}

-(void) bindEvt:(id<CPDom>) sender
{
   if (_recv)
      bindEvt(_recv, sender);
//      [_recv bindEvt: sender];

   id<CPClosureList> mList[6];
   ORUInt k = 0;
   mList[k] = _net._boundsEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._minEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._maxEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._domEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._bindEvt[0];
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_fdm,mList);
   if (_triggers)
      [_triggers bindEvt: _fdm];
}

-(void) domEvt: (id<CPDom>)sender
{
   if (_recv)
      domEvt(_recv,sender);
   id<CPClosureList> mList[6];
   ORUInt k = 0;
   mList[k] = _net._domEvt[0];
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_fdm,mList);
}

-(void) changeMinEvt: (ORInt) dsz sender:(id<CPDom>)sender
{
   if (_recv)
      changeMinEvt(_recv,dsz,sender);

   id<CPClosureList> mList[6];
   ORUInt k = 0;
   mList[k] = _net._boundsEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._minEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._domEvt[0];
   k += mList[k] != NULL;
   mList[k] = dsz==1 ? _net._bindEvt[0] : NULL;
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_fdm,mList);
   if (_triggers && dsz==1)
        [_triggers bindEvt:_fdm];
}

-(void) changeMaxEvt: (ORInt) dsz sender: (id<CPDom>)sender
{
   if (_recv)
      changeMaxEvt(_recv,dsz,sender);
  
   id<CPClosureList> mList[6];
   id<CPClosureList>* ptr = mList;
   *ptr  = _net._boundsEvt[0];
   ptr += *ptr != NULL;
   *ptr = _net._domEvt[0];
   ptr += *ptr != NULL;
   *ptr = _net._maxEvt[0];
   ptr += *ptr != NULL;
   *ptr = dsz==1 ? _net._bindEvt[0] : NULL;
   ptr += *ptr != NULL;
   *ptr = NULL;
   scheduleClosures(_fdm,mList);
   if (_triggers && dsz==1)
      [_triggers bindEvt:_fdm];
}

-(void) loseValEvt: (ORInt) val sender:(id<CPDom>)sender
{
   if (_recv !=nil) 
      [_recv loseValEvt:val sender:sender];
   if (_net._valueClosureQueue[0])
      [_fdm scheduleValueClosure:[CPValueLossEvent newValueLoss:val notify:_net._valueClosureQueue[0]]];
   if (_triggers)
      [_triggers loseValEvt:val solver:_fdm];
}
-(void) updateMin: (ORInt) newMin
{
   [_dom updateMin:newMin for:self tle:tracksLoseEvt(self)];
}
-(void) updateMax: (ORInt) newMax
{
   [_dom updateMax:newMax for:self tle:tracksLoseEvt(self)];
}
-(ORBounds) updateMin:(ORInt) newMin andMax:(ORInt)newMax
{
   [_dom updateMin:newMin andMax:newMax for:self tle:tracksLoseEvt(self)];
   return domBounds((CPBoundsDom*)_dom);
}
-(void) bind: (ORInt) val
{
   [_dom bind:val for:self tle:tracksLoseEvt(self)];
}
-(void) remove: (ORInt) val
{
   [_dom remove:val for:self];
}
-(void) inside:(ORIntSetI*) S
{
    ORInt m = [self min];
    ORInt M = [self max];
    for(ORInt i = m; i <= M; i++) {
        if ([self member: i] && ![S member: i])
            [self remove: i];
    }
}

-(CPIntVar*) initCPExplicitIntVar: (id<CPEngine>)engine bounds:(id<ORIntRange>)b
{
   ORInt l = [b low],u = [b up];
   self = [self initCPIntVarCore: engine low: l up: u];
   _dom = [[CPBoundsDom alloc] initBoundsDomFor:[_fdm trail] low: l up: u];
   return self;
}

-(CPIntVar*) initCPExplicitIntVar: (id<CPEngine>)engine low: (ORInt) low up: (ORInt) up
{
    self = [self initCPIntVarCore: engine low:low up:up];
    _dom = [[CPBitDom alloc] initBitDomFor:[_fdm trail] low:low up:up];
    return self;
}

-(CPIntVar*) initCPIntVarView: (id<CPEngine>) engine low: (ORInt) low up: (ORInt) up for: (CPIntVar*) x
{
   self = [self initCPIntVarCore:engine low: low up: up];
   _vc = CPVCAffine;
   CPMultiCast* xDeg = [x delegate];
   if (xDeg == nil) {
      CPMultiCast* mc = [[CPMultiCast alloc] initVarMC:2 root:x];
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

+(CPIntVar*)    initCPIntVar: (id<CPEngine>)fdm bounds:(id<ORIntRange>)b
{
   CPIntVarI* x = [[CPIntVarI alloc] initCPExplicitIntVar: fdm bounds:b];
   x->_isBool = ([b low] == 0 && [b up] == 1);
   return x;
}

+(CPIntVar*) initCPIntVar: (id<CPEngine>) fdm low: (ORInt) low up: (ORInt) up
{
   CPIntVarI* x = nil;
   ORLong sz = (ORLong)up - low + 1;
   if (low==0 && up==1)
      x = [[CPIntVarI alloc] initCPExplicitIntVar: fdm bounds: [fdm boolRange]];     // binary domain. Use bounds only.
   else if (sz >= 65536)
      x = [[CPIntVarI alloc] initCPExplicitIntVar: fdm bounds: RANGE(fdm,low,up)];  // large domain. Fall back to bounds only.
   else
      x = [[CPIntVarI alloc] initCPExplicitIntVar: fdm low: low up: up];            // Smallish domain. Use bit-vectors.
   x->_isBool = (low == 0 && up==1);
   return x;
}
+(CPIntVar*) initCPBoolVar: (id<CPEngine>) fdm
{
   CPIntVarI* x = [[CPIntVarI alloc] initCPExplicitIntVar: fdm bounds: [fdm boolRange]];
   x->_isBool = YES;
   return x;
}

+(CPIntVar*) initCPIntView: (CPIntVar*) x withShift: (ORInt) b
{
   CPIntShiftView* view = [[CPIntShiftView alloc] initIVarShiftView: x b: b];
   return view;
}
+(CPIntVar*) initCPFlipView: (CPIntVar*)x
{
   CPIntVar* rv = [x->_recv findAffine:-1 shift:0];
   if (rv==nil) {
      rv = [[CPIntFlipView alloc] initFlipViewFor:x];
   }
   return rv;
}
+(CPIntVar*) initCPIntView: (CPIntVar*) x withScale: (ORInt) a
{
   CPIntVar* rv = [x->_recv findAffine:a shift:0];
   if (rv == nil)
      rv = [[CPIntView alloc] initIVarAViewFor: a x: x b: 0];
   return rv;
}
+(CPIntVar*) initCPIntView: (CPIntVar*) x withScale: (ORInt) a andShift: (ORInt) b
{
   CPIntVar* rv = [x->_recv findAffine:a shift:b];
   if (rv==nil)
      rv = [[CPIntView alloc] initIVarAViewFor: a x: x b: b];
   return rv;
}
+(CPIntVar*) initCPNegateBoolView: (CPIntVar*) x
{
   CPIntVar* rv = [x->_recv findAffine:-1 shift:1];
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
-(CPIntShiftView*)initIVarShiftView: (CPIntVar*) x b: (ORInt) b
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
}
-(void) updateMin: (ORInt) newMin
{
   [_x updateMin: newMin-_b];
}
-(void) updateMax: (ORInt) newMax
{
   [_x updateMax: newMax-_b];
}
-(ORBounds) updateMin:(ORInt) newMin andMax:(ORInt)newMax
{
   [_x updateMin:newMin-_b];
   [_x updateMax:newMax-_b];
   ORBounds bnd;
   bnd = domBounds((CPBitDom*)[_x domain]);
   bnd.min += _b;
   bnd.max += _b;
   return bnd;
}

-(void) bind: (ORInt) val
{
    [_x bind: val-_b];
}
-(void) remove: (ORInt) val
{
    [_x remove: val-_b];
}
// get the notification from the underlying domain; need to shift it for the network
-(void) loseValEvt: (ORInt)  val sender:(id<CPDom>)sender
{
   [super loseValEvt: val+_b sender:sender];
}
-(CPIntVar*) findAffine:(ORInt)scale shift:(ORInt)shift
{
   if (scale==1 && shift==_b)
      return self;
   else
      return nil;
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
-(CPIntView*)initIVarAViewFor: (ORInt) a  x: (CPIntVar*) x b: (ORInt) b
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
-(void) whenChangeMinDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   if (_a<0)
      hookupEvent(_fdm, _net._maxEvt, todo, c, p);
   else
      hookupEvent(_fdm, _net._minEvt, todo, c, p);
}
-(void) whenChangeMaxDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   if (_a<0)
      hookupEvent(_fdm, _net._minEvt, todo, c, p);
   else
      hookupEvent(_fdm, _net._maxEvt, todo, c, p);
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   if (_a<0)
      hookupEvent(_fdm, _net._maxEvt, nil, c, p);
   else
      hookupEvent(_fdm, _net._minEvt, nil, c, p);
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   if (_a<0)
      hookupEvent(_fdm, _net._minEvt, nil, c, p);
   else
      hookupEvent(_fdm, _net._maxEvt, nil, c, p);
}

-(void) updateMin: (ORInt) newMin
{
   ORInt op = newMin - _b;
   ORInt mv = op % _a ? 1 : 0;   // multiplier value
   if (_a > 0) {
      ORInt ms = op > 0 ? +1 : 0;  // multiplier sign
      [_x updateMin:op / _a + ms * mv];
   }
   else {
      ORInt ms = op > 0 ?  -1 : 0;
      [_x updateMax:op / _a + ms * mv];
   }
}
-(void) updateMax: (ORInt) newMax
{
   ORInt op = newMax - _b;
   ORInt mv = op % _a ? 1 : 0;
   if (_a > 0) {
      ORInt ms = op > 0  ? 0 : -1;
      [_x updateMax:op / _a + ms * mv];
   }
   else {
      ORInt ms = op < 0 ? +1 : 0;
      [_x updateMin:op / _a + ms * mv];
   }
}

-(ORBounds) updateMin:(ORInt) newMin andMax:(ORInt)newMax
{
   [self updateMin:newMin];
   [self updateMax:newMax];
   ORBounds b = bounds(_x);
   return (ORBounds){
      _a > 0 ? b.min * _a + _b : b.max * _a + _b,
      _a > 0 ? b.max * _a + _b : b.min * _a + _b
   };
}

-(void) bind: (ORInt) val
{
    ORInt r = (val - _b) % _a;
    if (r != 0)
       failNow();
    ORInt ov = (val - _b) / _a; 
    [_x bind:ov];
}
-(void) remove: (ORInt) val
{
   ORInt ov;
   if (_a == -1)
      ov = _b - val;
   else if (_a== 1)
      ov = val - _b;
   else {
      ORInt r = (val - _b) % _a;
      if (r != 0)
         return;
      ov = (val - _b) / _a; 
   }
   [_x remove:ov];
}

-(void) changeMinEvt: (ORInt) dsz sender:(id<CPDom>)sender
{
   if (_recv) {
      if (_a >= 0)
         changeMinEvt(_recv,dsz,sender);
      else
         changeMaxEvt(_recv,dsz,sender);
   }
   
   id<CPClosureList> mList[6];
   ORUInt k = 0;
   mList[k] = _net._boundsEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._minEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._domEvt[0];
   k += mList[k] != NULL;
   mList[k] = dsz==1 ? _net._bindEvt[0] : NULL;
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_fdm,mList);
   if (_triggers && dsz==1)
      [_triggers bindEvt:_fdm];
}

-(void) changeMaxEvt: (ORInt) dsz sender: (id<CPDom>)sender
{
   if (_recv) {
      if (_a >=0)
         changeMaxEvt(_recv,dsz,sender);
      else
         changeMinEvt(_recv,dsz,sender);
   }
   
   id<CPClosureList> mList[6];
   id<CPClosureList>* ptr = mList;
   *ptr  = _net._boundsEvt[0];
   ptr += *ptr != NULL;
   *ptr = _net._domEvt[0];
   ptr += *ptr != NULL;
   *ptr = _net._maxEvt[0];
   ptr += *ptr != NULL;
   *ptr = dsz==1 ? _net._bindEvt[0] : NULL;
   ptr += *ptr != NULL;
   *ptr = NULL;
   scheduleClosures(_fdm,mList);
   if (_triggers && dsz==1)
      [_triggers bindEvt:_fdm];
}

-(void) loseValEvt: (ORInt) val sender:(id<CPDom>)sender
{
   [super loseValEvt:_a * val+_b sender:sender];
}
-(CPIntVar*) findAffine:(ORInt)scale shift:(ORInt)shift
{
   if (scale == _a && shift == _b)
      return self;
   else
      return nil;
}
-(NSString*)description
{
   return [super description];
}
@end

@implementation CPIntFlipView
-(CPIntFlipView*)initFlipViewFor:(CPIntVar*)x
{
   self = [super initCPIntVarView: [x engine] low:-[x max] up:-[x min] for:x];
   _vc = CPVCFlip;
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
-(void) whenChangeMinDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent(_fdm, _net._maxEvt, todo, c, p);
}
-(void) whenChangeMaxDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent(_fdm, _net._minEvt, todo, c, p);
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent(_fdm, _net._maxEvt, nil, c, p);
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent(_fdm, _net._minEvt, nil, c, p);
}

-(void) updateMin:(ORInt)newMin
{
   [_x updateMax:-newMin];
}
-(void) updateMax:(ORInt)newMax
{
   [_x updateMin:-newMax];
}
-(ORBounds) updateMin:(ORInt) newMin andMax:(ORInt)newMax
{
   [_x updateMax:-newMin];
   [_x updateMin:-newMax];
   ORBounds b = [_x bounds];
   return (ORBounds){-b.max,-b.min};
}
-(void) bind:(ORInt)val
{
   [_x bind:-val];
}
-(void) remove:(ORInt)val
{
   [_x remove:-val];
}
-(void) loseValEvt:(ORInt)val sender:(id<CPDom>)sender
{
   [super loseValEvt:-val sender:sender];
}
-(NSString*)description
{
   return [super description];
}
@end

@implementation CPEQLitView

-(CPEQLitView*)initEQLitViewFor:(CPIntVar*)x equal:(ORInt)v
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
-(void) updateMin: (ORInt) newMin
{
   // newMin>=1 => x==v
   // newMin==0 => nothing
   if (newMin) {
      [_secondary bind:_v];
   } 
}
-(void) updateMax:(ORInt)newMax
{
   // newMax == 0 => x != v
   // newMax >= 1 => nothing
   if (newMax==0) {
      [_secondary remove:_v];
   }
}
-(ORBounds) updateMin: (ORInt) newMin andMax: (ORInt) newMax
{
   if (newMin) 
      [_secondary bind:_v];
   if (newMax==0) 
      [_secondary remove:_v];
   return [self bounds];
}
-(void) bind:(ORInt)val
{
   assert(val==0 || val==1);
   // self=0 => x must loose _lit
   // self=1 => x must be bound to _lit
   if (val==0) {
      [_secondary remove:_v];
   }
   else {
      [_secondary bind:_v];
   }
}
-(void) remove:(ORInt)val
{
   assert(val==0 || val==1);
   // val==0 -> bind to 1 -> x must be bound to _lit
   // val==1 -> bind to 0 -> x must loose _lit
   if (val==0) {
      [_secondary bind:_v];
   }
   else {
      [_secondary remove:_v];
   }
}
-(void) bindEvt:(id<CPDom>)sender
{
   [super bindEvt:sender];
}
-(void) domEvt:(id<CPDom>)sender
{
   BOOL isb = bound(_secondary) || !memberDom(_secondary, _v);
   // [ldm]
   // There is no "dom Evt" to speak of in the literal view if the literal view is not
   // bound (the evt of the secondary must "disappear" in that case.
   if (isb)
      [super domEvt:sender];
}
-(void) loseValEvt:(ORInt)val sender:(id<CPDom>)sender
{
   if (val == _v) {
      // We lost the value being watched. So the boolean lost TRUE
      [super bindEvt:sender];
   }
   else {
      // We lost some other value. So we may have bound(_seconday) && minDom(_secondary)==_v      
      if (bound(_secondary) && minDom(_secondary) == _v) {
         [super bindEvt:sender];
      } 
   }
}
-(void) changeMinEvt:(ORInt)dsz sender:(id<CPDom>)sender
{
   if (bound(_secondary)) {
      [super bindEvt:sender];
   } else {
      if (minDom(_secondary) > _v)
         [super bindEvt:sender];
   }
}
-(void) changeMaxEvt:(ORInt)dsz sender:(id<CPDom>)sender
{
   if (bound(_secondary)) {
      [super bindEvt:sender];
   } else {
      ORInt sMax = maxDom(_secondary);
      if (sMax < _v)
         [super bindEvt:sender];
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
@end

/*****************************************************************************************/
/*                        MultiCast Notifier                                             */
/*****************************************************************************************/

@implementation CPMultiCast

-(id) initVarMC: (ORInt) n root: (CPIntVar*) root
{
   self = [super init];
   _mx  = n;
   _tab = malloc(sizeof(id<CPIntVarNotifier>)*_mx);
   _loseValIMP   = malloc(sizeof(UBType)*_mx);
   _minIMP   = malloc(sizeof(UBType)*_mx);
   _maxIMP   = malloc(sizeof(UBType)*_mx);
   _tracksLoseEvt = false;
   [root setDelegate: self];
   _nb = 0;
   _literals = nil;
   return self;
}
-(ORUInt) getId
{
   assert(FALSE);
   return 0;
}
-(void) dealloc
{
   free(_tab);
   free(_minIMP);
   free(_maxIMP);
   free(_loseValIMP);
   [super dealloc];
}
// PVH: Objective-C does not allow id<CPIntVarNotifier> for some obscure reason.
-(void) addVar:(id) v
{
   if (_nb >= _mx) {
      _tab = realloc(_tab,sizeof(id<CPIntVarNotifier>)*(_mx<<1));
      _loseValIMP = realloc(_loseValIMP,sizeof(UBType)*(_mx << 1));
      _minIMP     = realloc(_minIMP,sizeof(UBType)*(_mx << 1));
      _maxIMP     = realloc(_maxIMP,sizeof(UBType)*(_mx << 1));
      _mx <<= 1;
   }
   _tab[_nb] = v;  // DO NOT RETAIN. v will point to us because of the delegate
   _tracksLoseEvt |= [_tab[_nb] tracksLoseEvt];
   _loseValIMP[_nb] = (UBType)[v methodForSelector:@selector(loseValEvt:sender:)];
   _minIMP[_nb] = (UBType)[v methodForSelector:@selector(changeMinEvt:sender:)];
   _maxIMP[_nb] = (UBType)[v methodForSelector:@selector(changeMaxEvt:sender:)];
   CPEngineI* engine = (id)[v engine];
   id<ORTrail> theTrail = [engine trail];
   ORInt toFix = _nb;
   __block CPMultiCast* me = self;
   [theTrail trailClosure:^{
      me->_tab[toFix] = NULL;
      me->_loseValIMP[toFix] = NULL;
      me->_minIMP[toFix] = NULL;
      me->_maxIMP[toFix] = NULL;
      me->_nb = toFix;  // [ldm] This is critical (see comment below in bindEvt)
   }];
   _nb++;
   // PVH: Sanity check
   ORInt nbBare = 0;
   for(ORInt i=0;i<_nb;i++) {
      if (_tab[i] !=nil)
         nbBare += ([((id)_tab[i]) varClass] == CPVCBare);
   }
   assert(nbBare<=1);
   // PVH: End of sanity check
}

-(CPLiterals*) findLiterals: (CPIntVar*) ref
{
   if (_literals)
      return _literals;
   CPLiterals* newLits = [[CPLiterals alloc] initCPLiterals:ref];
   //_tracksLoseEvt = YES;
   id<ORTrail> theTrail = [[ref engine] trail];
   [theTrail trailClosure: ^{
      _literals = NULL;
   }];
   _literals = newLits;
   return newLits;
}

-(CPIntVar*) findAffine: (ORInt) scale shift: (ORInt) shift
{
   for(ORUInt i=0;i < _nb;i++) {
      CPIntVar* sel = [_tab[i] findAffine: scale shift: shift];
      if (sel)
         return sel;
   }
   return nil;
}

-(NSString*) description
{
   static const char* classes[] = {"Bare","Shift","Affine","EQLit","Literals","Flip","NEQLit"};
   NSMutableString* buf = [NSMutableString stringWithCapacity:64];
   [buf appendFormat:@"MC:<%d>[",_nb];
   for(ORUInt k=0;k<_nb;k++) {
      if (_tab[k] == nil)
         [buf appendFormat:@"nil %c",k < _nb -1 ? ',' : ']'];
      else
         [buf appendFormat:@"%s %c",classes[[((id)_tab[k]) varClass]],k < _nb -1 ? ',' : ']'];
   }
   return buf;
}
-(void) setTracksLoseEvt
{
    _tracksLoseEvt = true;
}
-(ORBool) tracksLoseEvt
{
   return _tracksLoseEvt;
   if (_tracksLoseEvt)
      return true;
   else {
      for(ORUInt k=0;k<_nb && !_tracksLoseEvt;k++)
	 _tracksLoseEvt |= [_tab[k] tracksLoseEvt];
      return _tracksLoseEvt;
   }
}
void bindEvt(CPMultiCast* x,id<CPDom> sender)
{
   if (x->_literals)
      [x->_literals bindEvt: sender];
   for(ORInt i=0;i<x->_nb;i++)
       [x->_tab[i] bindEvt:sender];
}
void domEvt(CPMultiCast* x,id<CPDom> sender)
{
   // [ldm] This should not be necessary
   // given that a set of loveValEvt _always_ preceeds a domEvt.
   // only relay to views, ignore the literals!
//   if (x->_literals)
//      literalDomEvt(x->_literals, sender);
   for(ORInt i=0;i<x->_nb;i++)
      [x->_tab[i] domEvt:sender];
}

void changeMinEvt(CPMultiCast* x,ORInt dsz,id<CPDom> sender)
{
   if (x->_literals)
      [x->_literals changeMinEvt: dsz sender: sender];
   SEL ms = @selector(changeMinEvt:sender:);
   for(ORInt i=0;i<x->_nb;i++)
      x->_minIMP[i](x->_tab[i],ms,dsz,sender);
}
void changeMaxEvt(CPMultiCast* x,ORInt dsz,id<CPDom> sender)
{
   if (x->_literals)
      [x->_literals changeMaxEvt: dsz sender: sender];
   SEL ms = @selector(changeMaxEvt:sender:);
   for(ORInt i=0;i<x->_nb;i++)
      x->_maxIMP[i](x->_tab[i],ms,dsz,sender);
}
-(void) loseValEvt:(ORInt)val sender:(id<CPDom>)sender
{
   if (!_tracksLoseEvt)
      return;
   if (_literals)
      [_literals loseValEvt: val sender: sender];
   for(ORInt i=0;i<_nb;i++) {
      _loseValIMP[i](_tab[i],@selector(loseValEvt:sender:),val,sender);
   }
 }
@end

@implementation CPLiterals {
   CPIntVar*     _ref;
   CPEQLitView** _pos;
   ORInt          _nb;
   ORInt         _ofs;
   TRInt           _a;
   TRInt           _b;
   BOOL       _tracksLoseEvt;
   IMP  _changeMaxEvtIMP;
   IMP  _changeMinEvtIMP;
   IMP  _domEvtIMP;
}
-(id) initCPLiterals: (CPIntVar*) ref
{
   self = [super init];
   id<CPDom> rd = [ref domain];
   _nb  = [rd imax] - [rd imin] + 1;
   _ofs = [rd imin];
   [rd release];
   _ref = ref;
   _pos = malloc(sizeof(CPIntVar*)*_nb);
   _a = makeTRInt([[ref engine] trail], 0);
   _b = makeTRInt([[ref engine] trail], _nb);
   for(ORInt i=0;i<_nb;i++)
      _pos[i] = nil;
   _tracksLoseEvt = NO;
   _changeMaxEvtIMP = [CPEQLitView instanceMethodForSelector:@selector(changeMaxEvt:sender:)];
   _changeMinEvtIMP = [CPEQLitView instanceMethodForSelector:@selector(changeMinEvt:sender:)];
   _domEvtIMP       = [CPEQLitView instanceMethodForSelector:@selector(domEvt:)];
   return self;
}
-(void) dealloc
{
   free(_pos);
   [super dealloc];
}
-(NSMutableSet*) constraints
{
   assert(FALSE);
   return nil;
}
-(void) setTracksLoseEvt
{
   _tracksLoseEvt = YES;
}
-(ORBool) tracksLoseEvt
{
   return _tracksLoseEvt;
}
-(CPIntVar*) findAffine: (ORInt) scale shift: (ORInt) shift
{
   return nil;
}
-(void) addPositive: (CPEQLitView*) x forValue: (ORInt) value
{
   assert(_pos[value - _ofs] == 0);
   _pos[value - _ofs] = x;
}
-(CPEQLitView*) positiveForValue: (ORInt) value
{
   return _pos[value - _ofs];
}
-(void) bindEvt:(id<CPDom>) sender
{
   for(ORInt i=_a._val;i <_b._val;i++) {
      [_pos[i] bindEvt:sender];
   }
   assignTRInt(&_b,_a._val, [[_ref engine] trail]);
}
void literalDomEvt(CPLiterals* x,id<CPDom> sender)
{
   SEL dSEL = @selector(domEvt:);
   for(ORInt i=x->_a._val;i < x->_b._val;i++)
      if (x->_pos[i])
         x->_domEvtIMP(x->_pos[i],dSEL,sender);
}
-(void) domEvt:(id<CPDom>)sender
{
   SEL dSEL = @selector(domEvt:);
   for(ORInt i=_a._val;i <_b._val;i++) {
      if (_pos[i])
         _domEvtIMP(_pos[i],dSEL,sender);
//      [_pos[i] domEvt:sender];
   }
}
-(void) changeMinEvt: (ORInt) dsz sender: (id<CPDom>) sender
{
   ORInt min = [_ref min];
   for(ORInt i=_a._val;i <min - _ofs;i++) {
      CPIntVar* lv = _pos[i];
      [lv bindEvt:sender];
   }
   assignTRInt(&_a,min - _ofs - 1,[[_ref engine] trail]);
   if (dsz==1) {
      CPIntVar* lv = _pos[[sender min] - _ofs];
      [lv bindEvt:sender];
   }
}
-(void) changeMaxEvt:(ORInt)dsz sender:(id<CPDom>)sender
{
   ORInt max = [_ref max];
   for(ORInt i = max + 1 - _ofs;i<_b._val;i++) {
      CPIntVar* lv = _pos[i];
      [lv bindEvt:sender];
   }
   assignTRInt(&_b, max - _ofs + 1, [[_ref engine] trail]);
   if (dsz==1) {
      CPIntVar* lv = _pos[[sender min] - _ofs];
      return [lv bindEvt:sender];
   } 
}
-(void) loseValEvt:(ORInt)val sender:(id<CPDom>)sender
{
   if (_pos[val - _ofs])
      [_pos[val - _ofs] bindEvt: sender];
}
@end
