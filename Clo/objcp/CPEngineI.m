/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPEngineI.h"
#import "CPIntVarI.h"
#import "CPBasicConstraint.h"
#import "CPTypes.h"
#import "ORFoundation/ORSetI.h"
#import "CPSolutionI.h"
#import "CPLinear.h"

#define AC5LOADED(q) ((q)->_csz)
#define ISLOADED(q)  ((q)->_csz)

/*****************************************************************************************/
/*                        VarEventNode                                                   */
/*****************************************************************************************/

@implementation VarEventNode
-(VarEventNode*)initVarEventNode:(VarEventNode*)next trigger:(id)t cstr:(CPCoreConstraint*)c at:(ORInt)prio
{
   self = [super init];
   _node = [next retain];
   _trigger = [t copy];
   _cstr = c;
   _priority = prio;
   return self;
}
-(void)dealloc
{
   //NSLog(@"VarEventNode::dealloc] %p\n",self);
   [_trigger release];
   [_node release];
   [super dealloc];
}
@end

typedef struct AC3Entry {
   ConstraintCallback   cb;
   CPCoreConstraint*    cstr;
} AC3Entry;

@interface CPAC3Queue : NSObject {
   @package
   ORInt      _mxs;
   ORInt      _csz;
   AC3Entry*  _tab;
   ORInt    _enter;
   ORInt     _exit;
   ORInt     _mask;
}
-(id)initAC3Queue:(ORInt)sz;
-(void)dealloc;
-(AC3Entry)deQueue;
-(void)enQueue:(ConstraintCallback)cb cstr:(CPCoreConstraint*)cstr;
-(void)reset;
-(bool)loaded;
@end



@implementation CPAC3Queue
-(id) initAC3Queue: (ORInt) sz
{
   self = [super init];
   _mxs = sz;
   _csz = 0;
   _mask = _mxs - 1;
   _tab = malloc(sizeof(AC3Entry)*_mxs);
   _enter = _exit = 0;
   return self;
}
-(void) dealloc
{
   free(_tab);
   [super dealloc];
}
-(void) reset
{
   _enter = _exit = 0;
   _csz = 0;
}
-(bool) loaded
{
   //ORInt nb = (_mxs + _enter - _exit)  & _mask;
   return _csz > 0;
}
-(void) resize
{
   AC3Entry* nt = malloc(sizeof(AC3Entry)*_mxs*2);
   AC3Entry* ptr = nt;
   ORInt cur = _exit;
   do {
      *ptr++ = _tab[cur];
      cur = (cur+1) & _mask;
   }
   while (cur != _enter);
   free(_tab);
   _tab = nt;
   _exit = 0;
   _enter = _mxs-1;
   _mxs <<= 1;
   _mask = _mxs - 1;
}
inline static void AC3reset(CPAC3Queue* q)
{
   q->_enter = q->_exit = 0;
   q->_csz = 0;
}
inline static void AC3enQueue(CPAC3Queue* q,ConstraintCallback cb,CPCoreConstraint* cstr)
{
   if (q->_csz == q->_mxs-1)
      [q resize];
   AC3Entry* last = q->_tab+ (q->_enter == 0 ? q->_mxs -1 : q->_enter - 1);
   if (q->_csz > 0 && last->cb == cb && last->cstr == cstr)
      return;
   q->_tab[q->_enter] = (AC3Entry){cb,cstr};
   q->_enter = (q->_enter+1) & q->_mask;
   ++q->_csz;
}
inline static AC3Entry AC3deQueue(CPAC3Queue* q)
{
   if (q->_enter != q->_exit) {
      AC3Entry cb = q->_tab[q->_exit];
      q->_exit = (q->_exit+1) & q->_mask;
      --q->_csz;
      return cb;
   }
   else
      return (AC3Entry){nil,nil};
}
-(void)enQueue:(ConstraintCallback)cb cstr:(CPCoreConstraint*)cstr
{
   AC3enQueue(self, cb,cstr);
}
-(AC3Entry)deQueue
{
   return AC3deQueue(self);
}
@end

// PVH: This may need to be generalized to cope with different types of events
typedef struct {
   VarEventNode* _list;
   ORInt        _value;
} AC5Event;


@interface CPAC5Queue : NSObject {
   @package
   ORInt      _mxs;
   ORInt      _csz;
   AC5Event*  _tab;
   ORInt    _enter;
   ORInt     _exit;
   ORInt     _mask;
}
-(id) initAC5Queue: (ORInt) sz;
-(void) dealloc;
-(AC5Event) deQueue;
-(void) enQueue: (VarEventNode*) cb with: (ORInt) val;
-(void) reset;
-(bool) loaded;
@end


