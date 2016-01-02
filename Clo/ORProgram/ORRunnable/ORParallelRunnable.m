//
//  ORParallelRunnable.m
//  Clo
//
//  Created by Daniel Fontaine on 1/15/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import "ORParallelRunnable.h"
#import "ORModelI.h"
#import "ORConcurrencyI.h"
#import <ORProgram/ORSolution.h>

#define CPR_DONE    0
#define CPR_RUNNING 1

@interface CPRComponent : NSObject {
   id<ORRunnable>    _c;  // the worker
   NSConditionLock* _cl;  // the condition to end
}
-(id)init:(id<ORRunnable>)w;
-(id<ORRunnable>)runnable;
-(void)dealloc;
-(void)join;
-(void)notifyDone;
@end

@implementation CPRComponent
-(id)init:(id<ORRunnable>)w
{
   self = [super init];
   _c   = w;
   _cl  = [[NSConditionLock alloc] initWithCondition:CPR_RUNNING];
   return self;
}
-(id<ORRunnable>)runnable
{
   return _c;
}
-(void)dealloc
{
   [_cl release];
   [super dealloc];
}
-(void)join
{
   [_cl lockWhenCondition:CPR_DONE];
   [_cl unlock];
}
-(void)notifyDone
{
   [_cl lockWhenCondition:CPR_RUNNING];
   [_cl unlockWithCondition:CPR_DONE];
}
-(void)start:(id<ORVoidInformer>)stop
{
   [stop whenNotifiedDo:^ {
      [_c cancelSearch];
   }];
   [_c start];
   [stop notify];
   [self notifyDone];
}
-(void)cancelSearch
{
   NSLog(@"Asking for a cancellation...");
   [_c cancelSearch];
}
@end

@implementation ORCompleteParallelRunnableI {
   CPRComponent* _r[2];
   id<ORSolutionPool> _solutionPool;
   ORDouble _bestBound;
   id<ORRunnable> _solvedRunnable;
   id<ORVoidInformer> _stop;
}

-(id) initWithPrimary: (id<ORRunnable>)r0 secondary: (id<ORRunnable>)r1 {
   if((self = [super initWithModel: [r0 model]]) != nil) {
      _r[0] = [[CPRComponent alloc] init:r0];
      _r[1] = [[CPRComponent alloc] init:r1];
      _solutionPool = [[ORSolutionPool alloc] init];
      _bestBound = -DBL_MAX;
      _solvedRunnable = nil;
      _stop = nil;
   }
   return self;
}

-(void) dealloc
{
   [_r[0] release];
   [_r[1] release];
   [_solutionPool release];
   [super dealloc];
}

-(id<ORModel>) model {
   return [_r[0].runnable model];
}

-(ORDouble) bestBound {
   return _bestBound;
}

-(void) setTimeLimit:(ORFloat)secs {
   [_r[0].runnable setTimeLimit: secs];
   [_r[1].runnable setTimeLimit: secs];
}

-(id<ORSolution>) bestSolution {
   if(_solvedRunnable) return [_solvedRunnable bestSolution];
   return nil;
}

-(id<ORRunnable>) solvedRunnable
{
   return  _solvedRunnable;
}

-(void) run
{  
   _stop = [ORConcurrency voidInformer];
   [NSThread detachNewThreadSelector:@selector(start:) toTarget:_r[0] withObject:_stop];
   [NSThread detachNewThreadSelector:@selector(start:) toTarget:_r[1] withObject:_stop];
   [_r[0] join];
   [_r[1] join];
   @synchronized(self) {
      [_stop release];
      _stop = nil;
   }

   id<ORSolution> s0 = [_r[0].runnable bestSolution];
   id<ORSolution> s1 = [_r[1].runnable bestSolution];
   if(s0 && s1) {
      id<ORObjectiveValue> ov0 = s0.objectiveValue;
      id<ORObjectiveValue> ov1 = s1.objectiveValue;
      NSComparisonResult cr = [ov0 compare:ov1];
      _solvedRunnable = cr == NSOrderedAscending ? _r[0].runnable : _r[1].runnable;
      _bestBound = _bestBound = [ov0 best:ov1].doubleValue;
   }
   else if(s0) { _bestBound = [[s0 objectiveValue] doubleValue]; _solvedRunnable = _r[0].runnable; }
   else if(s1) { _bestBound = [[s1 objectiveValue] doubleValue]; _solvedRunnable = _r[1].runnable; }
}

-(id<ORRunnable>) primaryRunnable   { return _r[0].runnable; }
-(id<ORRunnable>) secondaryRunnable { return _r[1].runnable; }

-(void) receiveSolution:(id<ORSolution>)sol
{
   NSLog(@"Sol: %@", [sol description]);
   [_solutionPool addSolution: sol];
}

-(void)cancelSearch
{
   @synchronized(self) {
      if (_stop)
         [_stop notify];
   }
}
@end

