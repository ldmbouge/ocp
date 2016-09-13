/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORData.h>
#import <ORFoundation/ORExprI.h>
#import <ORFoundation/ORError.h>

@interface ORIntegerI : ORExprI<NSCoding,NSCopying,ORInteger>
-(ORIntegerI*) initORIntegerI:(id<ORTracker>)tracker value:(ORInt) value;
-(ORInt)  value;
-(ORInt)  min;
-(ORInt)  max;
-(id<ORTracker>) tracker;
@end

@interface ORMutableIntegerI : ORExprI<NSCoding,ORMutableInteger>
-(ORMutableIntegerI*) initORMutableIntegerI: (id<ORTracker>) tracker value: (ORInt) value;
-(ORInt)  initialValue;
-(ORInt) setValue: (ORInt) value;
-(ORInt)  value: (id<ORGamma>) solver;
-(ORInt)  setValue: (ORInt) value in: (id<ORGamma>) solver;
-(ORInt)  incr: (id<ORGamma>) solver;
-(ORInt)  decr: (id<ORGamma>) solver;
-(id<ORTracker>) tracker;
-(ORInt) incr;
-(ORInt) decr;
@end

@interface ORMutableId : ORObject<ORMutableId> {
   id _value;
}
-(id) initWith:(id)v;
-(id) idValue;
-(id) idValue:(id<ORGamma>)solver;
-(void) setIdValue:(id)v in:(id<ORGamma>)solver;
-(void)setIdValue:(id)v;
@end

@interface ORDoubleI : ORExprI<NSCoding,NSCopying,ORDoubleNumber>
-(ORDoubleI*) init: (id<ORTracker>) tracker value: (ORDouble) value;
-(ORDouble) doubleValue;
-(ORDouble) value;
-(ORInt) intValue;
-(id<ORTracker>) tracker;
@end

@interface ORMutableDoubleI : ORExprI<NSCoding,ORMutableDouble>
-(ORMutableDoubleI*) initORMutableRealI: (id<ORTracker>) tracker value: (ORDouble) value;
-(ORDouble) initialValue;
-(ORDouble) value: (id<ORGamma>) solver;
-(ORDouble) doubleValue: (id<ORGamma>) solver;
-(ORDouble) setValue: (ORDouble) value in: (id<ORGamma>) solver;
-(id<ORTracker>) tracker;
@end

@interface ORRandomStreamI : ORObject<ORRandomStream>
-(ORRandomStreamI*) init;
-(void) dealloc;
-(ORLong) next;
@end

@interface ORZeroOneStreamI : ORObject<ORZeroOneStream>
-(ORZeroOneStreamI*) init;
-(void) dealloc;
-(double) next;
@end

@interface ORUniformDistributionI : ORObject<ORUniformDistribution>
-(ORUniformDistributionI*) initORUniformDistribution: (id<ORIntRange>) r;
-(void) dealloc;
-(ORInt) next;
@end

@interface ORRandomPermutationI : ORObject<ORRandomPermutation>
-(ORRandomPermutationI*)initWithSet:(id<ORIntIterable>)set;
-(ORInt)next;
-(void)reset;
@end

@interface ORTableI : ORObject<ORTable,NSCoding,NSCopying> {
@public
   ORInt   _arity;
   ORInt   _nb;
   ORInt   _size;
   ORInt** _column;
   bool    _closed;
   ORInt*  _min;          // _min[j] is the minimum value in column[j]
   ORInt*  _max;          // _max[j] is the maximun value in column[j]
   ORInt** _nextSupport;  // _nextSupport[j][i] is the next support of element j in tuple i
   ORInt** _support;      // _support[j][v] is the support (a row index) of value v in column j
}
-(ORTableI*) initORTableI: (ORInt) arity;
-(ORTableI*) initORTableWithTableI: (ORTableI*) table;
-(id)copyWithZone:(NSZone *)zone;
-(void) dealloc;
-(void) insert: (ORInt) i : (ORInt) j : (ORInt) k;
-(void)insertTuple:(ORInt*)t;
-(void) addEmptyTuple;
-(void) fill: (ORInt) j with: (ORInt) val;
-(void) close;
-(ORInt) size;
-(ORInt) arity;
-(ORInt) atColumn: (ORInt)c position: (ORInt)p;
-(void) encodeWithCoder: (NSCoder*) aCoder;
-(id) initWithCoder: (NSCoder*) aDecoder;
-(void) print;
-(void) visit:(ORVisitor*)visitor;
@end

@interface ORAutomatonI : ORObject<ORAutomaton,NSCoding> {
   id<ORIntRange> _alpha;
   id<ORIntRange> _states;
   ORInt          _initial;
   id<ORIntSet>   _final;
   ORInt          _nbt;
   ORTableI*      _transition;
}
-(id) init:(id<ORIntRange>)alphabet states:(id<ORIntRange>)states transition:(ORTransition*)tf size:(ORInt)stf
   initial:(ORInt)is
     final:(id<ORIntSet>)fs
     table:(id<ORTable>)table;
-(ORInt) initial;
-(id<ORIntSet>)final;
-(id<ORIntRange>)alphabet;
-(id<ORIntRange>)states;
-(ORInt)nbTransitions;
-(id<ORTable>)transition;
@end


@interface ORBindingArrayI : NSObject<ORBindingArray>
-(ORBindingArrayI*) initORBindingArray: (ORInt) nb;
-(id) at: (ORInt) value;
-(void) set: (id) x at: (ORInt) value;
-(ORInt) nb;
-(id)objectAtIndexedSubscript: (NSUInteger) key;
-(void)setObject: (id) newValue atIndexedSubscript: (NSUInteger) idx;
-(void) setImpl: (id) impl;
-(id) impl;
-(NSString*)description;
@end

