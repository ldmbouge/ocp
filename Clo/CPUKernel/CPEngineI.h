/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPTypes.h>
#import <CPUKernel/CPEngine.h>
#import <CPUKernel/CPConstraintI.h>

@class ORTrailI;
@class ORTrailIStack;
@class CPAC3Queue;
@class CPAC5Queue;


enum CPEngineState {
   CPOpen    = 0,
   CPClosing = 1,
   CPClosed  = 2
};

@interface CPEngineI : NSObject <CPEngine,NSCoding> {
   enum CPEngineState       _state;
   id<ORTrail>              _trail;
   NSMutableArray*          _vars;
   NSMutableArray*          _cStore;
   NSMutableArray*          _mStore;
   NSMutableArray*          _oStore;
   id<ORObjective>          _objective;
   CPAC3Queue*              _ac3[NBPRIORITIES];
   CPAC5Queue*              _ac5;
   ORStatus                _status;
   ORInt                _propagating;
   ORUInt               _nbpropag;
   id<CPConstraint>        _last;
   UBType                   _propagIMP;
   @package
   id<ORIntInformer>        _propagFail;
   id<ORVoidInformer>       _propagDone;
   ORFailException*         _fex;
}
-(CPEngineI*) initEngine: (id<ORTrail>) trail;
-(void)      dealloc;
-(id<CPEngine>) solver;
-(void)      trackVariable:(id)var;
-(void)      trackObject:(id)obj;
-(id)        trail;
-(void)      scheduleTrigger:(ConstraintCallback)cb onBehalf: (id<CPConstraint>)c;
-(void)      scheduleAC3:(id<VarEventNode>*)mlist;
-(void)      scheduleAC5:(id<CPAC5Event>)evt;
-(ORStatus)  propagate;
-(void) setObjective: (id<ORObjective>) obj;
-(id<ORObjective>)objective;
-(ORStatus)  addInternal:(id<ORConstraint>) c;
-(ORStatus)  add:(id<ORConstraint>)c;
-(ORStatus)  post:(id<ORConstraint>)c;
-(ORStatus)  enforce:(Void2ORStatus)cl;
-(NSMutableArray*) allVars;
-(NSMutableArray*) allConstraints;
-(ORStatus)  close;
-(ORStatus)  status;
-(bool)      closed;
-(ORUInt) nbPropagation;
-(ORUInt) nbVars;
-(id<ORInformer>) propagateFail;
-(id<ORInformer>) propagateDone;
-(ORStatus)enforceObjective;
@end
