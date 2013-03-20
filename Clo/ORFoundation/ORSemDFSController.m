/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "ORSemDFSController.h"

@implementation ORSemDFSController

- (id) initTheController:(id<ORTracer>)tracer engine:(id<OREngine>)engine
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
   //NSLog(@"SemDFSController %p dealloc called...\n",self);
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
   [_atRoot release];
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
   do {
      ORInt ofs = _sz-1;
      if (ofs >= 0) {
         id<ORCheckpoint> cp = _cpTab[ofs];
         ORStatus status = [_tracer restoreCheckpoint:cp inSolver:_engine];
         //assert(status != ORFailure);
         [cp release];
         NSCont* k = _tab[ofs];
         _tab[ofs] = 0;
         --_sz;
         if (k &&  status != ORFailure) {
            //NSLog(@"backtracking from ORSemDFSController %p",[NSThread currentThread]);
            [k call];
         } else {
            if (k==nil)
               @throw [[ORSearchError alloc] initORSearchError: "Empty Continuation in backtracking"];
            else [k letgo];
         }
      } else
         return;
   } while(true);
}

- (id)copyWithZone:(NSZone *)zone
{
   ORSemDFSController* ctrl = [[[self class] allocWithZone:zone] initTheController:_tracer engine:_engine];
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
      /*
      NSCont* c = _tab[_sz - 1];
      id<ORCheckpoint> cp = _cpTab[_sz - 1];
       */
      --_sz;
      ORHeist* rv = [[ORHeist alloc] initORHeist:c from:cp];
      [cp release];
      return rv;
   } else return nil;
}

-(BOOL)willingToShare
{
   return _sz >= 1;
}
@end

@implementation ORSemDFSControllerCSP
-(void) fail
{
   do {
      ORInt ofs = _sz-1;
      if (ofs >= 0) {
         id<ORCheckpoint> cp = _cpTab[ofs];
         [_tracer restoreCheckpoint:cp inSolver:_engine];
         [cp release];
         NSCont* k = _tab[ofs];
         _tab[ofs] = 0;
         --_sz;
         //NSLog(@"backtracking from ORSemDFSControllerCSP %p",[NSThread currentThread]);
         if (k)
            [k call];
         else {
            if (k==nil)
               @throw [[ORSearchError alloc] initORSearchError: "Empty Continuation in backtracking"];
            else [k letgo];
         }
      } else
         return;
   } while(true);
}
@end

