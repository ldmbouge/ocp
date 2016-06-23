/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORSemBFSController.h>
#import <ORUtilities/ORPQueue.h>

@interface BFSKey : NSObject {
@public
   id<ORObjectiveValue> _v;
   int              _depth;
}
-(id)init:(id<ORObjectiveValue>)v withDepth:(int)d;
-(NSString*)description;
-(void)dealloc;
-(id<ORObjectiveValue>)bound;
@end

@interface BFSNode : NSObject {
   NSCont*           _k;
   id<ORCheckpoint> _cp;
}
-(id)init:(NSCont*)k checkpoint:(id<ORCheckpoint>)cp;
-(NSCont*)cont;
-(id<ORCheckpoint>)cp;
@end

@implementation BFSKey

+(BFSKey*)key:(id<ORObjectiveValue>)v withDepth:(int)d
{
   BFSKey* k = [BFSKey alloc];
   k->_v     = v; // [v retain];
   k->_depth = d;
   return k;
}
-(BFSKey*)init:(id<ORObjectiveValue>)v withDepth:(int)d
{
   self = [super init];
   _v = [v retain];
   _depth = d;
   return self;
}
-(void)dealloc
{
   [_v release];
   [super dealloc];
}
-(id<ORObjectiveValue>)bound
{
   return _v;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"%@ - %d",_v,_depth];
   return buf;
}
@end

@implementation BFSNode
-(id)init:(NSCont*)k checkpoint:(id<ORCheckpoint>)cp
{
   self = [super init];
   _k = k;
   _cp = cp;
   return self;
}
-(NSCont*)cont
{
   return _k;
}
-(id<ORCheckpoint>)cp
{
   return _cp;
}
@end

@implementation ORSemBFSController {
@protected
   ORPQueue*             _buf;
   NSCont*                 _k;
   id<ORCheckpoint>       _cp;
   SemTracer*         _tracer;
   id<ORCheckpoint>   _atRoot;
   id<ORSearchEngine> _engine;
   id<ORPost>          _model;
}
- (id) initTheController:(id<ORTracer>)tracer engine:(id<ORSearchEngine>)engine posting:(id<ORPost>)model
{
   self = [super initORDefaultController];
   _tracer = [tracer retain];
   _engine = engine;
   _model  = model;
   _k      = NULL;
   _buf    = [[ORPQueue alloc] init:^BOOL(BFSKey* a,BFSKey* b) {
      NSComparisonResult cr = [a->_v compare:b->_v];
      switch(cr) {
         case NSOrderedDescending: return true;
         case NSOrderedAscending: return false;
         case NSOrderedSame: {
            return a->_depth > b->_depth;
         }
      }
      //return [a->_v compare:b->_v] == NSOrderedDescending; // GOOD
   }];
   return self;
}
- (void) dealloc
{
   [_tracer release];
   [super dealloc];
}
+(id<ORSearchController>)proto
{
   return [[ORSemBFSController alloc] initTheController:nil engine:nil posting:nil];
}
-(id<ORSearchController>)clone
{
   ORSemBFSController* c = [[ORSemBFSController alloc] initTheController:_tracer engine:_engine posting:_model];
   c->_atRoot = [_atRoot grab];
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
   while (![_buf empty]) {
      BFSNode* nd = [_buf extractBest];
      [nd.cont letgo];
      [nd.cp letgo];
      [nd release];
   }
   [_tracer restoreCheckpoint:_atRoot inSolver:_engine model:_model];
   [_atRoot letgo];
}

-(ORInt) addChoice: (NSCont*)k
{
   _k  = k;
   _cp = [_tracer captureCheckpoint];
   return  0;
}
-(void)makeAndRecordNode:(NSCont*)k
{
   id<ORCheckpoint> cp = [_tracer captureCheckpoint];
   BFSNode* node = [[BFSNode alloc] init:k checkpoint:cp];
   BFSKey* ov    = [BFSKey key:[[_engine objective] dualValue] withDepth:[_tracer level]];
//   BFSKey* ov    = [BFSKey key:[[_engine objective] value] withDepth:[_tracer level]];
   [_buf insertObject:node withKey:ov];
   [ov release];
   [node release];
}
-(void) exitTryallBody
{
   NSCont* k = [NSCont takeContinuation];
   if ([k nbCalls] == 0) {
      [self makeAndRecordNode:k];
      NSCont* back = _k;
      _k = NULL;
      [_tracer restoreCheckpoint:_cp inSolver:_engine model:_model];
      [_cp letgo];
      _cp = NULL;
      _k  = NULL;
      [back call];
   } else {
      [k letgo];
   }
}
-(void)exitTryLeft
{
   NSCont* k = [NSCont takeContinuation];
   if ([k nbCalls] == 0) {
      [self makeAndRecordNode:k];
      NSCont* back = _k;
      _k = NULL;
      [_tracer restoreCheckpoint:_cp inSolver:_engine model:_model];
      [_cp letgo];
      _cp = NULL;
      _k  = NULL;
      [back call];
   } else {
      [k letgo];
   }
}
-(void)exitTryRight
{
   NSCont* k = [NSCont takeContinuation];
   if ([k nbCalls] == 0) {
      [self makeAndRecordNode:k];
      [self fail];
   } else {
      [k letgo];
   }
}

-(void) trust
{
   [_tracer trust];
   [_tracer pushNode];
}

NSString * const ORStatus_toString[] = {
   [ORSuccess] = @"Success",
   [ORSuspend] = @"Suspend",
   [ORFailure] = @"Failure",
   [ORDelay  ] = @"Delay",
   [ORSkip   ] = @"Skip",
   [ORNoop   ] = @"noop"
};

static long __nbPull = 0;

-(void) fail
{
   id<ORSearchObjectiveFunction> of = (id)_engine.objective;
   do {
      if (_k != NULL) {
         NSCont* back = _k;
         [_tracer restoreCheckpoint:_cp inSolver:_engine model:_model];
         [_cp letgo];
         _cp = NULL;
         _k = NULL;
         [back call];
      }
      ORBool isEmpty = [_buf empty];
      if (!isEmpty) {
         BFSKey* bestKey = [[_buf peekAtKey] retain];
         BFSNode* nd = [_buf extractBest];
         
         ORStatus status = [of tightenDualBound:bestKey.bound];
         if (status != ORFailure)
            status = [_tracer restoreCheckpoint:nd.cp inSolver:_engine model:_model];
         if (__nbPull++ % 100 == 0)
            NSLog(@"pulling: %@ -- status: %@",bestKey,ORStatus_toString[status]);
         [nd.cp letgo];
         NSCont* k = nd.cont;
         [nd release];
         [bestKey release];
         if (k &&  status != ORFailure) {
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
   ORSemDFSController* ctrl = [[[self class] allocWithZone:zone] initTheController:_tracer
                                                                            engine:_engine
                                                                           posting:_model];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}

-(ORHeist*)steal
{
   if (![_buf empty]) {
      BFSNode* nd = [_buf extractBest];
      NSCont* c           = nd.cont;
      id<ORCheckpoint> cp = nd.cp;
      [nd release];
      ORHeist* rv = [[ORHeist alloc] init:c from:cp oValue:[[_engine objective] primalValue]];
      [cp letgo];
      return rv;
   } else return nil;
}

-(ORBool)willingToShare
{
   BOOL some = [_buf size] >= 4;
   //some = some && [_cpTab[0] sizeEstimate] < 10;
   return some;
}
@end
