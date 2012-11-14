/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPTypes.h>
#import <objcp/CPData.h>
@protocol CPIntVar;
@protocol CPEvent;
@protocol CPConstraint;
@protocol VarEventNode;
@class CPCoreConstraint;

@protocol CPEngine <OREngine>
-(void) scheduleTrigger:(ConstraintCallback)cb onBehalf: (id<CPConstraint>)c;
-(void) scheduleAC3:(id<VarEventNode>*)mlist;
-(void) scheduleAC5:(id<CPEvent>)evt;
-(void) setObjective: (id<ORObjective>) obj;
-(id<ORObjective>)objective;
-(ORStatus)  addInternal:(id<ORConstraint>) c;
-(ORStatus) add: (id<ORConstraint>) c;
-(ORStatus) post: (id<ORConstraint>) c;
-(ORStatus) label: (id<CPIntVar>) var with: (ORInt) val;
-(ORStatus) diff:  (id<CPIntVar>) var with: (ORInt) val;
-(ORStatus) lthen: (id<CPIntVar>) var with: (ORInt) val;
-(ORStatus) gthen: (id<CPIntVar>) var with: (ORInt) val;
-(ORStatus) restrict: (id<CPIntVar>) var to: (id<ORIntSet>) S;
-(ORStatus) propagate;
-(ORUInt) nbPropagation;
-(ORUInt) nbVars;
-(NSMutableArray*)allVars;
-(id) trail;
-(id<ORInformer>) propagateFail;
-(id<ORInformer>) propagateDone;
@end
