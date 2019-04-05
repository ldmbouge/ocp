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

#import <ORFoundation/fpi.h>
//#include "fpi.h"
#import "rationalUtilities.h"

#define NB_DOUBLE_BY_E (4.5035996e+15)
#define SD_PRECISION 52
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
-(void) updateMin: (ORDouble) newMin propagate:(ORBool) p;
-(void) updateMax: (ORDouble) newMax propagate:(ORBool) p;
-(void) updateMin: (ORDouble) newMin;
-(void) updateMinError: (id<ORRational>) newMinError;
-(void) updateMinErrorF: (ORDouble) newMinError;
-(void) updateMax: (ORDouble) newMax;
-(void) updateMaxError: (id<ORRational>) newMaxError;
-(void) updateMaxErrorF: (ORDouble) newMaxError;
-(void) updateInterval: (ORDouble) newMin and: (ORDouble)newMax;
-(void) updateIntervalError: (id<ORRational>) newMinError and: (id<ORRational>) newMaxError;
-(void) bind: (ORDouble) val;
-(void) bindError: (id<ORRational>) valError;
@end

//typedef struct  {
//    TRId           _bindEvt;
//    TRId            _minEvt;
//    TRId            _maxEvt;
//    TRId         _boundsEvt;
//    TRId        _bindEvtErr;
//    TRId         _maxEvtErr;
//    TRId         _minEvtErr;
//    TRId      _boundsEvtErr;
//} CPDoubleEventNetwork;

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
    id<ORRational>               _valueError;
    id<CPDoubleDom>          _dom;
    id<CPRationalDom>        _domError;
    //CPDoubleEventNetwork     _net;
    CPMultiCast*             _recv;
}
-(id)init:(id<CPEngine>)engine low:(ORDouble)low up:(ORDouble)up errLow:(id<ORRational>)elow errUp:(id<ORRational>) eup;
-(id)init:(id<CPEngine>)engine low:(ORDouble)low up:(ORDouble)up errLowF:(ORDouble)elow errUpF:(ORDouble) eup;
-(id)init:(id<CPEngine>)engine low:(ORDouble)low up:(ORDouble)up;
-(id<CPEngine>) engine;
-(id<ORTracker>) tracker;
-(id<OROSet>) constraints;
-(ORDouble) doubleValue;
-(id<ORRational>) errorValue;
-(ORLDouble) domwidth;
-(id<CPDom>) domain;
-(TRRationalInterval) domainError;
@end

@interface CPDoubleViewOnIntVarI : ORObject<CPDoubleVar,CPDoubleVarExtendedItf,CPIntVarNotifier> {
    CPEngineI* _engine;
    CPIntVar* _theVar;
}
-(id)init:(id<CPEngine>)engine intVar:(CPIntVar*)iv;
-(CPEngineI*)    engine;
-(id<ORTracker>) tracker;
-(id<OROSet>) constraints;
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

static inline int signD(double_cast p){
   if(p.parts.sign) return -1;
   return 1;
}

static inline float minDoubleBaseOnExponent(double v){
   double_cast v_cast;
   v_cast.f = v;
   v_cast.parts.mantissa = 1;
   if(v_cast.f > v){
      return v;
   }
   return v_cast.f;
}
static inline double doubleFromParts(unsigned long mantissa, unsigned int exponent,unsigned int sign){
   double_cast f_cast;
   f_cast.parts.mantissa = mantissa;
   f_cast.parts.exponent = exponent;
   f_cast.parts.sign = sign;
   return f_cast.f;
}
static inline  double cardinalityDV(double xmin, double xmax){
   double_cast i_inf;
   double_cast i_sup;
   i_inf.f = xmin;
   i_sup.f = xmax;
   if(xmin == xmax) return 1.0;
   if(xmin == -infinity() && xmax == infinity()) return DBL_MAX; // maybe just use -MAXFLT and maxFLT instead ?
   if(xmin < 0 && xmax > 0 &&  i_sup.parts.exponent == 0 && i_inf.parts.exponent == 0) return i_inf.parts.mantissa + i_sup.parts.mantissa;
   long double tmp;
   if(xmax <= 0) tmp = (signD(i_inf) * i_inf.parts.exponent - signD(i_sup) * i_sup.parts.exponent);
   else tmp = (signD(i_sup) * i_sup.parts.exponent - signD(i_inf) * i_inf.parts.exponent);
   long double res = tmp * (NB_DOUBLE_BY_E) - i_inf.parts.mantissa + i_sup.parts.mantissa;
   return (res < 0) ? -res : res;
}

