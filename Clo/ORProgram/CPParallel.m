/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORProgram/CPParallel.h>
#import <ORProgram/CPProgram.h>
#import <ORProgram/CPSolver.h>
#import <objcp/CPObjectQueue.h>

#if defined(__linux__)
#include <pthread.h>
#endif

@implementation CPParallelAdapter {
   id<CPSemanticProgram>  _solver;
   PCObjectQueue*           _pool;
   BOOL               _publishing;
   BOOL*                 _stopNow;
   CPGenerator*              _gen;
}
-(id)initCPParallelAdapter:(id<ORSearchController>)chain  explorer:(id<CPSemanticProgram>)solver
                    onPool:(PCObjectQueue *)pcq
             stopIndicator:(BOOL*)si
{
   self = [super init:chain parent:[[solver explorer] controller]];
   _solver = solver;
   _pool = [pcq retain];
   _publishing = NO;
   _stopNow    = si;
   return self;
}
-(void)dealloc
{
   //NSLog(@"CPParallel adapter dealloc %p  - %ld",self,[_pool retainCount]);
   [_pool release];
   [super dealloc];
}
-(ORInt)  addChoice: (NSCont*) k
{
   return [_controller addChoice:k];
}
-(void) succeeds
{
   return [_controller succeeds];
}
-(void) abort
{
   *_stopNow = YES;
   [super abort];
}

#if defined(__linux__)
static pthread_spinlock_t lock;
__attribute__((constructor))
void lock_constructor() {
  if (pthread_spin_init(&lock,0) != 0) {
    exit(1);
  }
}
#endif

-(void) publishWork
{
   _publishing = YES;
   ORTimeval cpu0 = [ORRuntimeMonitor now];
   //NSLog(@"BEFORE PUBLISH: %@ - thread %p",[_solver tracer],[NSThread currentThread]);
   id<ORTracer> tracer = [_solver tracer];
   id<ORCheckpoint> theCP = [tracer captureCheckpoint];
   //NSLog(@"MT(0):%d : %@",[NSThread threadID],[theCP getMT]);
   id<ORPost> pItf = [[CPINCModel alloc] init:_solver];
   ORHeist* stolen = [_controller steal];
   //NSLog(@"     Publishing(%d) : %@ - %p  -- current objective: %@ stole:%d",[NSThread threadID],
   //stolen.oValue,stolen.theCP,[_solver objective],[stolen sizeEstimate]);
   ORStatus ok;
   if (stolen) {
      ok = [tracer restoreCheckpoint:[stolen theCP] inSolver:[_solver engine] model:pItf];
      if (ok == ORFailure) {
         ok = [tracer restoreCheckpoint:theCP inSolver:[_solver engine] model:pItf];
         _publishing = NO;
         [theCP letgo];
         [pItf release];
         [stolen release];
         return;
      }
      assert(ok != ORFailure);
      
      [tracer pushNode];
      
      id<ORSearchController> base = [[ORSemDFSController alloc] initTheController:[_solver tracer]
                                                                           engine:[_solver engine]
                                                                          posting:[pItf retain]];
      
      [[_solver explorer] applyController: base
                                       in: ^ {
                                          [[_solver explorer] nestedSolveAll:^() { [[stolen cont] call];}
                                                                  onSolution:nil
                                                                      onExit:nil
                                                                     control:[[CPGenerator alloc] initCPGenerator:base
                                                                                                         explorer:_solver
                                                                                                           onPool:_pool
                                                                                                             post:pItf]];
                                       }];
      
      [tracer popNode];
      //NSLog(@"     PUBLISHED: - thread %d  - pool (%d) - Heist size(%d)",[NSThread threadID],[_pool size],[stolen sizeEstimate]);
      [stolen release];
   }
   //NSLog(@"MT(1):%d : %@",[NSThread threadID],[theCP getMT]);
   //NSLog(@"CT(1):%d : %@",[NSThread threadID],[tracer getMT]);
   ok = [tracer restoreCheckpoint:theCP inSolver:[_solver engine] model:pItf];
//   assert(ok != ORFailure);
   //NSLog(@"MT(2):%d : %@",[NSThread threadID],[theCP getMT]);
   //NSLog(@"CT(2):%d : %@",[NSThread threadID],[tracer getMT]);
   [theCP letgo];
   //NSLog(@"AFTER  PUBLISH: %@ - thread %p",[_solver tracer],[NSThread currentThread]);
   [pItf release];
   ORTimeval cpu1 = [ORRuntimeMonitor elapsedSince:cpu0];
#if defined(__APPLE__)
   static OSSpinLock lock = OS_SPINLOCK_INIT;
   OSSpinLockLock(&lock);
#else   
   pthread_spin_lock(&lock);
#endif
   static ORLong ttl = 0;
   ttl += cpu1.tv_sec*1000 + cpu1.tv_usec/1000;
#if defined(__APPLE__)
   OSSpinLockUnlock(&lock);
#else
   pthread_spin_unlock(&lock);
#endif   
   //NSLog(@"publishing took: %lld",ttl);
   _publishing = NO;
   if (ok == ORFailure)
      [self fail];
}
-(void)trust
{
   //[[_solver tracer] pushNode];
   [_controller trust];
}
-(void)startTry
{
   if (*_stopNow)
      [self fail:true];
   bool pe = !_publishing && [_pool empty] && [_controller willingToShare];
   if (pe) {
      //NSLog(@"Pool found to be empty[%d] and controller willing to share in thread: %p\n",pe,[NSThread currentThread]);
      //while (_controller.willingToShare)
//      NSLog(@"***** (%d) Start publishing...",[NSThread threadID]);
      while (_controller.willingToShare && [_pool size] < 10)
         [self publishWork];
//      NSLog(@"***** (%d) End   publishing... %d",[_pool size],[NSThread threadID]);
   }
   [_controller startTry];
}
-(void)startTryall
{
   if (*_stopNow)
      [self fail:true];
   bool pe = !_publishing && [_pool empty] && [_controller willingToShare];
   if (pe) {
      //NSLog(@"Pool found to be empty[%d] and controller willing to share in thread: %p\n",pe,[NSThread currentThread]);
      while (_controller.willingToShare && [_pool size] < 10)
         [self publishWork];
   }
   [_controller startTryall];
}
-(void)fail
{
   [_controller fail];
   [self finitelyFailed];  // [ldm] This is necessary since we *are* a nested controller after all (finitelyFailed is inherited)
   assert(FALSE);
}
-(void)fail:(ORBool)pruned
{
   [_controller fail];
   [self finitelyFailed];  // [ldm] This is necessary since we *are* a nested controller after all (finitelyFailed is inherited)
   assert(FALSE);
}
-(ORBool) isFinitelyFailed
{
   return NO;
}
-(void)startTryLeft
{
   if (*_stopNow)
      [self fail:true];
   [_controller startTryLeft];
}
-(void)startTryRight
{
   if (*_stopNow)
      [self fail:true];
   [_controller startTryRight];
}
-(void)exitTry
{
   if (*_stopNow)
      [self fail:true];
   [_controller exitTry];
}
@end

