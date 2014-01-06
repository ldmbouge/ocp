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

typedef struct  {
   TRId         _boundsEvt[2];
   TRId           _bindEvt[2];
   TRId            _domEvt[2];
   TRId            _minEvt[2];
   TRId            _maxEvt[2];
   TRId               _ac5[2];
} CPEventNetwork;

@class CPIntVar;
@class CPLiterals;
@class CPMultiCast;


@protocol CPIntVarNotifier<NSObject>
-(CPIntVar*) findAffine: (ORInt) scale shift: (ORInt) shift;
-(void)      setTracksLoseEvt;
-(ORBool)    tracksLoseEvt: (id<CPDom>) sender;
-(void)      bindEvt: (id<CPDom>) sender;
-(void)      domEvt: (id<CPDom>) sender;
-(void)      changeMinEvt:(ORInt) dsz sender: (id<CPDom>)sender;
-(void)      changeMaxEvt:(ORInt) dsz sender: (id<CPDom>)sender;
-(void)      loseValEvt: (ORInt) val sender: (id<CPDom>)sender;
@end

@interface CPIntVar : ORObject<CPIntVarNotifier,CPIntVar> {
@public
   BOOL            _isBool;
   enum CPVarClass _vc;
   CPEngineI*      _fdm;
   CPMultiCast*    _recv;
}
-(CPIntVar*)   initCPIntVar: (id<CPEngine>) cp;

-(ORRange)   around:(ORInt)v;
-(id<CPDom>) domain;
-(CPBitDom*) flatDomain;
-(ORInt) degree;
// delegation
-(CPMultiCast*) delegate;
-(void) setDelegate:(CPMultiCast*) d;
@end

@interface CPIntVarCst : CPIntVar
{
@public
   ORInt _value;
}
-(CPIntVar*) initCPIntVarCst: (id<CPEngine>) cp value: (ORInt) value;
-(void) dealloc;
@end


@interface CPIntVarI : CPIntVar {
@public
   id<CPDom>                           _dom;
   CPEventNetwork                      _net;
   id<CPTriggerMap>               _triggers;
}
-(CPIntVar*) initCPIntVarCore:(id<CPEngine>) cp low:(ORInt)low up:(ORInt)up;
-(CPIntVar*) initCPIntVarView: (id<CPEngine>) cp low: (ORInt) low up: (ORInt) up for: (CPIntVar*) x;
-(void) dealloc;
// Class methods
+(CPIntVar*)    initCPIntVar: (id<CPEngine>) fdm bounds:(id<ORIntRange>)b;
+(CPIntVar*)    initCPIntVar: (id<CPEngine>) fdm low:(ORInt)low up:(ORInt)up;
+(CPIntVar*)    initCPBoolVar:(id<CPEngine>) fdm;
+(CPIntVar*)    initCPFlipView:(id<CPIntVar>)x;
+(CPIntVar*)    initCPIntView: (id<CPIntVar>)x withShift:(ORInt)b;
+(CPIntVar*)    initCPIntView: (id<CPIntVar>)x withScale:(ORInt)a;
+(CPIntVar*)    initCPIntView: (id<CPIntVar>)x withScale:(ORInt)a andShift:(ORInt)b;
+(CPIntVar*)    initCPNegateBoolView:(id<CPIntVar>)x;
@end

// ---------------------------------------------------------------------
// Views

@interface CPIntShiftView : CPIntVarI {
   @public
   ORInt      _b;
   CPIntVar*  _x;
}
-(CPIntShiftView*)initIVarShiftView:(CPIntVar*)x b:(ORInt)b;
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
-(void)updateMin:(ORInt)newMin;
-(void)updateMax:(ORInt)newMax;
-(ORBounds)updateMin:(ORInt) newMin andMax:(ORInt)newMax;
-(void)bind:(ORInt)val;
-(void)remove:(ORInt)val;
-(void) loseValEvt:(ORInt)val sender:(id<CPDom>)sender;
@end

@interface CPIntView : CPIntVarI { // Affine View
@public
   ORInt _a;
   ORInt _b;
   CPIntVar*  _x;
}
-(CPIntView*)initIVarAViewFor: (ORInt) a  x:(CPIntVar*)x b:(ORInt)b;
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
-(void) updateMin:(ORInt)newMin;
-(void) updateMax:(ORInt)newMax;
-(ORBounds) updateMin:(ORInt) newMin andMax:(ORInt)newMax;
-(void) bind:(ORInt)val;
-(void) remove:(ORInt)val;
-(void) loseValEvt:(ORInt)val sender:(id<CPDom>)sender;
@end

