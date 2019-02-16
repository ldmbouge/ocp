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

@protocol CPLDoubleVarNotifier;


@protocol CPLDoubleVarSubscriber <NSObject>
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

@protocol CPLDoubleVarExtendedItf <CPLDoubleVarSubscriber>
-(void) updateMin: (ORLDouble) newMin;
-(void) updateMax: (ORLDouble) newMax;
-(void) bind: (ORLDouble) val;
@end

@class CPLDoubleVarI;
@protocol CPLDoubleVarNotifier <NSObject>
-(CPLDoubleVarI*) findAffine: (ORLDouble) scale shift: (ORLDouble) shift;
-(void) bindEvt:(id<CPLDoubleDom>)sender;
-(void) changeMinEvt:(ORBool) bound sender:(id<CPLDoubleDom>)sender;
-(void) changeMaxEvt:(ORBool) bound sender:(id<CPLDoubleDom>)sender;
@end

@interface CPLDoubleVarI : ORObject<CPLDoubleVar,CPLDoubleVarNotifier,CPLDoubleVarExtendedItf> {
    CPEngineI*               _engine;
    BOOL                     _hasValue;
    ORLDouble                  _value;    // This value is only used for storing the value of the variable in linear/convex relaxation. Bounds only are safe
    id<CPLDoubleDom>           _dom;
    CPMultiCast*             _recv;
}
-(id)init:(id<CPEngine>)engine low:(ORLDouble)low up:(ORLDouble)up;
-(id<CPEngine>) engine;
-(id<ORTracker>) tracker;
-(id<OROSet>) constraints;
-(ORLDouble) ldoubleValue;
-(ORLDouble) domwidth;
@end

@interface CPLDoubleViewOnIntVarI : ORObject<CPLDoubleVar,CPLDoubleVarExtendedItf,CPIntVarNotifier> {
    CPEngineI* _engine;
    CPIntVar* _theVar;
}
-(id)init:(id<CPEngine>)engine intVar:(CPIntVar*)iv;
-(CPEngineI*)    engine;
-(id<ORTracker>) tracker;
-(id<OROSet>) constraints;
@end
