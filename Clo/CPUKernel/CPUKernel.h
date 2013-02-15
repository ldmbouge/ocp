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
 
pvh: 
 
1. simplify scheduleAC3 et les appels
2. Rename CPEventNode
 
 */

typedef enum {
   CPChecked,
   CPTocheck,
   CPOff
} CPTodo;

@protocol CPGroup;

@protocol CPConstraint <ORConstraint,ORCommand>
-(ORUInt) getId;
-(void)setGroup:(id<CPGroup>)g;
-(id<CPGroup>)group;
@end

@protocol CPGroup <CPConstraint>
-(void)add:(id<CPConstraint>)p;
-(void)scheduleAC3:(id<CPEventNode>)evt;
@end

@protocol CPAC5Event<NSObject>
-(ORInt) execute;
@end

@protocol CPEventNode <NSObject>
-(id) trigger;                      // retrieves the closure responsible for responding to the event
-(id<CPEventNode>) next;           // fetches the next event in the list *list suffix*
-(void)scanWithBlock:(void(^)(id))block;
@end

typedef void(^ORID2Void)(id);

void scanListWithBlock(id<CPEventNode> list,ORID2Void block);
void collectList(id<CPEventNode> list,NSMutableSet* rv);
void freeList(id<CPEventNode> list);
void hookupEvent(id<CPEngine> engine,TRId* evtList,id todo,id<CPConstraint> c,ORInt priority);

@interface CPFactory : NSObject
+(id<CPEngine>) engine: (id<ORTrail>) trail;
+(id<CPGroup>)group:(id<CPEngine>)engine;
+(id<CPGroup>)bergeGroup:(id<CPEngine>)engine;
@end;