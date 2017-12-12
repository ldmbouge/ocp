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
-(void) updateMax: (ORRational) newMax;
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
-(void) bindEvt:(id<CPRationalDom>)sender;
-(void) changeMinEvt:(ORBool) bound sender:(id<CPRationalDom>)sender;
-(void) changeMaxEvt:(ORBool) bound sender:(id<CPRationalDom>)sender;
@end

@interface CPRationalVarI : ORObject<CPRationalVar,CPRationalVarNotifier,CPRationalVarExtendedItf> {
    CPEngineI*               _engine;
    BOOL                     _hasValue;
    ORRational               _value;    // This value is only used for storing the value of the variable in linear/convex relaxation. Bounds only are safe
    id<CPRationalDom>            _dom;
    CPRationalEventNetwork      _net;
    CPMultiCast*             _recv;
}
-(id)init:(id<CPEngine>)engine low:(ORRational)low up:(ORRational)up;
-(id<CPEngine>) engine;
-(id<ORTracker>) tracker;
-(NSMutableSet*) constraints;
-(ORRational*) rationalValue;
//-(ORLDouble) domwidth;
-(TRRationalInterval) domain;
@end

@interface CPRationalViewOnIntVarI : ORObject<CPRationalVar,CPRationalVarExtendedItf,CPIntVarNotifier> {
    CPEngineI* _engine;
    CPIntVar* _theVar;
    CPRationalEventNetwork _net;
}
-(id)init:(id<CPEngine>)engine intVar:(CPIntVar*)iv;
-(CPEngineI*)    engine;
-(id<ORTracker>) tracker;
-(NSMutableSet*) constraints;
@end

/*useful struct to get exponent mantissa and sign*/
typedef union {
    ORRational f;
    struct {
        unsigned int mantisa : 23;
        unsigned int exponent : 8;
        unsigned int sign : 1;
    } parts;
} rational_cast;

typedef struct {
    rational_interval  result;
    rational_interval  interval;
    int  changed;
} intersectionIntervalR;

static inline int signR(rational_cast p){
    if(p.parts.sign) return -1;
    return 1;
}

static inline bool isDisjointWithVR(ORRational xmin,ORRational xmax,ORRational ymin,ORRational ymax)
{
    return (mpq_cmp(xmin, ymin) < 0 &&  mpq_cmp(xmax, ymin) < 0) || (mpq_cmp(ymin, xmin) < 0 && mpq_cmp(ymax, xmin) < 0);
}

static inline bool isIntersectingWithVR(ORRational xmin,ORRational xmax,ORRational ymin,ORRational ymax)
{
    return !isDisjointWithVR(xmin,xmax,ymin,ymax);
}

/*static inline unsigned long long cardinalityV(float xmin, float xmax){
 Rational_cast i_inf;
 Rational_cast i_sup;
 i_inf.f = xmin;
 i_sup.f = xmax;
 if(xmin == xmax) return 1.0;
 if(xmin == -infinityf() && xmax == infinityf()) return DBL_MAX;
 long long res = (sign(i_sup) * i_sup.parts.exponent - sign(i_inf) * i_inf.parts.exponent) * NB_FLOAT_BY_E - i_inf.parts.mantisa + i_sup.parts.mantisa;
 return (res < 0) ? -res : res;
 }*/

static inline bool isDisjointWithR(CPRationalVarI* x, CPRationalVarI* y)
{
    return isDisjointWithVR(*[x min], *[x max], *[y min], *[y max]);
}

static inline bool isIntersectingWithR(CPRationalVarI* x, CPRationalVarI* y)
{
    return !isDisjointWithVR(*[x min], *[x max], *[y min], *[y max]);
}

static inline bool canPrecedeR(CPRationalVarI* x, CPRationalVarI* y)
{
    return mpq_cmp(*[x min], *[y min]) < 0 &&  mpq_cmp(*[x max], *[y max]) < 0;
}
static inline bool canFollowR(CPRationalVarI* x, CPRationalVarI* y)
{
    return mpq_cmp(*[x min], *[y min ]) > 0 && mpq_cmp(*[x max], *[y max]) > 0;
}

/*static inline ORDouble cardinality(CPRationalVarI* x)
 {
 return 0.0;//cardinalityV(*[x min], *[x max]);
 }*/
/*static inline float_interval computeAbsordedInterval(CPRationalVarI* x)
 {
 ORRational m, min, max;
 ORInt e;
 mpq_set(m, *fmaxR([x min],[x max]));
 frexpf(m, &e);
 min = -pow(2.0,e - S_PRECISION - 1);
 max = pow(2.0,e - S_PRECISION - 1);
 return (float_interval){min,max};
 }*/

static inline rational_interval makeRationalInterval(ORRational min, ORRational max)
{
    return (rational_interval){*min,*max};
}

static inline intersectionIntervalR intersectionR(int changed,rational_interval r, rational_interval x, ORDouble percent)
{
    /*double reduced = 0;
     if(percent == 0.0)
     fpi_narrowf(&r, &x, &changed);
     else{
     fpi_narrowpercentf(&r, &x, &changed, percent, &reduced);
     }*/
    return (intersectionIntervalR){r,x,changed};
}


