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
#import <objcp/CPDom.h>
#import <objcp/CPData.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPIntVarI.h>

#include "fpi.h"
#include "gmp.h"

#define NB_FLOAT_BY_E (8388608)
#define S_PRECISION 23
#define E_MAX (254)

@protocol CPFloatVarNotifier;

@protocol CPFloatVarSubscriber <NSObject>
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

@protocol CPFloatVarExtendedItf <CPFloatVarSubscriber>
-(void) updateMin: (ORFloat) newMin;
-(void) updateMinError: (ORRational) newMinError;
-(void) updateMinErrorF: (ORFloat) newMinError;
-(void) updateMax: (ORFloat) newMax;
-(void) updateMaxError: (ORRational) newMaxError;
-(void) updateMaxErrorF: (ORFloat) newMaxError;
-(void) updateInterval: (ORFloat) newMin and: (ORFloat)newMax;
-(void) updateIntervalError: (ORRational) newMinError and: (ORRational) newMaxError;
-(void) bind: (ORFloat) val;
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
} CPFloatEventNetwork;

@class CPFloatVarI;
@protocol CPFloatVarNotifier <NSObject>
-(CPFloatVarI*) findAffine: (ORFloat) scale shift: (ORFloat) shift;
-(void) bindEvt:(id<CPFloatDom>)sender;
-(void) bindEvtErr:(id<CPRationalDom>)sender;
-(void) changeMinEvt:(ORBool) bound sender:(id<CPFloatDom>)sender;
-(void) changeMinEvtErr:(ORBool) bound sender:(id<CPRationalDom>)sender;
-(void) changeMaxEvt:(ORBool) bound sender:(id<CPFloatDom>)sender;
-(void) changeMaxEvtErr:(ORBool) bound sender:(id<CPRationalDom>)sender;
@end

@interface CPFloatVarI : ORObject<CPFloatVar,CPFloatVarNotifier,CPFloatVarExtendedItf> {
   CPEngineI*               _engine;
   BOOL                     _hasValue;
   ORFloat                  _value;    // This value is only used for storing the value of the variable in linear/convex relaxation. Bounds only are safe
   ORRational              _valueError;
   id<CPFloatDom>            _dom;
   id<CPRationalDom>     _domError;
   CPFloatEventNetwork      _net;
   CPMultiCast*             _recv;
}
-(id)init:(id<CPEngine>)engine low:(ORFloat)low up:(ORFloat)up;
-(id)init:(id<CPEngine>)engine;
-(id<CPEngine>) engine;
-(id<ORTracker>) tracker;
-(NSMutableSet*) constraints;
-(ORFloat) floatValue;
-(ORRational*) errorValue;
-(ORLDouble) domwidth;
-(id<CPDom>) domain;
-(TRRationalInterval) domainError;
@end

@interface CPFloatViewOnIntVarI : ORObject<CPFloatVar,CPFloatVarExtendedItf,CPIntVarNotifier> {
   CPEngineI* _engine;
   CPIntVar* _theVar;
   CPFloatEventNetwork _net;
}
-(id)init:(id<CPEngine>)engine intVar:(CPIntVar*)iv;
-(CPEngineI*)    engine;
-(id<ORTracker>) tracker;
-(NSMutableSet*) constraints;
@end

/*useful struct to get exponent mantissa and sign*/
typedef union {
   float f;
   struct {
      unsigned int mantisa : 23;
      unsigned int exponent : 8;
      unsigned int sign : 1;
   } parts;
} float_cast;


typedef struct {
   float_interval  result;
   float_interval  interval;
   int  changed;
} intersectionInterval;

typedef struct {
    rational_interval result;
    rational_interval interval;
    int changed;
} intersectionIntervalError;

static inline int sign(float_cast p){
   if(p.parts.sign) return -1;
   return 1;
}

static inline float minFloatBaseOnExponent(float v){
   float_cast v_cast;
   v_cast.f = v;
   v_cast.parts.mantisa = 1;
   return v_cast.f;
}

static inline float floatFromParts(unsigned int mantissa, unsigned int exponent,unsigned int sign){
   float_cast f_cast;
   f_cast.parts.mantisa = mantissa;
   f_cast.parts.exponent = exponent;
   f_cast.parts.sign = sign;
   return f_cast.f;
}

static inline bool isDisjointWithV(float xmin,float xmax,float ymin, float ymax)
{
   return (xmin < ymin &&  xmax < ymin) || (ymin < xmin && ymax < xmin);
}

static inline bool isIntersectingWithV(float xmin,float xmax,float ymin, float ymax)
{
   return !isDisjointWithV(xmin,xmax,ymin,ymax);
}
//hzi : return double because this function is used to compute densisty
static inline double cardinalityV(float xmin, float xmax){
   float_cast i_inf;
   float_cast i_sup;
   i_inf.f = xmin;
   i_sup.f = xmax;
   if(xmin == xmax) return 1.0;
   if(xmin == -infinityf() && xmax == infinityf()) return DBL_MAX; // maybe just use -MAXFLT and maxFLT instead ?
   double res = (sign(i_sup) * i_sup.parts.exponent - sign(i_inf) * i_inf.parts.exponent) * ((double) NB_FLOAT_BY_E) - i_inf.parts.mantisa + i_sup.parts.mantisa;
   return (res < 0) ? -res : res;
}

static inline bool isDisjointWith(CPFloatVarI* x, CPFloatVarI* y)
{
   return isDisjointWithV([x min], [x max], [y min], [y max]);
}

