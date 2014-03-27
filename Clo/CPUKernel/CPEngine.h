/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPTypes.h>

@protocol CPValueEvent;
@protocol CPConstraint;
@protocol CPClosureList;
@class CPCoreConstraint;

#define NBPRIORITIES ((ORInt)8)
#define ALWAYS_PRIO  ((ORInt)0)
#define LOWEST_PRIO  ((ORInt)1)
#define HIGHEST_PRIO ((ORInt)7)

@protocol CPEngine <ORSearchEngine>

-(void) scheduleTrigger: (ORClosure) cb onBehalf: (id<CPConstraint>) c;
-(void) scheduleClosures: (id<CPClosureList>*) mlist;
-(void) scheduleValueClosure: (id<CPValueEvent>) evt;
-(void) propagate;

-(void) setObjective: (id<ORSearchObjectiveFunction>) obj;
-(id<ORSearchObjectiveFunction>) objective;
-(ORStatus) addInternal: (id<ORConstraint>) c;
-(ORStatus) add: (id<ORConstraint>) c;
-(ORStatus) post: (id<ORConstraint>) c;
-(ORStatus) status;
-(ORStatus) enforce: (ORClosure) cl;

-(ORUInt) nbPropagation;
-(ORUInt) nbVars;
-(ORUInt) nbConstraints;
-(id<ORBasicModel>) model;
-(id) trail;
-(id<ORInformer>) propagateFail;
-(id<ORInformer>) propagateDone;

@end

#define ISLOADED(q)  ((q)->_csz)

typedef struct CPClosureEntry {
   ORClosure  cb;
   CPCoreConstraint*    cstr;
} CPClosureEntry;

@interface CPClosureQueue : NSObject {
   @package
   ORInt      _mxs;
   ORInt      _csz;
   CPClosureEntry*  _tab;
   CPClosureEntry*  _last;
   ORInt     _enter;
   ORInt     _exit;
   ORInt     _mask;
}
-(id) initClosureQueue: (ORInt) sz;
-(void) dealloc;
-(CPClosureEntry) deQueue;
-(void) enQueue:(ORClosure) cb cstr: (id<CPConstraint>)cstr;
-(void) reset;
-(ORBool) loaded;
@end

@interface CPValueClosureQueue : NSObject {
   @package
   ORInt           _mxs;
   ORInt           _csz;
   id<CPValueEvent>* _tab;
   ORInt         _enter;
   ORInt          _exit;
   ORInt          _mask;
}
-(id) initValueClosureQueue: (ORInt) sz;
-(void) dealloc;
-(id<CPValueEvent>) deQueue;
-(void) enQueue: (id<CPValueEvent>)cb;
-(void) reset;
-(ORBool) loaded;
@end

