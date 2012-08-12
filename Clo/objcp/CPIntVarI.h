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
#import <objcp/CPData.h>
#import <objcp/CPDom.h>
#import <objcp/CPTrigger.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPBitDom.h>
#import <objcp/CPConstraintI.h>
#import "objcp/CPSolverI.h"

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
-(CPTrigger*) setLoseTrigger: (ORInt) val do: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
// create a trigger which executes todo when the variable is bound.
-(CPTrigger*) setBindTrigger: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
// assign a trigger which is executed when value val is removed.
-(void) watch:(ORInt) val with: (CPTrigger*) t;

@end

// Interface for CP extensions

@protocol CPIntVarExtendedItf <ORIntVar,CPIntVarSubscriber>
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
@class CPTriggerMap;

// This is really an implementation protocol

// PVH: Not sure that it brings anything to have a CPIntVarNotifier Interface
// PVH: my recommendation is to have an interface and this becomes the implementation class
@protocol CPIntVarNotifier <NSObject>
// [pvh] What is this?
@optional -(void) addVar:(CPIntVarI*)var;
-(void) setTracksLoseEvt;
-(bool) tracksLoseEvt;
-(void) bindEvt;
-(void) changeMinEvt:(ORInt) dsz;
-(void) changeMaxEvt:(ORInt) dsz;
-(void) loseValEvt: (ORInt) val;

-(void) loseRangeEvt:(ORClosure) clo;
-(CPIntVarI*)findAffine:(ORInt)scale shift:(ORInt)shift;
@end

enum CPVarClass {
   CPVCBare = 0,
   CPVCShift = 1,
   CPVCAffine = 2
};

@interface CPIntVarI : ORExprI<ORIntVar,CPIntVarNotifier,CPIntVarSubscriber,CPIntVarExtendedItf,NSCoding> {
@package
   enum CPVarClass                   _vc:16;
   CPUInt                        _isBool:16;
   CPUInt                             _name;
   id<CPSolver>                         _cp;
   CPEngineI*                          _fdm;
   id<CPDom>                           _dom;
   CPEventNetwork                      _net;
   CPTriggerMap*                  _triggers;
   id<CPIntVarNotifier,NSCoding>      _recv;
}
-(CPIntVarI*) initCPIntVarCore:(CPSolverI*) cp low:(ORInt)low up:(ORInt)up;
-(CPIntVarI*) initCPIntVarView: (CPSolverI*) cp low: (ORInt) low up: (ORInt) up for: (CPIntVarI*) x;
-(void) dealloc;
-(void) setId:(CPUInt)name;
-(CPUInt)getId;
-(BOOL) isBool;
-(NSString*) description;
-(CPEngineI*) engine;
-(id<CPSolver>) solver;
-(id<ORTracker>) tracker;
-(NSSet*)constraints;
-(CPBitDom*)flatDomain;

// need for speeding the code when not using AC5
-(bool) tracksLoseEvt;
-(void) setTracksLoseEvt;

// subscription

-(void) whenBindDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c; 
-(void) whenChangeMinDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c; 
-(void) whenChangeMaxDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c; 
-(void) whenChangeBoundsDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c; 

// PVH: Why is this thing not with the same syntax
-(void) whenLoseValue: (CPCoreConstraint*)c do: (ConstraintIntCallBack) todo;

// triggers

-(CPTrigger*) setLoseTrigger: (ORInt) val do: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
-(CPTrigger*) setBindTrigger: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
-(void) watch: (ORInt) val with: (CPTrigger*) t;
-(void) createTriggers;

// notification

-(void) bindEvt;
-(void) changeMinEvt:(ORInt)dsz;
-(void) changeMaxEvt:(ORInt)dsz;
-(void) loseValEvt:(ORInt)val;
// delegation

-(id<CPIntVarNotifier>) delegate;
-(void) setDelegate:(id<CPIntVarNotifier>)d;

// access

-(bool) bound;
-(ORInt) min;
-(ORInt) max;
-(ORInt) value;
-(void) bounds:(CPBounds*)bnd;
-(ORInt) domsize;
-(bool) member:(ORInt)v;
-(CPRange) around:(ORInt)v;
-(id<CPDom>) domain;
-(ORInt) shift;
-(ORInt) scale;
-(void)restoreDomain:(id<CPDom>)toRestore;
-(void)restoreValue:(ORInt)toRestore;

