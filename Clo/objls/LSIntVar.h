/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objls/LSVar.h>
#import "LSPriority.h"

@protocol LSEngine;
@class LSPropagator;
@class LSEngineI;

typedef enum LSStatus {
   LSFinal   = 0,
   LSPending = 1
} LSStatus;

@interface LSIntVar : ORObject<LSIntVar> {
   LSEngineI*       _engine;
   id<ORIntRange>   _dom;
   enum LSStatus    _status;
   NSMutableSet*    _outbound;  // [pvh] propagators
   NSMutableSet*    _inbound;
   NSMutableArray*  _closures;
   id<LSPriority>   _rank;
@package
   ORInt          _value;
}
-(id)initWithEngine:(id<LSEngine>)engine domain:(id<ORIntRange>)d;
-(LSEngineI*)engine;
-(id<ORIntRange>)domain;
-(void)setValue:(ORInt)v;
-(ORInt)value;
-(ORInt)incr;
-(ORInt)decr;
-(ORInt)lookahead:(id<LSIntVar>)y onAssign:(ORInt)v;
-(id)addListener:(LSPropagator*)p;
-(id)addDefiner:(id)p;
-(id<LSPriority>)rank;
-(void)setRank:(id<LSPriority>)r;
-(NSUInteger)inDegree;
-(id<NSFastEnumeration>)outbound;
-(id<NSFastEnumeration>)inbound;
-(void)enumerateOutbound:(void(^)(id))block;
-(void)scheduleOutbound:(LSEngineI*)engine;
@end

inline static ORInt getLSIntValue(LSIntVar* x) { return x->_value;}

