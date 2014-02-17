/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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

@protocol LSLink
-(id)target;
-(id)source;
@end

typedef enum LSStatus {
   LSFinal   = 0,
   LSPending = 1
} LSStatus;

@interface LSIntVar : ORObject<LSIntVar> {
   LSEngineI*    _engine;
   id<ORIntRange>   _dom;
   ORInt          _value;
   enum LSStatus _status;
   NSMutableSet*    _outbound;
   NSMutableSet*    _inbound;
   id<LSPriority>   _rank;
}
-(id)initWithEngine:(id<LSEngine>)engine domain:(id<ORIntRange>)d;
-(LSEngineI*)engine;
-(id<ORIntRange>)domain;
-(void)setValue:(ORInt)v;
-(ORInt)value;
-(ORInt)incr;
-(ORInt)decr;
-(ORInt)lookahead:(id<LSIntVar>)y onAssign:(ORInt)v;
-(id)addListener:(LSPropagator*)p term:(ORInt)k;
-(id)addDefiner:(id)p;
-(id<LSPriority>)rank;
-(void)setRank:(id<LSPriority>)r;
-(NSUInteger)inDegree;
-(id<NSFastEnumeration>)outbound;
-(id<NSFastEnumeration>)inbound;
-(void)enumerateOutbound:(void(^)(id,ORInt))block;
-(void)propagateOutbound:(void(^)(id,ORInt))block;
@end

@interface LSOutbound : NSObject<NSFastEnumeration> {
   NSSet* _theSet;
}
-(id)initWith:(NSSet*)theSet;
@end

@interface LSInbound : NSObject<NSFastEnumeration> {
   NSSet* _theSet;
}
-(id)initWith:(NSSet*)theSet;
@end

typedef enum LSLinkType {
   LSLogical = 0,
   LSPropagate = 1
} LSLinkType;

@interface LSLink : NSObject<LSLink> {
@public
   id _src;
   id _trg;
   ORInt      _k;
   void (^_block)();
   LSLinkType _t;
}
-(id)initLinkFrom:(id)src to:(id)trg for:(ORInt)k type:(LSLinkType)t;
-(id)initLinkFrom:(id)src to:(id)trg for:(ORInt)k block:(void(^)())block type:(LSLinkType)t;
-(id)source;
-(id)target;
-(ORInt)index;
-(LSLinkType)type;
@end
