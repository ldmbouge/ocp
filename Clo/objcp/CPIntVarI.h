/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSetI.h>
#import <CPUKernel/CPTrigger.h>
#import <CPUKernel/CPConstraintI.h>
#import <CPUKernel/CPTrigger.h>
#import <objcp/CPData.h>
#import <objcp/CPDom.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPBitDom.h>


@protocol CPIntVarSubscriber <NSObject>

// AC3 Closure Event 
-(void) whenBindDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c; 
-(void) whenChangeMinDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c; 
-(void) whenChangeMaxDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c; 
-(void) whenChangeBoundsDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c; 

-(void) whenBindDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c; 
-(void) whenChangeMinDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c; 
-(void) whenChangeMaxDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c; 
-(void) whenChangeBoundsDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c; 

// AC3 Constraint Event 
-(void) whenBindPropagate: (CPCoreConstraint*) c priority: (ORInt) p;
-(void) whenChangePropagate:  (CPCoreConstraint*) c priority: (ORInt) p; 
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p; 
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p; 
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c priority: (ORInt) p; 

-(void) whenBindPropagate: (CPCoreConstraint*) c;
-(void) whenChangePropagate:  (CPCoreConstraint*) c; 
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c; 
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c; 
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c; 

// AC5 Event
-(void) whenLoseValue: (CPCoreConstraint*) c do: (ConstraintIntCallBack) todo;

// Triggers
// create a trigger which executes todo when value val is removed.
-(id<CPTrigger>) setLoseTrigger: (ORInt) val do: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
// create a trigger which executes todo when the variable is bound.
-(id<CPTrigger>) setBindTrigger: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
// assign a trigger which is executed when value val is removed.
-(void) watch:(ORInt) val with: (id<CPTrigger>) t;

@end

// Interface for CP extensions

@protocol CPIntVarExtendedItf <CPIntVarSubscriber>
-(ORStatus) updateMin: (ORInt) newMin;
-(ORStatus) updateMax: (ORInt) newMax;
-(ORStatus) updateMin: (ORInt) newMin andMax:(ORInt)newMax;
-(ORStatus) bind: (ORInt) val;
-(ORStatus) remove: (ORInt) val;
@end

typedef struct  {
    TRId         _boundsEvt;
    TRId           _bindEvt;
    TRId            _domEvt;
    TRId            _minEvt;
    TRId            _maxEvt;
    TRId               _ac5;
} CPEventNetwork;

@class CPIntVarI;
@class CPLiterals;
@class CPIntVarMultiCast;
// This is really an implementation protocol
// PVH: Not sure that it brings anything to have a CPIntVarNotifier Interface
// PVH: my recommendation is to have an interface and this becomes the implementation class
@protocol CPIntVarNotifier <NSObject>
// [pvh] What is this?
-(ORInt)getId;
-(NSMutableSet*)constraints;
-(void)setDelegate:(id<CPIntVarNotifier>)delegate;
-(void) addVar:(CPIntVarI*)var;
-(enum CPVarClass)varClass;
-(CPLiterals*)findLiterals:(CPIntVarI*)ref;
-(CPIntVarI*)findAffine:(ORInt)scale shift:(ORInt)shift;
-(CPLiterals*)literals;
-(void) setTracksLoseEvt;
-(ORBool) tracksLoseEvt:(id<CPDom>)sender;
-(ORStatus) bindEvt:(id<CPDom>)sender;
-(ORStatus) changeMinEvt:(ORInt) dsz sender:(id<CPDom>)sender;
-(ORStatus) changeMaxEvt:(ORInt) dsz sender:(id<CPDom>)sender;
-(ORStatus) loseValEvt: (ORInt) val sender:(id<CPDom>)sender;
@end

@interface CPIntVarI : ORObject<CPIntVar,CPIntVarNotifier,CPIntVarSubscriber,CPIntVarExtendedItf> {
@package
   enum CPVarClass                      _vc;
   BOOL                             _isBool;
   CPEngineI*                          _fdm;
   id<CPDom>                           _dom;
   CPEventNetwork                      _net;
   id<CPTriggerMap>               _triggers;
   CPIntVarMultiCast*                 _recv;
}
-(CPIntVarI*) initCPIntVarCore:(id<CPEngine>) cp low:(ORInt)low up:(ORInt)up;
-(CPIntVarI*) initCPIntVarView: (id<CPEngine>) cp low: (ORInt) low up: (ORInt) up for: (CPIntVarI*) x;
-(void) dealloc;
-(enum CPVarClass)varClass;
-(ORBool) isBool;
-(NSString*) description;
-(CPEngineI*) engine;
-(id<ORTracker>) tracker;
-(NSMutableSet*)constraints;
-(CPBitDom*)flatDomain;
-(CPLiterals*)literals;

