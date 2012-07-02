/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPError.h"
#import "SemDFSController.h"
#import "CPTracer.h"


@implementation SemDFSController 

- (id) initSemController:(id<CPTracer>)tracer andSolver:(id<CPSolver>)solver
{
   self = [super initCPDefaultController];
   _tracer = [tracer retain];
   _solver = solver;
   _mx  = 100;
   _tab = malloc(sizeof(NSCont*)* _mx);
   _cpTab = malloc(sizeof(Checkpoint*)*_mx);
   _sz  = 0;
   return self;
}

- (void) dealloc
{
   //NSLog(@"SemDFSController dealloc called...\n");
   [_tracer release];
   free(_tab);
   for(CPInt i = 0;i  < _sz;i++)
      [_cpTab[i] release];
   free(_cpTab);
   [super dealloc];
}
-(void)setup
{
   _atRoot = [_tracer captureCheckpoint];
}
-(void) cleanup
{
   while (_sz > 0) {
      _sz -= 1;
      [_tab[_sz] letgo];
      [_cpTab[_sz] release];
   }
   [_tracer restoreCheckpoint:_atRoot inSolver:_solver];
}

-(CPInt) addChoice: (NSCont*)k 
{
   if (_sz >= _mx) {
      _tab = realloc(_tab,sizeof(NSCont*)*_mx*2);
      _cpTab = realloc(_cpTab,sizeof(Checkpoint*)*_mx*2);
      _mx <<= 1;      
   }
   _tab[_sz]   = k;
   _cpTab[_sz] = [_tracer captureCheckpoint];
   /*
   id arp = [NSAutoreleasePool new];
   [self newChoice:_cpTab[_sz] onSolver:_solver];
   [arp release];
    */
   _sz++;
   return [_cpTab[_sz-1] nodeId];
}
-(void) fail
{
   CPInt ofs = _sz-1;
   if (ofs >= 0) {      
      Checkpoint* cp = _cpTab[ofs];
      [_tracer restoreCheckpoint:cp inSolver:_solver];
      [cp release];
      NSCont* k = _tab[ofs];
      _tab[ofs] = 0;
      --_sz;
      if (k!=NULL) 
         [k call];      
      else {
      	@throw [[CPSearchError alloc] initCPSearchError: "Empty Continuation in backtracking"];
      }
   }
}

- (id)copyWithZone:(NSZone *)zone
{
   SemDFSController* ctrl = [[[self class] allocWithZone:zone] initSemController:_tracer andSolver:_solver];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}

-(CPHeist*)steal
{
   if (_sz >= 1) {
      NSCont* c      = _tab[0];
      Checkpoint* cp = _cpTab[0];
      for(CPInt i=1;i<_sz;i++) {
         _tab[i-1] = _tab[i];
         _cpTab[i-1] = _cpTab[i];
      }
      --_sz;
      CPHeist* rv = [[CPHeist alloc] initCPProblem:c from:cp];
      [c release];
      [cp release];
      return rv;
   } else return nil;
}

-(BOOL)willingToShare
{
   return _sz >= 1;
}

@end

