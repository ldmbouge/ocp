/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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
-(ORInt)getId;
-(id<LSEngine>)engine;
-(NSUInteger)inDegree;
-(id<LSPriority>)rank;
-(void)setRank:(id<LSPriority>)rank;
-(id)addListener:(id)p;
-(id)addListener:(id)p with:(ORClosure)block;
-(id)addDefiner:(id)p;
-(id<NSFastEnumeration>)outbound;
-(id<NSFastEnumeration>)inbound;
-(void)enumerateOutbound:(void(^)(id))block;
-(void)scheduleOutbound:(id<LSEngine>)engine;
@end

@protocol LSGradient<NSObject>
-(ORBool)isConstant;
-(ORBool)isVar;
-(ORBool)isLinear;
-(ORInt)constant;
-(id<LSIntVar>)variable;
-(id<LSIntVar>)intVar:(id<LSEngine>)engine;
@optional -(id<LSGradient>)addTerm:(id<LSIntVar>)x coef:(ORInt)a;
@optional -(id<LSGradient>)addConst:(ORInt)c;
@optional -(id<LSGradient>)addLinear:(id<LSGradient>)g;
@optional -(id<LSGradient>)scaleBy:(ORInt)c;
@end

@interface LSGradient : NSObject
+(id<LSGradient>)varGradient:(id<LSIntVar>)x;
+(id<LSGradient>)cstGradient:(ORInt)c;
+(id<LSGradient>)linGradient;
+(id<LSGradient>)maxOf:(id<LSGradient>)g1 and:(id<LSGradient>)g2;
+(id<LSGradient>)sumOf:(id<LSGradient>)g1 and:(id<LSGradient>)g2;
@end

@protocol  LSIntVar <LSVar>
-(ORInt)value;
-(ORInt)valueWhenVar:(id<LSIntVar>)x equal:(ORInt)v;
-(void)setValue:(ORInt)v;
-(id<ORIntRange>)domain;
-(void)setHardDomain:(id<ORIntRange>)newDomain;
-(id<LSGradient>)decrease:(id<LSIntVar>)x;
-(id<LSGradient>)increase:(id<LSIntVar>)x;
@end

@protocol LSIntVarArray <ORIdArray>
-(id<LSIntVar>) at: (ORInt) value;
-(void) set: (id<LSIntVar>) x at: (ORInt) value;
-(id<LSIntVar>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<LSIntVar>) newValue atIndexedSubscript: (NSUInteger) idx;
-(id<ORASolver>) solver;
-(id*)base;
@end

id<LSIntVarArray> sortById(id<LSIntVarArray> array);
ORBool isIdMapped(id<LSIntVarArray> array);
id<LSIntVar> findByName(id<LSIntVarArray> array,ORInt name);
ORInt findRankByName(id<LSIntVarArray> array,ORInt name);
ORBounds idRange(id<NSFastEnumeration> array,ORBounds ib);
ORBool containsVar(id<LSIntVarArray> array,ORInt name);
void collectSources(id<LSIntVarArray> x,NSArray** asv);
id<LSIntVarArray> sourceVariables(LSEngineI* engine,NSArray** asv,ORInt nb,ORBool* multiple);
id<LSIntVar>* makeVar2ViewMap(id<LSIntVarArray> x,id<LSIntVarArray> views,
                              NSArray**  asv,ORInt sz,ORBounds* b);