@implementation CPAC5Queue
-(id) initAC5Queue:(ORInt)sz
{
   self = [super init];
   _mxs = sz;
   _csz = 0;
   _mask = _mxs - 1;
   _tab = malloc(sizeof(AC5Event)*_mxs);
   _enter = _exit = 0;
   return self;
}
-(void)dealloc
{
   free(_tab);
   [super dealloc];
}
-(void)reset
{
   _enter = _exit = 0;
   _csz = 0;
}
-(bool)loaded
{
   return _csz > 0;
}
-(void)resize
{
   AC5Event* nt = malloc(sizeof(AC5Event)*_mxs*2);
   AC5Event* ptr = nt;
   ORInt cur = _exit;
   do {
      *ptr++ = _tab[cur];
      cur = (cur+1) & _mask;
   } while (cur != _enter);
   free(_tab);
   _tab = nt;
   _exit = 0;
   _enter = _mxs-1;
   _mxs <<= 1;
   _mask = _mxs - 1;
}
inline static void AC5reset(CPAC5Queue* q)
{
   q->_enter = q->_exit = 0;
   q->_csz = 0;
}
inline static void enQueueAC5(CPAC5Queue* q,VarEventNode* cb,ORInt val)
{
   if (q->_csz == q->_mxs-1)
      [q resize];
   ORInt enter = q->_enter;
   q->_tab[enter]  = (AC5Event){cb,val};
   q->_enter = (enter+1) & q->_mask;
   ++q->_csz;
}
inline static AC5Event deQueueAC5(CPAC5Queue* q)
{
   if (q->_enter != q->_exit) {
      ORInt oe = q->_exit;
      q->_exit = (oe+1) & q->_mask;
      --q->_csz;
      return q->_tab[oe];
   } else return (AC5Event){0,0};
}

-(void)enQueue:(VarEventNode*)cb with:(ORInt)val
{
   enQueueAC5(self, cb, val);
}
-(AC5Event)deQueue
{
   return deQueueAC5(self);
}
@end

@implementation CPEngineI
-(CPEngineI*) initSolver: (id<ORTrail>) trail
{
   self = [super init];
   _trail = trail;
   _state = CPOpen;
   _vars  = [[NSMutableArray alloc] init];
   _cStore = [[NSMutableArray alloc] initWithCapacity:32];
   _mStore = [[NSMutableArray alloc] initWithCapacity:32];
   _oStore = [[NSMutableArray alloc] initWithCapacity:32];
   _objective = nil;
   for(ORInt i=0;i<NBPRIORITIES;i++)
      _ac3[i] = [[CPAC3Queue alloc] initAC3Queue:512];
   _ac5 = [[CPAC5Queue alloc] initAC5Queue:512];
   _status = makeTRInt(_trail,ORSuspend);
   _propagating = 0;
   _nbpropag = 0;
   _propagIMP = (UBType)[self methodForSelector:@selector(propagate)];
   _propagFail = nil;
   _propagDone = nil;
   return self;
}
-(void) dealloc
{
   //NSLog(@"CPEngine [%p] dealloc called...\n",self);
   [_vars release];
   [_cStore release];
   [_mStore release];
   [_oStore release];
   [_objective release];
   [_ac5 release];
   [_propagFail release];
   [_propagDone release];
   for(ORInt i=0;i<NBPRIORITIES;i++)
      [_ac3[i] release];
   [super dealloc];
}

-(id<CPEngine>) solver
{
   return self;
}
-(NSMutableArray*)allVars
{
   return _vars;
}
-(NSMutableArray*)allConstraints
{
   return _cStore;
}
-(NSMutableArray*)allModelConstraints
{
   return _mStore;
}
-(ORUInt) nbPropagation
{
   return _nbpropag;
}
-(ORUInt) nbVars
{
   return (ORUInt)[_vars count];
}

-(void) trackVariable: (id) var
{
   [var setId:(ORUInt)[_vars count]];
   if (_state != CPClosed) {
      [_vars addObject:var];
      [var release];
   } else
      [_trail trailRelease:var];
}

-(void) trackObject:(id)obj
{
   if (_state != CPClosed) {
      [_oStore addObject:obj];
      [obj release];
   } else
      [_trail trailRelease:obj];
}

-(NSString*) description
{
   return [NSString stringWithFormat:@"Solver: %ld vars\n\t%d propagations\n",[_vars count],_nbpropag];
}
-(id) trail
{
   return _trail;
}

-(void) scheduleTrigger:(ConstraintCallback)cb onBehalf:(CPCoreConstraint*)c
{
   AC3enQueue(_ac3[HIGHEST_PRIO], cb, c);
}

-(void) scheduleAC3: (VarEventNode**) mlist
{
   while (*mlist) {
      VarEventNode* list = *mlist;
      while (list) {
         assert(list->_cstr);
         list->_cstr->_todo = CPTocheck;
         AC3enQueue(_ac3[list->_priority], list->_trigger,list->_cstr);
         list = list->_node;
      }
      ++mlist;
   }
}

