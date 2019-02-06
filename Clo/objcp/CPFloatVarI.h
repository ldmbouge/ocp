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
-(void) updateMax: (ORFloat) newMax;
-(void) updateInterval: (ORFloat) newMin and: (ORFloat)newMax;
-(void) bind: (ORFloat) val;
@end

@class CPFloatVarI;
@protocol CPFloatVarNotifier <NSObject>
-(CPFloatVarI*) findAffine: (ORFloat) scale shift: (ORFloat) shift;
-(void) bindEvt:(id<CPFloatDom>)sender;
-(void) changeMinEvt:(ORBool) bound sender:(id<CPFloatDom>)sender;
-(void) changeMaxEvt:(ORBool) bound sender:(id<CPFloatDom>)sender;
@end

@interface CPFloatVarI : ORObject<CPFloatVar,CPFloatVarNotifier,CPFloatVarExtendedItf> {
   CPEngineI*               _engine;
   BOOL                     _hasValue;
   ORFloat                  _value;    // This value is only used for storing the value of the variable in linear/convex relaxation. Bounds only are safe
   CPMultiCast*             _recv;
@public
   id<CPFloatDom>            _dom;
}
-(id)init:(id<CPEngine>)engine low:(ORFloat)low up:(ORFloat)up;
-(id<CPEngine>) engine;
-(id<ORTracker>) tracker;
-(NSMutableSet*) constraints;
-(ORFloat) floatValue;
-(ORLDouble) domwidth;
-(id<CPDom>) domain;
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
      unsigned int mantisa : 23;
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
   v_cast.parts.mantisa = 1;
   if(v_cast.f > v){
      return v;
   }
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
   return (xmax < ymin) || (ymax < xmin);
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
   if(xmin < 0 && xmax > 0 &&  i_sup.parts.exponent == 0 && i_inf.parts.exponent == 0) return i_inf.parts.mantisa + i_sup.parts.mantisa;
   double tmp;
   if(xmax <= 0) tmp = (sign(i_inf) * i_inf.parts.exponent - sign(i_sup) * i_sup.parts.exponent);
   else tmp = (sign(i_sup) * i_sup.parts.exponent - sign(i_inf) * i_inf.parts.exponent);
   double res = tmp * ((double) NB_FLOAT_BY_E) - i_inf.parts.mantisa + i_sup.parts.mantisa;
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
   float tmpMax = (x.max == +infinityf()) ? maxnormalf() : x.max;
   float tmpMin = (x.min == -infinityf()) ? -maxnormalf() : x.min;
   ORInt e;
   m = fmaxFlt(tmpMin,tmpMax);
   float_cast m_cast;
   m_cast.f = m;
   e = m_cast.parts.exponent - S_PRECISION - 1;
   if(m_cast.parts.mantisa == 0){
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
   float tmpMax = (x.max == +infinityf()) ? maxnormalf() : x.max;
   float tmpMin = (x.min == -infinityf()) ? -maxnormalf() : x.min;
   float m = fmaxFlt(tmpMin, tmpMax);
   float m_e = minFloatBaseOnExponent(m);
   float min,max;
   if(m == fabs(tmpMin)){
      min = x.min;
      max = minFlt(-m_e,x.max);
   }else{
      min = maxFlt(m_e,x.min);
      max = x.max;
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
