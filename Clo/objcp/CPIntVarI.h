/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import "CPData.h"
#import "CPDom.h"
#import "CPConstraint.h"
#import "CPDataI.h"
#import "ORFoundation/ORExprI.h"
#import "ORFoundation/ORSetI.h"
#import "CPBitDom.h"
#import "objc/runtime.h"
#import "CPConstraintI.h"

// PVH: I am not sure that I like the fact that it is a struct
// In any case, this should be hidden evenfrom those with access to extended interface.
// PVH to clean up

typedef struct CPTrigger {
   struct CPTrigger*  _prev;
   struct CPTrigger*  _next;
   ConstraintCallback   _cb;       // var/val held inside the closure (captured).
   CPCoreConstraint*  _cstr;
   CPInt _vId;               // local variable identifier (var being watched)
} CPTrigger;


@protocol CPIntVarSubscriber <NSObject>

// AC3 Closure Event 
-(void) whenBindDo: (ConstraintCallback) todo priority: (CPInt) p onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeDo: (ConstraintCallback) todo priority: (CPInt) p onBehalf:(CPCoreConstraint*)c; 
-(void) whenChangeMinDo: (ConstraintCallback) todo priority: (CPInt) p onBehalf:(CPCoreConstraint*)c; 
-(void) whenChangeMaxDo: (ConstraintCallback) todo priority: (CPInt) p onBehalf:(CPCoreConstraint*)c; 
-(void) whenChangeBoundsDo: (ConstraintCallback) todo priority: (CPInt) p onBehalf:(CPCoreConstraint*)c; 

-(void) whenBindDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c; 
-(void) whenChangeMinDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c; 
-(void) whenChangeMaxDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c; 
-(void) whenChangeBoundsDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c; 

// AC3 Constraint Event 
-(void) whenBindPropagate: (CPCoreConstraint*) c priority: (CPInt) p;
-(void) whenChangePropagate:  (CPCoreConstraint*) c priority: (CPInt) p; 
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (CPInt) p; 
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (CPInt) p; 
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c priority: (CPInt) p; 

-(void) whenBindPropagate: (CPCoreConstraint*) c;
-(void) whenChangePropagate:  (CPCoreConstraint*) c; 
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c; 
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c; 
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c; 

// AC5 Event
-(void) whenLoseValue: (CPCoreConstraint*) c do: (ConstraintIntCallBack) todo;

// Triggers
// create a trigger which executes todo when value val is removed.
-(CPTrigger*) setLoseTrigger: (CPInt) val do: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
// create a trigger which executes todo when the variable is bound.
-(CPTrigger*) setBindTrigger: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
// assign a trigger which is executed when value val is removed.
-(void) watch:(CPInt) val with: (CPTrigger*) t;

@end

// Interface for CP extensions

@protocol CPIntVarExtendedItf <CPIntVar,CPIntVarSubscriber>
-(CPStatus) updateMin: (CPInt) newMin;
-(CPStatus) updateMax: (CPInt) newMax;
-(CPStatus) updateMin: (CPInt) newMin andMax:(CPInt)newMax;
-(CPStatus) bind: (CPInt) val;
-(CPStatus) remove: (CPInt) val;
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
-(void) changeMinEvt:(CPInt) dsz;
-(void) changeMaxEvt:(CPInt) dsz;
-(void) loseValEvt: (CPInt) val;

//-(void) loseRangeEvt:(CPDoRange) clo;
-(void) loseRangeEvt:(CPClosure) clo;
-(CPIntVarI*)findAffine:(CPInt)scale shift:(CPInt)shift;
@end

enum CPVarClass {
   CPVCBare = 0,
   CPVCShift = 1,
   CPVCAffine = 2
};

@interface CPIntVarI : ORExprI<CPIntVarNotifier,CPIntVarSubscriber,CPIntVarExtendedItf,NSCoding> {
@package
   enum CPVarClass                   _vc:16;
   CPUInt                        _isBool:16;
   CPUInt                             _name;
   id<CP>                               _cp;
   CPSolverI*                          _fdm;
   id<CPDom>                           _dom;
   CPEventNetwork                      _net;
   CPTriggerMap*                  _triggers;
   id<CPIntVarNotifier,NSCoding>      _recv;
}
-(CPIntVarI*) initCPIntVarCore:(id<CP>) cp low:(CPInt)low up:(CPInt)up;
-(CPIntVarI*) initCPIntVarView: (id<CP>) cp low: (CPInt) low up: (CPInt) up for: (CPIntVarI*) x;
-(void) dealloc;
-(void) setId:(CPUInt)name;
-(CPUInt)getId;
-(BOOL) isBool;
-(NSString*) description;
-(CPSolverI*) solver;
-(id<CP>) cp;
-(id<ORTracker>) tracker;
-(NSSet*)constraints;
-(CPBitDom*)flatDomain;

