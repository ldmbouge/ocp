//
//  CPRationalVarI.h
//  Clo
//
//  Created by Rémy Garcia on 04/07/2018.
//

#ifndef CPRationalVarI_h
#define CPRationalVarI_h

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPTrigger.h>
#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPDom.h>
#import <objcp/CPData.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPIntVarI.h>

#include "fpi.h"
#include "gmp.h"
#include "rationalUtilities.h"

#define NB_FLOAT_BY_E (8388608)
#define S_PRECISION 23
#define E_MAX (254)

@protocol CPRationalVarNotifier;

@protocol CPRationalVarSubscriber <NSObject>
// AC3 Closure Event
-(void) whenBindDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeBoundsDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeMinDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeMaxDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c;

-(void) whenBindDo: (ORClosure) todo onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeBoundsDo: (ORClosure) todo onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeMinDo: (ORClosure) todo onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeMaxDo: (ORClosure) todo onBehalf:(CPCoreConstraint*)c;

// AC3 Constraint Event
-(void) whenBindPropagate: (CPCoreConstraint*) c priority: (ORInt) p;
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c priority: (ORInt) p;
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p;
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p;

-(void) whenBindPropagate: (CPCoreConstraint*) c;
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c;
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c;
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c;
@end

// Interface for CP extensions

@protocol CPRationalVarExtendedItf <CPRationalVarSubscriber>
-(void) updateMin: (ORRational) newMin;
-(void) updateMinF: (ORDouble) newMinError;
-(void) updateMax: (ORRational) newMax;
-(void) updateMaxF: (ORDouble) newMaxError;
-(void) updateInterval: (ORRational) newMin and: (ORRational)newMax;
-(void) bind: (ORRational) val;
@end

typedef struct  {
   TRId           _bindEvt;
   TRId            _minEvt;
   TRId            _maxEvt;
   TRId         _boundsEvt;
} CPRationalEventNetwork;


@class CPRationalVarI;
@protocol CPRationalVarNotifier <NSObject>
-(CPRationalVarI*) findAffine: (ORRational) scale shift: (ORRational) shift;
-(void) bindEvt:(id<CPRationalDomN>)sender;
-(void) changeMinEvt:(ORBool) bound sender:(id<CPRationalDomN>)sender;
-(void) changeMaxEvt:(ORBool) bound sender:(id<CPRationalDomN>)sender;
@end

@interface CPRationalVarI : ORObject<CPRationalVar,CPRationalVarNotifier,CPRationalVarExtendedItf> {
   CPEngineI*               _engine;
   BOOL                     _hasValue;
   ORRational              _value;    // This value is only used for storing the value of the variable in linear/convex relaxation. Bounds only are safe
   id<CPRationalDomN>       _dom;
   CPRationalEventNetwork   _net;
   CPMultiCast*             _recv;
}
-(id)init:(id<CPEngine>)engine low:(ORRational)low up:(ORRational)up;
-(id)init:(id<CPEngine>)engine;
-(id<CPEngine>) engine;
-(id<ORTracker>) tracker;
-(NSMutableSet*) constraints;
-(ORRational) rationalValue;
-(id<CPDom>) domain;
@end

/*@interface CPRationalViewOnIntVarI : ORObject<CPRationalVar,CPRationalVarExtendedItf,CPIntVarNotifier> {
   CPEngineI* _engine;
   CPIntVar* _theVar;
   CPRationalEventNetwork _net;
}
-(id)init:(id<CPEngine>)engine intVar:(CPIntVar*)iv;
-(CPEngineI*)    engine;
-(id<ORTracker>) tracker;
-(NSMutableSet*) constraints;
@end*/


typedef struct {
   ri interval;
   ri  result;
   int  changed;
} intersectionIntervalQ;

static inline bool isDisjointWithVQ(ORRational xmin, ORRational xmax, ORRational ymin, ORRational ymax)
{
   return (rational_cmp(&xmax, &ymin) < 0) || (rational_cmp(&ymax, &xmin) < 0 );
}


static inline bool isIntersectingWithVQ(ORRational xmin, ORRational xmax, ORRational ymin, ORRational ymax)
{
   return !isDisjointWithVQ(xmin,xmax,ymin,ymax);
}
static inline bool isDisjointWithQ(CPRationalVarI* x, CPRationalVarI* y)
{
   return isDisjointWithVQ([x min], [x max], [y min], [y max]);
}

