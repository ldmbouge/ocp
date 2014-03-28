/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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

typedef enum LSMode {
   LSInitial = 0,
   LSClosing = 1,
   LSIncremental = 2
} LSMode;

@interface LSEngineI : NSObject<ORSearchEngine,LSEngine> {
   NSMutableArray* _vars;
   NSMutableArray* _objs;
   NSMutableArray* _cstr;
   NSMutableArray* _invs;
   ORUInt        _nbObjects;
   LSMode           _mode;
   ORInt            _atomic;
   LSPrioritySpace* _pSpace;
   LSRQueue*        _queue;
}
-(LSEngineI*)initEngine;
-(void)dealloc;
-(ORStatus)close;
-(LSPrioritySpace*)space;
-(id<ORSearchObjectiveFunction>) objective;
-(void)add:(id<LSPropagator>)i;
-(id<LSConstraint>)addConstraint:(id<LSConstraint>)cstr;
-(NSMutableArray*)variables;
-(NSMutableArray*)invariants;
-(ORUInt)nbObjects;
-(void)label:(LSIntVar*)x with:(ORInt)v;
-(void)notify:(id<LSVar>)x;
-(void)schedule:(id<LSPropagator>)x;
@end
