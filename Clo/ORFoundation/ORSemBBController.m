//
//  ORSemBBController.m
//  ORFoundation
//
//  Created by Rémy Garcia on 25/02/2019.
//

#import <ORFoundation/ORSemBBController.h>
#import <ORUtilities/ORPQueue.h>
#import <ORFoundation/ORConstraint.h>
#import <ORFoundation/ORConstraintI.h>

@interface BBKey : NSObject {
@public
   id<ORObjectiveValue> _v;
   //int              _depth;
   double           _depth;
}
//-(id)init:(id<ORObjectiveValue>)v withDepth:(int)d;
-(id)init:(id<ORObjectiveValue>)v withDepth:(double)d;
-(id<ORObjectiveValue>)getValue;
-(NSString*)description;
-(void)dealloc;
-(id<ORObjectiveValue>)bound;
@end

@interface BBNode : NSObject {
   NSCont*           _k;
   id<ORCheckpoint> _cp;
}
-(id)init:(NSCont*)k checkpoint:(id<ORCheckpoint>)cp;
-(NSCont*)cont;
-(id<ORCheckpoint>)cp;
@end

@implementation BBKey

//+(BBKey*)key:(id<ORObjectiveValue>)v withDepth:(int)d
//{
//   BBKey* k  = [BBKey alloc];
//   k->_v     = [[ORObjectiveValueRationalI alloc] initObjectiveValueRationalI: [v rationalValue] minimize: [v direction] == 1]; //v; // [v retain];
//   k->_depth = d;
//   return k;
//}
+(BBKey*)key:(id<ORObjectiveValue>)v withDepth:(double)d
{
   BBKey* k  = [BBKey alloc];
   k->_v     = [[ORObjectiveValueRationalI alloc] initObjectiveValueRationalI: [v rationalValue] minimize: [v direction] == 1]; //v; // [v retain];
   k->_depth = d;
   return k;
}
//-(BBKey*)init:(id<ORObjectiveValue>)v withDepth:(int)d
//{
//   self = [super init];
//   _v = [[[ORObjectiveValueRationalI alloc] initObjectiveValueRationalI: [v rationalValue] minimize: [v direction] == 1] retain];
//   _depth = d;
//   return self;
//}
-(BBKey*)init:(id<ORObjectiveValue>)v withDepth:(double)d
{
   self = [super init];
   _v = [[[ORObjectiveValueRationalI alloc] initObjectiveValueRationalI: [v rationalValue] minimize: [v direction] == 1] retain];
   _depth = d;
   return self;
}
-(id<ORObjectiveValue>)getValue
{
   return _v;
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
   [buf appendFormat:@"%@ - %f",_v,_depth];
   return buf;
}

@end

@implementation BBNode
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

