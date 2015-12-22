/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORSemFDSController.h>

@interface FDSNode : NSObject {
   NSCont*              _k;
   id<ORCheckpoint> _state;
}
-(id)init:(NSCont*)k state:(id<ORCheckpoint>)cp;
-(id<ORCheckpoint>)state;
-(NSCont*)control;
@end

@implementation FDSNode
-(id)init:(NSCont*)k state:(id<ORCheckpoint>)cp
{
   self = [super init];
   _k = k;
   _state = cp;
   return self;
}
-(id<ORCheckpoint>)state
{
   return _state;
}
-(NSCont*)control
{
   return _k;
}
@end

@implementation ORSemFDSController {
@protected
   NSCont**              _tab;
   ORInt                  _sz;
   ORInt                  _mx;
   id<ORCheckpoint>*   _cpTab;
   SemTracer*         _tracer;
   id<ORCheckpoint>   _atRoot;
   id<ORSearchEngine> _engine;
   id<ORPost>          _model;
   ORPQueue*         _pending;
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
   _pending = [[ORPQueue alloc] init:^BOOL(NSNumber* a,NSNumber* b) {
      double diff = [a doubleValue] - [b doubleValue];
      return diff < 0;
   }];
   return self;
}

- (void) dealloc
{
   NSLog(@"SemFDSController %p dealloc called...\n",self);
   [_tracer release];
   free(_tab);
   for(ORInt i = 0;i  < _sz;i++)
      [_cpTab[i] release];
   free(_cpTab);
   [_pending release];
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
-(void)exitTryLeft
{
   NSCont* k = [NSCont takeContinuation];
   if ([k nbCalls] == 0) {
      id<ORCheckpoint> state = [_tracer captureCheckpoint];
      FDSNode* theNode = [[FDSNode alloc] init:k state:state];
      [_pending insertObject:theNode withKey:[NSNumber numberWithDouble:0.0]];
      [theNode release];
      [self fail];
   } else {
      [k letgo];
      //NSLog(@"Running left branch with %p\n",k);
   }
}
-(void)exitTryRight
{
   NSCont* k = [NSCont takeContinuation];
   if ([k nbCalls] == 0) {
      id<ORCheckpoint> state = [_tracer captureCheckpoint];
      FDSNode* theNode = [[FDSNode alloc] init:k state:state];
      [_pending insertObject:theNode withKey:[NSNumber numberWithDouble:0.0]];
      [theNode release];
      [self fail];
   } else {
      [k letgo];
      //NSLog(@"Running right branch with %p\n",k);
   }
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
         if (k &&  status != ORFailure) {
            [k call];
         } else {
            if (k==nil)
               @throw [[ORSearchError alloc] initORSearchError: "Empty Continuation in backtracking"];
            else [k letgo];
         }
      } else {
         //NSLog(@"Branches depleted... Pull from the pending queue");
         if ([_pending empty])
            return;
         FDSNode* bestNode = [_pending extractBest];
         NSCont* resume = bestNode.control;
         [_tracer restoreCheckpoint:bestNode.state inSolver:_engine model:_model];
         [bestNode release];
         [resume call];
      }
   } while(true);
}

-(void) fail: (ORBool) pruned
{
   [self fail];
}

- (id)copyWithZone:(NSZone *)zone
{
   id<ORSearchController> ctrl = [[[self class] allocWithZone:zone] initTheController:_tracer
                                                                               engine:_engine
                                                                              posting:_model];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}
-(ORHeist*)steal
{
   return nil;
}
-(ORBool)willingToShare
{
   return NO;
}
@end