@interface CPIntFlipView : CPIntVarI { // Flip View (y == -x)
@public
   CPIntVar*  _x;
}
-(CPIntFlipView*)initFlipViewFor:(CPIntVar*)x;
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
-(void) updateMin:(ORInt)newMin;
-(void) updateMax:(ORInt)newMax;
-(ORBounds) updateMin:(ORInt) newMin andMax:(ORInt)newMax;
-(void) bind:(ORInt)val;
-(void) remove:(ORInt)val;
-(void) loseValEvt:(ORInt)val sender:(id<CPDom>)sender;
@end

@interface CPEQLitView : CPIntVarI { // Literal view b <=> x == v
@public
   ORInt             _v;
   CPIntVar* _secondary;  // pointer to the original variable (x)
}
-(CPEQLitView*)initEQLitViewFor:(CPIntVar*)x equal:(ORInt)v;
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
-(void) updateMin:(ORInt)newMin;
-(void) updateMax:(ORInt)newMax;
-(ORBounds) updateMin:(ORInt) newMin andMax:(ORInt)newMax;
-(void) bind:(ORInt)val;
-(void) remove:(ORInt)val;
@end


static inline BOOL tracksLoseEvt(id<CPIntVarNotifier> x,id<CPDom> sender)
{
   switch(((CPIntVar*)x)->_vc) {
      case CPVCBare: {
         CPIntVarI* y = (CPIntVarI*)x;
         if (y->_net._ac5[0]._val != nil || y->_triggers != nil)
            return YES;
         else if (y->_recv && [y->_recv tracksLoseEvt:sender])
            return YES;
         else
            return NO;
      }
      default: return [x tracksLoseEvt:sender];
   }
}

static inline BOOL bound(CPIntVar* x)
{
   switch(x->_vc) {
      case CPVCBare: return ((CPBoundsDom*)((CPIntVarI*)x)->_dom)->_sz._val == 1;
      case CPVCShift:  return bound(((CPIntShiftView*)x)->_x);
      case CPVCAffine: return bound(((CPIntView*)x)->_x);
      case CPVCFlip: return bound(((CPIntFlipView*)x)->_x);
      case CPVCCst: return TRUE;
      default: return [x bound];
   }   
}

static inline ORInt minDom(CPIntVar* x)
{
   switch (x->_vc) {
      case CPVCBare:  return ((CPBoundsDom*)((CPIntVarI*)x)->_dom)->_min._val;
      case CPVCShift: return minDom(((CPIntShiftView*)x)->_x) + ((CPIntShiftView*)x)->_b;
      case CPVCCst: return ((CPIntVarCst*) x)->_value;
      default: return [x min];
   }
}

static inline ORInt maxDom(CPIntVar* x)
{
   switch (x->_vc) {
      case CPVCBare:  return ((CPBoundsDom*)((CPIntVarI*)x)->_dom)->_max._val;
      case CPVCShift: return maxDom(((CPIntShiftView*)x)->_x) + ((CPIntShiftView*)x)->_b;
      case CPVCCst: return ((CPIntVarCst*) x)->_value;
      default: return [x max];
   }
}

static inline ORBounds negBounds(CPIntVar* x)
{
   ORBounds b = [x bounds];
   return (ORBounds){- b.max, -b.min};
}

static inline ORInt memberDom(CPIntVar* x,ORInt value)
{
   switch (x->_vc) {
      case CPVCBare:
         return domMember((CPBoundsDom*)((CPIntVarI*)x)->_dom, value);
         break;
      case CPVCShift:
      {
         const ORInt b = ((CPIntShiftView*)x)->_b;
         return memberDom(((CPIntShiftView*)x)->_x, value - b);
      }
      break;
      case CPVCCst:
         return (((CPIntVarCst*) x)->_value == value);
      default:
         return [x member:value];
   }
}

static inline ORInt memberBitDom(CPIntVar* x,ORInt value)
{
   switch (x->_vc) {
      case CPVCBare:
         return getCPDom((CPBitDom*)((CPIntVarI*)x)->_dom, value);
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

#define DOMX ((CPBoundsDom*)((CPIntVarI*)x)->_dom)
static inline ORBounds bounds(CPIntVar* x)
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
      case CPVCCst: {
         ORInt v = ((CPIntVarCst*) x)->_value;
         return (ORBounds){v,v};
      }
      case CPVCEQLiteral: {
         CPIntVar*   sec = ((CPEQLitView*)x)->_secondary;
         ORBounds sb = sec->_vc == CPVCBare ? (ORBounds){
            ((CPBoundsDom*)((CPIntVarI*)sec)->_dom)->_min._val,
            ((CPBoundsDom*)((CPIntVarI*)sec)->_dom)->_max._val
         } : bounds(sec);
         if (sb.min == sb.max) {
            BOOL v = sb.min == ((CPEQLitView*)x)->_v;
            return (ORBounds){v,v};
         } else {
            const ORInt lit = ((CPEQLitView*)x)->_v;
            if (lit < sb.min || lit > sb.max)
               return (ORBounds){0,0};
            else if (lit == sb.min || lit == sb.max)
               return (ORBounds){0,1};
            else {
               ORInt ub = memberBitDom(sec,lit);
               return (ORBounds){0,ub!=0};
            }
         }
      }break;
      default: return [x bounds];
   }
}
#undef DOMX

