/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPTypes.h>
#import <CPUKernel/CPEngine.h>
#import <CPUKernel/CPTrigger.h>
#import <CPUKernel/CPClosureEvent.h>
#import <CPUKernel/CPLEngine.h>

/*
 
[PVH]
 
1. simplify scheduleClosures et les appels
2. Check if the group stuff can be simplified
 
*/

struct _CPBitAssignment;
typedef struct _CPBitAssignment CPBitAssignment;

struct _CPBitAntecedents;
typedef struct _CPBitAntecedents CPBitAntecedents;

typedef enum {
   CPChecked,
   CPTocheck,
   CPOff
} CPTodo;

@protocol CPGroup;

@protocol CPConstraint <ORConstraint>
-(ORUInt)      getId;
-(void)        setGroup:(id<CPGroup>) g;
-(id<CPGroup>) group;
-(void) post;
@end

@protocol CPBVConstraint <CPConstraint>
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*)assignment;
//-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*)assignment withState:(ORUInt**)state;
@end

@protocol CPGroup <CPConstraint>
-(void)  add:(id<CPConstraint>)p;
-(void)  assignIdToConstraint:(id<ORConstraint>)c;
-(void)  scheduleClosure:(id<CPClosureList>)evt;
@end

@protocol CPValueEvent<NSObject>
-(ORInt) execute;
@end

typedef void(^ORID2Void)(id);

void scanListWithBlock(id<CPClosureList> list,ORID2Void block);
void collectList(id<CPClosureList> list,NSMutableSet* rv);
void freeList(id<CPClosureList> list);
void hookupEvent(id<CPEngine> engine,TRId* evtList,id todo,id<CPConstraint> c,ORInt priority);

@interface CPFactory : NSObject
+(id<CPEngine>) engine: (id<ORTrail>) trail memory:(id<ORMemoryTrail>)mt;
+(id<CPEngine>) learningEngine: (id<ORTrail>)trail memory:(id<ORMemoryTrail>)mt tracer:(id<ORTracer>)tr;
+(id<CPGroup>)group:(id<CPEngine>)engine;
+(id<CPGroup>)bergeGroup:(id<CPEngine>)engine;
@end;
#import <CPUKernel/CPConstraintI.h>