@implementation CPGenerator {
   id<CPSemanticProgram>   _solver;
   id<ORTracer>        _tracer;
   PCObjectQueue*      _pool;
   NSCont**             _tab;
   id<ORCheckpoint>*  _cpTab;
   int                   _sz;
   int                   _mx;
   id<ORPost>          _model;
}
-(id)initCPGenerator:(id<ORSearchController>)chain explorer:(id<CPSemanticProgram>)solver onPool:(PCObjectQueue*)pcq post:(id<ORPost>)model
{
   self = [super initORDefaultController];
   [self setController:chain];
   _solver = solver;
   _tracer = [solver tracer];
   _pool = [pcq retain];   
   _mx  = 100;
   _tab = malloc(sizeof(NSCont*)* _mx);
   _cpTab = malloc(sizeof(id<ORCheckpoint>)*_mx);
   _sz  = 0;
   _model = model;
   return self;
}
-(void)dealloc
{
   assert(_sz == 0);
   free(_tab);
   free(_cpTab);
   [_pool release];
   [super dealloc];
}
-(void) setup
{
}
-(void) cleanup
{
   while (_sz > 0) {
      _sz -= 1;
      [_tab[_sz] letgo];
      [_cpTab[_sz] release];
   }
}
-(void) startTryRight
{
}
-(void) startTryLeft
{
}
-(void) startTryallBody:(ORInt)alt
{
}
-(void) startTryallOnFailure
{
}

-(ORInt)  addChoice: (NSCont*) k
{
   if (_sz >= _mx) {
      _tab = realloc(_tab,sizeof(NSCont*)*_mx*2);
      _cpTab = realloc(_cpTab,sizeof(id<ORCheckpoint>)*_mx*2);
      _mx <<= 1;      
   }
   _tab[_sz]   = k;
   _cpTab[_sz] = [_tracer captureCheckpoint];
   _sz++;
   return [_cpTab[_sz-1] nodeId];
}
-(void)fail
{
   do {
      long ofs = _sz-1;
      if (ofs >= 0) {
         id<ORCheckpoint> cp = _cpTab[ofs];
         ORStatus ok = [_tracer restoreCheckpoint:cp inSolver:[_solver engine] model:_model];
         [cp letgo];
         NSCont* k = _tab[ofs];
         _tab[ofs] = 0;
         --_sz;
         if (k &&  (k.admin || ok != ORFailure))
            [k call];
         else [k letgo];
      } else break;
   } while(true);
   [self finitelyFailed];
   assert(FALSE);
}
-(void) trust
{
   [[_solver tracer] pushNode];
}
-(void) finitelyFailed
{
   [_controller fail];
   //assert(FALSE);
}
-(ORBool) isFinitelyFailed
{
   return NO;
}

-(void)packAndFail
{
   id<ORProblem> p = [[_solver tracer] captureProblem];
   //NSLog(@"packAndFail called. Saving problem %@",p);
   [_pool enQueue:p];
   [self fail];
   [self finitelyFailed];
   assert(FALSE);
}

-(void)exitTry
{
   [self packAndFail];
}
-(void)exitTryall
{
   [self packAndFail];
}

- (id)copyWithZone:(NSZone *)zone
{
   CPGenerator* ctrl = [[[self class] allocWithZone:zone] initCPGenerator:_controller explorer:_solver onPool:_pool post:_model];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}
@end
