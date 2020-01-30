//
//  branchAndBoundUtilities.h
//  Clo
//
//  Created by Rémy Garcia on 29/01/2020.
//

#import <ORFoundation/ORTrail.h>
#import "rationalUtilities.h"

@protocol ORModel;
@protocol ORVar;

@interface SolWrapper : NSObject {
   id<ORSolution> _sol;
}
-(id)init:(id<ORSolution>)s;
-(void)set:(id<ORSolution>)s;
-(id<ORSolution>)get;
-(void)print:(id<ORModel>)m for:(NSString*)title;
@end

extern bool RUN_IMPROVE_GUESS;
extern bool RUN_DISCARDED_BOX;
extern bool IS_GUESS_ERROR_SOLVER;

extern id<ORRational> boundDiscardedBoxes;

extern int nbBoxGenerated;
extern int nbBoxExplored;
extern NSDate *branchAndBoundStart;
extern NSDate *branchAndBoundTime;
extern double boxCardinality;
extern TRInt limitCounter;
extern int nbConstraint;

extern SolWrapper* solution;

static inline ORFloat randomValue(ORFloat min, ORFloat max) {
   return (max - min) * ((float)drand48()) + min;
}
static inline ORDouble randomValueD(ORDouble min, ORDouble max) {
   return (max - min) * (drand48()) + min;
}

static inline ORDouble next_power_of_two(ORDouble value, ORInt next) {
    ORInt exp;
    frexp(value, &exp);
    if(next){
            return ldexp(1, exp);
    } else {
            return ldexp(1, exp-1);
    }
}
