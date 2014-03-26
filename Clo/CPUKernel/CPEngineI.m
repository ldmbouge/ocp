/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPEngineI.h"
#import "CPTypes.h"
#import "CPAC3Event.h"
#import <ORFoundation/ORSetI.h>

@implementation CPAC3Queue
-(id) initAC3Queue: (ORInt) sz
{
   self = [super init];
   _mxs = sz;
   _csz = 0;
   _mask = _mxs - 1;
   _tab = malloc(sizeof(AC3Entry)*_mxs);
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
   _last = nt + lx;
   _exit = 0;
   _enter = _mxs;
   _mxs <<= 1;
   _mask = _mxs - 1;
}
inline static void AC3reset(CPAC3Queue* q)
{
   q->_last = q->_tab+q->_mxs-1;
   q->_enter = q->_exit = 0;
   q->_csz = 0;
}
inline static void AC3enQueue(CPAC3Queue* q,ConstraintCallback cb,id<CPConstraint> cstr)
{
   if (q->_csz == q->_mxs)
      [q resize];
   if (q->_csz > 0 && q->_last->cb == cb && q->_last->cstr == cstr)
      return;
   q->_last  = q->_tab + q->_enter;
   *q->_last = (AC3Entry){cb,(CPCoreConstraint*)cstr};
   q->_enter = (q->_enter+1) & q->_mask;
   q->_csz += 1;
}
inline static AC3Entry AC3deQueue(CPAC3Queue* q)
{
   AC3Entry cb = q->_tab[q->_exit];
   q->_exit = (q->_exit+1) & q->_mask;
   --q->_csz;
   return cb;
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

@implementation CPAC5Queue
-(id) initAC5Queue:(ORInt)sz
{
   self = [super init];
   _mxs = sz; 
   _csz = 0;
   _mask = _mxs - 1;
   _tab = malloc(sizeof(id<CPAC5Event>)*_mxs);
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
   id<CPAC5Event>* nt = malloc(sizeof(id<CPAC5Event>)*_mxs*2);
   id<CPAC5Event>* ptr = nt;
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
   while (q->_csz) {
      [q->_tab[q->_exit] release];
      q->_exit = (q->_exit + 1) & q->_mask;
      --q->_csz;
   }
   q->_enter = q->_exit = 0;
   assert(q->_csz == 0);
}
inline static void enQueueAC5(CPAC5Queue* q,id<CPAC5Event> cb)
{
   if (q->_csz == q->_mxs-1)
      [q resize];
   ORInt enter = q->_enter;
   q->_tab[enter]  = cb;
   q->_enter = (enter+1) & q->_mask;
   ++q->_csz;
}
inline static id<CPAC5Event> deQueueAC5(CPAC5Queue* q)
{
   if (q->_enter != q->_exit) {
      ORInt oe = q->_exit;
      q->_exit = (oe+1) & q->_mask;
      --q->_csz;
      return q->_tab[oe];
   } else return nil;
}

-(void)enQueue:(id<CPAC5Event>)cb
{
   enQueueAC5(self, cb);
}
-(id<CPAC5Event>)deQueue
{
   return deQueueAC5(self);
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
   _objective = nil;
   for(ORInt i=0;i<NBPRIORITIES;i++)
      _ac3[i] = [[CPAC3Queue alloc] initAC3Queue:512];
   _ac5 = [[CPAC5Queue alloc] initAC5Queue:512];
   _status = ORSuspend;
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
-(id<ORTracker>)tracker
{
   return self;
}
-(id<CPEngine>) solver
{
   return self;
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
}
-(void)incNbPropagation:(ORUInt)add
{
   _nbpropag += add;
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

-(void) scheduleTrigger:(ConstraintCallback)cb onBehalf:(id<CPConstraint>)c
{
   AC3enQueue(_ac3[HIGHEST_PRIO], cb, c);
}

void scheduleAC3(CPEngineI* fdm,id<CPEventNode>* mlist)
{
   while (*mlist) {
      CPEventNode* list = *mlist;
      while (list) {
         CPCoreConstraint* lc = list->_cstr;
         if (lc->_active._val) {
            id<CPGroup> group = lc->_group;
            if (group) {
               lc->_todo = CPTocheck;
               AC3enQueue(fdm->_ac3[LOWEST_PRIO], nil, group);
               [group scheduleAC3:list];
            } else
               lc->_todo = CPTocheck;
               AC3enQueue(fdm->_ac3[list->_priority], list->_trigger,lc);
            // [ldm] not completely clear why. But the conditional enQueueing below breaks
            // the behavior w.r.t. idempotence.
            // Temporarily back to the original code until I figure this one out.
            // Benchmark affected: sport
            // Actually, if a constraint is tagged idemponent, the second disjunct is false and
            // therefore we _might_ try to save scheduling the currently running propagator.
            // This looks sounds to me, but the allDiffDC does _not_ check whether there was a change
            // it seems to do a single pass. over the variable set. Which  should be ok without views
            // but certainly wrong with views.  In sport, this _reduces_ the number of choices, but that
            // maybe an artifact of the different search caused by a _weaker_ fixpoint (not really reaching a glb).
            // For now, I'll keep this commented out. It only makes sense for idempotent propagators anyway and
            // would disappear if we get rid of idempotence. 
//               if (fdm->_last != lc || !lc->_idempotent) {
//                  lc->_todo = CPTocheck;
//                  AC3enQueue(fdm->_ac3[list->_priority], list->_trigger,lc);
//               }
               //else NSLog(@"Not scheduling the currently running idempotent constraint");
         }
         list = list->_node._val;
      }
      ++mlist;
   }
}

-(void) scheduleAC3: (id<CPEventNode>*) mlist
{
   scheduleAC3(self, mlist);
}

// PVH: there is a discrepancy between the AC3 and AC5 queues. AC5 uses CPEventNode; AC3 works with the trigger directly

-(void) scheduleAC5: (id<CPAC5Event>)evt
{
   enQueueAC5(_ac5, evt);
}

// PVH: This does the case analysis on the key of events {trigger,cstr} and handle the idempotence

static inline ORStatus executeAC3(AC3Entry cb,id<CPConstraint>* last)
{
   *last = cb.cstr;

//   static int cnt = 0;
//   @autoreleasepool {
//      NSString* cn = NSStringFromClass([*last class]);
//      NSLog(@"%d : propagate: %p : CN=%@",cnt++,*last,cn);
//   }

   if (cb.cb)
      cb.cb();
   else {
      CPCoreConstraint* cstr = cb.cstr;
      if (cstr->_todo == CPChecked)
         return ORSkip;
      else {
         if (cstr->_idempotent) {
            cstr->_propagate(cstr,@selector(propagate));
            cstr->_todo = CPChecked;
         } else {
            cstr->_todo = CPChecked;
            cstr->_propagate(cstr,@selector(propagate));
         }
      }
   }
   return ORSuspend;
}

ORStatus propagateFDM(CPEngineI* fdm)
{
   if (fdm->_propagating > 0)
      return ORDelay;
   ++fdm->_propagating;
   fdm->_status = ORSuspend;
   CPAC5Queue* ac5 = fdm->_ac5;
   CPAC3Queue** ac3 = fdm->_ac3;
   __block ORInt nbp = 0;
   return tryfail(^ORStatus{
      id<CPConstraint>* last = &fdm->_last;
      *last = nil;
      ORStatus status = ORSuspend;
      BOOL done = NO;
      while (!done) {
         // AC5 manipulates the list
         while (AC5LOADED(ac5)) {
            id<CPAC5Event> evt = deQueueAC5(ac5);
            nbp += [evt execute];
         }
         // Processing AC3
         int p = HIGHEST_PRIO;
         while (p>=LOWEST_PRIO && !ISLOADED(ac3[p]))
            --p;
         done = p < LOWEST_PRIO;
         while (!done) {
            status = executeAC3(AC3deQueue(ac3[p]),last);
            nbp += status !=ORSkip;
            if (AC5LOADED(ac5))
               break;
            p = HIGHEST_PRIO;
            while (p >= LOWEST_PRIO && !ISLOADED(ac3[p]))
               --p;
            done = p < LOWEST_PRIO;
         }
      }
      while (ISLOADED(ac3[ALWAYS_PRIO])) {
         // PVH: Failure to remove?
         ORStatus as = executeAC3(AC3deQueue(ac3[ALWAYS_PRIO]), last);
         nbp += as != ORSkip;
         // PVH: what is this stuff // [ldm] we are never supposed to return "failure", but call failNow() instead.
         assert(as != ORFailure);
      }
      if (fdm->_propagDone)
         [fdm->_propagDone notify];
      // PVH: This seems buggy or useless; is status still useful
      fdm->_status = status;
      fdm->_nbpropag += nbp;
      --fdm->_propagating;
      return status;
   }, ^ORStatus{
      id<CPConstraint>* last = &fdm->_last;
      while (ISLOADED(ac3[ALWAYS_PRIO])) {
         ORStatus as = executeAC3(AC3deQueue(ac3[ALWAYS_PRIO]), last);
         nbp += as != ORSkip;
         assert(as != ORFailure);
      }
      for(ORInt p=NBPRIORITIES-1;p>=0;--p)
         AC3reset(ac3[p]);
      AC5reset(ac5);
      if (fdm->_propagFail)
         [fdm->_propagFail notifyWith:[*last getId]];
      //[exception release];
      fdm->_status = ORFailure;
      fdm->_nbpropag += nbp;
      --fdm->_propagating;
      return ORFailure;
   });
}

-(ORStatus) propagate
{
   return propagateFDM(self);
}

static inline ORStatus internalPropagate(CPEngineI* fdm,ORStatus status)
{
   if (status == ORSuspend || status == ORSuccess || status == ORSkip)
      return propagateFDM(fdm);// fdm->_propagIMP(fdm,@selector(propagate));
   else if (status== ORFailure) {
      for(ORInt p=HIGHEST_PRIO;p>=LOWEST_PRIO;--p)
         AC3reset(fdm->_ac3[p]);
      return ORFailure;
   }
   else
      return status;
}

-(ORStatus) enforceObjective
{
   if (_objective == nil) return ORSuspend;
   _status = tryfail(^ORStatus{
      _status = ORSuspend;
      // PVH: Failure to remove?
      ORStatus ok = [_objective check];
      if (ok)
         ok = propagateFDM(self);// [self propagate];
      return ok;
   }, ^ORStatus{
      return ORFailure;
   });
   return _status;
}

-(ORStatus) post: (id<ORConstraint>) c
{
   _status = tryfail(^ORStatus{
      CPCoreConstraint* cstr = (CPCoreConstraint*) c;
      ORStatus status = [cstr post];
      ORStatus pstatus = internalPropagate(self,status);
      if (pstatus != ORFailure && status != ORSkip) {
         [_cStore addObject:c]; // only add when no failure
         const NSUInteger ofs = [_cStore count] - 1;
         [_trail trailClosure:^{
            [_cStore removeObjectAtIndex:ofs];
         }];
      }
      return ORSuspend;
   }, ^ORStatus{
      return ORFailure;
   });
   return _status;
}

// PVH: Failure to remove?
-(ORStatus) addInternal:(id<ORConstraint>) c
{
   assert(_state != CPOpen);
   ORStatus s = [self post:c];
   if (s==ORFailure)
      failNow();
   return s;
}

-(ORStatus) add: (id<ORConstraint>) c
{
   if (_state != CPOpen) {
      return [self post: c];
   }
   else {
      CPCoreConstraint* cstr = (CPCoreConstraint*) c;
      [cstr setId: (ORUInt)[_mStore count]];
      [_mStore addObject: c];
      return ORSuspend;
   }
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
   _status = tryfail(^ORStatus{
      cl();
      return internalPropagate(self,ORSuspend);
   }, ^ORStatus{
      return ORFailure;
   });
   return _status;
}
-(ORStatus) atomic: (ORClosure) cl
{
   ORInt oldPropag = _propagating;
   _status = tryfail(^ORStatus{
      _propagating++;
      cl();
      _propagating--;
      return internalPropagate(self,ORSuspend);
   }, ^ORStatus{
      _propagating = oldPropag;
      return ORFailure;
   });
   return _status;
}

-(ORStatus) close
{
   if (_state == CPOpen) {
      _state = CPClosing;
      _propagating++;
      for(id<ORConstraint> c in _mStore) {
         [self post:c];
         if (_status == ORFailure)
            return ORFailure;
      }
      _propagating--;
      _status = internalPropagate(self, ORSuspend);
      _state = CPClosed;
   }
   //printf("Closing CPEngine\n");
   return ORSuspend;
}

-(id<ORBasicModel>)model
{
   id<ORBasicModel> bm = [[CPModelI alloc] initCPModel:self];
   [self trackMutable:bm];
   return bm;
}


-(void) clearStatus
{
   _status = ORSuspend;
}

-(ORStatus)  status
{
   return _status;
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
   _status = ORSuspend;
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
