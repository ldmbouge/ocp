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

typedef struct  {
   TRId           _bindEvt;
   TRId            _minEvt;
   TRId            _maxEvt;
   TRId         _boundsEvt;
} CPFloatEventNetwork;

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
   id<CPFloatDom>            _dom;
   CPFloatEventNetwork      _net;
   CPMultiCast*             _recv;
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
static inline unsigned long long cardinalityV(float xmin, float xmax){
   float_cast i_inf;
   float_cast i_sup;
   i_inf.f = xmin;
   i_sup.f = xmax;
   if(xmin == xmax) return 1.0;
   if(xmin == -infinityf() && xmax == infinityf()) return ((unsigned long long) DBL_MAX);
   long long res = (sign(i_sup) * i_sup.parts.exponent - sign(i_inf) * i_inf.parts.exponent) * NB_FLOAT_BY_E - i_inf.parts.mantisa + i_sup.parts.mantisa;
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

static inline ORDouble cardinality(CPFloatVarI* x)
{
   return cardinalityV([x min], [x max]);
}

static inline float_interval makeFloatInterval(float min, float max)
{
   return (float_interval){min,max};
}
static inline void setFloatInterval(float min, float max,float_interval * ft)
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
