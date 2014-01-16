/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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

@protocol CPVar <NSObject>
-(ORUInt) getId;
-(id<ORTracker>)tracker;
-(id<CPEngine>)engine;
-(ORBool) bound;
-(NSSet*)constraints;
-(ORInt)degree;
-(enum CPVarClass)varClass;
@end

@protocol CPNumVar <CPVar>
-(ORFloat) floatMin;
-(ORFloat) floatMax;
-(ORFloat) floatValue;
@end

@protocol CPIntVarSubscriber <NSObject>

// AC3 Closure Event
-(void) whenBindDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeMinDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeMaxDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeBoundsDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c;

-(void) whenBindDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeMinDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeMaxDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
-(void) whenChangeBoundsDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;

// AC3 Constraint Event
-(void) whenBindPropagate: (CPCoreConstraint*) c priority: (ORInt) p;
-(void) whenChangePropagate:  (CPCoreConstraint*) c priority: (ORInt) p;
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p;
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p;
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c priority: (ORInt) p;

-(void) whenBindPropagate: (CPCoreConstraint*) c;
-(void) whenChangePropagate:  (CPCoreConstraint*) c;
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c;
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c;
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c;

// AC5 Event
-(void) whenLoseValue: (CPCoreConstraint*) c do: (ConstraintIntCallBack) todo;

// Triggers
// create a trigger which executes todo when value val is removed.
-(id<CPTrigger>) setLoseTrigger: (ORInt) val do: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
// create a trigger which executes todo when the variable is bound.
-(id<CPTrigger>) setBindTrigger: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c;
// assign a trigger which is executed when value val is removed.
-(void) watch:(ORInt) val with: (id<CPTrigger>) t;

@end
@class CPIntVar;

@protocol CPIntVar <CPNumVar,CPIntVarSubscriber>
-(enum CPVarClass)varClass;
-(ORInt) value;
-(ORInt) min;
-(ORInt) max;
-(ORInt) domsize;
-(ORBounds) bounds;
-(ORBool) member: (ORInt) v;
-(ORBool) isBool;
-(ORInt) scale;
-(ORInt) shift;
-(id<ORIntVar>) base;
-(ORBool) bound;
-(ORInt) countFrom: (ORInt) from to: (ORInt) to;
-(void) bind:(ORInt) val;
-(void) remove: (ORInt) val;
-(void) inside: (id<ORIntSet>) S;
-(void) updateMin: (ORInt) newMin;
-(void) updateMax: (ORInt) newMax;
-(ORBounds) updateMin: (ORInt) newMin andMax: (ORInt) newMax;
-(CPIntVar*) findAffine: (ORInt) scale shift: (ORInt) shift;
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

@protocol CPFloatVar<CPVar>
-(ORFloat) min;
-(ORFloat) max;
-(ORFloat) value;
-(ORInterval) bounds;
-(ORBool) member:(ORFloat)v;
-(ORBool) bound;
-(ORFloat) domwidth;
-(void) bind:(ORFloat) val;
-(void) updateMin:(ORFloat) newMin;
-(void) updateMax:(ORFloat) newMax;
-(ORNarrowing) updateInterval: (ORInterval) v;
@end

@protocol CPFloatVarArray <CPVarArray>
-(id<CPFloatVar>) at: (ORInt) value;
-(void) set: (id<CPFloatVar>) x at: (ORInt) value;
-(id<CPFloatVar>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<CPFloatVar>) newValue atIndexedSubscript: (NSUInteger) idx;
-(id<ORASolver>) solver;
@end

