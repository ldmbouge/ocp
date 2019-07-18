/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORSemBDSController.h>
@class CPEngineI;

@interface BDSStack : NSObject {
   struct BDSNode {
      NSCont*          _cont;
      id<ORCheckpoint>   _cp;
      ORInt            _disc;
      id<ORObjectiveValue> _atCapture;
   };
@private
   struct BDSNode* _tab;
   ORInt        _mx;
   ORInt        _sz;
}
-(id)initBDSStack:(ORInt)mx;
-(void)pushCont:(NSCont*)k cp:(id<ORCheckpoint>)cp discrepancies:(ORInt)d ov:(id<ORObjectiveValue>)ov;
-(void)push:(struct BDSNode)n;
-(struct BDSNode)pop;
-(struct BDSNode)steal;
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
-(void)pushCont:(NSCont*)k cp:(id<ORCheckpoint>)cp discrepancies:(ORInt)d ov:(id<ORObjectiveValue>)ov
{
   //NSLog(@"push size: %d cp : %@",_sz,cp);
   if (_sz >= _mx) {
      _mx <<= 1;      
      _tab = realloc(_tab,sizeof(struct BDSNode)* _mx);
   }   
   _tab[_sz] = (struct BDSNode){k,cp,d,ov};
   ++_sz;
}
-(void)push:(struct BDSNode)n
{
    if (_sz >= _mx) {
        _mx <<= 1;
        _tab = realloc(_tab,sizeof(struct BDSNode)* _mx);
    }
    _tab[_sz++] = n;
}

