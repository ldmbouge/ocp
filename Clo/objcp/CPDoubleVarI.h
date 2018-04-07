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
/*
@protocol CPDoubleVarNotifier <NSObject>
-(CPDoubleVarI*) findAffine: (ORDouble) scale shift: (ORDouble) shift;
-(void) bindEvt:(id<CPDoubleDom>)sender;
-(void) bindEvtErr:(id<CPRationalDom>)sender;
-(void) changeMinEvt:(ORBool) bound sender:(id<CPDoubleDom>)sender;
-(void) changeMinEvtErr:(ORBool) bound sender:(id<CPRationalDom>)sender;
-(void) changeMaxEvt:(ORBool) bound sender:(id<CPDoubleDom>)sender;
-(void) changeMaxEvtErr:(ORBool) bound sender:(id<CPRationalDom>)sender;
@end
 */
@protocol CPDoubleVarNotifier <CPFVarNotifier>
-(CPDoubleVarI*) findAffine: (ORDouble) scale shift: (ORDouble) shift;
-(void) bindEvt:(id<CPDoubleDom>)sender;
-(void) changeMinEvt:(ORBool) bound sender:(id<CPDoubleDom>)sender;
-(void) changeMaxEvt:(ORBool) bound sender:(id<CPDoubleDom>)sender;
@end

@interface CPDoubleVarI : ORObject<CPDoubleVar,CPDoubleVarNotifier,CPDoubleVarExtendedItf> {
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
-(ORRational*) errorValue;
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
      unsigned long mantisa : 52;
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
    rational_interval result;
    rational_interval interval;
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
    return (mpq_cmp(xmax, ymin) < 0) || (mpq_cmp(ymax, xmin) < 0 );
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
    return isDisjointWithDVR(*[x minErr], *[x maxErr], *[y minErr], *[y maxErr]);
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

static inline void makeRationalIntervalD(rational_interval* ri, ORRational min, ORRational max)
{
    mpq_set(ri->inf, min);
    mpq_set(ri->sup, max);
}

static inline void updateRationalIntervalD(rational_interval* ri, CPDoubleVarI* x)
{
    mpq_set(ri->inf, *x.minErr);
    mpq_set(ri->sup, *x.maxErr);
}

static inline void freeRationalIntervalD(rational_interval * r)
{
    mpq_clears(r->inf,r->sup, NULL);
}

static inline void setRationalIntervalD(rational_interval* r, rational_interval* r2){
    mpq_set(r->inf, r2->inf);
    mpq_set(r->sup, r2->sup);
}

static inline void minErrorD(ORRational* r, ORRational* a, ORRational* b){
    // if(mpq_get_d(*a) > mpq_get_d(*b)){ // WRONG: this might produce strange results (cpjm)
    if (mpq_cmp(*a, *b) > 0)
        mpq_set(*r, *b);
    else
        mpq_set(*r, *a);
}

static inline void maxErrorD(ORRational* r, ORRational* a, ORRational* b){
    // if(mpq_get_d(*a) > mpq_get_d(*b)){ // WRONG: this might produce strange results (cpjm)
    if (mpq_cmp(*a, *b) > 0)
        mpq_set(*r, *a);
    else
        mpq_set(*r, *b);
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

static inline void intersectionErrorD(intersectionIntervalErrorD* interErr, rational_interval original_error, rational_interval computed_error){
    int cmp_val;
    interErr->changed = false;
    
    /* inf = max of (original_error.inf, computed_error.inf) */
    cmp_val = mpq_cmp(original_error.inf, computed_error.inf);
    if(cmp_val < 0) {
        interErr->changed = true;
        mpq_set(interErr->result.inf, computed_error.inf);
    } else if (cmp_val >= 0) {
        mpq_set(interErr->result.inf, original_error.inf);
    }
    /* original_error > computed_error */
    cmp_val = mpq_cmp(original_error.sup, computed_error.sup);
    if(cmp_val > 0){
        interErr->changed = true;
        mpq_set(interErr->result.sup, computed_error.sup);
    } else if (cmp_val <= 0) {
        mpq_set(interErr->result.sup, original_error.sup);
    }
    
    if(mpq_cmp(interErr->result.inf, interErr->result.sup) > 0) // interErr empty !
        failNow();
    
    if(interErr->changed){
        rational_interval percent;
        ORRational hundred;
        mpq_inits(hundred, percent.inf, percent.sup, NULL);
        
        mpq_sub(percent.inf, original_error.inf, interErr->result.inf);
        mpq_sub(percent.sup, original_error.sup, interErr->result.sup);
        
        mpq_set_d(hundred, 0.0f);
        if(mpq_equal(original_error.inf, hundred)){
            mpq_set_d(percent.inf, -DBL_MAX);
        } else{
            mpq_div(percent.inf, percent.inf, original_error.inf);
        }
        if(mpq_equal(original_error.sup, hundred)){
            mpq_set_d(percent.sup, DBL_MAX);
        } else{
            mpq_div(percent.sup, percent.sup, original_error.sup);
        }
        
        mpq_set_d(hundred, 100.0f);
        mpq_mul(percent.inf, percent.inf, hundred);
        mpq_mul(percent.sup, percent.sup, hundred);
        
        mpq_abs(percent.inf, percent.inf);
        mpq_abs(percent.sup, percent.sup);
        
        mpq_set_d(hundred, 1.0f);
        
        if(mpq_cmp(percent.inf, hundred) <= 0 && mpq_cmp(percent.sup, hundred) <= 0)
            interErr->changed = false;
        
        mpq_clears(hundred, percent.inf, percent.sup, NULL);
    }
    mpq_set(interErr->interval.inf, original_error.inf);
    mpq_set(interErr->interval.sup, original_error.sup);
}

