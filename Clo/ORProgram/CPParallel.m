/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORProgram/CPParallel.h>
#import <ORFoundation/ORSemDFSController.h>
#import "CPProgram.h"

@implementation CPParallelAdapter
-(id)initCPParallelAdapter:(id<ORSearchController>)chain  explorer:(id<CPSemanticProgram>)solver onPool:(PCObjectQueue *)pcq
{
   self = [super init:chain parent:[[solver explorer] controller]];
   _solver = solver;
   _pool = [pcq retain];
   _publishing = NO;
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

-(void) publishWork
{
   _publishing = YES;
   //NSLog(@"BEFORE PUBLISH: %@ - thread %p",[_solver tracer],[NSThread currentThread]);
   id<ORTracer> tracer = [_solver tracer];   
   id<ORCheckpoint> theCP = [tracer captureCheckpoint];
   ORHeist* stolen = [_controller steal];
   ORStatus ok = [tracer restoreCheckpoint:[stolen theCP] inSolver:[_solver engine]];
   assert(ok != ORFailure);
   id<ORSearchController> base = [[ORSemDFSController alloc] initTheController:[_solver tracer] engine:[_solver engine]];
   
   [[_solver explorer] applyController: base
                                    in: ^ {
                                       [[_solver explorer] nestedSolveAll:^() { [[stolen cont] call];}
                                                               onSolution:nil
                                                                   onExit:nil
                                                                  control:[[CPGenerator alloc] initCPGenerator:base explorer:_solver onPool:_pool]];
                                    }];
   
   [stolen release];
   ok = [tracer restoreCheckpoint:theCP inSolver:[_solver engine]];
   assert(ok != ORFailure);
   [theCP letgo];
   //NSLog(@"AFTER  PUBLISH: %@ - thread %p",[_solver tracer],[NSThread currentThread]);
   _publishing = NO;
}
-(void)trust
{
   [[_solver tracer] pushNode];
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
   assert(FALSE);
}
-(ORBool) isFinitelyFailed
{
   return NO;
}
@end

@implementation CPGenerator

-(id)initCPGenerator:(id<ORSearchController>)chain explorer:(id<CPSemanticProgram>)solver onPool:(PCObjectQueue*)pcq
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
-(void) startTryallBody
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
         ORStatus ok = [_tracer restoreCheckpoint:cp inSolver:[_solver engine]];
         //assert(ok != ORFailure);
         [cp letgo];
         NSCont* k = _tab[ofs];
         _tab[ofs] = 0;
         --_sz;
         if (k && ok)
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
   assert(FALSE);
}
-(ORBool) isFinitelyFailed
{
   return NO;
}

-(void)packAndFail
{
   id<ORProblem> p = [[_solver tracer] captureProblem];
   //NSLog(@"PACKING: %@",p);
   NSData* theData = [p packFromSolver:[_solver engine]];
   [p release];
   assert(theData != nil);
   [_pool enQueue:theData];
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
   CPGenerator* ctrl = [[[self class] allocWithZone:zone] initCPGenerator:_controller explorer:_solver onPool:_pool];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}
@end
