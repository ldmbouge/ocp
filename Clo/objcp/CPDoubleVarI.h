/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPTrigger.h>
#import <CPUKernel/CPConstraintI.h>
#import <CPUKernel/CPTrigger.h>
#import <objcp/CPDom.h>
#import <objcp/CPData.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPIntVarI.h>

#include "fpi.h"
#include "gmp.h"
#include "rationalUtilities.h"

#define NB_DOUBLE_BY_E (4.5035996e+15)
#define ED_MAX (2047)


@protocol CPDoubleVarNotifier;

@protocol CPDoubleVarSubscriber <NSObject>
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

@protocol CPDoubleVarExtendedItf <CPDoubleVarSubscriber>
-(void) updateMin: (ORDouble) newMin;
-(void) updateMinError: (ORRational) newMinError;
-(void) updateMinErrorF: (ORDouble) newMinError;
-(void) updateMax: (ORDouble) newMax;
-(void) updateMaxError: (ORRational) newMaxError;
-(void) updateMaxErrorF: (ORDouble) newMaxError;
-(void) updateInterval: (ORDouble) newMin and: (ORDouble)newMax;
-(void) updateIntervalError: (ORRational) newMinError and: (ORRational) newMaxError;
-(void) bind: (ORDouble) val;
-(void) bindError: (ORRational) valError;
@end

typedef struct  {
    TRId           _bindEvt;
    TRId            _minEvt;
    TRId            _maxEvt;
    TRId         _boundsEvt;
    TRId        _bindEvtErr;
    TRId         _maxEvtErr;
    TRId         _minEvtErr;
    TRId      _boundsEvtErr;
} CPDoubleEventNetwork;

@class CPDoubleVarI;

@protocol CPDoubleVarNotifier <NSObject>
-(CPDoubleVarI*) findAffine: (ORDouble) scale shift: (ORDouble) shift;
-(void) bindEvt:(id<CPDoubleDom>)sender;
-(void) changeMinEvt:(ORBool) bound sender:(id<CPDoubleDom>)sender;
-(void) changeMaxEvt:(ORBool) bound sender:(id<CPDoubleDom>)sender;
@end

@interface CPDoubleVarI : ORObject<CPDoubleVar,CPDoubleVarNotifier,CPFloatVarRatNotifier,CPDoubleVarExtendedItf> {
    CPEngineI*               _engine;
    BOOL                     _hasValue;
    ORDouble                 _value;    // This value is only used for storing the value of the variable in linear/convex relaxation. Bounds only are safe
    ORRational               _valueError;
    id<CPDoubleDom>          _dom;
    id<CPRationalDom>        _domError;
    CPDoubleEventNetwork     _net;
    CPMultiCast*             _recv;
}
-(id)init:(CPEngineI*)engine low:(ORDouble)low up:(ORDouble)up errLow:(ORRational)elow errUp:(ORRational) eup;
-(id)init:(CPEngineI*)engine low:(ORDouble)low up:(ORDouble)up errLowF:(ORDouble)elow errUpF:(ORDouble) eup;
-(id)init:(id<CPEngine>)engine low:(ORDouble)low up:(ORDouble)up;
-(id<CPEngine>) engine;
-(id<ORTracker>) tracker;
-(NSMutableSet*) constraints;
-(ORDouble) doubleValue;
-(ORRational) errorValue;
-(ORLDouble) domwidth;
-(id<CPDom>) domain;
-(TRRationalInterval) domainError;
@end

@interface CPDoubleViewOnIntVarI : ORObject<CPDoubleVar,CPDoubleVarExtendedItf,CPIntVarNotifier> {
    CPEngineI* _engine;
    CPIntVar* _theVar;
    CPDoubleEventNetwork _net;
}
-(id)init:(id<CPEngine>)engine intVar:(CPIntVar*)iv;
-(CPEngineI*)    engine;
-(id<ORTracker>) tracker;
-(NSMutableSet*) constraints;
@end

