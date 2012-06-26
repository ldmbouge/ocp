/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/


#import <Foundation/Foundation.h>
#import "CPData.h"
#import "CPDom.h"
#import "CPConstraint.h"
#import "CPDataI.h"
#import "CPSetI.h"
#import "CPBitDom.h"
#import "objc/runtime.h"

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
-(CPIntVarI*)findOriginal;
@end


@interface CPIntVarI : CPExprI<CPIntVarNotifier,CPIntVarSubscriber,CPIntVarExtendedItf,NSCoding> {
@package
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
-(NSString*) description;
-(CPSolverI*) solver;
-(id<CP>) cp;
-(NSSet*)constraints;
-(CPDomain*)flatDomain;

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
-(CPStatus)     inside:(CPIntSetI*) S;
-(id)           snapshot;
// Class methods
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
-(CPDomain*)flatDomain;
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
-(CPDomain*)flatDomain;
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
   static id irvc = nil,isvc = nil;
   if (irvc==nil) {
      irvc = objc_getClass("CPIntVarI");
      isvc = objc_getClass("CPIntShiftView");
   }
   id cx = object_getClass(x);
   if (cx == irvc) {
      return ((CPBoundsDom*)x->_dom)->_min._val;
   } else if (cx == isvc) {
      return ((CPBoundsDom*)x->_dom)->_min._val + ((CPIntShiftView*)x)->_b;      
   } else {
      if (((CPIntView*)x)->_a > 0)
         return ((CPBoundsDom*)x->_dom)->_min._val * ((CPIntView*)x)->_a + ((CPIntView*)x)->_b;            
      else 
         return ((CPBoundsDom*)x->_dom)->_max._val * ((CPIntView*)x)->_a + ((CPIntView*)x)->_b;            
   }
}

static inline CPInt maxDom(CPIntVarI* x)
{
   static id irvc = nil,isvc = nil;
   if (irvc==nil) {
      irvc = objc_getClass("CPIntVarI");
      isvc = objc_getClass("CPIntShiftView");
   }
   id cx = object_getClass(x);
   if (cx == irvc) {
      return ((CPBoundsDom*)x->_dom)->_max._val;
   } else if (cx == isvc) {
      return ((CPBoundsDom*)x->_dom)->_max._val + ((CPIntShiftView*)x)->_b;      
   } else {
      if (((CPIntView*)x)->_a > 0)
         return ((CPBoundsDom*)x->_dom)->_max._val * ((CPIntView*)x)->_a + ((CPIntView*)x)->_b;            
      else 
         return ((CPBoundsDom*)x->_dom)->_min._val * ((CPIntView*)x)->_a + ((CPIntView*)x)->_b;            
   }
}

/*****************************************************************************************/
/*                        MultiCast Notifier                                             */
/*****************************************************************************************/

@interface CPIntVarMultiCast : NSObject<CPIntVarNotifier,NSCoding> {
   CPIntVarI**           _tab;
   BOOL        _tracksLoseEvt;
   CPInt                  _nb;
   CPInt                  _mx;
   IMP*         _loseRangeIMP;  
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

