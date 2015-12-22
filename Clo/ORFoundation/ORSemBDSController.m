/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORSemBDSController.h>

@interface BDSStack : NSObject {
   struct BDSNode {
      NSCont*          _cont;
      id<ORCheckpoint>   _cp;
      ORInt            _disc;
   };
@private
   struct BDSNode* _tab;
   ORInt        _mx;
   ORInt        _sz;
}
-(id)initBDSStack:(ORInt)mx;
-(void)pushCont:(NSCont*)k cp:(id<ORCheckpoint>)cp discrepancies:(ORInt)d;
-(struct BDSNode)pop;
-(ORInt)size;
-(ORBool)empty;
-(NSString*)description;
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
      [_tab[i]._cont letgo];
      [_tab[i]._cp release];
   }
   free(_tab);
   [super dealloc];
}
-(void)pushCont:(NSCont*)k cp:(id<ORCheckpoint>)cp discrepancies:(ORInt)d
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
-(ORBool)empty
{
   return _sz == 0;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"queue(%d)=[",_sz];
   for(ORInt i=0;i<_sz;i++)
      [buf appendFormat:@"%@%c",_tab[i]._cp,(i < _sz - 1) ? ',' : ']'];
   return buf;
}

@end

@implementation ORSemBDSController

- (id) initTheController:(id<ORTracer>)tracer engine:(id<ORSearchEngine>)engine posting:(id<ORPost>)model
{
   self = [super initORDefaultController];
   _tracer = [tracer retain];
   _solver = engine;
   _model = model;
   _tab  = [[BDSStack alloc] initBDSStack:32];
   _next = [[BDSStack alloc] initBDSStack:32];
   _nbDisc = _maxDisc = 0;
   return self;
}

- (void) dealloc
{
   //NSLog(@"SemBDSController dealloc called...\n");
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
   [_tracer restoreCheckpoint:_atRoot inSolver:_solver model:_model];
   [_atRoot letgo];
}

-(ORInt) addChoice: (NSCont*)k 
{
   id<ORCheckpoint> snap = [_tracer captureCheckpoint];
/*
   if (_nbDisc + 1 < _maxDisc)
      NSLog(@"adding snaphot to current wave: %@",snap);
   else
      NSLog(@"adding snaphot to next    wave: %@",snap);
*/
   if (_nbDisc + 1 < _maxDisc)
      [_tab  pushCont:k cp:snap discrepancies:_nbDisc+1];
   else [_next pushCont:k cp:snap discrepancies:_nbDisc+1];
   return -1;
}
-(void) fail
{
   do {
      if ([_tab empty] && [_next empty])
         return;  // Nothing left to process. Go back!
      else {
         if ([_tab empty]) {
            //NSLog(@"next wave: %@",_next);
            BDSStack* tmp = _tab;
            _tab = _next;
            _next = tmp;
            _maxDisc++;
         }
         struct BDSNode node = [_tab pop];
         _nbDisc = node._disc;
         //NSLog(@"********** RESTORING: %@",node._cp);
         ORStatus status = [_tracer restoreCheckpoint:node._cp inSolver:_solver model:_model];
         [node._cp letgo];
         //NSLog(@"BDS restoreCheckpoint status is: %d for thread %p",status,[NSThread currentThread]);
         if (status != ORFailure)
            [node._cont call];
         else
            [node._cont letgo]; // we must deallocate this continuation since it will never be used again.
      }
   } while (true);
}
-(void) fail: (ORBool) pruned
{
   [self fail];
}
-(void) trust
{
   [_tracer pushNode]; // no need to trust the tracer since pushNode automatically trusts
//   [_tracer trust];
}
- (id)copyWithZone:(NSZone *)zone
{
   ORSemBDSController* ctrl = [[[self class] allocWithZone:zone] initTheController:_tracer engine:_solver posting:_model];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}

-(ORHeist*)steal
{
   if ([_next size] >=1) {
      struct BDSNode node = [_next pop];
      ORHeist* rv = [[ORHeist alloc] initORHeist:node._cont from:node._cp];
      //[node._cont letgo];  // [ldm] no longer in the controller
      [node._cp release];  // [ldm] no longer in the controller
      return rv;
   } else return nil;
}

-(ORBool)willingToShare
{
   return [_next size] >= 1;
}
@end
