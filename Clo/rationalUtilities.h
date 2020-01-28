//
//  rationalUtilities.h
//  Clo
//
//  Created by remy on 05/04/2018.
//
//

#include "gmp.h"
#include <stdlib.h>
#include <mpfr.h>
#import <ORFoundation/ORObject.h>

typedef mpq_t rational_t;
typedef mpq_ptr rational_ptr;

typedef struct {
   int    _val;   // TRInt should be a 32-bit wide trailable signed integer
   ORUInt _mgc;
} TRInt;

extern int RUN_IMPROVE_GUESS;
extern int RUN_DISCARDED_BOX;
extern int INSIDE_GUESS_ERROR;

extern int nbBoxGenerated;
extern int nbBoxExplored;
extern int stoppingTime;
extern NSDate *branchAndBoundStart;
extern NSDate *branchAndBoundTime;
extern double boxCardinality;
extern TRInt limitCounter;
extern int nbConstraint;
extern int nbBoxDone;
extern bool newBox;
extern bool initLimitCounter;

extern ORBool previousGuessFailed;
extern ORBool repeatOnce;
extern ORBool dirHalfUlp;
extern ORInt indexCurrentVar;
extern ORInt nbVarSet;
extern NSMutableArray *arrayValue;
extern NSMutableArray *arrayError;
extern id<ORSolution> solution;



extern void exitfunc(int sig);


@protocol ORMemoryTrail;
@protocol ORTrail;
@protocol ORVisitor;

@protocol ORRational<ORObject>
-(id)init:(id<ORMemoryTrail>) mt;
-(id)init;
-(void) visit: (id<ORVisitor>) visitor;
-(void)dealloc;  // call clear
-(void)print;
-(rational_ptr)rational;
-(int)type;
-(id<ORMemoryTrail>)mt;
-(id)setNAN;
-(id)setZero;
-(id)setOne;
-(id)setMinusOne;
-(id)setPosInf;
-(id)setNegInf;
-(id)inc;
-(id)dec;
-(BOOL)isNAN;
-(BOOL)isZero;
-(BOOL)isOne;
-(BOOL)isMinusOne;
-(BOOL)isPosInf;
-(BOOL)isNegInf;
-(void)setType:(int)type;
-(void)setRational:(rational_t)rational;
-(id)set:(id<ORRational>)r;
-(id)set_str:(char*)str;
-(id)set_q:(rational_t)r;
-(id)set_t:(int)t;
-(void)trailRational:(id<ORTrail>)trail;
-(void)trailType:(id<ORTrail>)trail;
+(id<ORRational>)rationalWith:(id<ORRational>)r;
+(id<ORRational>)rationalWith_d:(double)d;
-(id)set_d:(double)d;
-(id)set:(long)num and:(long)den;
-(id<ORRational>)get;
-(char*)get_str;
-(double)get_d;
-(float)get_inf_f;
-(float)get_sup_f;
-(double)get_inf_d;
-(double)get_sup_d;
-(id<ORRational>)add:(id<ORRational>)r;
-(id<ORRational>)sub:(id<ORRational>)r;
-(id<ORRational>)mul:(id<ORRational>)r;
-(id<ORRational>)div:(id<ORRational>)r;
-(id<ORRational>)subI:(id<ORRational>)r;
-(id<ORRational>)divI:(id<ORRational>)r;
-(id<ORRational>)neg;
-(id<ORRational>)abs;
-(id<ORRational>)sqrt;
-(BOOL)cmp:(id<ORRational>)r;
-(BOOL)cmp:(long)num and:(long)den;
-(BOOL)lt:(id<ORRational>)r;
-(BOOL)gt:(id<ORRational>)r;
-(BOOL)leq:(id<ORRational>)r;
-(BOOL)geq:(id<ORRational>)r;
-(BOOL)eq:(id<ORRational>)r;
-(BOOL)neq:(id<ORRational>)r;
@end

