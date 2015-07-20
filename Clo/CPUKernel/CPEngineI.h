/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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
@class CPClosureQueue;
@class CPValueClosureQueue;


enum CPEngineState {
   CPOpen    = 0,
   CPClosing = 1,
   CPClosed  = 2
};

@interface CPEngineI : NSObject <CPEngine> {
   enum CPEngineState       _state;
   id<ORTrail>              _trail;
   id<ORMemoryTrail>        _mt;
   NSMutableArray*          _vars;
   NSMutableArray*          _cStore;
   NSMutableArray*          _mStore;
   NSMutableArray*          _oStore;
   id<ORSearchObjectiveFunction> _objective;
   CPClosureQueue*          _closureQueue[NBPRIORITIES];
   CPValueClosureQueue*     _valueClosureQueue;
   ORInt                    _propagating;
   ORUInt                   _nbpropag;
   id<CPConstraint>         _last;
   UBType                   _propagIMP;
   @package
   id<ORIntInformer>        _propagFail;
   id<ORVoidInformer>       _propagDone;
   ORFailException*         _fex;
   id<ORIntRange>           _br;
}
-(CPEngineI*) initEngine: (id<ORTrail>) trail memory:(id<ORMemoryTrail>)mt;
-(void)      dealloc;
-(id<CPEngine>) solver;
-(id<ORTracker>)tracker;
-(id)        trackVariable:(id)var;
-(id)        trackMutable:(id)obj;
-(id)        trackImmutable:(id)obj;
-(id)        trail;
-(void)      scheduleTrigger: (ORClosure) cb onBehalf: (id<CPConstraint>) c;
-(void)      scheduleClosures:(id<CPClosureList>*)mlist;
-(void)      scheduleValueClosure:(id<CPValueEvent>)evt;
-(ORStatus)  propagate;
-(void) setObjective: (id<ORSearchObjectiveFunction>) obj;
-(id<ORSearchObjectiveFunction>)objective;
-(void)      addInternal:(id<ORConstraint>) c;
-(ORStatus)  add:(id<ORConstraint>)c;
-(ORStatus)  post:(id<ORConstraint>)c;
-(ORStatus)  enforce:(ORClosure) cl;
-(ORStatus)  atomic:(ORClosure) cl;
-(ORStatus)  enforceObjective;
-(void)      tryEnforce:(ORClosure) cl;
-(void)      tryAtomic:(ORClosure) cl;
-(void)      tryEnforceObjective;
-(NSMutableArray*) variables;
-(NSMutableArray*) constraints;
-(NSMutableArray*) objects;
-(ORStatus)   close;
-(ORBool)     closed;
-(void)       open;
-(ORUInt) nbPropagation;
-(ORUInt) nbVars;
-(ORUInt) nbConstraints;
-(id<ORInformer>) propagateFail;
-(id<ORInformer>) propagateDone;

-(id<ORBasicModel>)model;
-(void)incNbPropagation:(ORUInt)add;
-(void)setLastFailure:(id<CPConstraint>)lastToFail;
-(id<ORIntRange>)boolRange;
@end
