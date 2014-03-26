/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPEngine.h>

/*
 
[PVH]
 
1. simplify scheduleClosures et les appels
2. Check if the group stuff can be simplified
 
*/

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
@end

@protocol CPGroup <CPConstraint>
-(void)  add:(id<CPConstraint>)p;
-(void)  scheduleClosures:(id<CPClosureList>)evt;
@end

@protocol CPValueEvent<NSObject>
-(ORInt) execute;
@end

// [PVH] To display the closure + the non-created closure to propagate constraints

@protocol CPClosureList <NSObject>
-(ORClosure) trigger;                
-(id<CPClosureList>) next;           // fetches the tail of the list
-(void) scanWithBlock:(void(^)(id))block;
-(void) scanCstrWithBlock:(void(^)(id))block;
@end

typedef void(^ORID2Void)(id);

void scanListWithBlock(id<CPClosureList> list,ORID2Void block);
void collectList(id<CPClosureList> list,NSMutableSet* rv);
void freeList(id<CPClosureList> list);
void hookupEvent(id<CPEngine> engine,TRId* evtList,id todo,id<CPConstraint> c,ORInt priority);

@interface CPFactory : NSObject
+(id<CPEngine>) engine: (id<ORTrail>) trail memory:(id<ORMemoryTrail>)mt;
+(id<CPGroup>) group:(id<CPEngine>)engine;
+(id<CPGroup>) bergeGroup:(id<CPEngine>)engine;
@end;
