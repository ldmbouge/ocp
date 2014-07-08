/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objls/LSEngine.h>

@class LSPrioritySpace;
@class LSPropagator;
@class LSPseudoPropagator;
@class LSRQueue;
@protocol LSConstraint;
@protocol LSPropagator;
@protocol LSPriority;


typedef enum LSMode {
   LSInitial = 0,
   LSClosing = 1,
   LSIncremental = 2
} LSMode;

@interface LSEngineI : NSObject<ORSearchEngine,LSEngine> {
   NSMutableArray*  _vars;
   NSMutableArray*  _objs;
   NSMutableArray*  _cstr;
   NSMutableArray*  _invs;
   ORUInt           _nbObjects;
   LSMode           _mode;
   ORInt            _atomic;
   LSPrioritySpace* _pSpace;
   LSRQueue*        _queue;
}
-(LSEngineI*)initEngine;
-(void)dealloc;
-(ORStatus)close;
-(LSPrioritySpace*)space;
-(id<ORSearchObjectiveFunction>)objective;
-(void)add:(id<LSPropagator>)i;
-(id<LSConstraint>)addConstraint:(id<LSConstraint>)cstr;
-(id<LSFunction>)addFunction:(id<LSFunction>)fun;
-(NSMutableArray*)variables;
-(NSMutableArray*)invariants;
-(ORUInt)nbObjects;
-(void)label:(LSIntVar*)x with:(ORInt)v;
-(void)swap:(LSIntVar*)x with:(LSIntVar*)y;
-(void)notify:(id<LSVar>)x;
-(void)schedule:(id<LSPropagator>)x;
-(void) updateMultipliers;
-(void) resetMultipliers;
@end

@interface PStore : NSObject {
   LSEngineI* _engine;
   ORInt*     _marks;
   ORInt      _low, _up;
}
-(id)initPStore:(LSEngineI*)engine;
-(BOOL)closed:(id<ORObject>)v;
-(BOOL)finalNotice:(id<ORObject>)v;
-(BOOL)lastTime:(id<ORObject>)v;
-(id<LSPriority>)maxWithRank:(id<LSPriority>)p;
-(void)prioritize;
@end

