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

@interface ORIntegerI : ORExprI<NSCoding,ORInteger>
-(ORIntegerI*) initORIntegerI:(id<ORTracker>)tracker value:(ORInt) value;
-(ORInt)  value;
-(ORInt) setValue: (ORInt) value;
-(void) incr;
-(void) decr;
-(ORInt)   min;
-(id<ORTracker>) tracker;
@end

@interface ORRandomStreamI : NSObject<ORRandomStream>
-(ORRandomStreamI*) init;
-(void) dealloc;
-(ORLong) next;
@end

@interface ORZeroOneStreamI : NSObject<ORZeroOneStream>
-(ORZeroOneStreamI*) init;
-(void) dealloc;
-(double) next;
@end

@interface ORUniformDistributionI : NSObject<ORUniformDistribution>
-(ORUniformDistributionI*) initORUniformDistribution: (id<ORIntRange>) r;
-(void) dealloc;
-(ORInt) next;
-(void)setId:(ORUInt)name;
@end

@interface ORTableI : ORDualUseObjectI<ORTable,NSCoding> {
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
-(void) dealloc;
-(void) insert: (ORInt) i : (ORInt) j : (ORInt) k;
-(void) addEmptyTuple;
-(void) fill: (ORInt) j with: (ORInt) val;
-(void) close;
-(void) encodeWithCoder: (NSCoder*) aCoder;
-(id) initWithCoder: (NSCoder*) aDecoder;
-(void) print;
-(void) visit:(id<ORVisitor>)visitor;
@end

@interface ORBindingArrayI : NSObject<ORBindingArray>
-(ORBindingArrayI*) initORBindingArray: (ORInt) nb;
-(id) at: (ORInt) value;
-(void) set: (id) x at: (ORInt) value;
-(ORInt) nb;
-(id)objectAtIndexedSubscript: (NSUInteger) key;
-(void)setObject: (id) newValue atIndexedSubscript: (NSUInteger) idx;
-(id) dereference;
-(void) setImpl: (id) impl;
-(id) impl;
-(NSString*)description;
@end

