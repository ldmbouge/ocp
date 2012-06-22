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

#import "CPSolverI.h"
#import "CPTrail.h"
#import "CPIntVarI.h"
#import "CPBasicConstraint.h"
#import "DFSController.h"
#import "CPTypes.h"
#import "CPSetI.h"
#import "CPSolutionI.h"

#define AC5LOADED(q) ((((q)->_mxs + (q)->_enter - (q)->_exit)  & (q)->_mask) > 0)
#define ISLOADED(q) (((q)->_csz) > 0)

@implementation CPFailException
-(CPFailException*)init
{
   self = [super init];
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
@end

/*****************************************************************************************/
/*                        VarEventNode                                                   */
/*****************************************************************************************/

@implementation VarEventNode
-(VarEventNode*)initVarEventNode:(VarEventNode*)next trigger:(id)t cstr:(CPCoreConstraint*)c at:(CPInt)prio
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
    [super dealloc];
}
@end

typedef struct AC3Entry {
   ConstraintCallback   cb;
   CPCoreConstraint*    cstr;
} AC3Entry;

@interface CPAC3Queue : NSObject {
   @package
   CPInt      _mxs;
   CPInt      _csz;
   AC3Entry*  _tab;
   CPInt    _enter;
   CPInt     _exit;
   CPInt     _mask;
}
-(id)initAC3Queue:(CPInt)sz;
-(void)dealloc;
-(AC3Entry)deQueue;
-(void)enQueue:(ConstraintCallback)cb cstr:(CPCoreConstraint*)cstr;
-(void)reset;
-(bool)loaded;
@end



@implementation CPAC3Queue 
-(id) initAC3Queue: (CPInt) sz
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
   //CPInt nb = (_mxs + _enter - _exit)  & _mask;
   return _csz > 0;
}
-(void) resize
{
   AC3Entry* nt = malloc(sizeof(AC3Entry)*_mxs*2);
   AC3Entry* ptr = nt;
   CPInt cur = _exit;
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
    CPInt        _value;
} AC5Event;


@interface CPAC5Queue : NSObject {
    @package
    CPInt      _mxs;
    AC5Event*      _tab;
    CPInt      _enter;
    CPInt      _exit;
    CPInt      _mask;
}
-(id) initAC5Queue: (CPInt) sz;
-(void) dealloc;
-(AC5Event) deQueue;
-(void) enQueue: (VarEventNode*) cb with: (CPInt) val;
-(void) reset;
-(bool) loaded;
@end


