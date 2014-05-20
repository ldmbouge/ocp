/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>

//@protocol ORPrecedes;
//
//@protocol ORActivity <ORObject>
//-(ORInt) getId;
//-(id<ORIntVar>) start;
//-(id<ORIntVar>) duration;
//-(id<ORIntVar>) end;
//-(id<ORPrecedes>) precedes: (id<ORActivity>) after;
//@end
//
//@interface ORActivity : ORObject<ORActivity> 
//-(id<ORActivity>) initORActivity: (id<ORTracker>) tracker horizon: (id<ORIntRange>) horizon duration: (ORInt) duration;
//-(id<ORActivity>) initORActivity: (id<ORTracker>) tracker horizon: (id<ORIntRange>) horizon durationVariable: (id<ORIntVar>) duration;
//@end
//
//@protocol ORActivityArray <ORObject>
//-(id<ORActivity>) at: (ORInt) idx;
//-(void) set: (id<ORActivity>) value at: (ORInt)idx;
//-(id<ORActivity>)objectAtIndexedSubscript:(NSUInteger)key;
//-(void)setObject:(id<ORActivity>)newValue atIndexedSubscript:(NSUInteger)idx;
//-(ORInt) low;
//-(ORInt) up;
//-(id<ORIntRange>) range;
//-(NSUInteger) count;
//-(NSString*) description;
//-(id<ORTracker>) tracker;
//@end




/*******************************************************************************
 Below is the definition of an optional activity object using a tripartite
 representation for "optional" variables
 ******************************************************************************/

    // Different activity types
    // NOTE: Last bit represents indicates whether the activity is optional or
    //  compulsory
typedef enum {
    ORACTCOMP  = 0,   // Standard compulsory activity
    ORACTOPT   = 1,   // Standard optional activity
    ORALTCOMP  = 2,   // Compositional compulsory activity by alternative constraint
    ORALTOPT   = 3,   // Compositional optional activity by alternative constraint
    ORSPANCOMP = 4,   // Compositional compulsory activity by span constraint
    ORSPANOPT  = 5    // Compositional optional activity by span constraint
} ORActivityType;

@protocol OROptionalPrecedes;
@protocol OROptionalActivityArray;

@protocol OROptionalActivity <ORObject>
-(ORInt) getId;
-(id<ORIntVar>) startLB;
-(id<ORIntVar>) startUB;
-(id<ORIntVar>) duration;
-(id<ORIntVar>) top;
-(BOOL) isOptional;
-(id<ORIntRange>) startRange;
-(id<OROptionalActivityArray>) composition;
-(ORInt) type;
-(id<OROptionalPrecedes>) precedes: (id<OROptionalActivity>) after;
@end

@interface OROptionalActivity : ORObject<OROptionalActivity>
-(id<OROptionalActivity>) initORActivity: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration;
-(id<OROptionalActivity>) initOROptionalActivity: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration;
-(id<OROptionalActivity>) initORAlternativeActivity: (id<ORModel>)model activities: (id<OROptionalActivityArray>) act;
@end

@protocol OROptionalActivityArray <ORObject>
-(id<OROptionalActivity>) at: (ORInt) idx;
-(void) set: (id<OROptionalActivity>) value at: (ORInt)idx;
-(id<OROptionalActivity>)objectAtIndexedSubscript:(NSUInteger)key;
-(void)setObject:(id<OROptionalActivity>)newValue atIndexedSubscript:(NSUInteger)idx;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end

@protocol ORActivityMatrix <ORObject>
-(id) flat:(ORInt)i;
-(id<OROptionalActivity>) at: (ORInt) i1 : (ORInt) i2;
-(id<OROptionalActivity>) at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(void) setFlat:(id<OROptionalActivity>) x at:(ORInt)i;
-(void) set: (id<OROptionalActivity>) x at: (ORInt) i1 : (ORInt) i2;
-(void) set: (id<OROptionalActivity>) x at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(ORInt) arity;
-(id<ORIntRange>) range: (ORInt) i;
-(NSUInteger)count;
-(NSString*) description;
-(id<ORTracker>) tracker;
-(id<OROptionalActivityArray>) flatten;
@end

@protocol ORDisjunctiveResource <ORObject>
-(void) isRequiredBy: (id<OROptionalActivity>) act;
-(id<OROptionalActivityArray>) activities;
@end

@interface ORDisjunctiveResource : ORObject<ORDisjunctiveResource>
-(id<ORDisjunctiveResource>) initORDisjunctiveResource: (id<ORTracker>) tracker;
-(void) isRequiredBy: (id<OROptionalActivity>) act;
-(id<OROptionalActivityArray>) activities;
@end

@protocol ORDisjunctiveResourceArray <ORObject>
-(id<ORDisjunctiveResource>) at: (ORInt) idx;
-(void) set: (id<ORDisjunctiveResource>) value at: (ORInt)idx;
-(id<ORDisjunctiveResource>)objectAtIndexedSubscript:(NSUInteger)key;
-(void)setObject:(id<ORDisjunctiveResource>)newValue atIndexedSubscript:(NSUInteger)idx;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end