@protocol ORRationalInterval<ORObject>
-(id)init:(id<ORMemoryTrail>) mt;
-(id)init;
-(void)dealloc;  // call clear
-(id<ORRational>)low;
-(id<ORRational>)up;
-(void)setLow:(id<ORRational>)l;
-(void)setUp:(id<ORRational>)u;
-(void)setChanged:(int)c;
-(int)changed;
-(id)set:(id<ORRationalInterval>)ri;
-(id)set_d:(double)low and:(double)up;
-(id)set_q:(id<ORRational>)low and:(id<ORRational>)up;
-(void)setNAN;
-(void)setZero;
-(void)setPosInf;
-(void)setNegInf;
-(id<ORRationalInterval>)add:(id<ORRationalInterval>)ri;
-(id<ORRationalInterval>)sub:(id<ORRationalInterval>)ri;
-(id<ORRationalInterval>)mul:(id<ORRationalInterval>)ri;
-(id<ORRationalInterval>)div:(id<ORRationalInterval>)ri;
-(id<ORRationalInterval>)neg;
-(id<ORRationalInterval>)abs;
-(id<ORRationalInterval>)sqrt;
-(BOOL)cmp:(id<ORRationalInterval>)ri;
-(BOOL)lt:(id<ORRationalInterval>)ri;
-(BOOL)gt:(id<ORRationalInterval>)ri;
-(BOOL)leq:(id<ORRationalInterval>)ri;
-(BOOL)geq:(id<ORRationalInterval>)ri;
-(BOOL)eq:(id<ORRationalInterval>)ri;
-(BOOL)neq:(id<ORRationalInterval>)ri;
-(BOOL)empty;
-(id<ORRationalInterval>)union:(id<ORRationalInterval>)ri;
-(id<ORRationalInterval>)intersection:(id<ORRationalInterval>)ri;
-(id<ORRationalInterval>)proj_inter:(id<ORRationalInterval>)ri;
-(id<ORRationalInterval>)proj_inter:(id<ORRational>)inf and:(id<ORRational>)sup;
@end

@interface ORRational : ORObject <ORRational> {
   mpq_t _rational;
   /* type :
    -2   -INFINITY
    -1   Negative number
    0   Zero
    1   Positive number
    2   INFINITY
    3   NaN
    */
   int _type;
   id<ORMemoryTrail> _mt;
}
-(id)init:(id<ORMemoryTrail>) mt;
-(id)init;
-(void) visit: (id<ORVisitor>) visitor;
-(void)dealloc;  // call clear
-(void)print;
-(rational_ptr)rational;
-(int)type;
-(id<ORMemoryTrail>)mt;
-(id)setNAN;
-(id)setZero;
-(id)setOne;
-(id)setMinusOne;
-(id)setPosInf;
-(id)setNegInf;
-(id)inc;
-(id)dec;
-(BOOL)isNAN;
-(BOOL)isZero;
-(BOOL)isOne;
-(BOOL)isMinusOne;
-(BOOL)isPosInf;
-(BOOL)isNegInf;
-(void)setType:(int)type;
-(void)setRational:(rational_t)rational;
-(id)set:(id<ORRational>)r;
-(id)set_q:(rational_t)r;
-(id)set_t:(int)t;
-(void)trailRational:(id<ORTrail>)trail;
-(void)trailType:(id<ORTrail>)trail;
+(id<ORRational>)rationalWith:(id<ORRational>)r;
+(id<ORRational>)rationalWith_d:(double)d;
-(id)set_d:(double)d;
-(id)set:(long)num and:(long)den;
-(id<ORRational>)get;
-(char*)get_str;
-(double)get_d;
-(float)get_inf_f;
-(float)get_sup_f;
-(double)get_inf_d;
-(double)get_sup_d;
-(id<ORRational>)add:(id<ORRational>)r;
-(id<ORRational>)sub:(id<ORRational>)r;
-(id<ORRational>)mul:(id<ORRational>)r;
-(id<ORRational>)div:(id<ORRational>)r;
-(id<ORRational>)subI:(id<ORRational>)r;
-(id<ORRational>)divI:(id<ORRational>)r;
-(id<ORRational>)neg;
-(id<ORRational>)abs;
-(id<ORRational>)sqrt;
-(BOOL)cmp:(id<ORRational>)r;
-(BOOL)cmp:(long)num and:(long)den;
-(BOOL)lt:(id<ORRational>)r;
-(BOOL)gt:(id<ORRational>)r;
-(BOOL)leq:(id<ORRational>)r;
-(BOOL)geq:(id<ORRational>)r;
-(BOOL)eq:(id<ORRational>)r;
-(BOOL)neq:(id<ORRational>)r;
@end

