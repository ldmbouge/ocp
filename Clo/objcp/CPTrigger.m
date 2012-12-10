/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "CPTrigger.h"
#import "ORFoundation/ORAVLTree.h"
#import "CPEngineI.h"
#import "CPConstraintI.h"

@interface CPDenseTriggerMap : CPTriggerMap {
@private
   CPTrigger**   _tab;
   ORInt         _low;
   ORInt          _sz;
}
-(id) initDenseTriggerMap:(ORInt)low size:(ORInt)sz;
-(CPTrigger*)linkTrigger:(CPTrigger*)t forValue:(ORInt)value;
-(void) loseValEvt:(ORInt)val solver:(CPEngineI*)fdm;
@end

@interface CPSparseTriggerMap : CPTriggerMap {
@private
   ORAVLTree* _map;
}
-(id) initSparseTriggerMap;
-(CPTrigger*) linkTrigger:(CPTrigger*)t forValue:(ORInt)value;
-(void) loseValEvt:(ORInt)val solver:(CPEngineI*)fdm;
@end

void detachTrigger(CPTrigger* toMove)
{
   toMove->_next->_prev = toMove->_prev;
   toMove->_prev->_next = toMove->_next;
}

ORInt varOfTrigger(CPTrigger* toMove)
{
   return toMove->_vId;
}
void setTriggerOwner(CPTrigger* t,ORInt vID)
{
   t->_vId = vID;
}
ORInt getVarOfTrigger(CPTrigger* t)
{
   return t->_vId;
}

/*****************************************************************************************/
/*                        CPTriggerMap                                                   */
/*****************************************************************************************/

@implementation CPTriggerMap {
   @package
   bool     _active;
   CPTrigger* _bind;
}

static void freeTriggers(CPTrigger* list)
{
    while (list) {
        CPTrigger* nxt = list->_next;
        [list->_cb release];
        free(list);
        list = nxt;
    }
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

+(CPTrigger*) createTrigger: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
   CPTrigger* trig = malloc(sizeof(CPTrigger));
   trig->_cb = [todo copy];
   trig->_cstr = c;
   return trig;
}

+(CPTriggerMap*)triggerMapFrom:(ORInt)low to:(ORInt)up dense:(bool)dense
{
    if (dense) {
        CPTriggerMap* tMap = [[CPDenseTriggerMap  alloc] initDenseTriggerMap:low size:up-low+1];
        return tMap;
    } else {
        CPTriggerMap* tMap = [[CPSparseTriggerMap alloc] initSparseTriggerMap];
        return tMap;
    }
}
-(CPTrigger*) linkBindTrigger: (CPTrigger*) t
{
    if (_bind==NULL) {
        CPTrigger* front = malloc(sizeof(CPTrigger));
        CPTrigger* back  = malloc(sizeof(CPTrigger));
        memset(front,0,sizeof(CPTrigger));
        memset(back,0,sizeof(CPTrigger));
        _bind        = front;
        front->_next = back;
        back->_prev  = front;      
        _active = YES;
    }
    CPTrigger* front = _bind;
    t->_next = front->_next;
    t->_prev = front;
    front->_next = t;
    t->_next->_prev = t;
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
        CPTrigger* front = malloc(sizeof(CPTrigger));
        CPTrigger* back  = malloc(sizeof(CPTrigger));
        memset(front,0,sizeof(CPTrigger));
        memset(back,0,sizeof(CPTrigger));
        _tab[value] = front;
        front->_next = back;
        back->_prev  = front;
        _active = YES;
    }  
    CPTrigger* front = _tab[value];
    trig->_next = front->_next;
    trig->_prev = front;
    front->_next = trig;
    trig->_next->_prev = trig;
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
        CPTrigger* front = malloc(sizeof(CPTrigger));
        CPTrigger* back  = malloc(sizeof(CPTrigger));
        memset(front,0,sizeof(CPTrigger));
        memset(back,0,sizeof(CPTrigger));
        front->_next = back;
        back->_prev  = front;
        _active = YES;      
        at = [_map insertObject:[[CPTriggerList alloc] initTriggerList:front] 
                         forKey:value];
    }
    CPTrigger* trig = malloc(sizeof(CPTrigger));
    CPTriggerList* tList = [at element];
    CPTrigger* front = tList->_list;
    trig->_next = front->_next;
    trig->_prev = front;
    front->_next = trig;
    trig->_next->_prev = trig;
    return trig;
}
-(CPTrigger*)linkTrigger:(CPTrigger*)trig forValue:(ORInt)value
{
    ORAVLTreeNode* at = [_map findNodeForKey:value];
    if (at==nil) {
        CPTrigger* front = malloc(sizeof(CPTrigger));
        CPTrigger* back  = malloc(sizeof(CPTrigger));
        memset(front,0,sizeof(CPTrigger));
        memset(back,0,sizeof(CPTrigger));
        front->_next = back;
        back->_prev  = front;
        _active = YES;      
        at = [_map insertObject:[[CPTriggerList alloc] initTriggerList:front] 
                         forKey:value];
    }
    CPTriggerList* tList = [at element];
    CPTrigger* front = tList->_list;
    trig->_next = front->_next;
    trig->_prev = front;
    front->_next = trig;
    trig->_next->_prev = trig;
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
