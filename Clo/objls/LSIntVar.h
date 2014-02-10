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

@protocol LSLink
-(id)target;
-(id)source;
@end

typedef enum LSStatus {
   LSFinal   = 0,
   LSPending = 1
} LSStatus;

@interface LSIntVar : ORObject<LSVar> {
   LSEngineI*    _engine;
   ORInt          _value;
   enum LSStatus _status;
   NSMutableSet*    _outbound;
   NSMutableSet*    _inbound;
   id<LSPriority>   _rank;
}
-(id)initWithEngine:(id<LSEngine>)engine andValue:(ORInt)v;
-(void)dealloc;
-(void)setValue:(ORInt)v;
-(ORInt)value;
-(ORInt)incr;
-(ORInt)decr;
-(id)addListener:(LSPropagator*)p term:(ORInt)k;
-(id)addDefiner:(LSPropagator*)p;
-(id<LSPriority>)rank;
-(void)setRank:(id<LSPriority>)r;
-(NSUInteger)inDegree;
-(id<NSFastEnumeration>)outbound;
-(id<NSFastEnumeration>)inbound;
-(void)enumerateOutbound:(void(^)(id,ORInt))block;
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