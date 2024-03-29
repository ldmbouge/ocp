/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import  <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPClosureEvent.h>
#import <CPUKernel/CPTypes.h>
#import "CPEngineI.h"

typedef struct CPClosureEntry {
   ORClosure             cb;
   id<CPConstraint>    cstr;
} CPClosureEntry;


@implementation CPClosureQueue {
   CPClosureEntry*  _tab;
   CPClosureEntry*  _last;
   ORInt     _enter;
   ORInt     _exit;
   ORInt     _mask;   
}
-(id) initClosureQueue: (ORInt) sz
{
   self = [super init];
   _mxs = sz;
   _csz = 0;
   _mask = _mxs - 1;
   _tab = malloc(sizeof(CPClosureEntry)*_mxs);
   _last = _tab+_mxs-1;
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
   _last = _tab + _mxs - 1;
   _enter = _exit = 0;
   _csz = 0;
}
-(ORBool) loaded
{
   return _csz > 0;
}
-(void) resize
{
   long lx = _last - _tab;
   CPClosureEntry* nt = malloc(sizeof(CPClosureEntry)*_mxs*2);
   CPClosureEntry* ptr = nt;
   ORInt cur = _exit;
   do {
      *ptr++ = _tab[cur];
      cur = (cur+1) & _mask;
   }
   while (cur != _enter);
   free(_tab);
   _tab = nt;
   _last = nt + lx;
   _exit = 0;
   _enter = _mxs;
   _mxs <<= 1;
   _mask = _mxs - 1;
}
inline static void ClosureQueueReset(CPClosureQueue* q)
{
   q->_last = q->_tab+q->_mxs-1;
   q->_enter = q->_exit = 0;
   q->_csz = 0;
}
inline static void ClosureQueueEnqueue(CPClosureQueue* q,ORClosure cb,id<CPConstraint> cstr)
{
   if (q->_csz == q->_mxs)
      [q resize];
   if (q->_csz > 0 && q->_last->cb == cb && q->_last->cstr == cstr)
      return;
   q->_last  = q->_tab + q->_enter;
   *q->_last = (CPClosureEntry){cb,(CPCoreConstraint*)cstr};
   q->_enter = (q->_enter+1) & q->_mask;
   q->_csz += 1;
}
inline static CPClosureEntry ClosureQueueDequeue(CPClosureQueue* q)
{
   CPClosureEntry cb = q->_tab[q->_exit];
   q->_exit = (q->_exit+1) & q->_mask;
   --q->_csz;
   return cb;
}
-(void) enQueue:(ORClosure) cb cstr: (CPCoreConstraint*) cstr
{
   ClosureQueueEnqueue(self, cb,cstr);
}
-(void)deQueue:(ORClosure*)cb forCstr:(id<CPConstraint>*)cstr
{
   CPClosureEntry cbe = ClosureQueueDequeue(self);
   *cb = cbe.cb;
   *cstr = cbe.cstr;
}
@end

