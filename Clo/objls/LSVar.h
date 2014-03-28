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
@class LSEngineI;
@protocol LSEngine;
@protocol LSPriority;
@protocol LSPropagator;
@protocol LSIntVar;

@protocol LSVar <LSObject>
-(ORUInt)getId;
-(id<LSEngine>)engine;
-(NSUInteger)inDegree;
-(id<LSPriority>)rank;
-(void)setRank:(id<LSPriority>)rank;
-(id)addListener:(id)p;
-(id)addListener:(id)p with:(void(^)())block;
-(id)addDefiner:(id)p;
-(id<NSFastEnumeration>)outbound;
-(id<NSFastEnumeration>)inbound;
-(void)enumerateOutbound:(void(^)(id))block;
-(void)scheduleOutbound:(LSEngineI*)engine;
@end

typedef enum : NSUInteger {
   LSGVar = 0,
   LSGCst = 1
} LSGradientType;

typedef struct LSGradient {
   union {
      id<LSIntVar>  _vg;
      ORInt         _cg;
   };
   LSGradientType   _gt;
} LSGradient;

@protocol  LSIntVar <LSVar>
-(ORInt)value;
-(void)setValue:(ORInt)v;
-(id<ORIntRange>)domain;
-(LSGradient)decrease:(id<LSIntVar>)x;
-(LSGradient)increase:(id<LSIntVar>)x;
@end

@protocol LSIntVarArray <ORIdArray>
-(id<LSIntVar>) at: (ORInt) value;
-(void) set: (id<LSIntVar>) x at: (ORInt) value;
-(id<LSIntVar>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<LSIntVar>) newValue atIndexedSubscript: (NSUInteger) idx;
-(id<ORASolver>) solver;
@end

ORBool isIdMapped(id<LSIntVarArray> array);
id<LSIntVar> findByName(id<LSIntVarArray> array,ORInt name);
ORInt findRankByName(id<LSIntVarArray> array,ORInt name);
ORBounds idRange(id<NSFastEnumeration> array,ORBounds ib);
ORBool containsVar(id<LSIntVarArray> array,ORInt name);
void collectSources(id<LSIntVarArray> x,NSArray** asv);
id<LSIntVarArray> sourceVariables(LSEngineI* engine,NSArray** asv,ORInt nb,ORBool* multiple);
id<LSIntVar>* makeVar2ViewMap(id<LSIntVarArray> x,id<LSIntVarArray> views,
                              NSArray**  asv,ORInt sz,ORBounds* b);
