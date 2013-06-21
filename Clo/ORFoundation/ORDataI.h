/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORData.h"
#import "ORExprI.h"
#import "ORError.h"

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
-(void) setId:(id)v in:(id<ORGamma>)solver;
-(void)setId:(id)v;
@end

@interface ORFloatI : ORExprI<NSCoding,ORFloatNumber>
-(ORFloatI*) initORFloatI: (id<ORTracker>) tracker value: (ORFloat) value;
-(ORFloat) floatValue;
-(ORFloat) value;
-(ORInt) intValue;
-(id<ORTracker>) tracker;
@end

@interface ORMutableFloatI : ORExprI<NSCoding,ORMutableFloat>
-(ORMutableFloatI*) initORMutableFloatI: (id<ORTracker>) tracker value: (ORFloat) value;
-(ORFloat) initialValue;
-(ORFloat) value: (id<ORGamma>) solver;
-(ORFloat) floatValue: (id<ORGamma>) solver;
-(ORFloat) setValue: (ORFloat) value in: (id<ORGamma>) solver;
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
-(void)setId:(ORUInt)name;
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
-(void) encodeWithCoder: (NSCoder*) aCoder;
-(id) initWithCoder: (NSCoder*) aDecoder;
-(void) print;
-(void) visit:(id<ORVisitor>)visitor;
@end

@interface ORAutomatonI : ORObject<ORAutomaton,NSCoding> {
   id<ORIntRange> _alpha;
   id<ORIntRange> _states;
   id<ORIntSet>   _final;
   ORInt          _nbt;
   ORTableI*      _transition;
}
-(id) init:(id<ORIntRange>)alphabet states:(id<ORIntRange>)states transition:(ORTransition*)tf size:(ORInt)stf final:(id<ORIntSet>)fs table:(id<ORTable>)table;
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

