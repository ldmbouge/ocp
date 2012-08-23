/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "ORSemDFSController.h"

@implementation ORSemDFSController

- (id) initTheController:(id<ORSolver>)solver
{
   self = [super initORDefaultController];
   _tracer = [[solver tracer] retain];
   _engine = [solver engine];
   _mx  = 64;
   _tab = malloc(sizeof(NSCont*)* _mx);
   _cpTab = malloc(sizeof(id<ORCheckpoint>)*_mx);
   _sz  = 0;
   return self;
}

- (id) initSemController:(id<ORTracer>)tracer engine:(id<OREngine>)engine
{
   self = [super initORDefaultController];
   _tracer = [tracer retain];
   _engine = engine;
   _mx  = 64;
   _tab = malloc(sizeof(NSCont*)* _mx);
   _cpTab = malloc(sizeof(id<ORCheckpoint>)*_mx);
   _sz  = 0;
   return self;
}

- (void) dealloc
{
   //NSLog(@"SemDFSController dealloc called...\n");
   [_tracer release];
   free(_tab);
   for(ORInt i = 0;i  < _sz;i++)
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
   [_tracer restoreCheckpoint:_atRoot inSolver:_engine];
}

-(ORInt) addChoice: (NSCont*)k 
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
-(void) trust
{
   [_tracer trust];
}
-(void) fail
{
   ORInt ofs = _sz-1;
   if (ofs >= 0) {      
      id<ORCheckpoint> cp = _cpTab[ofs];
      [_tracer restoreCheckpoint:cp inSolver:_engine];
      [cp release];
      NSCont* k = _tab[ofs];
      _tab[ofs] = 0;
      --_sz;
      if (k!=NULL) 
         [k call];      
      else {
      	@throw [[ORSearchError alloc] initORSearchError: "Empty Continuation in backtracking"];
      }
   }
}

- (id)copyWithZone:(NSZone *)zone
{
   ORSemDFSController* ctrl = [[[self class] allocWithZone:zone] initSemController:_tracer engine:_engine];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}

-(ORHeist*)steal
{
   if (_sz >= 1) {
      NSCont* c           = _tab[0];
      id<ORCheckpoint> cp = _cpTab[0];
      for(ORInt i=1;i<_sz;i++) {
         _tab[i-1] = _tab[i];
         _cpTab[i-1] = _cpTab[i];
      }
      --_sz;
      ORHeist* rv = [[ORHeist alloc] initORHeist:c from:cp];
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

