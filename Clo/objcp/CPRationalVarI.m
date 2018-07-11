//
//  CPRationalVarI.m
//  objcp
//
//  Created by Rémy Garcia on 04/07/2018.
//

#import "CPRationalVarI.h"
#import <CPUKernel/CPUKernel.h>
#import "CPRationalDomN.h"

/*****************************************************************************************/
/*                        CPRationalVarSnapshot                                          */
/*****************************************************************************************/

@interface CPRationalVarSnapshot : NSObject
{
   ORUInt      _name;
   ORRational* _value;
   ORBool      _bound;
   ORBool      _boundError;
}
-(CPRationalVarSnapshot*) init: (CPRationalVarI*) v name: (ORInt) name;
-(ORUInt) getId;
-(ORRational*) rationalValue;
-(NSString*) description;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
@end

@implementation CPRationalVarSnapshot
-(CPRationalVarSnapshot*) init: (CPRationalVarI*) v name: (ORInt) name
{
   self = [super init];
   _name = name;
   _value = [[ORRational alloc] init];
   if ([v bound]) {
      _bound = TRUE;
      [_value set: [v rationalValue]];
   }
   else {
      [_value set_d: 0.0];
      _bound = FALSE;
   }
   return self;
}
-(void) dealloc
{
   [_value release];
   [super dealloc];
}
-(ORRational*) rationalValue
{
   return _value;
}
-(ORBool) bound
{
   return _bound;
}
-(ORUInt) getId
{
   return _name;
}
-(ORBool) isEqual: (id) object
{
   if ([object isKindOfClass:[self class]]) {
      CPRationalVarSnapshot* other = object;
      if (_name == other->_name) {
         return [_value eq: other->_value] && _bound == other->_bound;
      }
      else
         return NO;
   }
   else
      return NO;
}
-(NSUInteger)hash
{
   return (_name << 16) + (ORInt) [_value get_d];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"Rational(%d) : %@",_name,_value];
   return buf;
}
- (void) encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aCoder encodeValueOfObjCType:@encode(ORRational) at:&_value];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_bound];
}
- (id) initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORRational) at:&_value];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_bound];
   return self;
}
@end

static void setUpNetwork(CPRationalEventNetwork* net,id<ORTrail> t)
{
   net->_bindEvt   = makeTRId(t,nil);
   net->_minEvt    = makeTRId(t,nil);
   net->_maxEvt    = makeTRId(t,nil);
   net->_boundsEvt = makeTRId(t,nil);
}

static void deallocNetwork(CPRationalEventNetwork* net)
{
   freeList(net->_bindEvt);
   freeList(net->_minEvt);
   freeList(net->_maxEvt);
   freeList(net->_boundsEvt);
}

static NSMutableSet* collectConstraints(CPRationalEventNetwork* net,NSMutableSet* rv)
{
   collectList(net->_bindEvt,rv);
   collectList(net->_minEvt,rv);
   collectList(net->_maxEvt,rv);
   collectList(net->_boundsEvt,rv);
   return rv;
}

@implementation CPRationalVarI

-(id)init:(CPEngineI*)engine low:(ORRational*)low up:(ORRational*)up
{
   self = [super init];
   _engine = engine;
   _dom = [[CPRationalDomN alloc] initCPRationalDom:[engine trail] low:low up:up];
   _recv = nil;
   _hasValue = false;
   _value = [[ORRational alloc] init];
   [_value set_d: 0.0];
   setUpNetwork(&_net, [engine trail]);
   [_engine trackVariable: self];
   return self;
}

