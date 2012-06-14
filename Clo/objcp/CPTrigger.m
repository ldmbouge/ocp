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


#import "CPTrigger.h"
#import "CPAVLTree.h"
#import "CPSolverI.h"

/*****************************************************************************************/
/*                        CPTriggerMap                                                   */
/*****************************************************************************************/

@implementation CPTriggerMap

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

+(CPTriggerMap*)triggerMapFrom:(CPInt)low to:(CPInt)up dense:(bool)dense
{
    if (dense) {
        CPTriggerMap* tMap = [[CPDenseTriggerMap  alloc] initDenseTriggerMap:low size:up-low+1];
        return tMap;
    } else {
        CPTriggerMap* tMap = [[CPSparseTriggerMap alloc] initSparseTriggerMap];
        return tMap;
    }
}
-(void) linkBindTrigger: (CPTrigger*) t
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
}
-(void) bindEvt: (CPSolverI*) fdm
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

-(id)initDenseTriggerMap:(CPInt)low size:(CPInt)sz
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
    for(CPInt i=0;i<_sz;i++)
        freeTriggers(_tab[i]);
    free(_tab);
    [super dealloc];
}

-(void)linkTrigger:(CPTrigger*)trig forValue:(CPInt)value
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
}
-(void)loseValEvt:(CPInt)val solver:(CPSolverI*)fdm
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
    _map = [[CPAVLTree alloc] initEmptyAVL];
    return self;
}
-(void) dealloc
{
    [_map release];
    [super dealloc];
}
-(CPTrigger*) addTriggerFor: (CPInt) value
{
    CPAVLTreeNode* at = [_map findNodeForKey:value];
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
-(void)linkTrigger:(CPTrigger*)trig forValue:(CPInt)value
{
    CPAVLTreeNode* at = [_map findNodeForKey:value];
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
}
-(void) loseValEvt:(CPInt)val solver:(CPSolverI*)fdm
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
