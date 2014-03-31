/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPConstraintI.h>

@class CPGroupController;

@interface CPGroup : CPCoreConstraint<CPGroup> {
   CPEngineI*               _engine;
   CPClosureQueue*          _closureQueue[NBPRIORITIES];
   CPValueClosureQueue*     _valueClosureQueue;
}
-(id)   init: (id<CPEngine>) engine;
-(void) add: (id<CPConstraint>) p;
-(void) scheduleTrigger: (ORClosure) cb onBehalf: (id<CPConstraint>) c;
-(void) scheduleClosure: (id<CPClosureList>) evt;
-(void) scheduleValueClosure: (id<CPValueEvent>) evt;
-(void) post;
-(ORStatus) propagate;
@end

@interface CPBergeGroup : CPCoreConstraint<CPGroup> {
   CPEngineI*               _engine;
   id<CPConstraint>*        _inGroup;
   id<CPClosureList>*       _scanMap;
   ORInt                    _nbIn;
   ORInt                    _max;
   ORInt                    _low;
   ORInt                    _sz;
   ORInt*                   _map;
}
-(id) init:(id<CPEngine>)engine;
-(void) add:(id<CPConstraint>)p;
-(void) scheduleTrigger: (ORClosure) cb onBehalf: (id<CPConstraint>) c;
-(void) scheduleClosure:(id<CPClosureList>)evt;
-(void) scheduleValueClosure: (id<CPValueEvent>)evt;
-(void) post;
-(ORStatus)propagate;
@end
