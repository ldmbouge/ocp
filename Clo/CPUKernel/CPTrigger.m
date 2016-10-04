/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "CPTrigger.h"
#import <ORFoundation/ORAVLTree.h>
#import "CPEngineI.h"
#import "CPConstraintI.h"


@interface CPDenseTriggerMap : CPTriggerMap {
@private
   CPTrigger**   _tab;
   ORInt         _low;
   ORInt          _sz;
}
-(id) initDenseTriggerMap: (ORInt)low size: (ORInt) sz;
-(CPTrigger*) linkTrigger: (CPTrigger*) t forValue: (ORInt)value;
-(void) loseValEvt: (ORInt) val solver: (CPEngineI*) fdm;
@end

@interface CPSparseTriggerMap : CPTriggerMap {
@private
   ORAVLTree* _map;
}
-(id) initSparseTriggerMap;
-(CPTrigger*) linkTrigger: (CPTrigger*) t forValue: (ORInt) value;
-(void) loseValEvt: (ORInt) val solver: (CPEngineI*) fdm;
@end

@implementation CPTrigger
-(id) init
{
   self = [super init];
   _cb = nil;
   _vId = -1;
   _cstr = nil;
   _prev = _next = nil;
   return self;
}
-(id) initTrigger:(ORClosure)cb onBehalf:(id<CPConstraint>) c
{
   self = [super init];
   _cb = [cb copy];
   _cstr = c;
   _vId = -1;
   _prev = _next = nil;
   return self;
}
-(void) dealloc
{
   [_cb release];
   [super dealloc];
}
-(void) detach
{
   _next->_prev = _prev;
   _prev->_next = _next;
}
-(ORInt) localID
{
   return _vId;
}
-(void) setLocalID: (ORInt) lid
{
   _vId = lid;
}
-(void) setNext: (CPTrigger*) new
{
   if (_next)
      _next->_prev = new;
   new->_next = _next;
   _next = new;
   new->_prev = self;
}
static void triggerSetNext(CPTrigger* x,CPTrigger* new)
{
   if (x->_next)
      x->_next->_prev = new;
   new->_next = x->_next;
   x->_next = new;
   new->_prev = x;
}
static void freeTriggers(CPTrigger* list)
{
   while (list) {
      CPTrigger* nxt = list->_next;
      [list release];
      list = nxt;
   }
}
@end

/*****************************************************************************************/
/*                        CPTriggerMap                                                   */
/*****************************************************************************************/

@implementation CPTriggerMap {
   @package
   bool     _active;
   CPTrigger* _bind;
}

-(CPTriggerMap*) init
{
    self = [super init];
    _active = NO;
    _bind = NULL;
    return self;
}

-(void )dealloc
{
    freeTriggers(_bind);
    [super dealloc];
}

+(CPTrigger*) createTrigger: (ORClosure) todo onBehalf:(id<CPConstraint>)c
{
   return [[CPTrigger alloc] initTrigger:todo onBehalf:c];
}

+(CPTriggerMap*)triggerMapFrom:(ORInt)low to:(ORInt)up dense:(ORBool)dense
{
    if (dense) {
        CPTriggerMap* tMap = [[CPDenseTriggerMap  alloc] initDenseTriggerMap:low size:up-low+1];
        return tMap;
    } else {
        CPTriggerMap* tMap = [[CPSparseTriggerMap alloc] initSparseTriggerMap];
        return tMap;
    }
}
-(id<CPTrigger>) linkTrigger:(id<CPTrigger>)trig forValue:(ORInt)value
{
   assert(NO);
   return 0;
}
-(CPTrigger*) linkBindTrigger: (CPTrigger*) t
{
   if (_bind==NULL) {
      CPTrigger* front = [[CPTrigger alloc] init];
      CPTrigger* back  = [[CPTrigger alloc] init];
      [front setNext:back];
      _bind        = front;
      _active = YES;
   }
   [_bind setNext:t];
   return t;
}
-(void) bindEvt: (CPEngineI*) fdm
{
    if (_bind) {
        CPTrigger* front = _bind->_next;
        while (front->_next) {
            [fdm scheduleTrigger:front->_cb onBehalf:front->_cstr];
            front = front->_next;         
        }      
    }
}
@end

