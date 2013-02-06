/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORExprI.h>
#import <ORFoundation/ORSetI.h>
#import <CPUKernel/CPTrigger.h>
#import <CPUKernel/CPConstraintI.h>
#import <CPUKernel/CPTrigger.h>
#import <objcp/CPData.h>
#import <objcp/CPDom.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPBitDom.h>
#import <objcp/CPSolverI.h>

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
// This is really an implementation protocol
// PVH: Not sure that it brings anything to have a CPIntVarNotifier Interface
// PVH: my recommendation is to have an interface and this becomes the implementation class
@protocol CPIntVarNotifier <NSObject>
// [pvh] What is this?
-(ORInt)getId;
-(void)setDelegate:(id<CPIntVarNotifier>)delegate;
-(void) addVar:(CPIntVarI*)var;
-(enum CPVarClass)varClass;
-(CPLiterals*)findLiterals:(CPIntVarI*)ref;
-(CPIntVarI*)findAffine:(ORInt)scale shift:(ORInt)shift;
-(CPLiterals*)literals;
-(void) setTracksLoseEvt;
-(bool) tracksLoseEvt:(id<CPDom>)sender;
-(ORStatus) bindEvt:(id<CPDom>)sender;
-(ORStatus) changeMinEvt:(ORInt) dsz sender:(id<CPDom>)sender;
-(ORStatus) changeMaxEvt:(ORInt) dsz sender:(id<CPDom>)sender;
-(ORStatus) loseValEvt: (ORInt) val sender:(id<CPDom>)sender;
@end



@interface CPIntVarI : NSObject<CPIntVar,CPIntVarNotifier,CPIntVarSubscriber,CPIntVarExtendedItf,NSCoding> {
@package
   enum CPVarClass                      _vc;
   ORUInt                         _isBool:1;
   ORUInt                          _name:31;
   CPEngineI*                          _fdm;
   id<CPDom>                           _dom;
   CPEventNetwork                      _net;
   id<CPTriggerMap>               _triggers;
   id<CPIntVarNotifier,NSCoding>      _recv;
}
-(CPIntVarI*) initCPIntVarCore:(id<CPEngine>) cp low:(ORInt)low up:(ORInt)up;
-(CPIntVarI*) initCPIntVarView: (id<CPEngine>) cp low: (ORInt) low up: (ORInt) up for: (CPIntVarI*) x;
-(void) dealloc;
-(enum CPVarClass)varClass;
-(void) setId:(ORUInt)name;
-(ORUInt)getId;
-(BOOL) isBool;
-(NSString*) description;
-(CPEngineI*) engine;
-(id<ORTracker>) tracker;
-(NSSet*)constraints;
-(CPBitDom*)flatDomain;
-(CPLiterals*)literals;

// needed for speeding the code when not using AC5
-(bool) tracksLoseEvt:(id<CPDom>)sender;
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

-(bool) bound;
-(ORInt) min;
-(ORInt) max;
-(ORInt) value;
-(ORBounds)bounds;
-(ORInt) domsize;
-(bool) member:(ORInt)v;
-(ORRange) around:(ORInt)v;
-(id<CPDom>) domain;
-(ORInt) shift;
-(ORInt) scale;
-(id<ORIntVar>)base;
-(ORInt)countFrom:(ORInt)from to:(ORInt)to;
-(void)restoreDomain:(id<CPDom>)toRestore;
-(void)restoreValue:(ORInt)toRestore;
-(void)restore:(id<ORSnapshot>)s;

// update
-(ORStatus)     updateMin: (ORInt) newMin;
-(ORStatus)     updateMax: (ORInt) newMax;
-(ORStatus)     updateMin: (ORInt) newMin andMax:(ORInt)newMax;
-(ORStatus)     bind:(ORInt) val;
-(ORStatus)     remove:(ORInt) val;
-(ORStatus)     inside:(ORIntSetI*) S;
//-(id)           snapshot;
// Class methods
+(CPIntVarI*)    initCPIntVar: (id<CPEngine>) fdm bounds:(id<ORIntRange>)b;
+(CPIntVarI*)    initCPIntVar: (id<CPEngine>) fdm low:(ORInt)low up:(ORInt)up;
+(CPIntVarI*)    initCPBoolVar:(id<CPEngine>) fdm;
+(CPIntVarI*)    initCPFlipView:(id<CPIntVar>)x;
+(CPIntVarI*)    initCPIntView: (id<CPIntVar>)x withShift:(ORInt)b;
+(CPIntVarI*)    initCPIntView: (id<CPIntVar>)x withScale:(ORInt)a;
+(CPIntVarI*)    initCPIntView: (id<CPIntVar>)x withScale:(ORInt)a andShift:(ORInt)b;
+(CPIntVarI*)    initCPNegateBoolView:(id<CPIntVar>)x;
-(id<ORIntVar>) dereference;
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
-(ORInt) min;
-(ORInt) max;
-(ORBounds)bounds;
-(bool)member:(ORInt)v;
-(ORRange)around:(ORInt)v;
-(ORInt) shift;
-(ORInt) scale;
-(ORStatus)updateMin:(ORInt)newMin;
-(ORStatus)updateMax:(ORInt)newMax;
-(ORStatus)updateMin:(ORInt) newMin andMax:(ORInt)newMax;
-(ORStatus)bind:(ORInt)val;
-(ORStatus)remove:(ORInt)val;
-(ORStatus) loseValEvt:(ORInt)val sender:(id<CPDom>)sender;
-(id)           snapshot;
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
-(ORInt) min;
-(ORInt) max;
-(ORBounds)bounds;
-(bool)member:(ORInt)v;
-(ORRange)around:(ORInt)v;
-(ORInt) shift;
-(ORInt) scale;
-(ORStatus)updateMin:(ORInt)newMin;
-(ORStatus)updateMax:(ORInt)newMax;
-(ORStatus)updateMin:(ORInt) newMin andMax:(ORInt)newMax;
-(ORStatus)bind:(ORInt)val;
-(ORStatus)remove:(ORInt)val;
-(ORStatus) loseValEvt:(ORInt)val sender:(id<CPDom>)sender;
-(id)           snapshot;
@end

