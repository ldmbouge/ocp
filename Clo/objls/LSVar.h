/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objls/LSObject.h>

@class LSPropagator;
@protocol LSEngine;
@protocol LSPriority;

@protocol LSVar <LSObject>
-(ORUInt)getId;
-(id<LSEngine>)engine;
-(NSUInteger)inDegree;
-(id<LSPriority>)rank;
-(void)setRank:(id<LSPriority>)rank;
-(id)addListener:(LSPropagator*)p term:(ORInt)k;
-(id)addDefiner:(LSPropagator*)p;
-(id<NSFastEnumeration>)outbound;
-(id<NSFastEnumeration>)inbound;
-(void)enumerateOutbound:(void(^)(id,ORInt))block;
@end

@protocol  LSIntVar <LSVar>
-(ORInt)value;
-(id<ORIntRange>)domain;
@end

@protocol LSIntVarArray <ORIdArray>
-(id<LSIntVar>) at: (ORInt) value;
-(void) set: (id<LSIntVar>) x at: (ORInt) value;
-(id<LSIntVar>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<LSIntVar>) newValue atIndexedSubscript: (NSUInteger) idx;
-(id<ORASolver>) solver;
@end