// update
-(ORStatus)     updateMin: (ORInt) newMin;
-(ORStatus)     updateMax: (ORInt) newMax;
-(ORStatus)     updateMin: (ORInt) newMin andMax:(ORInt)newMax;
-(ORStatus)     bind:(ORInt) val;
-(ORStatus)     remove:(ORInt) val;
-(ORStatus)     inside:(ORIntSetI*) S;
-(id)           snapshot;
// Class methods
+(CPIntVarI*)    initCPIntVar: (CPSolverI*) fdm bounds:(id<ORIntRange>)b;
+(CPIntVarI*)    initCPIntVar: (CPSolverI*) fdm low:(ORInt)low up:(ORInt)up;
+(CPIntVarI*)    initCPBoolVar:(CPSolverI*) fdm;
+(CPIntVarI*)    initCPIntView: (CPIntVarI*)x withShift:(ORInt)b;
+(CPIntVarI*)    initCPIntView: (CPIntVarI*)x withScale:(ORInt)a;
+(CPIntVarI*)    initCPIntView: (CPIntVarI*)x withScale:(ORInt)a andShift:(ORInt)b;
+(CPIntVarI*)    initCPNegateBoolView:(CPIntVarI*)x;
+(CPTrigger*)    createTrigger: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;

-(id<ORIntVar>) dereference;
@end

// ---------------------------------------------------------------------
// Views

@interface CPIntShiftView : CPIntVarI {
   @package
   ORInt _b;
}
-(CPIntShiftView*)initIVarShiftView:(CPIntVarI*)x b:(ORInt)b;
-(void)dealloc;
-(CPBitDom*)flatDomain;
-(ORInt) min;
-(ORInt) max;
-(void)bounds:(CPBounds*)bnd;
-(bool)member:(ORInt)v;
-(CPRange)around:(ORInt)v;
-(ORInt) shift;
-(ORInt) scale;
-(ORStatus)updateMin:(ORInt)newMin;
-(ORStatus)updateMax:(ORInt)newMax;
-(ORStatus)updateMin:(ORInt) newMin andMax:(ORInt)newMax;
-(ORStatus)bind:(ORInt)val;
-(ORStatus)remove:(ORInt)val;
-(void) loseValEvt:(ORInt)val;
-(id)           snapshot;
@end

@interface CPIntView : CPIntVarI { // Affine View
   @package
    ORInt _a;
    ORInt _b;
}
-(CPIntView*)initIVarAViewFor: (ORInt) a  x:(CPIntVarI*)x b:(ORInt)b;
-(void)dealloc;
-(CPBitDom*)flatDomain;
-(ORInt) min;
-(ORInt) max;
-(void)bounds:(CPBounds*)bnd;
-(bool)member:(ORInt)v;
-(CPRange)around:(ORInt)v;
-(ORInt) shift;
-(ORInt) scale;
-(ORStatus)updateMin:(ORInt)newMin;
-(ORStatus)updateMax:(ORInt)newMax;
-(ORStatus)updateMin:(ORInt) newMin andMax:(ORInt)newMax;
-(ORStatus)bind:(ORInt)val;
-(ORStatus)remove:(ORInt)val;
-(void) loseValEvt:(ORInt)val;
-(id)           snapshot;
@end

static inline BOOL bound(CPIntVarI* x)
{
   return ((CPBoundsDom*)x->_dom)->_sz._val == 1;
}

static inline ORInt minDom(CPIntVarI* x)
{
   switch (x->_vc) {
      case CPVCBare:  return ((CPBoundsDom*)x->_dom)->_min._val;
      case CPVCShift: return ((CPBoundsDom*)x->_dom)->_min._val + ((CPIntShiftView*)x)->_b;
      case CPVCAffine: {
         if (((CPIntView*)x)->_a > 0)
            return ((CPBoundsDom*)x->_dom)->_min._val * ((CPIntView*)x)->_a + ((CPIntView*)x)->_b;            
         else 
            return ((CPBoundsDom*)x->_dom)->_max._val * ((CPIntView*)x)->_a + ((CPIntView*)x)->_b;                  
      }
   }
}