// need for speeding the code when not using AC5
-(bool) tracksLoseEvt;
-(void) setTracksLoseEvt;

// subscription

-(void) whenBindDo: (ConstraintCallback) todo priority: (CPInt) p onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeDo: (ConstraintCallback) todo priority: (CPInt) p onBehalf:(CPCoreConstraint*)c; 
-(void) whenChangeMinDo: (ConstraintCallback) todo priority: (CPInt) p onBehalf:(CPCoreConstraint*)c; 
-(void) whenChangeMaxDo: (ConstraintCallback) todo priority: (CPInt) p onBehalf:(CPCoreConstraint*)c; 
-(void) whenChangeBoundsDo: (ConstraintCallback) todo priority: (CPInt) p onBehalf:(CPCoreConstraint*)c; 

// PVH: Why is this thing not with the same syntax
-(void) whenLoseValue: (CPCoreConstraint*)c do: (ConstraintIntCallBack) todo;

// triggers

-(CPTrigger*) setLoseTrigger: (CPInt) val do: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
-(CPTrigger*) setBindTrigger: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
-(void) watch: (CPInt) val with: (CPTrigger*) t;
-(void) createTriggers;

// notification

-(void) bindEvt;
-(void) changeMinEvt:(CPInt)dsz;
-(void) changeMaxEvt:(CPInt)dsz;
-(void) loseValEvt:(CPInt)val;
// delegation

-(id<CPIntVarNotifier>) delegate;
-(void) setDelegate:(id<CPIntVarNotifier>)d;

// access

-(bool) bound;
-(CPInt) min;
-(CPInt) max;
-(CPInt) value;
-(void) bounds:(CPBounds*)bnd;
-(CPInt) domsize;
-(bool) member:(CPInt)v;
-(CPRange)around:(CPInt)v;
-(id<CPDom>) domain;
-(CPInt) shift;
-(CPInt) scale;
-(void)restoreDomain:(id<CPDom>)toRestore;
-(void)restoreValue:(CPInt)toRestore;

// update
-(CPStatus)     updateMin: (CPInt) newMin;
-(CPStatus)     updateMax: (CPInt) newMax;
-(CPStatus)     updateMin: (CPInt) newMin andMax:(CPInt)newMax;
-(CPStatus)     bind:(CPInt) val;
-(CPStatus)     remove:(CPInt) val;
-(CPStatus)     inside:(ORIntSetI*) S;
-(id)           snapshot;
// Class methods
+(CPIntVarI*)    initCPIntVar: (id<CP>)fdm bounds:(CPRange)b;
+(CPIntVarI*)    initCPIntVar: (id<CP>)fdm low:(CPInt)low up:(CPInt)up;
+(CPIntVarI*)    initCPBoolVar:(id<CP>)fdm;
+(CPIntVarI*)    initCPIntView: (CPIntVarI*)x withShift:(CPInt)b;
+(CPIntVarI*)    initCPIntView: (CPIntVarI*)x withScale:(CPInt)a;
+(CPIntVarI*)    initCPIntView: (CPIntVarI*)x withScale:(CPInt)a andShift:(CPInt)b;
+(CPIntVarI*)    initCPNegateBoolView:(CPIntVarI*)x;
+(CPTrigger*)    createTrigger: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
@end

// ---------------------------------------------------------------------
// Views

@interface CPIntShiftView : CPIntVarI {
   @package
   CPInt _b;
}
-(CPIntShiftView*)initIVarShiftView:(CPIntVarI*)x b:(CPInt)b;
-(void)dealloc;
-(CPBitDom*)flatDomain;
-(CPInt) min;
-(CPInt) max;
-(void)bounds:(CPBounds*)bnd;
-(bool)member:(CPInt)v;
-(CPRange)around:(CPInt)v;
-(CPInt) shift;
-(CPInt) scale;
-(CPStatus)updateMin:(CPInt)newMin;
-(CPStatus)updateMax:(CPInt)newMax;
-(CPStatus)updateMin:(CPInt) newMin andMax:(CPInt)newMax;
-(CPStatus)bind:(CPInt)val;
-(CPStatus)remove:(CPInt)val;
-(void) loseValEvt:(CPInt)val;
-(id)           snapshot;
@end