// needed for speeding the code when not using AC5
-(ORBool) tracksLoseEvt:(id<CPDom>)sender;
-(void) setTracksLoseEvt;

// subscription

-(void) whenBindDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf: (CPCoreConstraint*)c;
-(void) whenChangeDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf: (CPCoreConstraint*)c; 
-(void) whenChangeMinDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf: (CPCoreConstraint*)c; 
-(void) whenChangeMaxDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf: (CPCoreConstraint*)c; 
-(void) whenChangeBoundsDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf: (CPCoreConstraint*)c; 

// PVH: Why is this thing not with the same syntax
-(void) whenLoseValue: (CPCoreConstraint*)c do: (ConstraintIntCallBack) todo;

// triggers

-(id<CPTrigger>) setLoseTrigger: (ORInt) val do: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
-(id<CPTrigger>) setBindTrigger: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
-(void) watch: (ORInt) val with: (id<CPTrigger>) t;
-(void) createTriggers;

// notification

-(ORStatus) bindEvt:(id<CPDom>)sender;
-(ORStatus) changeMinEvt: (ORInt) dsz sender:(id<CPDom>)sender;
-(ORStatus) changeMaxEvt: (ORInt) dsz sender:(id<CPDom>)sender;
-(ORStatus) loseValEvt: (ORInt)val sender:(id<CPDom>)sender;

// delegation

-(id<CPIntVarNotifier>) delegate;
-(void) setDelegate:(id<CPIntVarNotifier>)d;

// access

-(ORBool) bound;
-(ORInt) min;
-(ORInt) max;
-(ORInt) value;
-(ORInt) intValue;
-(ORBounds)bounds;
-(ORInt) domsize;
-(ORBool) member:(ORInt)v;
-(ORRange) around:(ORInt)v;
-(id<CPDom>) domain;
-(ORInt) shift;
-(ORInt) scale;
-(id<ORIntVar>)base;
-(ORInt)countFrom:(ORInt)from to:(ORInt)to;

// update
-(ORStatus)     updateMin: (ORInt) newMin;
-(ORStatus)     updateMax: (ORInt) newMax;
-(ORStatus)     updateMin: (ORInt) newMin andMax:(ORInt)newMax;
-(ORStatus)     bind:(ORInt) val;
-(ORStatus)     remove:(ORInt) val;
-(ORStatus)     inside:(ORIntSetI*) S;

// Class methods
+(CPIntVarI*)    initCPIntVar: (id<CPEngine>) fdm bounds:(id<ORIntRange>)b;
+(CPIntVarI*)    initCPIntVar: (id<CPEngine>) fdm low:(ORInt)low up:(ORInt)up;
+(CPIntVarI*)    initCPBoolVar:(id<CPEngine>) fdm;
+(CPIntVarI*)    initCPFlipView:(id<CPIntVar>)x;
+(CPIntVarI*)    initCPIntView: (id<CPIntVar>)x withShift:(ORInt)b;
+(CPIntVarI*)    initCPIntView: (id<CPIntVar>)x withScale:(ORInt)a;
+(CPIntVarI*)    initCPIntView: (id<CPIntVar>)x withScale:(ORInt)a andShift:(ORInt)b;
+(CPIntVarI*)    initCPNegateBoolView:(id<CPIntVar>)x;
//-(id<ORIntVar>) dereference;
@end

// ---------------------------------------------------------------------
// Views

@interface CPIntShiftView : CPIntVarI {
   @package
   ORInt       _b;
   CPIntVarI*  _x;
}
-(CPIntShiftView*)initIVarShiftView:(CPIntVarI*)x b:(ORInt)b;
-(void)dealloc;
-(CPBitDom*)flatDomain;
-(ORBool) bound;
-(ORInt) min;
-(ORInt) max;
-(ORBounds)bounds;
-(ORBool)member:(ORInt)v;
-(ORInt) domsize;
-(ORRange)around:(ORInt)v;
-(ORInt) shift;
-(ORInt) scale;
-(ORStatus)updateMin:(ORInt)newMin;
-(ORStatus)updateMax:(ORInt)newMax;
-(ORStatus)updateMin:(ORInt) newMin andMax:(ORInt)newMax;
-(ORStatus)bind:(ORInt)val;
-(ORStatus)remove:(ORInt)val;
-(ORStatus) loseValEvt:(ORInt)val sender:(id<CPDom>)sender;
@end

