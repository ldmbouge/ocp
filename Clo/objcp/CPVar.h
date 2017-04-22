/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPData.h>
#import <CPUKernel/CPTrigger.h>

@protocol CPEngine;
@protocol ORTracer;
@protocol CPBitVar;

enum CPVarClass {
   CPVCBare = 0,
   CPVCShift = 1,
   CPVCAffine = 2,
   CPVCEQLiteral = 3,
   CPVCFlip = 4,
   CPVCCast = 5,
   CPVCCst = 6
};

@protocol CPParam <NSObject>
-(ORUInt) getId;
-(id<ORTracker>)tracker;
-(id<CPEngine>)engine;
-(NSSet*)constraints;
@end

@protocol CPVar <NSObject>
-(ORUInt) getId;
-(id<ORTracker>)tracker;
-(id<CPEngine>)engine;
-(ORBool) bound;
-(NSSet*)constraints;
-(ORInt)degree;
-(ORBool)vertical;
-(ORInt) domsize;
@end


@protocol CPNumVarSubscriber <NSObject>

// AC3 Closure Event
-(void) whenChangeDo: (ORClosure) todo priority: (ORInt) p onBehalf:(id<CPConstraint>)c;
-(void) whenChangeMinDo: (ORClosure) todo priority: (ORInt) p onBehalf:(id<CPConstraint>)c;
-(void) whenChangeMaxDo: (ORClosure) todo priority: (ORInt) p onBehalf:(id<CPConstraint>)c;
-(void) whenChangeBoundsDo: (ORClosure) todo priority: (ORInt) p onBehalf:(id<CPConstraint>)c;

-(void) whenChangeDo: (ORClosure) todo onBehalf:(id<CPConstraint>)c;
-(void) whenChangeMinDo: (ORClosure) todo onBehalf:(id<CPConstraint>)c;
-(void) whenChangeMaxDo: (ORClosure) todo onBehalf:(id<CPConstraint>)c;
-(void) whenChangeBoundsDo: (ORClosure) todo onBehalf:(id<CPConstraint>)c;

// AC3 Constraint Event
-(void) whenChangePropagate:  (id<CPConstraint>) c priority: (ORInt) p;
-(void) whenChangeMinPropagate: (id<CPConstraint>) c priority: (ORInt) p;
-(void) whenChangeMaxPropagate: (id<CPConstraint>) c priority: (ORInt) p;
-(void) whenChangeBoundsPropagate: (id<CPConstraint>) c priority: (ORInt) p;

-(void) whenChangePropagate:  (id<CPConstraint>) c;
-(void) whenChangeMinPropagate: (id<CPConstraint>) c;
-(void) whenChangeMaxPropagate: (id<CPConstraint>) c;
-(void) whenChangeBoundsPropagate: (id<CPConstraint>) c;

@end

@protocol CPNumVar <CPVar,CPNumVarSubscriber>
-(ORDouble) doubleMin;
-(ORDouble) doubleMax;
-(ORDouble) doubleValue;
@end

@protocol CPIntVarSubscriber <CPNumVarSubscriber>

// AC3 Closure Event
-(void) whenBindDo: (ORClosure) todo priority: (ORInt) p onBehalf:(id<CPConstraint>)c;
-(void) whenBindDo: (ORClosure) todo onBehalf:(id<CPConstraint>)c;

// AC3 Constraint Event
-(void) whenBindPropagate: (id<CPConstraint>) c priority: (ORInt) p;
-(void) whenBindPropagate: (id<CPConstraint>) c;

// AC5 Event
-(void) whenLoseValue: (id<CPConstraint>) c do: (ORIntClosure) todo;

// Triggers
// create a trigger which executes todo when value val is removed.
-(id<CPTrigger>) setLoseTrigger: (ORInt) val do: (ORClosure) todo onBehalf:(id<CPConstraint>)c;
// create a trigger which executes todo when the variable is bound.
-(id<CPTrigger>) setBindTrigger: (ORClosure) todo onBehalf:(id<CPConstraint>)c;
// assign a trigger which is executed when value val is removed.
-(void) watch:(ORInt) val with: (id<CPTrigger>) t;
-(void) watchBind:(id<CPTrigger>)t;
@end
@class CPIntVar;

@protocol CPIntVar <CPNumVar,CPIntVarSubscriber>
-(enum CPVarClass)varClass;
-(ORInt) value;
-(ORInt) min;
-(ORInt) max;
-(ORInt) domsize;
-(ORInt) regret;
-(ORBounds) bounds;
-(ORBool) member: (ORInt) v;
-(ORBool) isBool;
-(id<ORIntVar>) base;
-(ORBool) bound;
-(ORInt) countFrom: (ORInt) from to: (ORInt) to;
-(void) bind:(ORInt) val;
-(void) remove: (ORInt) val;
-(void) inside: (id<ORIntSet>) S;
-(void) updateMin: (ORInt) newMin;
-(void) updateMax: (ORInt) newMax;
-(ORBounds) updateMin: (ORInt) newMin andMax: (ORInt) newMax;
@end

@protocol CPVarArray <ORVarArray>
-(id<CPVar>) at: (ORInt) value;
-(void) set: (id<CPVar>) x at: (ORInt) value;
-(id<CPVar>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<CPVar>) newValue atIndexedSubscript: (NSUInteger) idx;
-(id<ORASolver>) solver;
@end

@protocol CPIntVarArray <CPVarArray>
-(id<CPIntVar>) at: (ORInt) value;
-(void) set: (id<CPIntVar>) x at: (ORInt) value;
-(id<CPIntVar>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<CPIntVar>) newValue atIndexedSubscript: (NSUInteger) idx;
-(id<ORASolver>) solver;
@end

