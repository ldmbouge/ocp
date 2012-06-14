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

#import "CPError.h"
#import "SemBDSController.h"
#import "CPTracer.h"

@implementation BDSStack
-(id)initBDSStack:(CPInt)mx
{
   self = [super init];
   _mx = mx;
   _tab  = malloc(sizeof(struct BDSNode)* _mx);
   _sz = 0;
   return self;
}
-(void)dealloc 
{
   for(CPInt i = 0;i  < _sz;i++) {
      [_tab[i]._cont release];
      [_tab[i]._cp release];
   }
   free(_tab);
   [super dealloc];
}
-(void)pushCont:(NSCont*)k cp:(Checkpoint*)cp discrepancies:(CPInt)d
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
-(CPInt)size 
{
   return _sz;
}
-(bool)empty
{
   return _sz == 0;
}
@end

@implementation SemBDSController 

- (id) initSemBDSController:(id<CPTracer>)tracer andSolver:(id<CPSolver>)solver
{
   self = [super initCPDefaultController];
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

-(CPInt) addChoice: (NSCont*)k 
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
         CPStatus status = [_tracer restoreCheckpoint:node._cp inSolver:_solver];
         [node._cp release];
         if (status != CPFailure)
            [node._cont call];      
      }
   } while (true);
}
- (id)copyWithZone:(NSZone *)zone
{
   SemBDSController* ctrl = [[[self class] allocWithZone:zone] initSemBDSController:_tracer andSolver:_solver];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}
@end

