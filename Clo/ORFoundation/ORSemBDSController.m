/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "ORSemBDSController.h"

@interface BDSStack : NSObject {
   struct BDSNode {
      NSCont*     _cont;
      ORCheckpoint*   _cp;
      ORInt         _disc;
   };
@private
   struct BDSNode* _tab;
   ORInt        _mx;
   ORInt        _sz;
}
-(id)initBDSStack:(ORInt)mx;
-(void)pushCont:(NSCont*)k cp:(ORCheckpoint*)cp discrepancies:(ORInt)d;
-(struct BDSNode)pop;
-(ORInt)size;
-(bool)empty;
@end

@implementation BDSStack
-(id)initBDSStack:(ORInt)mx
{
   self = [super init];
   _mx = mx;
   _tab  = malloc(sizeof(struct BDSNode)* _mx);
   _sz = 0;
   return self;
}
-(void)dealloc 
{
   for(ORInt i = 0;i  < _sz;i++) {
      [_tab[i]._cont release];
      [_tab[i]._cp release];
   }
   free(_tab);
   [super dealloc];
}
-(void)pushCont:(NSCont*)k cp:(ORCheckpoint*)cp discrepancies:(ORInt)d
{
   if (_sz >= _mx) {
      _mx <<= 1;      
      _tab = realloc(_tab,sizeof(struct BDSNode)* _mx);
   }   
   _tab[_sz] = (struct BDSNode){k,cp,d};
   ++_sz;
}
-(struct BDSNode)pop
{
   return _tab[--_sz];
}
-(ORInt)size 
{
   return _sz;
}
-(bool)empty
{
   return _sz == 0;
}
@end

@implementation ORSemBDSController

- (id) initSemController:(id<ORTracer>)tracer andSolver:(id<OREngine>)solver
{
   self = [super initORDefaultController];
   _tracer = [tracer retain];
   _solver = solver;
   _tab  = [[BDSStack alloc] initBDSStack:32];
   _next = [[BDSStack alloc] initBDSStack:32];
   _nbDisc = _maxDisc = 0;   
   return self;
}

- (void) dealloc
{
   NSLog(@"SemBDSController dealloc called...\n");
   [_tracer release];
   [_tab release];
   [_next release];
   [super dealloc];
}

-(void) setup
{
   _atRoot = [_tracer captureCheckpoint];
}
-(void) cleanup
{
   while (![_tab empty]) {
      struct BDSNode nd = [_tab pop];
      [nd._cont letgo];
      [nd._cp release];
   }
   while (![_next empty]) {
      struct BDSNode nd = [_next pop];
      [nd._cont letgo];
      [nd._cp release];
   }
   [_tracer restoreCheckpoint:_atRoot inSolver:_solver];
}

-(ORInt) addChoice: (NSCont*)k 
{
   if (_nbDisc + 1 < _maxDisc) 
      [_tab  pushCont:k cp:[_tracer captureCheckpoint] discrepancies:_nbDisc+1];
   else [_next pushCont:k cp:[_tracer captureCheckpoint] discrepancies:_nbDisc+1];  
   return -1;
}
-(void) fail
{
   do {
      if ([_tab empty] && [_next empty])
         return;  // Nothing left to process. Go back!
      else {
         if ([_tab empty]) {
            BDSStack* tmp = _tab;
            _tab = _next;
            _next = tmp;
            _maxDisc++;
         }
         struct BDSNode node = [_tab pop];
         _nbDisc = node._disc;
         ORStatus status = [_tracer restoreCheckpoint:node._cp inSolver:_solver];
         [node._cp release];
         if (status != ORFailure)
            [node._cont call];      
      }
   } while (true);
}
-(void) trust
{
   [_tracer pushNode]; // no need to trust the tracer since pushNode automatically trusts
//   [_tracer trust];
}
- (id)copyWithZone:(NSZone *)zone
{
   ORSemBDSController* ctrl = [[[self class] allocWithZone:zone] initSemController:_tracer andSolver:_solver];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}
@end