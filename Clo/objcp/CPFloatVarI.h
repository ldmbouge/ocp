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

#import <ORFoundation/fpi.h>
//#include "fpi.h"
#import "rationalUtilities.h"

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
-(void) updateMinError: (id<ORRational>) newMinError;
-(void) updateMinErrorF: (ORDouble) newMinError;
-(void) updateMax: (ORFloat) newMax;
-(void) updateMaxError: (id<ORRational>) newMaxError;
-(void) updateMaxErrorF: (ORDouble) newMaxError;
-(void) updateInterval: (ORFloat) newMin and: (ORFloat)newMax;
-(void) updateIntervalError: (id<ORRational>) newMinError and: (id<ORRational>) newMaxError;
-(void) bind: (ORFloat) val;
-(void) bindError: (id<ORRational>) valError;

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
-(void) changeMinEvt:(ORBool) bound sender:(id<CPFloatDom>)sender;
-(void) changeMaxEvt:(ORBool) bound sender:(id<CPFloatDom>)sender;
@end

@interface CPFloatVarI : ORObject<CPFloatVar,CPFloatVarNotifier,CPFloatVarRatNotifier,CPFloatVarExtendedItf> {
   CPEngineI*               _engine;
   BOOL                     _hasValue;
   ORFloat                  _value;    // This value is only used for storing the value of the variable in linear/convex relaxation. Bounds only are safe
   id<ORRational>              _valueError;
   id<CPFloatDom>            _dom;
   id<CPRationalDom>     _domError;
   CPFloatEventNetwork      _net;
   CPMultiCast*             _recv;
@public
   id<CPFloatDom>            _dom;
}
-(id)init:(id<CPEngine>)engine low:(ORFloat)low up:(ORFloat)up;
-(id)init:(id<CPEngine>)engine low:(ORFloat)low up:(ORFloat)up errLow:(id<ORRational>)elow errUp:(id<ORRational>) eup;
-(id)init:(id<CPEngine>)engine low:(ORFloat)low up:(ORFloat)up errLowF:(ORDouble)elow errUpF:(ORDouble) eup;
-(id)init:(id<CPEngine>)engine;
-(id<CPEngine>) engine;
-(id<ORTracker>) tracker;
-(NSMutableSet*) constraints;
-(ORFloat) floatValue;
-(id<ORRational>) errorValue;
-(ORLDouble) domwidth;
-(id<CPDom>) domain;
-(id<CPDom>) domainError;
//-(TRRationalInterval) domainError;
@end

@interface CPFloatViewOnIntVarI : ORObject<CPFloatVar,CPFloatVarExtendedItf,CPIntVarNotifier> {
   CPEngineI* _engine;
   CPIntVar* _theVar;
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
      unsigned int mantissa : 23;
      unsigned int exponent : 8;
      unsigned int sign : 1;
   } parts;
} float_cast;


typedef struct {
   float_interval  result;
   int  changed;
} intersectionInterval;

static inline int sign(float_cast p){
   if(p.parts.sign) return -1;
   return 1;
}
static inline float minFloatBaseOnExponent(float v){
   float_cast v_cast;
   v_cast.f = v;
   v_cast.parts.mantissa = 1;
   return v_cast.f;
}
static inline float floatFromParts(unsigned int mantissa, unsigned int exponent,unsigned int sign){
   float_cast f_cast;
   f_cast.parts.mantissa = mantissa;
   f_cast.parts.exponent = exponent;
   f_cast.parts.sign = sign;
   return f_cast.f;
}
static inline bool isDisjointWithV(float xmin,float xmax,float ymin, float ymax)
{
   return (xmax < ymin) || (ymax < xmin);
}
static inline bool isDisjointWithVR(id<ORRational> xmin, id<ORRational> xmax, id<ORRational> ymin, id<ORRational> ymax)
{
   return ([xmax lt: ymin]) || ([ymax lt: xmin]);
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
   double res = (sign(i_sup) * i_sup.parts.exponent - sign(i_inf) * i_inf.parts.exponent) * ((double) NB_FLOAT_BY_E) - i_inf.parts.mantissa + i_sup.parts.mantissa;
   return (res < 0) ? -res : res;
}

static inline bool isDisjointWith(CPFloatVarI* x, CPFloatVarI* y)
{
   return isDisjointWithV([x min], [x max], [y min], [y max]);
}

static inline bool isDisjointWithR(CPFloatVarI* x, CPFloatVarI* y)
{
   return isDisjointWithVR([x minErr], [x maxErr], [y minErr], [y maxErr]);
}

static inline bool isIntersectingWith(CPFloatVarI* x, CPFloatVarI* y)
{
   return !isDisjointWithV([x min],[x max], [y min], [y max]);
}
static inline bool canPrecede(CPFloatVarI* x, CPFloatVarI* y)
{
   return [x->_dom max] < [y->_dom min];
}
static inline bool canFollow(CPFloatVarI* x, CPFloatVarI* y)
{
   return [x min] > [y max]; 
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
static inline void updateFTWithValues(float_interval * ft,float min, float max)
{
   ft->inf = min;
   ft->sup = max;
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
   if(m_cast.parts.mantissa == 0){
      e--;
   }
   if(e < 0){
      return makeFloatInterval(0,0);
   }else{
      max = floatFromParts(0,e,0);
      max = nextafterf(max, -INFINITY);
      min = -max;
      return makeFloatInterval(min,max);
   }
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
static inline intersectionInterval intersection(float_interval r, float_interval x, ORDouble percent)
{
   double reduced = 0;
   int changed = 0;
   if(percent == 0.0)
      fpi_narrowf(&r, &x, &changed);
   else
      fpi_narrowpercentf(&r, &x, &changed, percent, &reduced);
   
   if(x.inf > x.sup)
      failNow();
   return (intersectionInterval){r,changed};
}
static inline float next_nb_float(float v, int nb, float def)
{
   for(int i = 1; i < nb && v < def; i++)
      v = fp_next_float(v);
   return v;
}
static inline float previous_nb_float(float v, int nb, float def)
{
   for(int i = 1; i < nb && v > def; i++)
      v = fp_previous_float(v);
   return v;
}