@interface CPIntView : CPIntVarI { // Affine View
   @package
    CPInt _a;
    CPInt _b;
}
-(CPIntView*)initIVarAViewFor: (CPInt) a  x:(CPIntVarI*)x b:(CPInt)b;
-(void)dealloc;
-(CPBitDom*)flatDomain;
-(CPInt) min;
-(CPInt) max;
-(void)bounds:(CPBounds*)bnd;
-(bool)member:(CPInt)v;
-(CPRange)around:(CPInt)v;
-(CPInt) shift;
-(CPInt) scale;
-(CPStatus)updateMin:(CPInt)newMin;
-(CPStatus)updateMax:(CPInt)newMax;
-(CPStatus)updateMin:(CPInt) newMin andMax:(CPInt)newMax;
-(CPStatus)bind:(CPInt)val;
-(CPStatus)remove:(CPInt)val;
-(void) loseValEvt:(CPInt)val;
-(id)           snapshot;
@end

static inline BOOL bound(CPIntVarI* x)
{
   return ((CPBoundsDom*)x->_dom)->_sz._val == 1;
}

static inline CPInt minDom(CPIntVarI* x)
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

static inline CPInt maxDom(CPIntVarI* x)
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
         CPInt fmin = DOMX->_min._val * ((CPIntView*)x)->_a + ((CPIntView*)x)->_b;
         CPInt fmax = DOMX->_max._val * ((CPIntView*)x)->_a + ((CPIntView*)x)->_b;
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


static inline CPInt memberDom(CPIntVarI* x,CPInt value)
{
   CPInt target;
   switch (x->_vc) {
      case CPVCBare: target = value;
         break;
      case CPVCShift:
         target = value - ((CPIntShiftView*)x)->_b;
         break;
      case CPVCAffine: {
         const CPInt a = ((CPIntView*)x)->_a;
         const CPInt b = ((CPIntView*)x)->_b;
         if (a == 1) 
            target = value - b;
         else if (a== -1)
            target = b - value;
         else {
            const CPInt r = (value - b) % a;
            if (r != 0) return NO;
            target = (value - b) / a;
         }
      }break;
   }
   return domMember((CPBoundsDom*)x->_dom, target);
}

static inline CPInt memberBitDom(CPIntVarI* x,CPInt value)
{
   CPInt target;
   switch (x->_vc) {
      case CPVCBare: target = value;
         break;
      case CPVCShift:
         target = value - ((CPIntShiftView*)x)->_b;
         break;
      case CPVCAffine: {
         const CPInt a = ((CPIntView*)x)->_a;
         const CPInt b = ((CPIntView*)x)->_b;
         if (a == 1) 
            target = value - b;
         else if (a== -1)
            target = b - value;
         else {
            const CPInt r = (value - b) % a;
            if (r != 0) return NO;
            target = (value - b) / a;
         }
      }break;
   }
   return getCPDom((CPBitDom*)x->_dom, target);   
}

static inline CPStatus removeDom(CPIntVarI* x,CPInt v)
{
   CPInt target;
   switch (x->_vc) {
      case CPVCBare:  target = v;break;
      case CPVCShift: target = v - ((CPIntShiftView*)x)->_b;break;
      case CPVCAffine: {
         CPInt a = ((CPIntView*)x)->_a;
         CPInt b = ((CPIntView*)x)->_b;
         if (a == -1)
            target = b - v;
         else if (a== 1)
            target = v - b;
         else {
            CPInt r = (v - b) % a;
            if (r != 0) return CPSuspend;
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
   CPInt                  _nb;
   CPInt                  _mx;
   IMP*           _loseValIMP;
}
-(id)initVarMC:(CPInt)n;
-(void) dealloc;
-(void) addVar:(CPIntVarI*) v;
-(void) bindEvt;
-(void) changeMinEvt:(CPInt)dsz;
-(void) changeMaxEvt:(CPInt)dsz;
-(void) loseValEvt:(CPInt)val;
@end

