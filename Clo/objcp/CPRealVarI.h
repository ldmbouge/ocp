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

@protocol CPRealVarNotifier;


@protocol CPRealVarSubscriber <NSObject>
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

@protocol CPRealVarExtendedItf <CPRealVarSubscriber>
-(void) updateMin: (ORDouble) newMin;
-(void) updateMax: (ORDouble) newMax;
-(ORStatus) updateInterval: (ORInterval)nb;
-(void) bind: (ORDouble) val;
@end

typedef struct  {
   TRId           _bindEvt;
   TRId            _minEvt;
   TRId            _maxEvt;
   TRId         _boundsEvt;
} CPRealEventNetwork;

@class CPRealVarI;

@protocol CPRealVarNotifier <NSObject>
-(CPRealVarI*) findAffine: (ORDouble) scale shift: (ORDouble) shift;
-(void) bindEvt:(id<CPFDom>)sender;
-(void) changeMinEvt:(ORBool) bound sender:(id<CPFDom>)sender;
-(void) changeMaxEvt:(ORBool) bound sender:(id<CPFDom>)sender;
@end

@interface CPRealVarI : ORObject<CPRealVar,CPRealVarNotifier,CPRealVarExtendedItf> {
   CPEngineI*               _engine;
   BOOL                     _hasValue;
   ORDouble                  _value;    // This value is only used for storing the value of the variable in linear/convex relaxation. Bounds only are safe
   id<CPFDom>               _dom;
   CPRealEventNetwork      _net;
   CPMultiCast*             _recv;
}
-(id)init:(id<CPEngine>)engine low:(ORDouble)low up:(ORDouble)up;
-(id<CPEngine>) engine;
-(id<ORTracker>) tracker;
-(NSMutableSet*) constraints;
-(ORDouble) doubleValue;
-(ORDouble) domwidth;
@end

@interface CPRealViewOnIntVarI : ORObject<CPRealVar,CPRealVarExtendedItf,CPIntVarNotifier> {
   CPEngineI* _engine;
   CPIntVar* _theVar;
   CPRealEventNetwork _net;
}
-(id)init:(id<CPEngine>)engine intVar:(CPIntVar*)iv;
-(CPEngineI*)    engine;
-(id<ORTracker>) tracker;
-(NSMutableSet*) constraints;
@end

@interface CPRealParamI : ORObject<CPRealParam> {
    CPEngineI*            _engine;
    ORDouble               _value;
}
-(id)initCPRealParam:(id<CPEngine>)engine initialValue:(ORDouble)v;
-(CPEngineI*) engine;
-(CPEngineI*) tracker;
-(NSMutableSet*) constraints;
-(ORDouble) value;
@end