@interface CPIntView : CPIntVarI { // Affine View
   @package
    ORInt _a;
    ORInt _b;
   CPIntVarI*  _x;
}
-(CPIntView*)initIVarAViewFor: (ORInt) a  x:(CPIntVarI*)x b:(ORInt)b;
-(void)dealloc;
-(CPBitDom*)flatDomain;
-(ORBool) bound;
-(ORInt) min;
-(ORInt) max;
-(ORBounds)bounds;
-(ORBool)member:(ORInt)v;
-(ORInt) domsize;
-(ORRange)around:(ORInt)v;
-(ORInt) shift;
-(ORInt) scale;
-(ORStatus)updateMin:(ORInt)newMin;
-(ORStatus)updateMax:(ORInt)newMax;
-(ORStatus)updateMin:(ORInt) newMin andMax:(ORInt)newMax;
-(ORStatus)bind:(ORInt)val;
-(ORStatus)remove:(ORInt)val;
-(ORStatus) loseValEvt:(ORInt)val sender:(id<CPDom>)sender;
@end

@interface CPIntFlipView : CPIntVarI { // Flip View (y == -x)
   @package
   CPIntVarI*  _x;
}
-(CPIntFlipView*)initFlipViewFor:(CPIntVarI*)x;
-(void)dealloc;
-(CPBitDom*)flatDomain;
-(ORBool) bound;
-(ORInt) min;
-(ORInt) max;
-(ORBounds)bounds;
-(ORBool)member:(ORInt)v;
-(ORInt) domsize;
-(ORRange)around:(ORInt)v;
-(ORInt) shift;
-(ORInt) scale;
-(ORStatus)updateMin:(ORInt)newMin;
-(ORStatus)updateMax:(ORInt)newMax;
-(ORStatus)updateMin:(ORInt) newMin andMax:(ORInt)newMax;
-(ORStatus)bind:(ORInt)val;
-(ORStatus)remove:(ORInt)val;
-(ORStatus) loseValEvt:(ORInt)val sender:(id<CPDom>)sender;
@end

@interface CPEQLitView : CPIntVarI { // Literal view b <=> x == v
   @package
   ORInt              _v;
   CPIntVarI* _secondary;  // pointer to the original variable (x)
}
-(CPEQLitView*)initEQLitViewFor:(CPIntVarI*)x equal:(ORInt)v;
-(void)dealloc;
-(CPBitDom*)flatDomain;
-(ORBool) bound;
-(ORInt) min;
-(ORInt) max;
-(ORBounds)bounds;
-(ORInt) domsize;
-(ORBool)member:(ORInt)v;
-(ORRange)around:(ORInt)v;
-(ORInt) shift;
-(ORInt) scale;
-(ORStatus)updateMin:(ORInt)newMin;
-(ORStatus)updateMax:(ORInt)newMax;
-(ORStatus)updateMin:(ORInt) newMin andMax:(ORInt)newMax;
-(ORStatus)bind:(ORInt)val;
-(ORStatus)remove:(ORInt)val;
@end

static inline BOOL bound(CPIntVarI* x)
{
   switch(x->_vc) {
      case CPVCBare: return ((CPBoundsDom*)x->_dom)->_sz._val == 1;
      case CPVCShift:  return bound(((CPIntShiftView*)x)->_x);
      case CPVCAffine: return bound(((CPIntView*)x)->_x);
      case CPVCFlip: return bound(((CPIntFlipView*)x)->_x);
      default: return [x bound];
   }   
}

static inline ORInt minDom(CPIntVarI* x)
{
   switch (x->_vc) {
      case CPVCBare:  return ((CPBoundsDom*)x->_dom)->_min._val;
      case CPVCShift: return minDom(((CPIntShiftView*)x)->_x) + ((CPIntShiftView*)x)->_b;
      default: return [x min];
   }
}

static inline ORInt maxDom(CPIntVarI* x)
{
   switch (x->_vc) {
      case CPVCBare:  return ((CPBoundsDom*)x->_dom)->_max._val;
      case CPVCShift: return maxDom(((CPIntShiftView*)x)->_x) + ((CPIntShiftView*)x)->_b;
      default: return [x max];
   }
}

