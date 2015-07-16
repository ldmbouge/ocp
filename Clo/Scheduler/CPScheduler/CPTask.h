/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <objcp/CPVar.h>

@class CPTaskDisjunctive;
@class CPTaskCumulative;
@protocol CPTaskVarArray;
@protocol CPDisjunctiveArray;
@protocol CPResourceArray;


@protocol CPTaskVarSubscriber <NSObject>

// AC3 Closure Event
-(void) whenChangeDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c;
-(void) whenChangeStartDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c;
-(void) whenChangeEndDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c;
-(void) whenAbsentDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c;
-(void) whenPresentDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c;
-(void) whenChangeDurationDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c;

-(void) whenChangeDo: (ORClosure) todo onBehalf: (id<CPConstraint>) c;
-(void) whenChangeStartDo: (ORClosure) todo onBehalf: (id<CPConstraint>) c;
-(void) whenChangeEndDo: (ORClosure) todo onBehalf: (id<CPConstraint>) c;
-(void) whenAbsentDo: (ORClosure) todo onBehalf: (id<CPConstraint>) c;
-(void) whenPresentDo: (ORClosure) todo onBehalf: (id<CPConstraint>) c;
-(void) whenChangeDurationDo: (ORClosure) todo onBehalf: (id<CPConstraint>) c;

// AC3 Constraint Event
-(void) whenChangePropagate:  (id<CPConstraint>) c priority: (ORInt) p;
-(void) whenChangeStartPropagate: (id<CPConstraint>) c priority: (ORInt) p;
-(void) whenChangeEndPropagate: (id<CPConstraint>) c priority: (ORInt) p;
-(void) whenAbsentPropagate: (id<CPConstraint>) c priority: (ORInt) p;
-(void) whenPresentPropagate: (id<CPConstraint>) c priority: (ORInt) p;
-(void) whenChangeDurationPropagate: (id<CPConstraint>) c priority: (ORInt) p;


-(void) whenChangePropagate: (id<CPConstraint>) c;
-(void) whenChangeStartPropagate: (id<CPConstraint>) c;
-(void) whenChangeEndPropagate: (id<CPConstraint>) c;
-(void) whenAbsentPropagate: (id<CPConstraint>) c;
-(void) whenPresentPropagate: (id<CPConstraint>) c;
-(void) whenChangeDurationPropagate: (CPCoreConstraint*) c;
@end

@protocol CPTaskVar <CPVar,CPTaskVarSubscriber>
-(ORInt) getId;
-(id<CPEngine>) engine;
-(ORInt) est;
-(ORInt) ect;
-(ORInt) lst;
-(ORInt) lct;
-(ORBool) bound;
-(ORInt) minDuration;
-(ORInt) maxDuration;
-(ORBool) isPresent;
-(ORBool) isAbsent;
-(ORBool) isOptional;
-(ORBool) readEst: (ORInt *) est lct: (ORInt *) lct minDuration: (ORInt *) minD maxDuration: (ORInt *) maxD present: (ORBool *) present absent: (ORBool *) absent forResource:(id)resource;
-(void) updateStart: (ORInt) newStart;
-(void) updateEnd: (ORInt) newEnd;
-(void) updateStart: (ORInt) newStart end:(ORInt) newEnd;
-(void) updateMinDuration: (ORInt) newMinDuration;
-(void) updateMaxDuration: (ORInt) newMaxDuration;
-(void) labelStart: (ORInt) start;
-(void) labelEnd: (ORInt) end;
-(void) labelDuration: (ORInt) duration;
-(void) labelPresent: (ORBool) present;
@end

@protocol CPAlternativeTask <CPTaskVar>
-(id<CPTaskVarArray>) alternatives;
@end

@protocol CPSpanTask <CPTaskVar>
-(id<CPTaskVarArray>) compound;
@end

@protocol CPResourceTask <CPTaskVar>
-(id<CPResourceArray>) resources;
-(void) set: (id<CPConstraint>) resource at: (ORInt) idx;
-(id<ORIntArray>) getAvailResources;
-(ORBool) isPresentOn: (id<CPConstraint>) resource;
-(ORBool) isAbsentOn: (id<CPConstraint>) resource;
-(ORBool) isAssigned;
-(void) bind: (id<CPConstraint>) resource;
-(void) remove: (id<CPConstraint>) resource;
-(ORInt) runsOn;
@end

@protocol CPTaskVarArray <ORObject>
-(id<CPTaskVar>) at: (ORInt) idx;
-(void) set: (id<CPTaskVar>) value at: (ORInt)idx;
-(id<CPTaskVar>)objectAtIndexedSubscript:(NSUInteger)key;
-(void)setObject:(id<CPTaskVar>)newValue atIndexedSubscript:(NSUInteger)idx;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end

@protocol CPResourceArray <ORObject>
-(id<CPConstraint>) at: (ORInt) idx;
-(void) set: (id<CPConstraint>) value at: (ORInt)idx;
-(id<CPConstraint>)objectAtIndexedSubscript:(NSUInteger)key;
-(void)setObject:(id<CPConstraint>)newValue atIndexedSubscript:(NSUInteger)idx;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end