@interface CPIntFlipView : CPIntVarI { // Flip View (y == -x)
   @package
   CPIntVarI*  _x;
}
-(CPIntFlipView*)initFlipViewFor:(CPIntVarI*)x;
-(void)dealloc;
-(CPBitDom*)flatDomain;
-(ORInt) min;
-(ORInt) max;
-(ORBounds)bounds;
-(bool)member:(ORInt)v;
-(ORRange)around:(ORInt)v;
-(ORInt) shift;
-(ORInt) scale;
-(ORStatus)updateMin:(ORInt)newMin;
-(ORStatus)updateMax:(ORInt)newMax;
-(ORStatus)updateMin:(ORInt) newMin andMax:(ORInt)newMax;
-(ORStatus)bind:(ORInt)val;
-(ORStatus)remove:(ORInt)val;
-(ORStatus) loseValEvt:(ORInt)val sender:(id<CPDom>)sender;
-(id)           snapshot;
@end

@interface CPEQLitView : CPIntVarI { // Literal view b <=> x == v
   @package
   ORInt              _v;
   CPIntVarI* _secondary;  // pointer to the original variable (x)
}
-(CPEQLitView*)initEQLitViewFor:(CPIntVarI*)x equal:(ORInt)v;
-(void)dealloc;
-(CPBitDom*)flatDomain;
-(ORInt) min;
-(ORInt) max;
-(ORBounds)bounds;
-(bool)member:(ORInt)v;
-(ORRange)around:(ORInt)v;
-(ORInt) shift;
-(ORInt) scale;
-(ORStatus)updateMin:(ORInt)newMin;
-(ORStatus)updateMax:(ORInt)newMax;
-(ORStatus)updateMin:(ORInt) newMin andMax:(ORInt)newMax;
-(ORStatus)bind:(ORInt)val;
-(ORStatus)remove:(ORInt)val;
-(id) snapshot;
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
      default: return [x min];
   }
}

static inline ORInt maxDom(CPIntVarI* x)
{
   switch (x->_vc) {
      case CPVCBare:  return ((CPBoundsDom*)x->_dom)->_max._val;
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
         return (ORBounds){b.min + ((CPIntShiftView*)x)->_b,b.max + ((CPIntShiftView*)x)->_b};
      }
      case CPVCAffine: {
         ORBounds b = bounds(((CPIntView*)x)->_x);
         ORInt fmin = b.min * ((CPIntView*)x)->_a + ((CPIntView*)x)->_b;
         ORInt fmax = b.max * ((CPIntView*)x)->_a + ((CPIntView*)x)->_b;
         if (((CPIntView*)x)->_a > 0)
            return (ORBounds){fmin,fmax};
         else
            return (ORBounds){fmax,fmin};
      }
      case CPVCEQLiteral: return [x bounds];
      case CPVCFlip: return [x bounds];
      default:assert(NO);return (ORBounds){0,0};
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
      default:
         return [x member:value];
   }
}

static inline ORInt memberBitDom(CPIntVarI* x,ORInt value)
{
   switch (x->_vc) {
      case CPVCBare:
         return domMember((CPBoundsDom*)x->_dom, value);
         break;
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

@interface CPIntVarMultiCast : NSObject<CPIntVarNotifier,NSCoding> {
   id<CPIntVarNotifier>* _tab;
   BOOL        _tracksLoseEvt;
   ORInt                  _nb;
   ORInt                  _mx;
   UBType*        _loseValIMP;
}
-(id)initVarMC:(ORInt)n root:(CPIntVarI*)root;
-(void) dealloc;
-(enum CPVarClass)varClass;
-(CPLiterals*)literals;
-(void) addVar:(CPIntVarI*) v;
-(ORStatus) bindEvt:(id<CPDom>)sender;
-(ORStatus) changeMinEvt:(ORInt)dsz sender:(id<CPDom>)sender;
-(ORStatus) changeMaxEvt:(ORInt)dsz sender:(id<CPDom>)sender;
-(ORStatus) loseValEvt:(ORInt)val sender:(id<CPDom>)sender;
@end

@interface CPLiterals : NSObject<CPIntVarNotifier,NSCoding> {
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
-(void)addPositive:(id<CPIntVar>)x forValue:(ORInt)value;
-(id<CPIntVar>)positiveForValue:(ORInt)value;
-(ORStatus) bindEvt:(id<CPDom>)sender;
-(ORStatus) changeMinEvt:(ORInt)dsz sender:(id<CPDom>)sender;
-(ORStatus) changeMaxEvt:(ORInt)dsz sender:(id<CPDom>)sender;
-(ORStatus) loseValEvt:(ORInt)val sender:(id<CPDom>)sender;
@end

