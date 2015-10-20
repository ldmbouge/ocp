/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

/*!
 *  @header
 *
 *  For information, contact <a href="http://org.nicta.com.au/people/andreas-schutt/">Andreas Schutt</a>.
 *
 *  @author Andreas Schutt and Pascal Van Hentenryck
 *  @copyright 2014-2015 NICTA
 *  @updated 2015-02-11
 */

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>

@protocol ORTaskPrecedes;
@protocol ORTaskIsFinishedBy;
@protocol ORTaskVarArray;
@protocol ORResourceArray;

/*!
 *  @brief A standard task variable which can be optional, too.
 */
@protocol ORTaskVar <ORVar>
-(id<ORTracker>) tracker;
-(id<ORIntRange>) horizon;
-(id<ORIntRange>) duration;
-(ORBool) isOptional;
-(id<ORTaskPrecedes>) precedes: (id<ORTaskVar>) after;
-(id<ORTaskIsFinishedBy>) isFinishedBy: (id<ORIntVar>) date;
-(id<ORIntVar>) getStartVar;
-(id<ORIntVar>) getDurationVar;
-(id<ORIntVar>) getPresenceVar;
@end

/*!
 * @brief An alternative task variable that is equal to exactly one of its alternative task variables and extends standard task variables.
 */
@protocol ORAlternativeTask <ORTaskVar>
-(id<ORTaskVarArray>) alternatives;
@end

/*!
 * @brief A span task variable that is composed by a set of other task variables and extends standard task variables.
 */
@protocol ORSpanTask <ORTaskVar>
-(id<ORTaskVarArray>) compound;
@end

/*!
 * @brief A resource task variable that is like ORAlternativeTask, but without creation of other task variables. It also extends standard task variables.
 */
@protocol ORResourceTask <ORTaskVar>
-(id<ORResourceArray>) resources;
-(id<ORIntRangeArray>) durationArray;
-(void) addResource: (id<ORConstraint>) resource with: (id<ORIntRange>) duration;
-(ORInt) getIndex: (id<ORConstraint>) resource;
-(void) close;
@end

/*!
 * @brief An array storing task variables.
 */
@protocol ORTaskVarArray <ORObject>
-(id<ORTaskVar>) at: (ORInt) idx;
-(void) set: (id<ORTaskVar>) value at: (ORInt)idx;
-(id<ORTaskVar>)objectAtIndexedSubscript:(NSUInteger)key;
-(void)setObject:(id<ORTaskVar>)newValue atIndexedSubscript:(NSUInteger)idx;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end

/*!
 * @brief A matrix storing task variables.
 */
@protocol ORTaskVarMatrix <ORObject>
-(id) flat:(ORInt)i;
-(id<ORTaskVar>) at: (ORInt) i1 : (ORInt) i2;
-(id<ORTaskVar>) at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(void) setFlat:(id<ORTaskVar>) x at:(ORInt)i;
-(void) set: (id<ORTaskVar>) x at: (ORInt) i1 : (ORInt) i2;
-(void) set: (id<ORTaskVar>) x at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(ORInt) arity;
-(id<ORIntRange>) range: (ORInt) i;
-(NSUInteger)count;
-(NSString*) description;
-(id<ORTracker>) tracker;
-(id<ORTaskVarArray>) flatten;
@end

@protocol ORTaskVarSnapshot
-(ORInt) ect;
@end;

/*!
 * @brief An array storing alternative task variables.
 */
@protocol ORAlternativeTaskArray <ORObject>
-(id<ORAlternativeTask>) at: (ORInt) idx;
-(void) set: (id<ORAlternativeTask>) value at: (ORInt)idx;
-(id<ORAlternativeTask>)objectAtIndexedSubscript:(NSUInteger)key;
-(void)setObject:(id<ORAlternativeTask>)newValue atIndexedSubscript:(NSUInteger)idx;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end

/*!
 * @brief An array storing resource task variables.
 */
@protocol ORResourceArray <ORObject>
-(id<ORConstraint>) at: (ORInt) idx;
-(void) set: (id<ORConstraint>) value at: (ORInt)idx;
-(id<ORConstraint>)objectAtIndexedSubscript:(NSUInteger)key;
-(void)setObject:(id<ORConstraint>)newValue atIndexedSubscript:(NSUInteger)idx;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end
