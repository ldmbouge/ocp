/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "LSEngineI.h"
#import "LSPriority.h"
#import <objls/LSObject.h>
#import <objls/LSVar.h>

@protocol LSVar;
@class LSLink;
@class LSIntVar;



@protocol LSPropagator<LSObject>
-(void)define;
-(void)post;
-(void)execute;
-(id<LSPriority>)rank;
@end

@interface LSPropagator : ORObject<LSPropagator> {
@package
   id<LSPriority>   _rank;
   LSEngineI*       _engine;
   NSMutableSet*    _inbound;
   BOOL             _inQueue;
}
-(id)initWith:(id<LSEngine>)engine;
-(void)post;
-(void)define;
-(void)execute;
-(void)addTrigger:(id)link;
-(NSUInteger)inDegree;
@end

// [pvh] These are views. They seem to still have a lot of the stuff to propagate. Need to check.

@interface LSCoreView : ORObject<LSIntVar> {
   LSEngineI*       _engine;
   id<ORIntRange>      _dom;
   NSMutableSet*  _outbound;  // [pvh] propagator
   NSMutableSet*   _inbound;  // [pvh] propagator
   NSMutableArray* _closures; // [pvh] closure to propagate
   NSArray*            _src;  // [pvh] source variables of the view
   id<LSPriority>     _rank;  // [pvh] why a rank on variables; check if still needed
}
-(id)initWith:(id<LSEngine>)engine  domain:(id<ORIntRange>)d src:(NSArray*)src;
-(LSEngineI*)engine;
-(id<ORIntRange>)domain;
-(NSArray*)sourceVars;
-(void)setValue:(ORInt)v;
-(id)addListener:(LSPropagator*)p;
-(id<LSPriority>)rank;
-(void)setRank:(id<LSPriority>)r;
-(NSUInteger)inDegree;
-(id<NSFastEnumeration>)outbound;
-(id<NSFastEnumeration>)inbound;
-(void)enumerateOutbound:(void(^)(id))block;
-(void)scheduleOutbound:(LSEngineI*)engine;
-(ORInt)valueWhenVar:(id<LSIntVar>)x equal:(ORInt)v;
@end

@interface LSIntVarView : LSCoreView {
   ORInt(^_fun)();
}
-(id)initWithEngine:(id<LSEngine>)engine domain:(id<ORIntRange>)d fun:(ORInt(^)())fun src:(NSArray*)src;
-(ORInt)value;
-(ORInt)valueWhenVar:(id<LSIntVar>)x equal:(ORInt)v;
@end

// [pvh]: This is a (x == c) view

@interface LSEQLitView : LSCoreView {
   id<LSIntVar>        _x;
   ORInt               _lit;
}
-(id)initWithEngine:(id<LSEngine>)engine on:(id<LSIntVar>)x eqLit:(ORInt)c;
-(ORInt)value;
-(ORInt)valueWhenVar:(id<LSIntVar>)x equal:(ORInt)v;
@end

@interface LSAffineView : LSCoreView {
   ORInt         _a,_b;
   id<LSIntVar>     _x;
}
-(id)initWithEngine:(id<LSEngine>)engine a:(ORInt)a times:(id<LSIntVar>)x plus:(ORInt)b;
-(ORInt)value;
-(ORInt)valueWhenVar:(id<LSIntVar>)x equal:(ORInt)v;
@end

// [pvh]: Not sue what this is at this point

@interface LSBlock : LSPropagator {
   ORClosure _block;
}
-(id)initWith:(id<LSEngine>)engine block:(ORClosure)block atPriority:(id<LSPriority>)p;
-(void)define;
-(void)post;
-(void)execute;
-(id<LSPriority>)rank;
-(void)setRank:(id<LSPriority>)rank;
@end