static inline void removeDom(CPIntVar* x,ORInt v)
{
   switch (x->_vc) {
      case CPVCBare:
         //[((CPIntVarI*)x)->_dom remove:v for: (CPIntVarI*) x];
         domRemove((CPBoundsDom*)(((CPIntVarI*)x)->_dom), v, x);
         break;
      case CPVCShift: {
         const ORInt b = ((CPIntShiftView*)x)->_b;
         removeDom(((CPIntShiftView*)x)->_x, v - b);
         break;
      }
      default:
         [x remove:v];
   }
}

static inline void bindDom(CPIntVar* x,ORInt v)
{
   switch(x->_vc) {
      case CPVCBare:
         [((CPIntVarI*)x)->_dom bind:v for:x];
      default:
         [x bind:v];
   }
}

static inline ORBounds updateMinAndMaxOfDom(CPIntVar* x,ORInt lb,ORInt ub)
{
   switch(x->_vc) {
      case CPVCBare:
         [((CPIntVarI*)x)->_dom updateMin:lb andMax:ub for:x];
         return domBounds((CPBoundsDom*)((CPIntVarI*)x)->_dom);
      default:
         return [x updateMin:lb andMax:ub];
   }
}

static inline void updateMinDom(CPIntVar* x,ORInt newMin)
{
   switch(x->_vc) {
      case CPVCBare:
         [((CPIntVarI*)x)->_dom updateMin:newMin for:x];
         break;
      default:
         return [x updateMin:newMin];
   }
}

static inline void updateMaxDom(CPIntVar* x,ORInt newMax)
{
   switch(x->_vc) {
      case CPVCBare:
         [((CPIntVarI*)x)->_dom updateMax:newMax for:x];
         break;
      default:
         return [x updateMax:newMax];
   }
}

/*****************************************************************************************/
/*                        MultiCast Notifier                                             */
/*****************************************************************************************/

@interface CPMultiCast : NSObject {
   id<CPIntVarNotifier>* _tab;
   BOOL                  _tracksLoseEvt;
   ORInt                 _nb;
   ORInt                 _mx;
   UBType*               _loseValIMP;
   UBType*               _minIMP;
   UBType*               _maxIMP;
   CPLiterals*           _literals;
}
-(id) initVarMC: (ORInt) n root: (CPIntVar*) root;
-(void) dealloc;
-(CPLiterals*) findLiterals:(CPIntVar*)ref;
-(void) addVar: (id<CPIntVarNotifier>) v;
-(ORBool) tracksLoseEvt:(id<CPDom>)sender;
-(void) setTracksLoseEvt;
-(CPIntVar*) findAffine: (ORInt) scale shift: (ORInt) shift;
//-(void) bindEvt:(id<CPDom>)sender;
//-(void) domEvt: (id<CPDom>)sender;
//-(void) changeMinEvt:(ORInt)dsz sender:(id<CPDom>)sender;
//-(void) changeMaxEvt:(ORInt)dsz sender:(id<CPDom>)sender;
-(void) loseValEvt:(ORInt)val sender:(id<CPDom>)sender;
@end

void bindEvt(CPMultiCast* x,id<CPDom> sender);
void domEvt(CPMultiCast* x,id<CPDom> sender);
void changeMinEvt(CPMultiCast* x,ORInt dsz,id<CPDom> sender);
void changeMaxEvt(CPMultiCast* x,ORInt dsz,id<CPDom> sender);


@interface CPLiterals : NSObject<CPIntVarNotifier> {
   CPIntVar*     _ref;
   CPEQLitView** _pos;
   ORInt          _nb;
   ORInt         _ofs;
   TRInt           _a;
   TRInt           _b;
   BOOL       _tracksLoseEvt;
   IMP  _changeMaxEvtIMP;
   IMP  _changeMinEvtIMP;
   IMP  _domEvtIMP;
}
-(id) initCPLiterals:(CPIntVar*)ref;
-(void) dealloc;
-(NSMutableSet*) constraints;
-(void) addPositive:(CPEQLitView*)x forValue:(ORInt)value;
-(CPEQLitView*) positiveForValue:(ORInt)value;
-(void) bindEvt:(id<CPDom>)sender;
-(void) domEvt: (id<CPDom>)sender;
-(void) changeMinEvt:(ORInt)dsz sender:(id<CPDom>)sender;
-(void) changeMaxEvt:(ORInt)dsz sender:(id<CPDom>)sender;
-(void) loseValEvt:(ORInt)val sender:(id<CPDom>)sender;
@end

void literalDomEvt(CPLiterals* x,id<CPDom> sender);


