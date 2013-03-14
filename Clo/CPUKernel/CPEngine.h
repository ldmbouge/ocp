/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPTypes.h>

@protocol CPAC5Event;
@protocol CPConstraint;
@protocol CPEventNode;
@class CPCoreConstraint;

#define NBPRIORITIES ((ORInt)8)
#define ALWAYS_PRIO  ((ORInt)0)
#define LOWEST_PRIO  ((ORInt)1)
#define HIGHEST_PRIO ((ORInt)7)

@protocol CPEngine <OREngine>
-(void) scheduleTrigger: (ConstraintCallback) cb onBehalf: (id<CPConstraint>)c;
-(void) scheduleAC3: (id<CPEventNode>*) mlist;
-(void) scheduleAC5: (id<CPAC5Event>) evt;
-(void) setObjective: (id<ORObjective>) obj;
-(id<ORObjective>) objective;
-(ORStatus) addInternal: (id<ORConstraint>) c;
-(ORStatus) add: (id<ORConstraint>) c;
-(ORStatus) post: (id<ORConstraint>) c;
-(ORStatus) enforce: (Void2ORStatus)cl;
-(ORStatus) propagate;
-(ORUInt) nbPropagation;
-(ORUInt) nbVars;
-(ORUInt) nbConstraints;
-(id<ORBasicModel>)model;
-(id) trail;
-(id<ORInformer>) propagateFail;
-(id<ORInformer>) propagateDone;
@end

#define AC5LOADED(q) ((q)->_csz)
#define ISLOADED(q)  ((q)->_csz)

typedef struct AC3Entry {
   ConstraintCallback   cb;
   CPCoreConstraint*    cstr;
} AC3Entry;

@interface CPAC3Queue : NSObject {
   @package
   ORInt      _mxs;
   ORInt      _csz;
   AC3Entry*  _tab;
   ORInt    _enter;
   ORInt     _exit;
   ORInt     _mask;
}
-(id)initAC3Queue:(ORInt)sz;
-(void)dealloc;
-(AC3Entry)deQueue;
-(void)enQueue:(ConstraintCallback)cb cstr:(CPCoreConstraint*)cstr;
-(void)reset;
-(bool)loaded;
@end

@interface CPAC5Queue : NSObject {
   @package
   ORInt           _mxs;
   ORInt           _csz;
   id<CPAC5Event>* _tab;
   ORInt         _enter;
   ORInt          _exit;
   ORInt          _mask;
}
-(id) initAC5Queue: (ORInt) sz;
-(void) dealloc;
-(id<CPAC5Event>) deQueue;
-(void) enQueue: (id<CPAC5Event>)cb;
-(void) reset;
-(bool) loaded;
@end

