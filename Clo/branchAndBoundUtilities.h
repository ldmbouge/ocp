//
//  branchAndBoundUtilities.h
//  Clo
//
//  Created by Rémy Garcia on 29/01/2020.
//

#import <ORFoundation/ORTrail.h>
#import "rationalUtilities.h"

@protocol CPEngine;
@protocol CPRationalVar;

@interface SolWrapper : NSObject {
   id<ORSolution> _sol;
}
-(id)init:(id<ORSolution>)s;
-(void)set:(id<ORSolution>)s;
-(id<ORSolution>)get;
-(void)print:(NSArray*)variables for:(NSString*)title;
-(void)print:(NSArray*)variables with:(id<ORSolution>)s for:(NSString*)title;
@end

@interface ORGammaError : NSObject  {
   NSMutableDictionary* _dic;
}
- (id)init;
- (void) dealloc;
- (id)concretizeError:(NSUInteger)index;
- (id)concretizeValue:(NSUInteger)index;
- (id)saveError:(id<CPRationalVar>)error of:(NSUInteger)index;
- (id)saveValue:(id<CPRationalVar>)value of:(NSUInteger)index;
- (NSString*)description;
@end

extern ORBool RUN_IMPROVE_GUESS;
extern ORBool RUN_DISCARDED_BOX;
extern ORBool RUN_3B_ERROR;


extern id<CPEngine> errorGroup;
extern ORGammaError* _gammaE;
// Save print of best solution for primal
extern NSMutableString* primalSolution;


extern id<ORRational> boundDiscardedBoxes;
extern id<ORRational> boundDegeneratedBoxes;
extern id<ORRational> boundTopOfQueue;
extern id<ORRational> boundRatioOfTwoBoxes;

extern NSDate *branchAndBoundStart;
extern NSDate *branchAndBoundTime;
extern ORDouble boxCardinality;
extern TRInt limitCounter;
extern TRInt indexSplit;
extern ORInt nbConstraint;

extern ORInt nbBoxExplored;
extern ORInt nbBoxGenerated;

static inline ORFloat randomValue(ORFloat min, ORFloat max)
{
   return (max - min) * ((ORFloat)drand48()) + min;
}
static inline ORDouble randomValueD(ORDouble min, ORDouble max)
{
   return (max - min) * (drand48()) + min;
}

static inline id<ORRational> halfUlpOfD(ORDouble v)
{
   id<ORRational> vQ = [[ORRational alloc] init];
   id<ORRational> vQNext = [[ORRational alloc] init];
   id<ORRational> two = [[ORRational alloc] init];
   id<ORRational> hUlp = [[[ORRational alloc] init] autorelease];
   [vQ set_d: v];
   [vQNext set_d: nextafter(v, +INFINITY)];
   [two set_d: 2.0];
   
   [hUlp set: [[vQNext sub: vQ] div: two]];
   
   [vQ release];
   [vQNext release];
   [two release];
   
   return hUlp;
}

static inline id<ORRational> halfUlpOf(ORFloat v)
{
   id<ORRational> vQ = [[ORRational alloc] init];
   id<ORRational> vQNext = [[ORRational alloc] init];
   id<ORRational> two = [[ORRational alloc] init];
   id<ORRational> hUlp = [[[ORRational alloc] init] autorelease];
   [vQ set_d: v];
   [vQNext set_d: nextafterf(v, +INFINITY)];
   [two set_d: 2.0f];
   
   [hUlp set: [[vQNext sub: vQ] div: two]];
   
   [vQ release];
   [vQNext release];
   [two release];
   
   return hUlp;
}