-(id)init:(CPEngineI*)engine
{
   self = [super init];
   _engine = engine;
   _dom = [[CPRationalDomN alloc] initCPRationalDom:[engine trail] lowF:-INFINITY upF:INFINITY];
   _recv = nil;
   _hasValue = false;
   [_value set_d: 0.0];
   setUpNetwork(&_net, [engine trail]);
   [_engine trackVariable: self];
   return self;
}
-(void)dealloc
{
   deallocNetwork(&_net);
   [_value release];
   [super dealloc];
}
-(CPEngineI*) engine
{
   return _engine;
}
-(CPEngineI*) tracker
{
   return _engine;
}
-(id) takeSnapshot: (ORInt) id
{
   return [[CPRationalVarSnapshot alloc] init: self name: id];
}
-(NSMutableSet*)constraints
{
   NSMutableSet* rv = collectConstraints(&_net,[[NSMutableSet alloc] initWithCapacity:2]);
   return rv;
}
-(ORInt)degree
{
   __block ORUInt d = 0;
   [_net._bindEvt scanCstrWithBlock:^(CPCoreConstraint* cstr)   { d += [cstr nbVars] - 1;}];
   [_net._maxEvt scanCstrWithBlock:^(CPCoreConstraint* cstr)    { d += [cstr nbVars] - 1;}];
   [_net._minEvt scanCstrWithBlock:^(CPCoreConstraint* cstr)    { d += [cstr nbVars] - 1;}];
   [_net._boundsEvt scanCstrWithBlock:^(CPCoreConstraint* cstr) { d += [cstr nbVars] - 1;}];
   return d;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"var<%d>=",_name];
   [buf appendString:[_dom description]];
   return buf;
}
-(void)setDelegate:(id<CPRationalVarNotifier>)delegate
{}
-(void) addVar:(CPRationalVarI*)var
{}
-(enum CPVarClass)varClass
{
   return CPVCBare;
}
-(CPRationalVarI*) findAffine: (ORRational*) scale shift:(ORRational*) shift
{
   return nil;
}
-(void) whenBindDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._bindEvt, todo, c, p);
}
-(void) whenChangeMinDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._minEvt, todo, c, p);
}
-(void) whenChangeMaxDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._maxEvt, todo, c, p);
}
-(void) whenChangeBoundsDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._boundsEvt, todo, c, p);
}
- (void)whenChangeDo:(ORClosure)todo priority:(ORInt)p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._boundsEvt, todo, c, p);
}
-(void) whenBindDo: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenBindDo:todo priority:HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeMinDo: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenChangeMinDo:todo priority:HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeMaxDo: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenChangeMaxDo:todo priority:HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeBoundsDo: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenChangeBoundsDo:todo priority:HIGHEST_PRIO onBehalf:c];
}
// AC3 Constraint Event
-(void) whenBindPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent((id)_engine, &_net._bindEvt, nil, c, p);
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent((id)_engine, &_net._minEvt, nil, c, p);
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent((id)_engine, &_net._maxEvt, nil, c, p);
}
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent((id)_engine, &_net._boundsEvt, nil, c, p);
}
- (void)whenChangePropagate:(CPCoreConstraint*)c priority:(ORInt)p
{
   hookupEvent((id)_engine, &_net._boundsEvt, nil, c, p);
}
-(void) whenBindPropagate: (CPCoreConstraint*) c
{
   [self whenBindPropagate:c priority:HIGHEST_PRIO];
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
- (void)whenChangePropagate:(id<CPConstraint>)c
{
   [self whenChangePropagate: c priority:HIGHEST_PRIO];
}
- (void)whenChangeDo:(ORClosure)todo onBehalf:(id<CPConstraint>)c
{
   [self whenChangeDo: todo priority: HIGHEST_PRIO onBehalf:c];
}
-(void) bindEvt:(id<CPRationalDomN>)sender
{
   id<CPClosureList> mList[3];
   ORUInt k = 0;
   mList[k] = _net._bindEvt;
   k += mList[k] != NULL;
   mList[k] = _net._boundsEvt;
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}
-(void) changeMinEvt:(ORBool) bound sender:(id<CPRationalDomN>)sender
{
   id<CPClosureList> mList[4];
   ORUInt k = 0;
   mList[k] = _net._minEvt;
   k += mList[k] != NULL;
   mList[k] = _net._boundsEvt;
   k += mList[k] != NULL;
   mList[k] = bound ? _net._bindEvt : NULL;
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}

-(void) changeMaxEvt:(ORBool) bound sender:(id<CPRationalDomN>)sender
{
   id<CPClosureList> mList[4];
   ORUInt k = 0;
   mList[k] = _net._maxEvt;
   k += mList[k] != NULL;
   mList[k] = _net._boundsEvt;
   k += mList[k] != NULL;
   mList[k] = bound ? _net._bindEvt : NULL;
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}
-(void) bind:(ORRational*) val
{
   [_dom bind:val for:self];
}
-(void) updateMin: (ORRational*) newMin
{
   if([newMin gt: [self min]])
      [_dom updateMin:newMin for:self];
}
-(void) updateMax: (ORRational*) newMax
{
   if([newMax lt: [self max]])
      [_dom updateMax:newMax for:self];
}
-(void) updateInterval: (ORRational*) newMin and:(ORRational*)newMax
{
   if([newMin gt: newMax])
      failNow();
   [self updateMin:newMin];
   [self updateMax:newMax];
}
- (void)updateMaxF:(ORDouble)newMaxError {
   ORRational* mError = [[ORRational alloc ] init];
   [mError set_d: newMaxError];
   [_dom updateMax:mError for:self];
   [mError release];
}
- (void)updateMinF:(ORDouble)newMinError {
   ORRational* mError = [[ORRational alloc ] init];
   [mError set_d: newMinError];
   [_dom updateMin:mError for:self];
   [mError release];
}
-(ORRational*) min
{
   return [_dom min];
}
-(ORRational*) max
{
   return [_dom max];
}
-(ORRational*) value
{
   if ([_dom bound])
      return [_dom min];
   return _value;
}
-(ORRational*) rationalValue
{
   if ([_dom bound])
      return [_dom min];
   return _value;
}
-(id<CPRationalDomN>) domain
{
   return _dom;
}
-(void) assignRelaxationValue: (ORRational*) f
{
   if ([f lt: [_dom min]] && [f gt: [_dom max]])
      @throw [[ORExecutionError alloc] initORExecutionError: "Assigning a relaxation value outside the bounds"];
   [_value set: f];
}
-(ORInterval) bounds
{
   return [_dom bounds];
}
-(ORBool) member:(ORRational*)v
{
   return [_dom member:v];
}
-(ORBool) bound
{
   return [_dom bound];
}
- (ORInt)domsize
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPFloatVar: method domsize  not defined"];
   return 0;
}
- (ORBool)sameDomain:(CPRationalVarI*)x
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPRationalVar: method sameDomain not defined"];
   //return [_dom isEqual:x->_dom];
}
- (void)subsumedBy:(id<CPRationalVar>)x
{
   [self updateInterval:[x min] and:[x max]];
}
- (void)subsumedByDomain:(id<CPRationalDomN>)dom
{
   [self updateInterval:[dom min] and:[dom max]];
}

- (void)visit:(ORVisitor *)visitor
{}

@end