static inline ORInt maxDom(CPIntVarI* x)
{
   switch (x->_vc) {
      case CPVCBare:  return ((CPBoundsDom*)x->_dom)->_max._val;
      case CPVCShift: return ((CPBoundsDom*)x->_dom)->_max._val + ((CPIntShiftView*)x)->_b;
      case CPVCAffine: {
         if (((CPIntView*)x)->_a > 0)
            return ((CPBoundsDom*)x->_dom)->_max._val * ((CPIntView*)x)->_a + ((CPIntView*)x)->_b;            
         else 
            return ((CPBoundsDom*)x->_dom)->_min._val * ((CPIntView*)x)->_a + ((CPIntView*)x)->_b;                  
      }
   }
}

#define DOMX ((CPBoundsDom*)x->_dom)
static inline CPBounds bounds(CPIntVarI* x)
{
   switch (x->_vc) {
      case CPVCBare:  return (CPBounds){DOMX->_min._val,DOMX->_max._val};
      case CPVCShift: return (CPBounds){DOMX->_min._val + ((CPIntShiftView*)x)->_b,
                                        DOMX->_max._val + ((CPIntShiftView*)x)->_b};
      case CPVCAffine: {
         ORInt fmin = DOMX->_min._val * ((CPIntView*)x)->_a + ((CPIntView*)x)->_b;
         ORInt fmax = DOMX->_max._val * ((CPIntView*)x)->_a + ((CPIntView*)x)->_b;
         if (((CPIntView*)x)->_a > 0)
            return (CPBounds){fmin,fmax};
         else
            return (CPBounds){fmax,fmin};
      }
   }
}
#undef DOMX

static inline CPBounds negBounds(CPIntVarI* x)
{
   CPBounds b;
   [x bounds:&b];
   return (CPBounds){- b.max, -b.min};
}


static inline ORInt memberDom(CPIntVarI* x,ORInt value)
{
   ORInt target;
   switch (x->_vc) {
      case CPVCBare: target = value;
         break;
      case CPVCShift:
         target = value - ((CPIntShiftView*)x)->_b;
         break;
      case CPVCAffine: {
         const ORInt a = ((CPIntView*)x)->_a;
         const ORInt b = ((CPIntView*)x)->_b;
         if (a == 1) 
            target = value - b;
         else if (a== -1)
            target = b - value;
         else {
            const ORInt r = (value - b) % a;
            if (r != 0) return NO;
            target = (value - b) / a;
         }
      }break;
   }
   return domMember((CPBoundsDom*)x->_dom, target);
}

static inline ORInt memberBitDom(CPIntVarI* x,ORInt value)
{
   ORInt target;
   switch (x->_vc) {
      case CPVCBare: target = value;
         break;
      case CPVCShift:
         target = value - ((CPIntShiftView*)x)->_b;
         break;
      case CPVCAffine: {
         const ORInt a = ((CPIntView*)x)->_a;
         const ORInt b = ((CPIntView*)x)->_b;
         if (a == 1) 
            target = value - b;
         else if (a== -1)
            target = b - value;
         else {
            const ORInt r = (value - b) % a;
            if (r != 0) return NO;
            target = (value - b) / a;
         }
      }break;
   }
   return getCPDom((CPBitDom*)x->_dom, target);   
}

static inline ORStatus removeDom(CPIntVarI* x,ORInt v)
{
   ORInt target;
   switch (x->_vc) {
      case CPVCBare:  target = v;break;
      case CPVCShift: target = v - ((CPIntShiftView*)x)->_b;break;
      case CPVCAffine: {
         ORInt a = ((CPIntView*)x)->_a;
         ORInt b = ((CPIntView*)x)->_b;
         if (a == -1)
            target = b - v;
         else if (a== 1)
            target = v - b;
         else {
            ORInt r = (v - b) % a;
            if (r != 0) return ORSuspend;
            target = (v - b) / a; 
         }
      }
   }
   return [x->_dom remove:target for:x->_recv];
}

/*****************************************************************************************/
/*                        MultiCast Notifier                                             */
/*****************************************************************************************/

@interface CPIntVarMultiCast : NSObject<CPIntVarNotifier,NSCoding> {
   CPIntVarI**           _tab;
   BOOL        _tracksLoseEvt;
   ORInt                  _nb;
   ORInt                  _mx;
   IMP*           _loseValIMP;
}
-(id)initVarMC:(ORInt)n;
-(void) dealloc;
-(void) addVar:(CPIntVarI*) v;
-(void) bindEvt;
-(void) changeMinEvt:(ORInt)dsz;
-(void) changeMaxEvt:(ORInt)dsz;
-(void) loseValEvt:(ORInt)val;
@end