static inline bool isIntersectingWith(CPFloatVarI* x, CPFloatVarI* y)
{
   return !isDisjointWithV([x min],[x max], [y min], [y max]);
}

static inline bool canPrecede(CPFloatVarI* x, CPFloatVarI* y)
{
   return [x min] < [y min] &&  [x max] < [y max];
}
static inline bool canFollow(CPFloatVarI* x, CPFloatVarI* y)
{
   return [x min] > [y min ] && [x max] > [y max];
}

static inline double cardinality(CPFloatVarI* x)
{
   return cardinalityV([x min], [x max]);
}

static inline float_interval makeFloatInterval(float min, float max)
{
   return (float_interval){min,max};
}

static inline void updateFloatInterval(float_interval * ft,CPFloatVarI* x)
{
   ft->inf = x.min;
   ft->sup = x.max;
}
static inline void makeRationalInterval(rational_interval* ri, ORRational min, ORRational max)
{
    mpq_set(ri->inf, min);
    mpq_set(ri->sup, max);
}

static inline void updateRationalInterval(rational_interval* ri, CPFloatVarI* x)
{
   mpq_set(ri->inf, *x.minErr);
   mpq_set(ri->sup, *x.maxErr);
}

static inline void freeRationalInterval(rational_interval * r)
{
   mpq_clears(r->inf,r->sup, NULL);
}

static inline void setRationalInterval(rational_interval* r, rational_interval* r2){
   mpq_set(r->inf, r2->inf);
   mpq_set(r->sup, r2->sup);
}
//hzi : missing denormalised case
static inline float_interval computeAbsordedInterval(CPFloatVarI* x)
{
   ORFloat m, min, max;
   ORInt e;
   m = fmaxFlt([x min],[x max]);
   float_cast m_cast;
   m_cast.f = m;
   e = m_cast.parts.exponent - S_PRECISION - 1;
   if(m_cast.parts.mantisa == 0){
      e--;
   }
   max = floatFromParts(0,e,0);
   max = nextafterf(max, -INFINITY);
   min = -max;
   return makeFloatInterval(min,max);
}

static inline float_interval computeAbsorbingInterval(CPFloatVarI* x)
{
   float m = fmaxFlt([x min], [x max]);
   float m_e = minFloatBaseOnExponent(m);
   float min,max;
   if(m == fabs([x min])){
      min = -m;
      max = minFlt(-m_e,[x max]);
   }else{
      min = maxFlt(m_e,[x min]);
      max = m;
   }
   return makeFloatInterval(min,max);
}

static inline void minError(ORRational* r, ORRational* a, ORRational* b){
    //if(mpq_cmp(*a, *b) > 0){
   if(mpq_get_d(*a) > mpq_get_d(*b)){

        mpq_set(*r, *b);
    }
    else {
        mpq_set(*r, *a);
    }
}

static inline void maxError(ORRational* r, ORRational* a, ORRational* b){
    //if(mpq_cmp(*a, *b) > 0){
   if(mpq_get_d(*a) > mpq_get_d(*b)){
        mpq_set(*r, *a);
    }
    else {
        mpq_set(*r, *b);
    }
}

static inline intersectionInterval intersection(float_interval r, float_interval x, ORDouble percent)
{
   double reduced = 0;
   int changed = 0;
   if(percent == 0.0)
      fpi_narrowf(&r, &x, &changed);
   else{
      fpi_narrowpercentf(&r, &x, &changed, percent, &reduced);
      if(x.inf > x.sup)
         failNow();
   }
   return (intersectionInterval){r,x,changed};
}

static inline void intersectionError(intersectionIntervalError* interErr, rational_interval original_error, rational_interval computed_error){
   interErr->changed = false;
   if(((mpq_get_d(original_error.inf) < mpq_get_d(computed_error.inf)) && (mpq_get_d(original_error.sup) < mpq_get_d(computed_error.sup))) ||
      ((mpq_get_d(original_error.inf) > mpq_get_d(computed_error.inf)) && (mpq_get_d(original_error.sup) > mpq_get_d(computed_error.sup))))
      failNow();
   /* original_error < computed_error */
   if(mpq_get_d(original_error.inf) < mpq_get_d(computed_error.inf)){
      interErr->changed = true;
      mpq_set(interErr->result.inf, computed_error.inf);
   }
   /* original_error > computed_error */
   if(mpq_get_d(original_error.sup) > mpq_get_d(computed_error.sup)){
      interErr->changed = true;
      mpq_set(interErr->result.sup, computed_error.sup);
   }
   
   if(mpq_get_d(interErr->result.inf) > mpq_get_d(interErr->result.sup))
      failNow();
   
   if(interErr->changed){
      float_interval original;
      original.inf = mpq_get_d(original_error.inf);
      original.sup = mpq_get_d(original_error.sup);
      float_interval computed;
      computed.inf = mpq_get_d(interErr->result.inf);
      computed.sup = mpq_get_d(interErr->result.sup);
      float_interval percent;
      percent.inf = fabsf(((original.inf - computed.inf)/original.inf)*100.0f);
      percent.sup = fabsf(((original.sup - computed.sup)/original.sup)*100.0f);
      if(percent.inf <= 1.0f || percent.sup <= 1.0f)
         interErr->changed = false;
   }
   mpq_set(interErr->interval.inf, original_error.inf);
   mpq_set(interErr->interval.sup, original_error.sup);
}