@implementation CPValueClosureQueue {
   id<CPValueEvent>* _tab;
   ORInt         _enter;
   ORInt          _exit;
   ORInt          _mask;
}
-(id) initValueClosureQueue:(ORInt)sz
{
   self = [super init];
   _mxs = sz; 
   _csz = 0;
   _mask = _mxs - 1;
   _tab = malloc(sizeof(id<CPValueEvent>)*_mxs);
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
-(ORBool)loaded
{
   return _csz > 0;
}
-(void)resize
{
   id<CPValueEvent>* nt = malloc(sizeof(id<CPValueEvent>)*_mxs*2);
   id<CPValueEvent>* ptr = nt;
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
inline static void ValueClosureQueueReset(CPValueClosureQueue* q)
{
   while (q->_csz) {
      [q->_tab[q->_exit] release];
      q->_exit = (q->_exit + 1) & q->_mask;
      --q->_csz;
   }
   q->_enter = q->_exit = 0;
   assert(q->_csz == 0);
}
inline static void ValueClosureQueueEnqueue(CPValueClosureQueue* q,id<CPValueEvent> cb)
{
   if (q->_csz == q->_mxs-1)
      [q resize];
   ORInt enter = q->_enter;
   q->_tab[enter]  = cb;
   q->_enter = (enter+1) & q->_mask;
   ++q->_csz;
}
inline static id<CPValueEvent> ValueClosureQueueDequeue(CPValueClosureQueue* q)
{
   if (q->_enter != q->_exit) {
      ORInt oe = q->_exit;
      q->_exit = (oe+1) & q->_mask;
      --q->_csz;
      return q->_tab[oe];
   } else return nil;
}

-(void) enQueue: (id<CPValueEvent>) cb
{
   ValueClosureQueueEnqueue(self, cb);
}
-(id<CPValueEvent>) deQueue
{
   return ValueClosureQueueDequeue(self);
}
@end

@interface CPModelI : NSObject<ORBasicModel> {
   CPEngineI* _engine;
   ORInt      _printing;
}
-(id)initCPModel:(CPEngineI*)e;
-(NSString*)description;
@end

@implementation CPModelI
-(id)initCPModel:(CPEngineI*)e
{
   self = [super init];
   _engine = e;
   _printing = 0;
   return self;
}
-(id<ORObjectiveFunction>) objective
{
   return [_engine objective];
}
-(id<ORIntVarArray>)intVars
{
   ORInt nbVars = (ORInt) [[_engine variables] count];
   id<ORIntVarArray> iva = (id<ORIntVarArray>)[ORFactory idArray:_engine range:RANGE(_engine,0,nbVars-1)];
   __block ORInt k = 0;
   [[_engine variables] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [iva set:obj at:k++];
   }];
   return iva;
}
-(NSArray*) variables
{
   return [_engine variables];
}
-(NSArray*) constraints
{
   return [_engine constraints];
}
-(NSArray*) mutables
{
   return [_engine objects];
}
-(NSArray*) immutables
{
   return nil; // [ldm] tofix
}

-(NSString*)description
{
   if (_printing) {
      return [NSString stringWithFormat:@"model(%p)",self];
   } else {
      _printing++;
      NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:512] autorelease];
      [buf appendFormat:@"vars[%ld] = {\n",[[_engine variables] count]];
      for(id<ORVar> v in [_engine variables])
         [buf appendFormat:@"\t%@\n",v];
      [buf appendFormat:@"}\n"];
      
      [buf appendFormat:@"objects[%ld] = {\n",[[_engine objects] count]];
      for(id<ORObject> v in [_engine objects]) {
         if (![v conformsToProtocol:@protocol(ORConstraint)])
         [buf appendFormat:@"\t%@\n",v];
      }
      [buf appendFormat:@"}\n"];
      
      [buf appendFormat:@"cstr[%ld] = {\n",[[_engine constraints] count]];
      for(id<ORConstraint> c in [_engine constraints])
         [buf appendFormat:@"\t%@\n",c];
      [buf appendFormat:@"}\n"];
      _printing--;
      return buf;
   }
}
@end