static inline long double cardinalityD(CPDoubleVarI* x)
{
   return cardinalityDV(x.min, x.max);
}
static inline bool isDisjointWithDV(double xmin,double xmax,double ymin, double ymax)
{
   return (xmax < ymin) || (ymax < xmin);
}
static inline bool isDisjointWithDVR(id<ORRational> xmin, id<ORRational> xmax, id<ORRational> ymin, id<ORRational> ymax)
{
   return ([xmax lt: ymin]) || ([ymax lt: xmin]);
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
   return [x max] < [y min];
}
static inline bool canFollowD(CPDoubleVarI* x, CPDoubleVarI* y)
{
    return [x min] > [y max];
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
static inline void updateDTWithValues(double_interval * ft,float min, float max)
{
   ft->inf = min;
   ft->sup = max;
}
static inline intersectionIntervalD intersectionD(CPDoubleVarI* v, double_interval r, double_interval x, ORDouble percent)
{
   double reduced = 0;
   int changed = 0;
   if(percent == 0.0)
      fpi_narrowd(&r, &x, &changed);
   else
      fpi_narrowpercentboundd(&r, &x, &changed, percent, &reduced);
   
   if(r.inf > r.sup)
      failNow();
//   to make changes without propage
//   if(!changed && reduced > 0.0){
//      [v updateMin:r.inf propagate:NO];
//      [v updateMax:r.sup propagate:NO];
//   }
   return (intersectionIntervalD){r,changed};
}

static inline float next_nb_double(float v, int nb, float def)
{
   for(int i = 1; i < nb && v < def; i++)
      v = fp_next_double(v);
   return v;
}

static inline float previous_nb_double(double v, int nb, double def)
{
   for(int i = 1; i < nb && v > def; i++)
      v = fp_previous_double(v);
   return v;
}

//hzi : missing denormalised case
static inline double_interval computeAbsordedIntervalD(CPDoubleVarI* x)
{
   ORDouble m, min, max;
   double tmpMax = (x.max == +infinity()) ? maxnormal() : x.max;
   double tmpMin = (x.min == -infinity()) ? -maxnormal() : x.min;
   ORInt e;
   m = fmaxDbl(tmpMin,tmpMax);
   double_cast m_cast;
   m_cast.f = m;
   e = m_cast.parts.exponent - SD_PRECISION - 1;
   if(m_cast.parts.mantissa == 0){
      e--;
   }
   if(e < 0){
      return makeDoubleInterval(0,0);
   }else{
      max = doubleFromParts(0,e,0);
      max = nextafter(max, -INFINITY);
      min = -max;
      return makeDoubleInterval(min,max);
   }
}

static inline double_interval computeAbsorbingIntervalD(CPDoubleVarI* x)
{
   double tmpMax = (x.max == +infinity()) ? maxnormal() : x.max;
   double tmpMin = (x.min == -infinity()) ? -maxnormal() : x.min;
   double m = fmaxDbl(tmpMin, tmpMax);
   double m_e = minDoubleBaseOnExponent(m);
   double min,max;
   if(m == fabs(tmpMin)){
      min = x.min;
      max = minDbl(-m_e,x.max);
   }else{
      min = maxDbl(m_e,x.min);
      max = x.max;
   }
   return makeDoubleInterval(min,max);
}