@implementation CPDenseTriggerMap
-(id)initDenseTriggerMap:(ORInt)low size:(ORInt)sz
{
    self = [super init];
    _sz  = sz;
    _low = low;
    _tab = malloc(sizeof(CPTrigger*)*_sz);
    memset(_tab,0, sizeof(CPTrigger*)*_sz);
    _tab -= _low;
    return self;
}
-(void)dealloc 
{
    _tab += _low;
    for(ORInt i=0;i<_sz;i++)
        freeTriggers(_tab[i]);
    free(_tab);
    [super dealloc];
}

-(CPTrigger*)linkTrigger:(CPTrigger*)trig forValue:(ORInt)value
{
   if (_tab[value] == 0) {
      CPTrigger* front = [[CPTrigger alloc] init];
      CPTrigger* back  = [[CPTrigger alloc] init];
      _tab[value] = front;
      triggerSetNext(front,back);
      _active = YES;
   }
   triggerSetNext(_tab[value],trig);
   return trig;
}
-(void)loseValEvt:(ORInt)val solver:(CPEngineI*)fdm
{
    if (_tab[val]) {
        CPTrigger* front = _tab[val]->_next;
        while (front->_next) {
            [fdm scheduleTrigger:front->_cb onBehalf:front->_cstr];
            front = front->_next;         
        }
    }
}
@end

@interface CPTriggerList : NSObject {
    @package
    CPTrigger* _list;
}
-(CPTriggerList*) initTriggerList:(CPTrigger*)t;
@end

@implementation CPTriggerList
-(CPTriggerList*) initTriggerList:(CPTrigger*)t
{
    self = [super init];
    _list = t;
    return self;
}
-(void) dealloc 
{
    freeTriggers(_list);
    [super dealloc];
}
@end

@implementation CPSparseTriggerMap
-(id) initSparseTriggerMap
{
    self = [super init];
    _map = [[ORAVLTree alloc] initEmptyAVL];
    return self;
}
-(void) dealloc
{
    [_map release];
    [super dealloc];
}
-(CPTrigger*) addTriggerFor: (ORInt) value
{
   ORAVLTreeNode* at = [_map findNodeForKey:value];
   if (at==nil) {
      CPTrigger* front = [[CPTrigger alloc] init];
      CPTrigger* back  = [[CPTrigger alloc] init];
      [front setNext:back];
      _active = YES;
      at = [_map insertObject:[[CPTriggerList alloc] initTriggerList:front]
                       forKey:value];
   }
   CPTrigger* trig = [[CPTrigger alloc] init];
   CPTriggerList* tList = [at element];
   [tList->_list setNext:trig];
   return trig;
}
-(CPTrigger*)linkTrigger:(CPTrigger*)trig forValue:(ORInt)value
{
   ORAVLTreeNode* at = [_map findNodeForKey:value];
   if (at==nil) {
      CPTrigger* front = [[CPTrigger alloc] init];
      CPTrigger* back  = [[CPTrigger alloc] init];
      [front setNext:back];
      _active = YES;
      at = [_map insertObject:[[CPTriggerList alloc] initTriggerList:front]
                       forKey:value];
   }
   CPTriggerList* tList = [at element];
   [tList->_list setNext:trig];
   return trig;
}
-(void) loseValEvt:(ORInt)val solver:(CPEngineI*)fdm
{
    CPTriggerList* tList = [_map findObjectForKey:val];
    if (tList) {
        CPTrigger* front = tList->_list->_next;
        while (front->_next) {
            [fdm scheduleTrigger:front->_cb onBehalf:front->_cstr];
            front = front->_next;         
        }
    }
}
@end