static inline bool isIntersectingWithQ(CPRationalVarI* x, CPRationalVarI* y)
{
   return !isDisjointWithVQ([x min], [x max], [y min], [y max]);
}

static inline bool canPrecedeQ(CPRationalVarI* x, CPRationalVarI* y)
{
   ORRational xmin;
   ORRational ymin;
   ORRational xmax;
   ORRational ymax;
   xmin = [x min];
   ymin = [y min];
   xmax = [x max];
   ymax = [y max];
   return rational_lt(&xmin, &ymin) &&  rational_lt(&xmax, &ymax);
}
static inline bool canFollowQ(CPRationalVarI* x, CPRationalVarI* y)
{
   ORRational xmin;
   ORRational ymin;
   ORRational xmax;
   ORRational ymax;
   xmin = [x min];
   ymin = [y min];
   xmax = [x max];
   ymax = [y max];
   return rational_gt(&xmin, &ymin) && rational_gt(&xmax, &ymax);
}
static inline void makeRationalIntervalQ(ri ri_, ORRational min, ORRational max)
{
   ri_set_q(&ri_, &min, &max);
}

static inline void updateRationalIntervalQ(ri ri, CPRationalVarI* x)
{
   ORRational min;
   ORRational max;
   rational_init(&min);
   rational_init(&max);
   min = x.min;
   max = x.max;
   ri_set_q(&ri, &min, &max);
   rational_clear(&min);
   rational_clear(&max);
}

static inline void intersectionQ(intersectionIntervalQ* interErr, ri original_error, ri computed_error){
   int cmp_val;
   interErr->changed = false;
   
   /* inf = max of (original_error.inf, computed_error.inf) */
   cmp_val = rational_cmp(&original_error.inf, &computed_error.inf);
   if(cmp_val < 0) {
      interErr->changed = true;
      rational_set(&interErr->result.inf, &computed_error.inf);
   } else if (cmp_val >= 0) {
      rational_set(&interErr->result.inf, &original_error.inf);
   }
   /* original_error > computed_error */
   cmp_val = rational_cmp(&original_error.sup, &computed_error.sup);
   if(cmp_val > 0){
      interErr->changed = true;
      rational_set(&interErr->result.sup, &computed_error.sup);
   } else if (cmp_val <= 0) {
      rational_set(&interErr->result.sup, &original_error.sup);
   }
   
   if(rational_cmp(&interErr->result.inf, &interErr->result.sup) > 0) // interErr empty !
      failNow();
   
   if(interErr->changed){
      ri percent;
      ORRational hundred;
      ri_init(&percent);
      rational_init(&hundred);
      
      rational_subtraction(&percent.inf, &original_error.inf, &interErr->result.inf);
      rational_subtraction(&percent.sup, &original_error.sup, &interErr->result.sup);
      
      rational_set_d(&hundred, 0.0f);
      if(rational_eq(&original_error.inf, &hundred)){
         rational_set_d(&percent.inf, -DBL_MAX);
      } else{
         rational_division(&percent.inf, &percent.inf, &original_error.inf);
      }
      if(rational_eq(&original_error.sup, &hundred)){
         rational_set_d(&percent.sup, DBL_MAX);
      } else{
         rational_division(&percent.sup, &percent.sup, &original_error.sup);
      }
      
      rational_set_d(&hundred, 100.0f);
      rational_multiplication(&percent.inf, &percent.inf, &hundred);
      rational_multiplication(&percent.sup, &percent.sup, &hundred);
      
      rational_abs(&percent.inf, &percent.inf);
      rational_abs(&percent.sup, &percent.sup);
      
      rational_set_d(&hundred, 1.0f);
      
      if(rational_cmp(&percent.inf, &hundred) <= 0 && rational_cmp(&percent.sup, &hundred) <= 0)
         interErr->changed = false;
      
      rational_clear(&hundred);
      ri_clear(&percent);
   }
   rational_set(&interErr->interval.inf, &original_error.inf);
   rational_set(&interErr->interval.sup, &original_error.sup);
}

#endif /* CPRationalVarI_h */