// PVH: there is a discrepancy between the AC3 and AC5 queues. AC5 uses varEventNode; AC3 works with the trigger directly

-(void) scheduleAC5: (VarEventNode*) list  with: (ORInt) val
{
   enQueueAC5(_ac5, list, val);
}

// PVH: This does the case analysis on the key of events {trigger,cstr} and handle the idempotence

static inline ORStatus executeAC3(AC3Entry cb,CPCoreConstraint** last)
{
   *last = cb.cstr;
   if (cb.cb)
      cb.cb();
   else {
      CPCoreConstraint* cstr = cb.cstr;
      if (cstr->_todo == CPChecked)
         return ORSkip;
      else {
         cstr->_todo = cstr->_idempotent == NO ? CPChecked : cstr->_todo;
         //[cstr propagate];
         cstr->_propagate(cstr,@selector(propagate));
         cstr->_todo = cstr->_idempotent == YES ? CPChecked : cstr->_todo;
      }
   }
   return ORSuspend;
}

-(ORStatus) propagate
{
   if (_propagating > 0)
      return ORDelay;
   _last = nil;
   ++_propagating;
   ORStatus status = ORSuspend;
   bool done = false;
   @try {
      while (!done) {
         // AC5 manipulates the list
         while (AC5LOADED(_ac5)) {
            AC5Event evt = deQueueAC5(_ac5);
            VarEventNode* list = evt._list;
            while (list) {
               // PVH: this may need to be generalized for more general events
               ((ConstraintIntCallBack)(list->_trigger))(evt._value);
               ++_nbpropag;
               list = list->_node;
            }
         }
         // Processing AC3
         int p = HIGHEST_PRIO;
         while (p>=LOWEST_PRIO && !ISLOADED(_ac3[p]))
            --p;
         done = p < LOWEST_PRIO;
         while (!done) {
            status = executeAC3(AC3deQueue(_ac3[p]),&_last);
            _nbpropag += status !=ORSkip;
            if (AC5LOADED(_ac5))
               break;
            p = HIGHEST_PRIO;
            while (p >= LOWEST_PRIO && !ISLOADED(_ac3[p]))
               --p;
            done = p < LOWEST_PRIO;
         }
      }
      if (_propagDone)
         [_propagDone notify];
      //_status = status;
      assignTRInt(&_status, status, _trail);
      --_propagating;
      return _status._val;
   }
   @catch (ORFailException *exception) {
      for(ORInt p=NBPRIORITIES-1;p>=0;--p)
         AC3reset(_ac3[p]);
      AC5reset(_ac5);
      if (_propagFail)
         [_propagFail notifyWith:[_last getId]];
      CFRelease(exception);
      assignTRInt(&_status, ORFailure, _trail);
      --_propagating;
      return _status._val;
   }
}

static inline ORStatus internalPropagate(CPEngineI* fdm,ORStatus status)
{
   switch (status) {
      case ORFailure:
         for(ORInt p=HIGHEST_PRIO;p>=LOWEST_PRIO;--p)
            AC3reset(fdm->_ac3[p]);
         break;
      case ORSuccess:
      case ORSuspend:
         //status = [fdm propagate];
         status = fdm->_propagIMP(fdm,@selector(propagate));
         break;
      case ORDelay:
         break;
      default:
         break;
   }
   return status;
}

-(ORStatus)enforceObjective
{
   if (_objective != nil) {
      return [_objective check];
   }
   else
      return ORSuspend;
}

-(ORStatus) post: (id<ORConstraint>) c
{
   @try {
      CPCoreConstraint* cstr = (CPCoreConstraint*) c;
      ORStatus status = [cstr post];
      ORStatus pstatus = internalPropagate(self,status);
      assignTRInt(&_status, pstatus, _trail);
      if (pstatus && status != ORSkip) {
         [cstr setId:(ORUInt)[_cStore count]];
         [_cStore addObject:c]; // only add when no failure
         const NSUInteger ofs = [_cStore count] - 1;
         [_trail trailClosure:^{
            [_cStore removeObjectAtIndex:ofs];
         }];
      }
   } @catch (ORFailException* ex) {
      CFRelease(ex);
      assignTRInt(&_status, ORFailure, _trail);
   }
   return _status._val;
}
-(id<ORConstraint>) wrapExpr: (id<ORSolver>) solver for: (id<ORRelation>) e  consistency:(CPConsistency)cons
{
   CPExprConstraintI* wrapper = [[CPExprConstraintI alloc] initCPExprConstraintI: solver expr:e consistency:cons];
   [self trackObject:wrapper];
   return wrapper;
}