@implementation ORSemBBController {
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
   _cp     = NULL;
   _buf    = [[ORPQueue alloc] init:^BOOL(BBKey* a,BBKey* b) {
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
   return [[ORSemBBController alloc] initTheController:nil engine:nil posting:nil];
}
-(id<ORSearchController>)clone
{
   ORSemBBController* c = [[ORSemBBController alloc] initTheController:_tracer engine:_engine posting:_model];
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
      BBNode* nd = [_buf extractBest];
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
   BBNode* node = [[BBNode alloc] init:k checkpoint:cp];
   //ORInt depth;
   //ORInt primalBound = 1000 * frexp([[[[_engine objective] primalBound] rationalValue] get_d], &depth);
   //BBKey* ov = [BBKey key:[[_engine objective] dualValue] withDepth:[_tracer level]];
   BBKey* ov = [BBKey key:[[_engine objective] dualValue] withDepth:boxCardinality];
   [_buf insertObject:node withKey:ov];
   //NSLog(@"%@ -- %@", node, ov);
   //NSLog(@"BUF: %d", [_buf size]);
   //NSLog(@"_buf: %@", _buf);
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
-(void)startTryLeft
{
}
-(void)startTryRight
{
}
-(void)exitTryLeft
{
   NSCont* k = [NSCont takeContinuation];
   branchAndBoundTime = [NSDate date];
   NSLog(@"L: %d/%d -- %.3fs", limitCounter._val, nbConstraint, [branchAndBoundTime timeIntervalSinceDate:branchAndBoundStart]);
   if ([k nbCalls] == 0) {
      if(limitCounter._val < nbConstraint){
      [self makeAndRecordNode:k];
      NSCont* back = _k;
      _k = NULL;
      [_tracer restoreCheckpoint:_cp inSolver:_engine model:_model];
      [_cp letgo];
      _cp = NULL;
      _k  = NULL;
      [back call];
      }  else {
         nbBoxDone++;
         if([[[[_engine objective] dualValue] rationalValue] gt: boundDiscardedBoxes])
            [boundDiscardedBoxes set:[[[_engine objective] dualValue] rationalValue]];
         [k letgo];
        }
   } else {
      [k letgo];
   }
}
-(void)exitTryRight
{
   NSCont* k = [NSCont takeContinuation];
   branchAndBoundTime = [NSDate date];
   NSLog(@"R: %d/%d -- %.3fs", limitCounter._val, nbConstraint, [branchAndBoundTime timeIntervalSinceDate:branchAndBoundStart]);
   if ([k nbCalls] == 0) {
      if(limitCounter._val < nbConstraint){
         [self makeAndRecordNode:k];
         [self fail];
      } else {
         nbBoxDone++;
         if([[[[_engine objective] dualValue] rationalValue] gt: boundDiscardedBoxes])
            [boundDiscardedBoxes set:[[[_engine objective] dualValue] rationalValue]];
         [self fail];
      }
   } else {
      [k letgo];
   }
}

-(void) trust
{
   [_tracer trust];
   [_tracer pushNode];
}

NSString * const ORStatus_toString_BB[] = {
   [ORSuccess] = @"Success",
   [ORSuspend] = @"Suspend",
   [ORFailure] = @"Failure",
   [ORDelay  ] = @"Delay",
   [ORSkip   ] = @"Skip",
   [ORNoop   ] = @"noop"
};

//static long __nbPull = 0;

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
      if (!isEmpty){
         BBKey* bestKey = [[_buf peekAtKey] retain];
         /* skip box if sup of error is less than primalBound */
         if([[[[_engine objective] primalBound] rationalValue] lt: [[[_engine objective] dualBound] rationalValue]]){ //&&
            //([[bestKey.bound rationalValue] geq: [[[_engine objective] primalBound] rationalValue]] ||
             //[boundDiscardedBoxes geq: [[[_engine objective] primalBound] rationalValue]])){
            BBNode* nd = [_buf extractBest];
            
            ORStatus status = [of tightenDualBound:bestKey.bound];
            if (status != ORFailure)
               status = [_tracer restoreCheckpoint:nd.cp inSolver:_engine model:_model];
            //if (__nbPull++ % 100 == 0)
               //NSLog(@"pulling: %@ -- status: %@",bestKey,ORStatus_toString_BB[status]);
            [nd.cp letgo];
            NSCont* k = nd.cont;
            [nd release];
            if (k &&  status != ORFailure) {
               [bestKey release];
               [k call];
            } else {
               [bestKey release];
               if (k==nil)
                  @throw [[ORSearchError alloc] initORSearchError: "Empty Continuation in backtracking"];
               else [k letgo];
            }
         } else {
            NSLog(@"EQUAL BOUND: %@ <  %@", [[_engine objective] primalBound], [[_engine objective] dualBound]);
            NSLog(@"           : %@ >= %@", [bestKey.bound rationalValue], [[_engine objective] primalBound]);
            NSLog(@"           : %@ >= %@", boundDiscardedBoxes, [[_engine objective] primalBound]);
            return;
         }
      } else {
         NSLog(@"EMPTY QUEUE %@", _buf);
         return;
      }
   } while(true);
}

-(void) fail: (ORBool) pruned
{
   [self fail];
}

- (id)copyWithZone:(NSZone *)zone
{
   ORSemBBController* ctrl = [[[self class] allocWithZone:zone] initTheController:_tracer
                                                                           engine:_engine
                                                                          posting:_model];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}

-(ORHeist*)steal
{
   if (![_buf empty]) {
      BBNode* nd = [_buf extractBest];
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
