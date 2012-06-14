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

#import "CPParallel.h"
#import "CPI.h"
#import "CPFactory.h"

@interface CPGenerator : CPDefaultController<CPSearchController> {
   id<CPExplorer>  _explorer;
   PCObjectQueue*      _pool;   
   NSCont**             _tab;
   Checkpoint**       _cpTab;
   int                   _sz;
   int                   _mx;
}
-(id)initCPGenerator:(id<CPSearchController>)chain explorer:(id<CPExplorer>)explorer onPool:(PCObjectQueue*)pcq;
-(CPInt)  addChoice: (NSCont*) k;
-(void)       fail;
-(BOOL) isFinitelyFailed;
-(void)       exitTryLeft;
-(void)       exitTryRight;
-(void)       exitTryallBody;
-(void)       exitTryallOnFailure;
@end

@interface CPParallelAdapter : CPNestedController<CPSearchController> {
   id<CPExplorer>     _explorer;
   PCObjectQueue*         _pool;
   BOOL             _publishing;
   CPGenerator*            _gen;
}
-(id)initCPParallelAdapter:(id<CPSearchController>)chain  explorer:(id<CPExplorer>)explorer onPool:(PCObjectQueue*)pcq;
-(CPInt)  addChoice: (NSCont*) k;
-(void)       fail;
-(void)       succeeds;
-(void)       startTry;
-(void)       startTryall;
-(void) publishWork;
-(BOOL) isFinitelyFailed;
@end

@implementation CPParallelAdapter
-(id)initCPParallelAdapter:(id<CPSearchController>)chain  explorer:(id<CPExplorer>)explorer onPool:(PCObjectQueue *)pcq
{
   self = [super initCPNestedController:chain];
   _explorer = explorer;
   _pool = [pcq retain];
   _publishing = NO;
   return self;
}
-(void)dealloc
{
   //NSLog(@"CPParallel adapter dealloc %p  - %d",self,[_pool retainCount]);
   [_pool release];
   [super dealloc];
}
-(CPInt)  addChoice: (NSCont*) k
{
   return [_controller addChoice:k];
}
-(void) succeeds
{
   return [_controller succeeds];
}

-(void) publishWork
{
   _publishing = YES;
   Checkpoint* theCP = [_explorer captureCheckpoint];
   CPHeist* stolen = [_controller steal];
   id<CPSearchController> genc = [[CPGenerator alloc] initCPGenerator:self explorer:_explorer onPool:_pool];
   [_explorer restoreCheckpoint:[stolen theCP]];
   [_explorer nestedSolveAll:^() { [[stolen cont] call];} 
                  onSolution:nil 
                      onExit:nil
                     control:genc];
   [stolen release];
   [_explorer restoreCheckpoint:theCP];
   _publishing = NO;
}

-(void)startTry
{
   bool pe = !_publishing && [_pool empty] && [_controller willingToShare];
   if (pe) {
      //NSLog(@"Pool found to be empty[%d] and controller willing to share in thread: %p\n",pe,[NSThread currentThread]);
      [self publishWork];
   }
   [_controller startTry];
}
-(void)startTryall
{
   bool pe = !_publishing && [_pool empty] && [_controller willingToShare];
   if (pe) {
      //NSLog(@"Pool found to be empty[%d] and controller willing to share in thread: %p\n",pe,[NSThread currentThread]);
      [self publishWork];
   }
   [_controller startTryall];
}
-(void)fail
{
   [_controller fail];
   [self finitelyFailed];  // [ldm] This is necessary since we *are* a nested controller after all (finitelyFailed is inherited)
}
-(BOOL) isFinitelyFailed
{
   return NO;
}
@end

@implementation CPGenerator