@implementation CPEngineI
-(CPEngineI*) initEngine: (id<ORTrail>) trail memory:(id<ORMemoryTrail>)mt
{
   self = [super init];
   _trail = trail;
   _mt    = mt;
   _state = CPOpen;
   _vars  = [[NSMutableArray alloc] init];
   _cStore = [[NSMutableArray alloc] initWithCapacity:32];
   _mStore = [[NSMutableArray alloc] initWithCapacity:32];
   _oStore = [[NSMutableArray alloc] initWithCapacity:32];
   _nbCstrs = 0;
   _objective = nil;
   for(ORInt i=0;i<NBPRIORITIES;i++)
      _closureQueue[i] = [[CPClosureQueue alloc] initClosureQueue:512];
   _valueClosureQueue = [[CPValueClosureQueue alloc] initValueClosureQueue:512];
   _propagating = 0;
   _nbpropag = 0;
   _nbFailures = 0;
   _propagIMP = (UBType)[self methodForSelector:@selector(propagate)];
   _propagFail = nil;
   _propagDone = nil;
   _br = RANGE(self, 0, 1);
   _iStat = makeTRInt(_trail,ORSuspend);
   return self;
}
-(id<ORIntRange>)boolRange
{
   return _br;
}
-(void) dealloc
{
   //NSLog(@"CPEngine [%p] dealloc called...\n",self);
   [_vars release];
   [_cStore release];
   [_mStore release];
   [_oStore release];
   [_objective release];
   [_valueClosureQueue release];
   [_propagFail release];
   [_propagDone release];
   for(ORInt i=0;i<NBPRIORITIES;i++)
      [_closureQueue[i] release];
   [super dealloc];
}
-(id<ORTracker>)tracker
{
   return self;
}
-(id<CPEngine>) solver
{
   return self;
}
-(ORBool)holdsVertical
{
   ORBool isVertical = NO;
   for(id<ORObject> obj in _oStore) {
      isVertical |= [obj vertical];
      if (isVertical)
         break;
   }
   return isVertical;
}
-(NSMutableArray*)variables
{
   return _vars;
}
-(NSMutableArray*)constraints
{
   return _cStore;
}
-(NSMutableArray*) objects
{
   return _oStore;
}
-(void) setLastFailure:(id<CPConstraint>)lastToFail
{
   _last = lastToFail;
   _nbFailures += 1;
}
-(void)incNbPropagation:(ORUInt)add
{
   _nbpropag += add;
}
-(void)incNbFailures:(ORUInt)add
{
   _nbFailures += add;
}
-(ORUInt) nbFailures
{
   return _nbFailures;
}
-(ORUInt) nbPropagation
{
   return _nbpropag;
}
-(ORUInt) nbVars
{
   return (ORUInt)[_vars count];
}
-(ORUInt) nbConstraints
{
   return (ORUInt)[_mStore count];
}
-(id) inCache:(id)obj
{
   return nil;
}
-(id) addToCache:(id)obj
{
   return obj;
}
-(id) trackVariable: (id) var
{
   [var setId:(ORUInt)[_vars count]];
   if (_state != CPClosed) {
      [_vars addObject:var];
      [var release];
   }
   else
      [[_mt track:var] release];
   return var;
}
-(id) trackObject:(id)obj
{
   if (_state != CPClosed) {
      [_oStore addObject:obj];
      [obj release];
   }
   else
      [[_mt track:obj] release];
   return obj;
}
-(id) trackConstraintInGroup:(id)obj
{
   return obj;
}
-(id) trackObjective:(id)obj
{
   if (_state != CPClosed) {
      [_oStore addObject:obj];
      [obj release];
   }
   else
      [[_mt track:obj] release];
   return obj;
}
-(id) trackMutable:(id)obj
{
   if (_state != CPClosed) {
      [_oStore addObject:obj];
      [obj release];
   }
   else
      [[_mt track:obj] release];
   return obj;
}
-(id) trackImmutable: (id) obj
{
   if (_state != CPClosed) {
      [_oStore addObject:obj];
      [obj release];
   }
   else
      [[_mt track:obj] release];
   return obj;
}

-(NSString*) description
{
   return [NSString stringWithFormat:@"Solver: %ld vars\n\t%ld constraints\n\t%d propagations\n",
      [_vars count],[_cStore count],_nbpropag];
}
-(id) trail
{
   return _trail;
}

-(void) scheduleTrigger: (ORClosure) cb onBehalf:(CPCoreConstraint*)c
{
   if (c->_active._val)
      	ClosureQueueEnqueue(_closureQueue[HIGHEST_PRIO], cb, c);
}

//static ORLong __active = 0;
//static ORLong __inactive = 0;
//
//void printStats()
//{
//   NSLog(@"A/I : %lld,%lld",__active,__inactive);
//}

void scheduleClosures(CPEngineI* fdm,id<CPClosureList>* mlist)
{
   while (*mlist) {
      CPClosureList* list = *mlist;
      while (list) {
         CPCoreConstraint* lc = list->_cstr;
         if (lc->_active._val) {
            //__active++;
            id<CPGroup> group = lc->_group;
            lc->_todo = CPTocheck;
            if (group) {
               [group toCheck];
               ClosureQueueEnqueue(fdm->_closureQueue[LOWEST_PRIO], nil, group);
               [group scheduleClosure:list];
            }
            else {
               ClosureQueueEnqueue(fdm->_closureQueue[list->_priority], list->_trigger,lc);
            }
//         } else {
//            __inactive++;
         }
         list = list->_node;
      }
      ++mlist;
   }
}