@interface ORRationalInterval : ORObject <ORRationalInterval> {
   id<ORRational> _low;
   id<ORRational> _up;
   int _changed;
}
-(id)init:(id<ORMemoryTrail>) mt;
-(id)init;
-(void)dealloc;  // call clear
-(id<ORRational>)low;
-(id<ORRational>)up;
-(void)setLow:(id<ORRational>)l;
-(void)setUp:(id<ORRational>)u;
-(void)setChanged:(int)c;
-(int)changed;
-(id)set:(id<ORRationalInterval>)ri;
-(id)set_d:(double)low and:(double)up;
-(id)set_q:(id<ORRational>)low and:(id<ORRational>)up;
-(void)setNAN;
-(void)setZero;
-(void)setPosInf;
-(void)setNegInf;
-(id<ORRationalInterval>)add:(id<ORRationalInterval>)ri;
-(id<ORRationalInterval>)sub:(id<ORRationalInterval>)ri;
-(id<ORRationalInterval>)mul:(id<ORRationalInterval>)ri;
-(id<ORRationalInterval>)div:(id<ORRationalInterval>)ri;
-(id<ORRationalInterval>)neg;
-(id<ORRationalInterval>)abs;
-(id<ORRationalInterval>)sqrt;
-(BOOL)cmp:(id<ORRationalInterval>)ri;
-(BOOL)lt:(id<ORRationalInterval>)ri;
-(BOOL)gt:(id<ORRationalInterval>)ri;
-(BOOL)leq:(id<ORRationalInterval>)ri;
-(BOOL)geq:(id<ORRationalInterval>)ri;
-(BOOL)eq:(id<ORRationalInterval>)ri;
-(BOOL)neq:(id<ORRationalInterval>)ri;
-(BOOL)empty;
-(id<ORRationalInterval>)union:(id<ORRationalInterval>)ri;
-(id<ORRationalInterval>)intersection:(id<ORRationalInterval>)ri;
-(id<ORRationalInterval>)proj_inter:(id<ORRationalInterval>)ri;
-(id<ORRationalInterval>)proj_inter:(id<ORRational>)inf and:(id<ORRational>)sup;
@end

static inline id<ORRational> minQ(id<ORRational> a,id<ORRational> b) { return [a lt: b] ? a : b;}
static inline id<ORRational> maxQ(id<ORRational> a,id<ORRational> b) { return [a gt: b] ? a : b;}
static inline void clear_q(rational_t r) { mpq_clear(r); }
static inline void init_q(rational_t r) { mpq_init(r); }
static inline void set_q(rational_t r, rational_t s) { mpq_set(r, s); }
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

extern id<ORRational> boundDiscardedBoxes;


///* START NEW GUESS */
//if (RUN_IMPROVE_GUESS) {
//   /* BEGIN: Attempt to improve the error */
//   id<ORSolution> tmp_solution = [self captureSolution];
//   bool improved = FALSE, improved_var = FALSE;
//   int nvar = 0, nv, nbiter = 0;
//   int direction = 1;
//   ORStatus s;
//   while (nbiter < 200) {
//      [_tracer popNode];
//      [_tracer pushNode];
//      nbiter++; //printf("nb iter = %d\n", nbiter);
//      if (nvar == 0) {
//         nv = 0; for (id<ORDoubleVar> v in x) { xc = _gamma[v.getId]; nv++; if (! [xc bound]) { nvar = nv; break; }}
//         if (nvar == 0) break;
//      }
//      nv = 0;
//      for (id<ORVar> v in x) {
//         xc = _gamma[v.getId]; nv++;
//         if (! [xc bound]) {
//            double value = [[tmp_solution value:v] doubleValue];
//            if (nv == nvar) value = nextafter(value, (direction == 1)?(+INFINITY):(-INFINITY));
//            s = [_engine enforce:^{ [xc bind:value];}];
//            if (s == ORFailure) break;
//         }
//      }
//      if ((s != ORFailure) && ([[[tmp_solution value:ez] rationalValue] lt: [ezi min]])) { // Better err
//         tmp_solution = [self captureSolution];
//         improved_var = TRUE;
//         improved = TRUE;
//      } else {
//         if ((! improved_var) && (direction == 1)) {
//            direction = -1;
//         } else {
//            direction = 1;
//            improved_var = FALSE;
//            nv = 0;
//            int old_nvar = nvar;
//            for (id<ORDoubleVar> v in x) {
//               xc = _gamma[v.getId]; nv++;
//               if ((nv > nvar) && (! [xc bound])) { nvar = nv; break; }
//            }
//            if (nvar == old_nvar) break;
//         }
//      }
//   }
//   /* END: Attempt to improve the error */
//   if ([[[[_engine objective] primalBound] rationalValue] lt: [[tmp_solution value:ez] rationalValue]]) {
//      // And as updatePrimalBound does test whether the value is actually better or not
//      // testing it here is useless
//      printf("*** nb iter = %d\n", nbiter);
//      id<ORObjectiveValue> objv = [ORFactory objectiveValueRational:[[tmp_solution value:ez] rationalValue] minimize:FALSE];
//      [[_engine objective] tightenPrimalBound:objv];
//      [objv release];
//      solution = tmp_solution; // Keep it as a solution
//      NSLog(@"#####");
//      NSLog(@"[GuessError]");
//      for (id<ORVar> v in [_model variables]) {
//         if([v prettyname])
//            NSLog(@"%@: %@", [v prettyname], [solution value:v]);
//      }
//      NSLog(@"#####");
//      [_tracer popNode]; // need to restore initial state before going out of loop !
//      break;
//   }
//   /* END: NEW GUESS */