#define DOMX ((CPBoundsDom*)x->_dom)
static inline ORBounds bounds(CPIntVarI* x)
{
   switch (x->_vc) {
      case CPVCBare:  return (ORBounds){DOMX->_min._val,DOMX->_max._val};
      case CPVCShift: {
         ORBounds b = bounds(((CPIntShiftView*)x)->_x);
         ORInt    c =((CPIntShiftView*)x)->_b;
         return (ORBounds){b.min + c,b.max + c};
      }
         /*
      case CPVCAffine: {
         ORBounds b = bounds(((CPIntView*)x)->_x);
         ORInt fmin = b.min * ((CPIntView*)x)->_a + ((CPIntView*)x)->_b;
         ORInt fmax = b.max * ((CPIntView*)x)->_a + ((CPIntView*)x)->_b;
         if (((CPIntView*)x)->_a > 0)
            return (ORBounds){fmin,fmax};
         else
            return (ORBounds){fmax,fmin};
      }*/
      default: return [x bounds];
   }
}
#undef DOMX

static inline ORBounds negBounds(CPIntVarI* x)
{
   ORBounds b = [x bounds];
   return (ORBounds){- b.max, -b.min};
}

static inline ORInt memberDom(CPIntVarI* x,ORInt value)
{
   switch (x->_vc) {
      case CPVCBare:
         return domMember((CPBoundsDom*)x->_dom, value);
         break;
      case CPVCShift: {
         const ORInt b = ((CPIntShiftView*)x)->_b;
         return memberDom(((CPIntShiftView*)x)->_x, value - b);
      }break;
      default:
         return [x member:value];
   }
}

static inline ORInt memberBitDom(CPIntVarI* x,ORInt value)
{
   switch (x->_vc) {
      case CPVCBare:
         return getCPDom((CPBitDom*)x->_dom, value);
         break;
      case CPVCShift: {
         const ORInt b = ((CPIntShiftView*)x)->_b;
         return memberBitDom(((CPIntShiftView*)x)->_x, value - b);
      }
      default:
         return [x member:value];
         break;
   }
}

static inline ORStatus removeDom(CPIntVarI* x,ORInt v)
{
   switch (x->_vc) {
      case CPVCBare:
         return [x->_dom remove:v for:x];
      case CPVCShift: {
         const ORInt b = ((CPIntShiftView*)x)->_b;
         return removeDom(((CPIntShiftView*)x)->_x, v - b);
      }
      default:
         return [x remove:v];
   }
}

static inline ORStatus bindDom(CPIntVarI* x,ORInt v)
{
   switch(x->_vc) {
      case CPVCBare:
         return [x->_dom bind:v for:x];
      default:
         return [x bind:v];
   }
}

/*****************************************************************************************/
/*                        MultiCast Notifier                                             */
/*****************************************************************************************/

@interface CPIntVarMultiCast : NSObject<CPIntVarNotifier> {
   id<CPIntVarNotifier>* _tab;
   BOOL        _tracksLoseEvt;
   ORInt                  _nb;
   ORInt                  _mx;
   UBType*        _loseValIMP;
   UBType*            _minIMP;
   UBType*            _maxIMP;
}
-(id)initVarMC:(ORInt)n root:(CPIntVarI*)root;
-(void) dealloc;
-(enum CPVarClass)varClass;
-(CPLiterals*)literals;
-(void) addVar:(CPIntVarI*) v;
-(NSMutableSet*)constraints;
-(ORStatus) bindEvt:(id<CPDom>)sender;
-(ORStatus) changeMinEvt:(ORInt)dsz sender:(id<CPDom>)sender;
-(ORStatus) changeMaxEvt:(ORInt)dsz sender:(id<CPDom>)sender;
-(ORStatus) loseValEvt:(ORInt)val sender:(id<CPDom>)sender;
@end

@interface CPLiterals : NSObject<CPIntVarNotifier> {
   CPIntVarI*  _ref;
   CPIntVarI** _pos;
   ORInt        _nb;
   ORInt       _ofs;
   BOOL        _tracksLoseEvt;
}
-(id)initCPLiterals:(CPIntVarI*)ref;
-(void)dealloc;
-(enum CPVarClass)varClass;
-(CPLiterals*)literals;
-(NSMutableSet*)constraints;
-(void)addPositive:(id<CPIntVar>)x forValue:(ORInt)value;
-(id<CPIntVar>)positiveForValue:(ORInt)value;
-(ORStatus) bindEvt:(id<CPDom>)sender;
-(ORStatus) changeMinEvt:(ORInt)dsz sender:(id<CPDom>)sender;
-(ORStatus) changeMaxEvt:(ORInt)dsz sender:(id<CPDom>)sender;
-(ORStatus) loseValEvt:(ORInt)val sender:(id<CPDom>)sender;
@end