-(void) scheduleClosures: (id<CPClosureList>*) mlist
{
   scheduleClosures(self, mlist);
}

-(void) scheduleValueClosure: (id<CPValueEvent>)evt
{
   ValueClosureQueueEnqueue(_valueClosureQueue, evt);
}

static inline ORStatus executeClosure(CPClosureEntry cb,id<CPConstraint>* last)
{
    *last = cb.cstr;   // [pvh] This is for wdeg: need to know the last constraint that has failed
   CPCoreConstraint* cstr = cb.cstr;
   if (cstr->_active._val == 0)
      return ORSkip;
   if (cb.cb) {    // closure event
      cb.cb();
   } else {        // propagation event; closure not created explicitly for efficiency reasons
        if (cstr->_todo == CPChecked)
            return ORSkip;
        else {
            cstr->_todo = CPChecked;
            cstr->_propagate(cstr,@selector(propagate));
           //[cstr propagate];
        }
    }
    return ORSuspend;
}

ORStatus propagateFDM(CPEngineI* fdm)
{
   if (fdm->_propagating > 0)
      return ORDelay;
   if (fdm->_iStat._val == ORFailure)
      return ORFailure;
   ++fdm->_propagating;
   CPValueClosureQueue* vcQueue = fdm->_valueClosureQueue;
   CPClosureQueue** cQueue = fdm->_closureQueue;
   __block ORInt nbp = 0;
   TRYFAIL
      id<CPConstraint>* last = &fdm->_last;
      *last = nil;
      ORStatus status = ORSuspend;
      BOOL done = NO;
      while (!done) {
         
         while (ISLOADED(vcQueue)) {
            id<CPValueEvent> evt = ValueClosureQueueDequeue(vcQueue);
            nbp += [evt execute];
         }
         
         int p = HIGHEST_PRIO;
         while (p>=LOWEST_PRIO && !ISLOADED(cQueue[p]))
            --p;
         done = p < LOWEST_PRIO;
         while (!done) {
            status = executeClosure(ClosureQueueDequeue(cQueue[p]),last);
            nbp += status !=ORSkip;
            if (ISLOADED(vcQueue))
               break;
            p = HIGHEST_PRIO;
            while (p >= LOWEST_PRIO && !ISLOADED(cQueue[p]))
               --p;
            done = p < LOWEST_PRIO;
         }
      }
      while (ISLOADED(cQueue[ALWAYS_PRIO])) {
          ORStatus as = executeClosure(ClosureQueueDequeue(cQueue[ALWAYS_PRIO]), last);
          nbp += as != ORSkip;
      }
      if (fdm->_propagDone)
         [fdm->_propagDone notify];
      fdm->_nbpropag += nbp;
      --fdm->_propagating;
      assignTRInt(&fdm->_iStat, status, fdm->_trail);
   ONFAIL(status);
      id<CPConstraint>* last = &fdm->_last;
      while (ISLOADED(cQueue[ALWAYS_PRIO])) {
         ORStatus as = executeClosure(ClosureQueueDequeue(cQueue[ALWAYS_PRIO]), last);
         nbp += as != ORSkip;
         assert(as != ORFailure);
      }
      for(ORInt p=NBPRIORITIES-1;p>=0;--p)
         ClosureQueueReset(cQueue[p]);
      ValueClosureQueueReset(vcQueue);
      if (fdm->_propagFail)
         [fdm->_propagFail notifyWith:[*last getId]];
      //[exception release];
      fdm->_nbpropag += nbp;
      fdm->_nbFailures += 1;
      --fdm->_propagating;
      assignTRInt(&fdm->_iStat, ORFailure, fdm->_trail);
   ENDFAIL(ORFailure)
}
-(ORBool)isPropagating
{
   return _propagating > 0;
}
-(ORStatus) propagate
{
   return propagateFDM(self);
}

-(ORStatus) enforceObjective
{
   if (_objective == nil)
       return ORSuspend;
   return tryfail(^ORStatus{
      ORStatus ok = [_objective check];
      if (ok)
         ok = propagateFDM(self);
      return ok;
   }, ^ORStatus{
      assignTRInt(&_iStat, ORFailure, _trail);
      return ORFailure;
   });
}