-(id)initCPGenerator:(id<CPSearchController>)chain explorer:(id<CPExplorer>)explorer onPool:(PCObjectQueue*)pcq
{
   self = [super initCPDefaultController];
   [self setController:chain];
   _explorer = explorer;
   _pool = [pcq retain];   
   _mx  = 100;
   _tab = malloc(sizeof(NSCont*)* _mx);
   _cpTab = malloc(sizeof(Checkpoint*)*_mx);
   _sz  = 0;
   return self;
}
-(void)dealloc
{
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

-(CPInt)  addChoice: (NSCont*) k
{
   if (_sz >= _mx) {
      _tab = realloc(_tab,sizeof(NSCont*)*_mx*2);
      _cpTab = realloc(_cpTab,sizeof(Checkpoint*)*_mx*2);
      _mx <<= 1;      
   }
   _tab[_sz]   = k;
   _cpTab[_sz] = [_explorer captureCheckpoint];
   _sz++;
   return [_cpTab[_sz-1] nodeId];
}
-(void)fail
{
   long ofs = _sz-1;
   if (ofs >= 0) {      
      Checkpoint* cp = _cpTab[ofs];
      [_explorer restoreCheckpoint:cp];
      [cp release];
      NSCont* k = _tab[ofs];
      _tab[ofs] = 0;
      --_sz;
      if (k!=NULL) 
         [k call];      
      else return;
   } else return;
}
-(void) finitelyFailed
{
   [_controller fail];   
}
-(BOOL) isFinitelyFailed
{
   return NO;
}

-(void)packAndFail
{
   NSData* theData = [_explorer captureAndPackProblem];
   [_pool enQueue:theData];
   [self fail];
   [self finitelyFailed];   
}

-(void)exitTryLeft
{
   [self packAndFail];
}
-(void)exitTryRight
{
   [self packAndFail];
}
-(void)exitTryallBody
{
   [self packAndFail];
}
-(void)exitTryallOnFailure
{
   [self packAndFail];
}
@end

// =================================================================================================
// Sem Parallel
// =================================================================================================

@implementation SemParallel
-(id)initSemParallel:(SemCP*)orig  nbWorkers:(CPUInt)nbt
{
   self = [super init];
   _original = orig;
   _nbt  = nbt;
   _queue = [[PCObjectQueue alloc] initPCQueue:128 nbWorkers:_nbt];
   _terminated = [[NSCondition alloc] init];
   _nbDone     = 0;
   return self;
}
-(void)dealloc
{
   NSLog(@"SemParallel dealloc");
   [_queue release];
   for(CPInt i = 0;i < _nbt;i++)
      assert(_clones[i] == nil);
   free(_clones);
   [super dealloc];
}
-(void)waitWorkers
{
   [_terminated lock];
   while (_nbDone < _nbt) 
      [_terminated wait];
   [_terminated unlock];
}

-(void)runSearcher:(NSArray*)array
{
   id arp = [[NSAutoreleasePool alloc] init];
   CPUInt i   = [[array objectAtIndex:0] intValue];
   NSData*  model = [array objectAtIndex:1];
   CPVirtualClosure body = [array objectAtIndex:2];
   _clones[i] = [[NSKeyedUnarchiver unarchiveObjectWithData:model] retain];
   [arp release];

   [_clones[i] search: ^() {
      [_clones[i] close];
      if (i == 0) {
         // The first guy produces a sub-problem that is the root of the whole tree.
         NSData* rootSerial = [[_clones[i] explorer] captureAndPackProblem];
         [_queue enQueue:rootSerial];
      }
      NSData* cpRoot = nil;
      while ((cpRoot = [_queue deQueue]) !=nil) {
         [self setupAndGo:cpRoot forCP:_clones[i] searchWith:body];
         [cpRoot release];
      }      
   }];
   [_clones[i] release];
   _clones[i] = nil;
   [body release];
   [CPFactory shutdown];   
   [_terminated lock];
   ++_nbDone;
   if (_nbDone == _nbt)
      [_terminated signal];
   [_terminated unlock];
}

-(void)setupWork:(NSData*)root forCP:(SemCP*)cp
{
   CPProblem* theSub = [[CPProblem unpack:root forSolver:cp] retain];
   CPStatus status = [cp installProblem:theSub];
   [theSub release];
   if (status == CPFailure)
      [[cp explorer] fail];
}
-(void)setupAndGo:(NSData*)root forCP:(SemCP*)cp searchWith:(CPVirtualClosure)body 
{
   id<CPSearchController> parc = [[CPParallelAdapter alloc] initCPParallelAdapter:[cp controller] explorer:[cp explorer] onPool:_queue];
   [cp nestedSolveAll:^() {  [self setupWork:root forCP:cp]; body((id<CP>)cp);} 
           onSolution:nil 
               onExit:nil
              control:parc];
}

-(void)parallel:(CPVirtualClosure)body
{
#if 0 && defined(__linux__)
   NSMutableData* archive = [[NSMutableData alloc] initWithCapacity:32];
   NSArchiver* archiver   = [[NSArchiver alloc] initForWritingWithMutableData:archive];
   [archiver encodeRootObject:_original];
#else
   NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:_original];
#endif
   _clones = malloc(sizeof(SemCP*)*_nbt);   
   for(CPInt i=0;i<_nbt;i++) {
      CPVirtualClosure copy = [body copy];
      [NSThread detachNewThreadSelector:@selector(runSearcher:) 
                               toTarget:self 
                             withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:(int) i],archive,copy,nil]];   
   }   
   [self waitWorkers];
}

@end
