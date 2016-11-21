/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORBackjumpingDFSController.h"

@class CPLearningEngineI;

@implementation ORBackjumpingDFSController{
@protected
   NSCont**                  _tab;
   ORInt                      _sz;
   ORInt                      _mx;
   id<ORCheckpoint>*       _cpTab;
   SemTracer*             _tracer;
   id<ORCheckpoint>       _atRoot;
   id<ORSearchEngine>     _engine;
   id<ORPost>              _model;
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

+(id<ORSearchController>)proto
{
   return [[ORSemDFSController alloc] initTheController:nil engine:nil posting:nil];
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
//   ORUInt faillevel = [_tracer level];
//   ORUInt level = faillevel;
//   ORUInt jumplevel = (ORUInt)[(CPLearningEngineI*)_engine getBackjumpLevel];
   
//   ORBool retry = (jumplevel != (level - 1));
//   NSLog(@"Backtracking to level %d from level %d",jumplevel, level);
//   NSLog(@"fail at level %d", level);

   do {
      ORInt ofs = _sz-1;
      
      if (ofs >= 0) {
         id<ORCheckpoint> cp = _cpTab[ofs];
         ORStatus status = [_tracer restoreCheckpoint:cp inSolver:_engine model:_model];
         //assert(status != ORFailure);
         [cp letgo];
         NSCont* k = _tab[ofs];
         _tab[ofs] = 0;
         --_sz;
            
//         //Jump back if constraint was learned
//         level = [_tracer level];
//         if (jumplevel < level) {
////)            NSLog(@"Jumping over level %d to level %d",level,jumplevel);
//            [k letgo];
//            continue;
//         }

         if (k &&  status != ORFailure) {
////            NSLog(@"Restarting search at level %d",level);
//            if ((jumplevel != -1) && (level < faillevel-1)){
////               NSLog(@"Retry search at level %d",level);
//               [k callInvisible];
//            }
//            else
               [k call];
         } else {
            if (k==nil)
               @throw [[ORSearchError alloc] initORSearchError: "Empty Continuation in backtracking"];
            else
            [k letgo];
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

//-(ORHeist*)steal
//{
//   if (_sz >= 1) {
//      NSCont* c           = _tab[0];
//      id<ORCheckpoint> cp = _cpTab[0];
//      for(ORInt i=1;i<_sz;i++) {
//         _tab[i-1] = _tab[i];
//         _cpTab[i-1] = _cpTab[i];
//      }
//      /*
//       NSCont* c = _tab[_sz - 1];
//       id<ORCheckpoint> cp = _cpTab[_sz - 1];
//       */
//      --_sz;
//      ORHeist* rv = [[ORHeist alloc] initORHeist:c from:cp];
//      [cp letgo];
//      return rv;
//   } else return nil;
//}

-(ORBool)willingToShare
{
   BOOL some = _sz >= 2;
   //some = some && [_cpTab[0] sizeEstimate] < 10;
   return some;
}
@end