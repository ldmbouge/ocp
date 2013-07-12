/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORInterval.h>
#import <CPUKernel/CPTrigger.h>
#import <CPUKernel/CPConstraintI.h>
#import <CPUKernel/CPTrigger.h>
#import <objcp/CPDom.h>
#import <objcp/CPData.h>
#import <objcp/CPConstraint.h>

@protocol CPFloatVarNotifier;


@protocol CPFloatVarSubscriber <NSObject>
// AC3 Closure Event
-(void) whenBindDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeBoundsDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeMinDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeMaxDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c;

-(void) whenBindDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeBoundsDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeMinDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeMaxDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;

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
-(ORStatus) updateMin: (ORFloat) newMin;
-(ORStatus) updateMax: (ORFloat) newMax;
-(ORStatus) updateInterval: (ORInterval)nb;
-(ORStatus) bind: (ORFloat) val;
@end

typedef struct  {
   TRId           _bindEvt;
   TRId            _minEvt;
   TRId            _maxEvt;
   TRId         _boundsEvt;
} CPFloatEventNetwork;

@class CPFloatVarMultiCast;
@class CPFloatVarI;

@protocol CPFloatVarNotifier <NSObject>
-(ORInt)getId;
-(NSMutableSet*)constraints;
-(void)setDelegate:(id<CPFloatVarNotifier>)delegate;
-(void) addVar:(CPFloatVarI*)var;
-(enum CPVarClass)varClass;
-(CPFloatVarI*)findAffine:(ORInt)scale shift:(ORInt)shift;
-(ORStatus) bindEvt:(id<CPFDom>)sender;
-(ORStatus) changeMinEvt:(ORBool) bound sender:(id<CPFDom>)sender;
-(ORStatus) changeMaxEvt:(ORBool) bound sender:(id<CPFDom>)sender;
@end

@interface CPFloatVarI : ORObject<CPFloatVar,CPFloatVarNotifier,CPFloatVarExtendedItf> {
   CPEngineI*            _engine;
   id<CPFDom>               _dom;
   CPFloatEventNetwork      _net;
   CPFloatVarMultiCast*    _recv;
}
-(id)initCPFloatVar:(id<CPEngine>)engine low:(ORFloat)low up:(ORFloat)up;
-(CPEngineI*) engine;
-(id<ORTracker>) tracker;
-(NSMutableSet*)constraints;
@end