@protocol CPBitVarArray <CPVarArray>
-(id<CPBitVar>) at: (ORInt) value;
-(void) set: (id<CPBitVar>) x at: (ORInt) value;
-(id<CPBitVar>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<CPBitVar>) newValue atIndexedSubscript: (NSUInteger) idx;
-(id<ORASolver>) solver;
@end

@protocol CPIntVarMatrix <ORIdMatrix>
-(ORInt) arity;
-(id<CPIntVar>) flat:(ORInt)i;
-(id<CPIntVar>) at: (ORInt) i1 : (ORInt) i2;
-(id<CPIntVar>) at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(void) set: (id) x at: (ORInt) i1 : (ORInt) i2;
-(void) set: (id) x at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(id<ORIntRange>) range: (ORInt) i;
-(NSUInteger)count;
-(NSString*) description;
-(id<ORASolver>) solver;
@end

@protocol CPRealVar<CPVar>
-(ORDouble) min;
-(ORDouble) max;
-(ORDouble) value;
-(ORInterval) bounds;
-(ORBool) member:(ORDouble)v;
-(ORBool) bound;
-(ORDouble) domwidth;
-(void) bind:(ORDouble) val;
-(void) updateMin:(ORDouble) newMin;
-(void) updateMax:(ORDouble) newMax;
-(void) assignRelaxationValue: (ORDouble) f;
-(ORNarrowing) updateInterval: (ORInterval) v;
@end
//----------------------
@protocol CPFloatVar<CPVar>
-(ORFloat) min;
-(ORFloat) max;
-(ORFloat) value;
-(ORFloat) floatValue;
-(ORInterval) bounds;
-(ORBool) member:(ORFloat)v;
-(ORBool) bound;
-(ORLDouble) domwidth;
-(ORDouble) cardinality;
-(ORLDouble) density;
-(ORFloat) magnitude;
-(void) bind:(ORFloat) val;
-(void) updateMin:(ORFloat) newMin;
-(void) updateMax:(ORFloat) newMax;
-(void) assignRelaxationValue: (ORFloat) f;
-(void) updateInterval: (ORFloat) newMin and:(ORFloat) newMax;
//TODO change to function
-(ORBool) isIntersectingWith : (id<CPFloatVar>) y;
-(ORBool) isDisjointWith : (id<CPFloatVar>) y;
-(ORBool) canPrecede : (id<CPFloatVar>) y;
-(ORBool) canFollow : (id<CPFloatVar>) y;
@end

@protocol CPDoubleVar<CPVar>
-(ORDouble) min;
-(ORDouble) max;
-(ORDouble) value;
-(ORInterval) bounds;
-(ORBool) member:(ORDouble)v;
-(ORBool) bound;
-(ORDouble) domwidth;
-(void) bind:(ORDouble) val;
-(void) updateMin:(ORDouble) newMin;
-(void) updateMax:(ORDouble) newMax;
-(void) assignRelaxationValue: (ORDouble) f;
-(ORNarrowing) updateInterval: (ORInterval) v;
@end

@protocol CPLDoubleVar<CPVar>
-(ORLDouble) min;
-(ORLDouble) max;
-(ORLDouble) value;
-(ORInterval) bounds;
-(ORBool) member:(ORLDouble)v;
-(ORBool) bound;
-(ORLDouble) domwidth;
-(void) bind:(ORLDouble) val;
-(void) updateMin:(ORLDouble) newMin;
-(void) updateMax:(ORLDouble) newMax;
-(void) assignRelaxationValue: (ORLDouble) f;
-(ORNarrowing) updateInterval: (ORInterval) v;
@end
//----------------------

@protocol CPFloatVarArray <CPVarArray>
-(id<CPFloatVar>) at: (ORInt) value;
-(void) set: (id<CPFloatVar>) x at: (ORInt) value;
-(id<CPFloatVar>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<CPFloatVar>) newValue atIndexedSubscript: (NSUInteger) idx;
-(id<ORASolver>) solver;
@end

@protocol CPRealParam<CPParam>
-(ORDouble) value;
-(void) setValue: (ORDouble)val;
@end

@protocol CPRealVarArray <CPVarArray>
-(id<CPRealVar>) at: (ORInt) value;
-(void) set: (id<CPRealVar>) x at: (ORInt) value;
-(id<CPRealVar>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<CPRealVar>) newValue atIndexedSubscript: (NSUInteger) idx;
-(id<ORASolver>) solver;
@end

@protocol CPIntSetVar <CPVar>
-(id<CPIntVar>)cardinality;
-(ORBool)bound;
-(id<IntEnumerator>)required;
-(id<IntEnumerator>)possible;
-(id<IntEnumerator>)excluded;
-(ORInt)cardRequired;
-(ORInt)cardPossible;
-(ORBool)isRequired:(ORInt)v;
-(ORBool)isPossible:(ORInt)v;
-(ORBool)isExcluded:(ORInt)v;
-(void)require:(ORInt)v;
-(void)exclude:(ORInt)v;
// notifications APIs
-(void)whenRequired:(id<CPConstraint>)c do:(ORIntClosure)todo;
-(void)whenExcluded:(id<CPConstraint>)c do:(ORIntClosure)todo;
-(void)whenBound:(id<CPConstraint>)c do:(ORClosure)todo;
-(void)whenChange:(id<CPConstraint>)c do:(ORClosure)todo;
// events
-(void)requireEvt:(ORInt)v;
-(void)excludeEvt:(ORInt)v;
-(void)bindEvt;
-(void)changeEvt;
@end

