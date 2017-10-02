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

@protocol CPDoubleVarNotifier;

@protocol CPDoubleVarSubscriber <NSObject>
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

@protocol CPDoubleVarExtendedItf <CPDoubleVarSubscriber>
-(void) updateMin: (ORDouble) newMin;
-(void) updateMax: (ORDouble) newMax;
-(void) updateInterval: (ORDouble) newMin and: (ORDouble)newMax;
-(void) bind: (ORDouble) val;
@end

typedef struct  {
    TRId           _bindEvt;
    TRId            _minEvt;
    TRId            _maxEvt;
    TRId         _boundsEvt;
} CPDoubleEventNetwork;

@class CPDoubleVarI;
@protocol CPDoubleVarNotifier <NSObject>
-(CPDoubleVarI*) findAffine: (ORDouble) scale shift: (ORDouble) shift;
-(void) bindEvt:(id<CPDoubleDom>)sender;
-(void) changeMinEvt:(ORBool) bound sender:(id<CPDoubleDom>)sender;
-(void) changeMaxEvt:(ORBool) bound sender:(id<CPDoubleDom>)sender;
@end

@interface CPDoubleVarI : ORObject<CPDoubleVar,CPDoubleVarNotifier,CPDoubleVarExtendedItf> {
    CPEngineI*               _engine;
    BOOL                     _hasValue;
    ORDouble                  _value;    // This value is only used for storing the value of the variable in linear/convex relaxation. Bounds only are safe
    id<CPDoubleDom>            _dom;
    CPDoubleEventNetwork      _net;
    CPMultiCast*             _recv;
}
-(id)init:(id<CPEngine>)engine low:(ORDouble)low up:(ORDouble)up;
-(id<CPEngine>) engine;
-(id<ORTracker>) tracker;
-(NSMutableSet*) constraints;
-(ORDouble) doubleValue;
-(ORLDouble) domwidth;
-(TRDoubleInterval) domain;
@end

@interface CPDoubleViewOnIntVarI : ORObject<CPDoubleVar,CPDoubleVarExtendedItf,CPIntVarNotifier> {
    CPEngineI* _engine;
    CPIntVar* _theVar;
    CPDoubleEventNetwork _net;
}
-(id)init:(id<CPEngine>)engine intVar:(CPIntVar*)iv;
-(CPEngineI*)    engine;
-(id<ORTracker>) tracker;
-(NSMutableSet*) constraints;
@end
