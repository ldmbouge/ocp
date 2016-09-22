/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/OREngine.h>
#import <ORFoundation/ORConstraint.h>

@protocol CPValueEvent;
@protocol CPConstraint;
@protocol CPClosureList;

#define NBPRIORITIES ((ORInt)8)
#define ALWAYS_PRIO  ((ORInt)0)
#define LOWEST_PRIO  ((ORInt)1)
#define HIGHEST_PRIO ((ORInt)7)

@protocol CPEngine <ORSearchEngine>

-(void) scheduleTrigger: (ORClosure) cb onBehalf: (id<CPConstraint>) c;
-(void) scheduleClosures: (id<CPClosureList>*) mlist;
-(void) scheduleValueClosure: (id<CPValueEvent>) evt;
-(void) propagate;
-(void) open;

-(void) setObjective: (id<ORSearchObjectiveFunction>) obj;
-(id<ORSearchObjectiveFunction>) objective;
-(ORStatus) addInternal: (id<ORConstraint>) c;
-(ORStatus) add: (id<ORConstraint>) c;
-(ORStatus) post: (id<ORConstraint>) c;
-(ORStatus) enforce: (ORClosure) cl;
-(void)  tryEnforce:(ORClosure) cl;
-(void)  tryAtomic:(ORClosure) cl;
-(ORStatus) atomic: (ORClosure) cl;
-(ORBool) isPropagating;

-(ORUInt) nbPropagation;
-(ORUInt) nbVars;
-(ORUInt) nbConstraints;
-(id<ORBasicModel>) model;
-(id) trail;
-(id<ORInformer>) propagateFail;
-(id<ORInformer>) propagateDone;
-(id<ORIntRange>)boolRange;
@end

#define ISLOADED(q)  ((q)->_csz)

@interface CPClosureQueue : NSObject {
   @package
   ORInt      _mxs;
   ORInt      _csz;
}
-(id) initClosureQueue: (ORInt) sz;
-(void) dealloc;
-(void) deQueue:(ORClosure*)cb forCstr:(id<CPConstraint>*)cstr;
-(void) enQueue:(ORClosure) cb cstr: (id<CPConstraint>)cstr;
-(void) reset;
-(ORBool) loaded;
@end

@interface CPValueClosureQueue : NSObject {
   @package
   ORInt      _mxs;
   ORInt      _csz;
}
-(id) initValueClosureQueue: (ORInt) sz;
-(void) dealloc;
-(id<CPValueEvent>) deQueue;
-(void) enQueue: (id<CPValueEvent>)cb;
-(void) reset;
-(ORBool) loaded;
@end

@class CPEngineI;
ORStatus propagateFDM(CPEngineI* fdm);
void scheduleClosures(CPEngineI* fdm,id<CPClosureList>* mlist);