-(void) tryEnforceObjective
{
    if (_objective != nil) {
        if ([_objective check] == ORFailure)
            failNow();
        propagateFDM(self);
    }
}

// [pvh] the post method on a constraint may throw a failure, so this must be catched.

-(ORStatus) post: (id<ORConstraint>) c
{
    return tryfail(^ORStatus{
      CPCoreConstraint* cstr = (CPCoreConstraint*) c;
      [cstr post];
      ORStatus pstatus =  propagateFDM(self);
      if (pstatus != ORFailure && cstr->_active._val != 0) {
         [_cStore addObject:c]; // only add when no failure
         const NSUInteger ofs = [_cStore count] - 1;
         [_trail trailClosure:^{
            [_cStore removeObjectAtIndex:ofs];
         }];
      }
      return pstatus;
   }, ^ORStatus{
      assignTRInt(&_iStat, ORFailure, _trail);
      return ORFailure;
   });
}

// LDM: addInternal must _raise_ a failure if the post returns a failure status.
// PVH: This is the case where a constraint adds another constraint

-(void) addInternal:(id<ORConstraint>) c
{
   assert(_state != CPOpen);
    if (getId(c) == -1)
        [c setId: _nbCstrs++];
   ORStatus s = [self post:c];
   if (s==ORFailure) {
      failNow();
   }
}

-(ORStatus) add: (id<ORConstraint>) c
{
   if (_state != CPOpen) {
      return [self post: c];
   }
   else {
      [c setId: _nbCstrs++];
      [_mStore addObject: c];
      return ORSuspend;
   }
}

-(void) assignIdToConstraint:(id<ORConstraint>)c
{
   [c setId: _nbCstrs++];
}

-(void) setObjective: (id<ORSearchObjectiveFunction>) obj
{
   [_objective release];
   _objective = [obj retain];
}

-(id<ORSearchObjectiveFunction>) objective
{
   return _objective;
}

-(ORStatus) enforce: (ORClosure) cl
{
   _last = NULL;
   TRYFAIL
      cl();
      ORStatus st = propagateFDM(self);
   ONFAIL(st);
   ENDFAIL(ORFailure);
}

-(void) tryEnforce: (ORClosure) cl
{
    _last = NULL;
    cl();
    propagateFDM(self);
}

-(ORStatus) atomic: (ORClosure) cl
{
   ORInt oldPropag = _propagating;
   return tryfail(^ORStatus{
      _propagating++;
      cl();
      _propagating--;
      return propagateFDM(self);
   }, ^ORStatus{
      _propagating = oldPropag;
      assignTRInt(&_iStat, ORFailure, _trail);
      return ORFailure;
   });
}

-(void) tryAtomic: (ORClosure) cl
{
    ORInt oldPropag = _propagating;
    ORStatus status = tryfail(^ORStatus{
        _propagating++;
        cl();
        _propagating--;
        return propagateFDM(self);
    }, ^ORStatus{
        _propagating = oldPropag;
        assignTRInt(&_iStat, ORFailure, _trail);
        return ORFailure;
    });
    if (status == ORFailure)
        failNow();
}
-(void) open
{
   _state = CPOpen;
}
-(ORStatus)currentStatus
{
   return _iStat._val;
}
-(ORStatus) close
{
    if (_state == CPOpen) {
        _state = CPClosing;
        _propagating++;
        for(id<ORConstraint> c in _mStore) {
            if ([self post: c] == ORFailure) {
                _propagating--;
                return ORFailure;
            }
        }
        _propagating--;
        if (propagateFDM(self) == ORFailure)
            return ORFailure;
        _state = CPClosed;
    }
    return ORSuspend;
}

// [PVH] this is for debugging purposes only
-(id<ORBasicModel>) model
{
   id<ORBasicModel> bm = [[CPModelI alloc] initCPModel:self];
   [self trackMutable:bm];
   return bm;
}

-(ORBool) closed
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
      _closureQueue[i] = [[[CPClosureQueue alloc] initClosureQueue:512] retain];
   _valueClosureQueue = [[[CPValueClosureQueue alloc] initValueClosureQueue:512] retain];
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