-(ORStatus) add: (id<ORConstraint>) c
{
   if (_state != CPOpen) {
      return [self post: c];
   }
   else {
      CPCoreConstraint* cstr = (CPCoreConstraint*) c;
      [cstr setId:(ORUInt)[_mStore count]];
      [_mStore addObject:c];
      return ORSuspend;
   }
}

-(void) setObjective: (id<ORObjective>) obj
{
   [_objective release];
   _objective = [obj retain];
}

-(ORStatus) label: (id) var with: (ORInt) val
{
   @try {
      assert(_status._val != ORFailure);
      ORStatus status = [var bind: val];
      ORStatus pstatus = internalPropagate(self,status);
      assignTRInt(&_status, pstatus, _trail);
   } @catch (ORFailException *exception) {
      CFRelease(exception);
      assignTRInt(&_status, ORFailure, _trail);
   }
   return _status._val;
}

-(ORStatus) diff: (CPIntVarI*) var with: (ORInt) val
{
   @try {
      assert(_status._val != ORFailure);
      ORStatus status =  removeDom(var, val);
      ORStatus pstatus = internalPropagate(self,status);
      assignTRInt(&_status, pstatus, _trail);
   } @catch (ORFailException *exception) {
      CFRelease(exception);
      assignTRInt(&_status, ORFailure, _trail);
   }
   return _status._val;
}
-(ORStatus)  lthen:(id)var with:(ORInt)val
{
   @try {
      ORStatus status = [var updateMax:val-1];
      ORStatus pstatus = internalPropagate(self,status);
      assignTRInt(&_status, pstatus, _trail);
   } @catch (ORFailException *exception) {
      CFRelease(exception);
      assignTRInt(&_status, ORFailure, _trail);
   }
   return _status._val;
}
-(ORStatus)  gthen:(id)var with:(ORInt)val
{
   @try {
      ORStatus status = [var updateMin:val+1];
      ORStatus pstatus = internalPropagate(self,status);
      assignTRInt(&_status, pstatus, _trail);
   } @catch (ORFailException *exception) {
      CFRelease(exception);
      assignTRInt(&_status, ORFailure, _trail);
   }
   return _status._val;
}
-(ORStatus) restrict: (CPIntVarI*) var to: (ORIntSetI*) S
{
   @try {
      ORStatus status = [var inside: S];
      ORStatus pstatus = internalPropagate(self,status);
      assignTRInt(&_status, pstatus, _trail);
   } @catch (ORFailException *exception) {
      CFRelease(exception);
      assignTRInt(&_status, ORFailure, _trail);
   }
   return _status._val;
}
-(void) saveSolution
{
   [_aSol release];
   _aSol = [[CPSolutionI alloc] initCPSolution:self];
}

-(void) restoreSolution
{
   [_aSol restoreInto:self];
}
-(id<ORSolution>) solution
{
   return _aSol;
}
-(ORStatus) close
{
   if (_state == CPOpen) {
      _state = CPClosing;
      for(id<ORConstraint> c in _mStore) {
         [self post:c];
         if (_status._val == ORFailure)
            return ORFailure;
      }
      _state = CPClosed;
   }
   //printf("Closing CPEngine\n");
   return ORSuspend;
}
-(ORStatus)  status
{
   return _status._val;
}
-(bool) closed
{
   return _state == CPClosed;
}
-(id<ORInformer>) propagateFail
{
   if (_propagFail == nil)
      _propagFail = [ORConcurrency  intInformer];
   return _propagFail;
}
-(id<ORInformer>) propagateDone
{
   if (_propagDone == nil)
      _propagDone = [ORConcurrency  voidInformer];
   return _propagDone;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_state];
   [aCoder encodeObject:_vars];
   [aCoder encodeObject:_trail];
   [aCoder encodeObject:_mStore];
   [aCoder encodeObject:_oStore];
}
- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super init];
   _cStore = [[NSMutableArray alloc] initWithCapacity:32];
   _mStore = [[NSMutableArray alloc] initWithCapacity:32];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_state];
   _vars = [[aDecoder decodeObject] retain];
   _trail = [[aDecoder decodeObject] retain];
   NSMutableArray* originalStore = [aDecoder decodeObject];
   _oStore = [[aDecoder decodeObject] retain];
   for(ORInt i=0;i<NBPRIORITIES;i++)
      _ac3[i] = [[[CPAC3Queue alloc] initAC3Queue:512] retain];
   _ac5 = [[[CPAC5Queue alloc] initAC5Queue:512] retain];
   _status = makeTRInt(_trail,ORSuspend);
   _propagating = 0;
   _nbpropag = 0;
   _propagIMP = (UBType)[self methodForSelector:@selector(propagate)];
   for(id<ORConstraint> c in originalStore) {
      // The retain is necessary given that the post will release it after storing in cStore.
      [self add:[c retain]];
   }
   return self;
}
@end