-(struct BDSNode)pop
{
   // we pick the first checkpoint + continuation
   // the continuation should not be administrative one
   // pack the tab again and return the node.
/*   ORInt selection = -1;
   for(ORInt i=0;i<_sz;i++) {
      if (!_tab[i]._cont.admin) {
         selection = i;
         break;
      }
   }
   if (selection != -1) {
      struct BDSNode stolen = _tab[selection];
      _sz--;
      //NSLog(@"pop size: %d cp : %@",_sz,stolen._cp);
      for(ORInt i=selection;i < _sz;i++)
         _tab[i] = _tab[i+1];
      return stolen;
   } else {
      struct BDSNode stolen = {nil,nil,0,nil};
      return stolen;
 } */
    return _tab[--_sz];
}
-(struct BDSNode)steal
{
   ORInt selection = -1;
   for(ORInt i=0;i<_sz;i++) {
      if (!_tab[i]._cont.admin) {
         selection = i;
         break;
      }
   }
   if (selection != -1) {
      struct BDSNode stolen = _tab[selection];
      _sz--;
      for(ORInt i=selection;i < _sz;i++)
         _tab[i] = _tab[i+1];
      return stolen;
   } else {
      struct BDSNode stolen = {nil,nil,0,nil};
      return stolen;
   }
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

@interface ORDiscrepancy : NSObject {
   ORInt _bound;
}
-(id)initWith:(ORInt)b;
-(id)init;
-(void)setBound:(ORInt)b;
-(ORInt)bound;
@end

@implementation ORDiscrepancy
-(id)initWith:(ORInt)b
{
   self = [super init];
   _bound = b;
   return self;
}
-(id)init
{
   self = [super init];
   _bound = 0;
   return self;
}
-(void)setBound:(ORInt)b
{
   _bound = b;
}
-(ORInt)bound
{
   return _bound;
}
-(NSString*)description
{
   return [[[NSString alloc] initWithFormat:@"%d",_bound] autorelease];
}
@end

@implementation ORSemBDSController {
   BDSStack*             _tab;
   BDSStack*            _next;
   ORDiscrepancy*    _maxDisc;
   ORInt              _nbDisc;
   SemTracer*         _tracer;
   id<ORCheckpoint>   _atRoot;
   id<ORSearchEngine> _solver;
   id<ORPost>          _model;
   ORInt               _nextD;
   ORInt               _initD;
}

- (id) initTheController:(id<ORTracer>)tracer engine:(id<ORSearchEngine>)engine posting:(id<ORPost>)model
{
   return [self initTheController:tracer engine:engine posting:model];
}

- (id) initTheController:(id<ORTracer>)tracer engine:(id<ORSearchEngine>)engine posting:(id<ORPost>)model withDisc:(ORInt) nb incr:(ORInt) inc
{
   self = [super initORDefaultController];
   _tracer = [tracer retain];
   _solver = engine;
   _model = model;
   _tab  = [[BDSStack alloc] initBDSStack:32];
   _next = [[BDSStack alloc] initBDSStack:32];
   _nbDisc = 0;
   _maxDisc = [[ORDiscrepancy alloc] initWith:nb];
   _nextD = inc;
   _initD = inc;
   return self;
}

- (void) dealloc
{
   //NSLog(@"SemBDSController dealloc called...\n");
   [_tracer release];
   [_tab release];
   [_next release];
   [_maxDisc release];
   [super dealloc];
}
+(id<ORSearchController>)protoWithDisc:(ORInt) nb times:(ORInt) t
{
   return [[ORSemBDSController alloc] initTheController:nil engine:nil posting:nil withDisc:nb incr:t];
}
+(id<ORSearchController>)proto
{
   return [[ORSemBDSController alloc] initTheController:nil engine:nil posting:nil withDisc:0 incr:2];
}
- (id)copyWithZone:(NSZone *)zone
{
   ORSemBDSController* ctrl = [[[self class] allocWithZone:zone] initTheController:_tracer engine:_solver posting:_model withDisc:_initD incr:_nextD];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}
-(id<ORSearchController>)clone
// Clone makes a shallow copy (takes a reference) to the bound on the maximum # of discrepancies. That's different from
// copy makes a deep copy of the bound (good for thread separation). 
{
   ORSemBDSController* c = [[ORSemBDSController alloc] initTheController:_tracer engine:_solver posting:_model withDisc:_initD incr:_nextD];
   c->_atRoot = [_atRoot grab];
   [c->_maxDisc release];
   c->_maxDisc = [_maxDisc retain];  // sharing accross instantiation of this proto.
   return c;
}
-(id<ORSearchController>)tuneWith:(id<ORTracer>)tracer engine:(id<ORSearchEngine>)engine pItf:(id<ORPost>)pItf
{
   [_tracer release];
   _tracer = [tracer retain];
   _solver = engine;
   _model  = pItf;
   return self;
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
    
//   if (_nbDisc + 1 < _maxDisc.bound)
//      NSLog(@"adding snaphot to current wave: %d - %@ - %@",_nbDisc+1,_maxDisc,snap);
//   else
//      NSLog(@"adding snaphot to next    wave: %@",snap);

   id<ORObjectiveValue> ov = [[_solver objective] primalValue];
   if (_nbDisc + 1 < _maxDisc.bound)
      [_tab  pushCont:k cp:snap discrepancies:_nbDisc+1 ov:ov];
   else [_next pushCont:k cp:snap discrepancies:_nbDisc+1 ov:ov];
   return -1;
}
-(void) fail
{
   do {
      if ([_tab empty] && [_next empty])
         return;  // Nothing left to process. Go back!
      else {
         if ([_tab empty]) {
            NSLog(@"**************************** next wave: [%d] #failure [%d]",[_next size], [((CPEngineI*)_solver) nbFailures]);
//            NSLog(@"**************************** next wave: [%d]",[_next size]);
/*            BDSStack* tmp = _tab;
            _tab = _next;
            _next = tmp;
 */
             while (_next.size > 0)
                 [_tab push:_next.pop];
            [_maxDisc setBound:_maxDisc.bound * 5];
         }
         //NSLog(@"BDSStack -- fail call -- : %d %d",_tab.size,_next.size);
         struct BDSNode node = [_tab pop];
         _nbDisc = node._disc;
         //NSLog(@"Restoring: %@", node._cp);
         ORStatus status = [_tracer restoreCheckpoint:node._cp inSolver:_solver model:_model];
         [node._cp letgo];
         //NSLog(@"BDS restoreCheckpoint status is: %d for thread %p admin? %d",status,[NSThread currentThread],node._cont.admin);
         if (node._cont &&  (node._cont.admin || status != ORFailure))
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

-(ORHeist*)steal
{
   if ([_next size] >=1) {
      struct BDSNode node = [_next steal];
      if (node._cont == nil)
         return  nil;
      ORHeist* rv = [[ORHeist alloc] init:node._cont from:node._cp oValue:node._atCapture];
      //[node._cont letgo];  // [ldm] no longer in the controller
      [node._cp letgo];  // [ldm] no longer in the controller
      return rv;
   } else return nil;
}

-(ORBool)willingToShare
{
   return [_next size] >= 20;
}
@end