@implementation CPAC5Queue 
-(id) initAC5Queue:(CPInt)sz
{
   self = [super init];
   _mxs = sz;
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
}
-(bool)loaded
{
   CPInt nb = (_mxs + _enter - _exit)  & _mask;
   return nb > 0;
}
-(void)enQueue:(VarEventNode*)cb with:(CPInt)val
{
   CPInt nb = (_mxs + _enter - _exit)  & _mask;
   if (nb == _mxs-1) {
      AC5Event* nt = malloc(sizeof(AC5Event)*_mxs*2);
      AC5Event* ptr = nt;
      CPInt cur = _exit;
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
   _tab[_enter]._list  = cb;
   _tab[_enter]._value = val;
   _enter = (_enter+1) & _mask;
}
-(AC5Event)deQueue
{
   if (_enter != _exit) {
      CPInt oe = _exit;
      _exit = (_exit+1) & _mask;
      return _tab[oe];
   } else return (AC5Event){0,0};
}
@end

@implementation CPSolverI
-(CPSolverI*) initSolver: (CPTrail*) trail
{
   self = [super init];
   _trail = trail;
   _closed = false;
   _vars  = [[NSMutableArray alloc] init];
   _cStore = [[NSMutableArray alloc] initWithCapacity:32];
   _mStore = [[NSMutableArray alloc] initWithCapacity:32];
   _oStore = [[NSMutableArray alloc] initWithCapacity:32];
   for(CPInt i=0;i<NBPRIORITIES;i++)
      _ac3[i] = [[CPAC3Queue alloc] initAC3Queue:512];
   _ac5 = [[CPAC5Queue alloc] initAC5Queue:512];
   _status = CPSuspend;
   _propagating = 0;
   _nbpropag = 0;
   _propagSEL = @selector(propagate);
   _propagIMP = [self methodForSelector:_propagSEL];
   _propagFail = nil;
   _propagDone = nil;
   _fex = [CPFailException new];
   return self;
}

-(void) dealloc
{
   NSLog(@"Solver [%p] dealloc called...\n",self);
   [_vars release];
   [_cStore release];
   [_mStore release];
   [_oStore release];
   [_ac5 release];
   [_propagFail release];
   [_propagDone release];
   for(CPInt i=0;i<NBPRIORITIES;i++)
      [_ac3[i] release];
   [_fex release];
   [super dealloc];
}

-(id<CPSolver>) solver
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
-(CPUInt) nbPropagation
{
   return _nbpropag;
}
-(CPUInt) nbVars
{
   return [_vars count];
}

-(void) trackVariable: (id) var
{
   [var setId:[_vars count]];
   [_vars addObject:var];
   if (!_closed) 
      [var autorelease];
   else 
      [_trail trailRelease:var];
}

-(void) trackObject:(id)obj
{
   [_oStore addObject:obj];
   if (!_closed) 
      [obj autorelease];
   else 
      [_trail trailRelease:obj];
}
-(id)virtual:(id<CPVirtual>)obj
{
   CPInt oOfs = [obj virtualOffset];
   if (oOfs != NSNotFound)
      return [_oStore objectAtIndex:oOfs];
   else 
      return nil;
}
-(CPInt)virtualOffset:(id)obj
{
   CPUInt idx = [_oStore indexOfObjectIdenticalTo:obj];
   return idx;
}

-(NSString*) description
{
  return [NSString stringWithFormat:@"Solver: %d vars\n\t%d propagations\n",[_vars count],_nbpropag];
}
-(id) trail
{
   return _trail;
}

-(void) scheduleTrigger:(ConstraintCallback)cb onBehalf:(CPCoreConstraint*)c
{
   AC3enQueue(_ac3[HIGHEST_PRIO], cb, c);
}

-(void) scheduleAC3: (VarEventNode*) list
{
   while (list) {
       if (list->_cstr) 
           list->_cstr->_todo = CPTocheck;
       AC3enQueue(_ac3[list->_priority], list->_trigger,list->_cstr);        
       list = list->_node;
   }
}

// PVH: there is a discrepancy between the AC3 and AC5 queues. AC5 uses varEventNode; AC3 works with the trigger directly

-(void) scheduleAC5: (VarEventNode*) list  with: (CPInt) val
{
   [_ac5 enQueue: list with: val];
}

// PVH: This does the case analysis on the key of events {trigger,cstr} and handle the idempotence

static inline CPStatus executeAC3(AC3Entry cb,CPCoreConstraint** last)
{
   CPStatus status;
   *last = cb.cstr;
   if (cb.cb) 
      status = cb.cb();
   else {
      CPCoreConstraint* cstr = cb.cstr;
      if (cstr->_todo == CPChecked) 
         return CPSkip;
      else {
         cstr->_todo = cstr->_idempotent == NO ? CPChecked : cstr->_todo;
         status = [cstr propagate];
         cstr->_todo = cstr->_idempotent == YES ? CPChecked : cstr->_todo;
      }
   }
   return status;
}

-(CPStatus) propagate
{
   if (_propagating > 0) 
       return CPDelay;
   _last = nil;
   ++_propagating;
   CPStatus status = CPSuspend;
   bool done = false;
   @try {
      while (!done) {
         // AC5 manipulates the list
         while (AC5LOADED(_ac5)) {
            AC5Event evt = [_ac5 deQueue];
            VarEventNode* list = evt._list;
            while (list) {
               // PVH: this may need to be generalized for more general events
               status = ((ConstraintIntCallBack)(list->_trigger))(evt._value);
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
            _nbpropag += status !=CPSkip;
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
   }
   @catch (CPFailException *exception) {
      for(CPInt p=NBPRIORITIES-1;p>=0;--p)
         [_ac3[p] reset];
      [_ac5 reset];
      if (_propagFail)
	 [_propagFail notifyWith:[_last getId]];
      [exception release];
      _status = CPFailure;
   }
   @finally {
      --_propagating;
      return _status;
   }
}

static inline CPStatus internalPropagate(CPSolverI* fdm,CPStatus status)
{
   switch (status) {
      case CPFailure:
         for(CPInt p=HIGHEST_PRIO;p>=LOWEST_PRIO;--p)
            [fdm->_ac3[p] reset];
         break; 
      case CPSuccess:
      case CPSuspend:
         //status = [fdm propagate];
         status = (CPStatus) fdm->_propagIMP(fdm,fdm->_propagSEL);
         break;
      case CPDelay:
         break;
      default:
         break;
   }  
   return status;
}

-(CPStatus) post: (id<CPConstraint>) c
{
   CPCoreConstraint* cstr = (CPCoreConstraint*) c;
   CPStatus status = [cstr post];
   _status = internalPropagate(self,status);
   if (_status) {
      [cstr setId:[_cStore count]];
      [_cStore addObject:c]; // only add when no failure
   }
   return _status;
}
-(CPStatus) add: (id<CPConstraint>) c
{
   if (_closed) {
      return [self post: c];
   }
   else {
      CPCoreConstraint* cstr = (CPCoreConstraint*) c;
      [cstr setId:[_mStore count]];
      [_mStore addObject:c]; 
      return CPSuspend;
   }
}

-(CPStatus) label: (id) var with: (CPInt) val
{
   CPStatus status = [var bind:val];
   _status = internalPropagate(self,status);
   return _status;
}

-(CPStatus) diff: (CPIntVarI*) var with: (CPInt) val
{
    CPStatus status = [var remove:val];
   _status = internalPropagate(self,status);
   return _status;
}
-(CPStatus)  lthen:(id)var with:(CPInt)val
{
   CPStatus status = [var updateMax:val-1];
   _status = internalPropagate(self,status);
   return _status;
}
-(CPStatus)  gthen:(id)var with:(CPInt)val
{
   CPStatus status = [var updateMin:val+1];
   _status = internalPropagate(self,status);
   return _status;
}
-(CPStatus) restrict: (CPIntVarI*) var to: (CPIntSetI*) S
{
    CPStatus status = [var inside: S];
    _status = internalPropagate(self,status);
    return _status;   
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
-(CPStatus) close
{
   if (!_closed) {
      _closed = true;
      for(id<CPConstraint> c in _mStore) {
         [self post:c];
         if (_status == CPFailure)
            return CPFailure;
      }
   }
   //printf("Closing CPSolver\n");
   return CPSuspend;
}
-(bool) closed
{
    return _closed;
}

-(id<CPInformer>) propagateFail
{
   if (_propagFail == nil)
      _propagFail = [CPConcurrency  intInformer];
   return _propagFail;
}
-(id<CPInformer>) propagateDone
{
   if (_propagDone == nil)
      _propagDone = [CPConcurrency  voidInformer];
   return _propagDone;
}

-(void)raiseFailure
{
   @throw [_fex retain];
}

void failNow(CPSolverI* fdm)
{
   @throw [fdm->_fex retain];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeValueOfObjCType:@encode(BOOL) at:&_closed];
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
   [aDecoder decodeValueOfObjCType:@encode(BOOL) at:&_closed];
   _vars = [[aDecoder decodeObject] retain];
   _trail = [[aDecoder decodeObject] retain];
   NSMutableArray* originalStore = [aDecoder decodeObject];
   _oStore = [[aDecoder decodeObject] retain];
   for(CPInt i=0;i<NBPRIORITIES;i++)
      _ac3[i] = [[[CPAC3Queue alloc] initAC3Queue:512] retain];
   _ac5 = [[[CPAC5Queue alloc] initAC5Queue:512] retain];
   _status = CPSuspend;
   _propagating = 0;
   _nbpropag = 0;
   _propagSEL = @selector(propagate);
   _propagIMP = [self methodForSelector:_propagSEL];
   for(id<CPConstraint> c in originalStore) {
      // The retain is necessary given that the post will release it after storing in cStore.
      [self add:[c retain]];  
   }
   return self;
}
@end