/*useful struct to get exponent mantissa and sign*/
typedef union {
   double f;
   struct {
      unsigned long mantissa : 52;
      unsigned int exponent : 11;
      unsigned int sign : 1;
   } parts;
} double_cast;

typedef struct {
   double_interval  result;
   int  changed;
} intersectionIntervalD;

/* Already defined */
typedef struct {
    ri result;
    ri interval;
    int changed;
} intersectionIntervalErrorD;

 
static inline int signD(double_cast p){
   if(p.parts.sign) return -1;
   return 1;
}

static inline bool isDisjointWithDV(double xmin,double xmax,double ymin, double ymax)
{
   return (xmax < ymin) || (ymax < xmin);
}

static inline bool isDisjointWithDVR(ORRational xmin, ORRational xmax, ORRational ymin, ORRational ymax)
{
    return (rational_cmp(&xmax, &ymin) < 0) || (rational_cmp(&ymax, &xmin) < 0 );
}

static inline bool isIntersectingWithDV(double xmin,double xmax,double ymin, double ymax)
{
   return !isDisjointWithDV(xmin,xmax,ymin,ymax);
}

static inline bool isDisjointWithD(CPDoubleVarI* x, CPDoubleVarI* y)
{
   return isDisjointWithDV([x min], [x max], [y min], [y max]);
}

static inline bool isIntersectingWithD(CPDoubleVarI* x, CPDoubleVarI* y)
{
   return !isDisjointWithDV([x min],[x max], [y min], [y max]);
}

static inline bool isDisjointWithDR(CPDoubleVarI* x, CPDoubleVarI* y)
{
    return isDisjointWithDVR([x minErr], [x maxErr], [y minErr], [y maxErr]);
}

static inline bool canPrecedeD(CPDoubleVarI* x, CPDoubleVarI* y)
{
   return [x min] < [y min] &&  [x max] < [y max];
}
static inline bool canFollowD(CPDoubleVarI* x, CPDoubleVarI* y)
{
   return [x min] > [y min ] && [x max] > [y max];
}

static inline double_interval makeDoubleInterval(double min, double max)
{
   return (double_interval){min,max};
}

static inline void updateDoubleInterval(double_interval * ft,CPDoubleVarI* x)
{
   ft->inf = x.min;
   ft->sup = x.max;
}

static inline void makeRationalIntervalD(ri ri_, ORRational min, ORRational max)
{
   ri_set_q(&ri_, &min, &max);
}

static inline void updateRationalIntervalD(ri ri_, CPDoubleVarI* x)
{
    ORRational minE;
    ORRational maxE;
    rational_init(&minE);
    rational_init(&maxE);
    minE = x.minErr;
    maxE = x.maxErr;
    ri_set_q(&ri_, &minE, &maxE);
    rational_clear(&minE);
    rational_clear(&maxE);
}

static inline void freeRationalIntervalD(ri r)
{
    ri_clear(&r);
}

static inline void setRationalIntervalD(ri r, ri r2){
   ri_set(&r, &r2);
}

static inline void minErrorD(ORRational* r, ORRational* a, ORRational* b){
    if (rational_cmp(a, b) > 0)
        rational_set(r, b);
    else
        rational_set(r, a);
}

static inline void maxErrorD(ORRational* r, ORRational* a, ORRational* b){
    if (rational_cmp(a, b) > 0)
        rational_set(r, a);
    else
        rational_set(r, b);
}

static inline intersectionIntervalD intersectionD(double_interval r, double_interval x, ORDouble percent)
{
   double reduced = 0;
   int changed = 0;
   if(percent == 0.0)
      fpi_narrowd(&r, &x, &changed);
   else
      fpi_narrowpercentd(&r, &x, &changed, percent, &reduced);
   
   if(x.inf > x.sup)
      failNow();
   return (intersectionIntervalD){r,changed};
}

static inline void intersectionErrorD(intersectionIntervalErrorD* interErr, ri original_error, ri computed_error){
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
        rational_init(&hundred);
        ri_init(&percent);
        
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

