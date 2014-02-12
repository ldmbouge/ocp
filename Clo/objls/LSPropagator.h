/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "LSEngineI.h"
#import "LSPriority.h"
#import <objls/LSObject.h>


@protocol LSVar;
@class LSLink;
@class LSIntVar;

@interface PStore : NSObject {
   LSEngineI* _engine;
   ORInt*      _marks;
   ORInt     _low,_up;
}
-(id)initPStore:(LSEngineI*)engine;
-(BOOL)closed:(id<ORObject>)v;
-(BOOL)finalNotice:(id<ORObject>)v;
-(BOOL)lastTime:(id<ORObject>)v;
-(id<LSPriority>)maxWithRank:(id<LSPriority>)p;
-(void)prioritize;
@end

@protocol LSPropagator<LSObject>
-(void)define;
-(void)post;
-(void)execute;
@end

@interface LSPropagator : ORObject<LSPropagator> {
@package
   id<LSPriority>   _rank;
   LSEngineI*     _engine;
   NSMutableSet* _inbound;
   BOOL          _inQueue;
}
-(id)initWith:(id<LSEngine>)engine;
-(void)post;
-(void)define;
-(void)execute;
-(void)addTrigger:(LSLink*)link;
-(void)prioritize:(PStore*)p;
-(NSUInteger)inDegree;
@end

@interface LSBlock : LSPropagator {
   void       (^_block)();
}
-(id)initWith:(id<LSEngine>)engine block:(void(^)())block atPriority:(id<LSPriority>)p;
-(void)define;
-(void)post;
-(void)execute;
-(id<LSPriority>)rank;
-(void)setRank:(id<LSPriority>)rank;
@end

@protocol LSPull
-(void)pull:(ORInt)k;
@end