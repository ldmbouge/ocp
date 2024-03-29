/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORSemDFSController.h>

@implementation ORSemDFSController {
@protected
   NSCont**            _tab;
   ORInt                _sz;
   ORInt                _mx;
   id<ORCheckpoint>* _cpTab;
   SemTracer*       _tracer;
   id<ORCheckpoint> _atRoot;
   id<ORSearchEngine>     _engine;
   id<ORPost>        _model;
}

- (id) initTheController:(id<ORTracer>)tracer engine:(id<ORSearchEngine>)engine posting:(id<ORPost>)model
{
   self = [super initORDefaultController];
   _tracer = [tracer retain];
   _engine = engine;
   _model  = model;
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
   [_model release];
   [super dealloc];
}
+(id<ORSearchController>)proto
{
   return [[ORSemDFSController alloc] initTheController:nil engine:nil posting:nil];
}
-(id<ORSearchController>)clone
{
   ORSemDFSController* c = [[ORSemDFSController alloc] initTheController:_tracer engine:_engine posting:_model];
   c->_atRoot = [_atRoot grab];
   free(c->_tab);
   free(c->_cpTab);
   c->_tab = malloc(sizeof(NSCont*)*_mx);
   c->_cpTab = malloc(sizeof(id<ORCheckpoint>)*_mx);
   for(ORInt k=0;k<_sz;k++) {
      c->_tab[k]   = [_tab[k] grab];
      c->_cpTab[k] = [_cpTab[k] grab];
   }
   c->_sz = _sz;
   c->_mx = _mx;
   return c;
}
-(id<ORSearchController>)tuneWith:(id<ORTracer>)tracer engine:(id<ORSearchEngine>)engine pItf:(id<ORPost>)pItf
{
   [_tracer release];
   _tracer = [tracer retain];
   _engine = engine;
   _model  = pItf;
   return self;
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
      [_cpTab[_sz] letgo];
   }
   [_tracer restoreCheckpoint:_atRoot inSolver:_engine model:_model];
   [_atRoot letgo];
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
         ORStatus status = [_tracer restoreCheckpoint:cp inSolver:_engine model:_model];
         [cp letgo];
         NSCont* k = _tab[ofs];
         _tab[ofs] = 0;
         --_sz;
         if (k &&  (k.admin || status != ORFailure)) {
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

-(void) fail: (ORBool) pruned
{
   [self fail];
}

- (id)copyWithZone:(NSZone *)zone
{
   ORSemDFSController* ctrl = [[[self class] allocWithZone:zone] initTheController:_tracer engine:_engine posting:_model];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}

-(ORHeist*)steal
{
   if (_sz >= 1) {
//      NSCont* c = _tab[_sz - 1];
//      id<ORCheckpoint> cp = _cpTab[_sz -1];
      ORInt selection = -1;
      for(ORInt i=0;i<_sz;i++) {
         if (!_tab[i].admin) {
            selection = i;
            break;
         }
      }
      if (selection != -1) {
         NSCont* c           = _tab[selection];
         id<ORCheckpoint> cp = _cpTab[selection];
         for(ORInt i=selection + 1;i<_sz;i++) {
            _tab[i-1] = _tab[i];
            _cpTab[i-1] = _cpTab[i];
         }
         --_sz;
         id<ORObjectiveValue> pb = [[_engine objective] primalValue];
         ORHeist* rv = [[ORHeist alloc] init:c from:cp oValue:pb];
         [pb release]; // needed to avoid leak.
         [cp letgo];
         return rv;
      } else return nil;
   } else return nil;
}

-(ORBool)willingToShare
{
   BOOL some = _sz >= 4;
   for(ORInt i=0;i<_sz;i++)
      if (!_tab[i].admin)
         return some;
   return NO;
   //some = some && [_cpTab[0] sizeEstimate] < 10;
   //return some;
}
@end

@implementation ORSemDFSControllerCSP
+(id<ORSearchController>)proto
{
   return [[ORSemDFSControllerCSP alloc] initTheController:nil engine:nil posting:nil];
}
-(void) fail
{
   do {
      ORInt ofs = _sz-1;
      if (ofs >= 0) {
         id<ORCheckpoint> cp = _cpTab[ofs];
         [_tracer restoreCheckpoint:cp inSolver:_engine model:_model];
         [cp letgo];
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

