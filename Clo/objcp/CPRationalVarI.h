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
#import <objcp/CPFloatVarI.h>
#import <objcp/CPDoubleVarI.h>
#include "fpi.h"
#import "rationalUtilities.h"

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
-(void) updateMin: (id<ORRational>) newMin;
-(void) updateMinF: (ORDouble) newMinError;
-(void) updateMax: (id<ORRational>) newMax;
-(void) updateMaxF: (ORDouble) newMaxError;
-(void) updateInterval: (id<ORRational>) newMin and: (id<ORRational>)newMax;
-(void) bind: (id<ORRational>) val;
@end


@class CPRationalVarI;
@protocol CPRationalVarNotifier <NSObject>
-(CPRationalVarI*) findAffine: (id<ORRational>) scale shift: (id<ORRational>) shift;
-(void) bindEvt:(id<CPRationalDomN>)sender;
-(void) changeMinEvt:(ORBool) bound sender:(id<CPRationalDomN>)sender;
-(void) changeMaxEvt:(ORBool) bound sender:(id<CPRationalDomN>)sender;
@end

@interface CPRationalVarI : ORObject<CPRationalVar,CPRationalVarNotifier,CPRationalVarExtendedItf> {
   CPEngineI*               _engine;
   BOOL                     _hasValue;
   id<ORRational>              _value;    // This value is only used for storing the value of the variable in linear/convex relaxation. Bounds only are safe
   id<CPRationalDomN>       _dom;
   //CPRationalEventNetwork   _net;
   CPMultiCast*             _recv;
}
-(id)init:(id<CPEngine>)engine low:(id<ORRational>)low up:(id<ORRational>)up;
-(id)init:(id<CPEngine>)engine;
-(id<CPEngine>) engine;
-(id<ORTracker>) tracker;
-(NSMutableSet*) constraints;
-(ORLDouble) domwidth;
-(id<ORRational>) rationalValue;
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


static inline bool isDisjointWithVQ(id<ORRational> xmin, id<ORRational> xmax, id<ORRational> ymin, id<ORRational> ymax)
{
   return ([xmax lt: ymin]) || ([ymax lt: xmin]);
}
static inline bool isDisjointWithQ(CPRationalVarI* x, CPRationalVarI* y)
{
   return isDisjointWithVQ([x min], [x max], [y min], [y max]);
}
static inline bool isIntersectingWithQ(CPRationalVarI* x, CPRationalVarI* y)
{
   return !isDisjointWithVQ([x min],[x max], [y min], [y max]);
}
static inline bool isDisjointWithQF(CPFloatVarI* x, CPRationalVarI* y)
{
   return isDisjointWithVQ([x minErr], [x maxErr], [y min], [y max]);
}
static inline bool isDisjointWithQFC(CPFloatVarI* x, CPRationalVarI* y)
{
   id<ORRational> xminRat = [ORRational rationalWith_d:x.min];
   id<ORRational> xmaxRat = [ORRational rationalWith_d:x.max];
   BOOL res = isDisjointWithVQ(xminRat, xmaxRat, [y min], [y max]);
   [xminRat release];
   [xmaxRat release];
   return res;
}
static inline bool isDisjointWithQD(CPDoubleVarI* x, CPRationalVarI* y)
{
   return isDisjointWithVQ([x minErr], [x maxErr], [y min], [y max]);
}
static inline bool isDisjointWithQDC(CPDoubleVarI* x, CPRationalVarI* y)
{
   id<ORRational> xminRat = [ORRational rationalWith_d:x.min];
   id<ORRational> xmaxRat = [ORRational rationalWith_d:x.max];
   BOOL res = isDisjointWithVQ(xminRat, xmaxRat, [y min], [y max]);
   [xminRat release];
   [xmaxRat release];
   return res;
}
#endif /* CPRationalVarI_h */
