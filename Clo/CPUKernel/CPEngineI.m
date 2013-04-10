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
#import "ORFoundation/ORSetI.h"

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
inline static void AC3enQueue(CPAC3Queue* q,ConstraintCallback cb,id<CPConstraint> cstr)
{
   if (q->_csz == q->_mxs-1)
      [q resize];
   AC3Entry* last = q->_tab+ (q->_enter == 0 ? q->_mxs -1 : q->_enter - 1);
   if (q->_csz > 0 && last->cb == cb && last->cstr == cstr)
      return;
   q->_tab[q->_enter] = (AC3Entry){cb,cstr};
   q->_enter = (q->_enter+1) & q->_mask;
   ++q->_csz;
   assert(cb || cstr);
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
-(bool)loaded
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
-(NSArray*) objects
{
   return [_engine objects];
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
-(CPEngineI*) initEngine: (id<ORTrail>) trail
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
-(void)setLastFailure:(id<CPConstraint>)lastToFail
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
-(void) trackVariable: (id) var
{
   [var setId:(ORUInt)[_vars count]];
   if (_state != CPClosed) {
      [_vars addObject:var];
      [var release];
   }
   else
      [_trail trailRelease:var];
}
-(void) trackObject:(id)obj
{
   if (_state != CPClosed) {
      [_oStore addObject:obj];
      [obj release];
   }
   else
      [_trail trailRelease:obj];
}
-(void) trackConstraint:(id)obj
{
   if (_state != CPClosed) {
      [_oStore addObject:obj];
      [obj release];
   }
   else
      [_trail trailRelease:obj];
}
-(NSString*) description
{
   return [NSString stringWithFormat:@"Solver: %ld vars\n\t%ld constraints\n\t%d propagations\n",[_vars count],[_cStore count],_nbpropag];
}
-(id) trail
{
   return _trail;
}

-(void) scheduleTrigger:(ConstraintCallback)cb onBehalf:(id<CPConstraint>)c
{
   AC3enQueue(_ac3[HIGHEST_PRIO], cb, c);
}

-(void) scheduleAC3: (id<CPEventNode>*) mlist
{
   while (*mlist) {
      CPEventNode* list = *mlist;
      while (list) {
         assert(list->_cstr);
         if (list->_cstr->_active._val) {
            list->_cstr->_todo = CPTocheck;
            id<CPGroup> group = list->_cstr->_group;
            if (group) {
               AC3enQueue(_ac3[LOWEST_PRIO], nil, group);
               [group scheduleAC3:list];
            } else
               AC3enQueue(_ac3[list->_priority], list->_trigger,list->_cstr);
         }
         list = list->_node;
      } 
      ++mlist;
   }
}

// PVH: there is a discrepancy between the AC3 and AC5 queues. AC5 uses CPEventNode; AC3 works with the trigger directly

-(void) scheduleAC5: (id<CPAC5Event>)evt
{
   enQueueAC5(_ac5, evt);
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
   ORStatus status = fdm->_status = ORSuspend;
   bool done = false;
   CPAC5Queue* ac5 = fdm->_ac5;
   CPAC3Queue** ac3 = fdm->_ac3;
   id<CPConstraint>* last = &fdm->_last;
   *last = nil;
   ORInt nbp = 0;
   @try {
      while (!done) {
         // AC5 manipulates the list
         while (AC5LOADED(ac5)) {
            
            assert(0);
            
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
         ORStatus as = executeAC3(AC3deQueue(ac3[ALWAYS_PRIO]), last);
         nbp += as != ORSkip;
         assert(as != ORFailure);
      }
      if (fdm->_propagDone)
         [fdm->_propagDone notify];
      fdm->_status = status;
      fdm->_nbpropag += nbp;
      --fdm->_propagating;
      return status;
   }
   @catch (ORFailException *exception) {
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
      [exception release];
      fdm->_status = ORFailure;
      fdm->_nbpropag += nbp;
      --fdm->_propagating;
      return ORFailure;
   } 
}

-(ORStatus) propagate
{
   if (_propagating > 0)
      return ORDelay;
   _last = nil;
   ++_propagating;
   ORStatus status = _status = ORSuspend;
   bool done = false;
   @try {
      while (!done) {
         // AC5 manipulates the list
         while (AC5LOADED(_ac5)) {
            id<CPAC5Event> evt = deQueueAC5(_ac5);
            _nbpropag += [evt execute];
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
      _status = status;
      --_propagating;
      return _status;
   }
   @catch (ORFailException *exception) {
      for(ORInt p=NBPRIORITIES-1;p>=0;--p)
         AC3reset(_ac3[p]);
      AC5reset(_ac5);
      if (_propagFail)
         [_propagFail notifyWith:[_last getId]];
      [exception release];
      _status = ORFailure;
      --_propagating;
      return _status;
   }
}

static inline ORStatus internalPropagate(CPEngineI* fdm,ORStatus status)
{
   if (status == ORSuspend || status == ORSuccess)
      return propagateFDM(fdm);// fdm->_propagIMP(fdm,@selector(propagate));
   else if (status== ORFailure) {
      for(ORInt p=HIGHEST_PRIO;p>=LOWEST_PRIO;--p)
         AC3reset(fdm->_ac3[p]);
      return ORFailure;
   } else return status;
}

-(ORStatus) enforceObjective
{
   if (_objective == nil) return ORSuspend;
   @try {
      _status = ORSuspend;
      ORStatus ok = [_objective check];
      if (ok)
         ok = propagateFDM(self);// [self propagate];
      return ok;
   } @catch (ORFailException *exception) {
      [exception release];
      _status = ORFailure;
   }
   return _status;
}

-(ORStatus) post: (id<ORConstraint>) c
{
   @try {
      CPCoreConstraint* cstr = (CPCoreConstraint*) c;
      ORStatus status = [cstr post];
      ORStatus pstatus = internalPropagate(self,status);
      _status = pstatus;
      if (pstatus && status != ORSkip) {
         [_cStore addObject:c]; // only add when no failure
         const NSUInteger ofs = [_cStore count] - 1;
         [_trail trailClosure:^{
            [_cStore removeObjectAtIndex:ofs];
         }];
      }
   } @catch (ORFailException* ex) {
#if defined(__linux__)      
      [ex release];
#else
      CFRelease(ex);
#endif
      _status = ORFailure;
   }
   return _status;
}

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

-(ORStatus) enforce: (Void2ORStatus) cl
{
   @try {
      ORStatus status = cl();
      _status = internalPropagate(self,status);
   } @catch (ORFailException *exception) {
      [exception release];
      _status = ORFailure;
   }
   return _status;
}
-(ORStatus) atomic:(Void2ORStatus)cl
{
   ORInt oldPropag = _propagating;
   @try {
      _propagating++;
      ORStatus status = cl();
      _propagating--;
      _status = internalPropagate(self,status);
   } @catch (ORFailException* exception) {
      [exception release];
      _propagating = oldPropag;
      _status = ORFailure;
   }
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
   [self trackObject:bm];
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
