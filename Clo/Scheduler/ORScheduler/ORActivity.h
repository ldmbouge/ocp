/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>


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

@protocol ORPrecedes;
@protocol ORActivityArray;

@protocol ORActivity <ORObject>
-(ORInt) getId;
-(id<ORIntVar>) startLB;
-(id<ORIntVar>) startUB;
-(id<ORIntVar>) duration;
-(id<ORIntVar>) top;
-(BOOL) isOptional;
-(id<ORIntRange>) startRange;
-(id<ORActivityArray>) composition;
-(ORInt) type;
-(id<ORPrecedes>) precedes: (id<ORActivity>) after;
@end

@interface ORActivity : ORObject<ORActivity>
-(id<ORActivity>) initORActivity: (id<ORModel>)model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration;
-(id<ORActivity>) initORActivity: (id<ORModel>)model alternatives: (id<ORActivityArray>)act;
-(id<ORActivity>) initORActivity: (id<ORModel>)model span: (id<ORActivityArray>)act;
-(id<ORActivity>) initOROptionalActivity: (id<ORModel>)model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration;
-(id<ORActivity>) initOROptionalActivity: (id<ORModel>)model alternatives: (id<ORActivityArray>)act;
-(id<ORActivity>) initOROptionalActivity: (id<ORModel>)model span: (id<ORActivityArray>)act;
@end

@protocol ORActivityArray <ORObject>
-(id<ORActivity>) at: (ORInt) idx;
-(void) set: (id<ORActivity>) value at: (ORInt)idx;
-(id<ORActivity>)objectAtIndexedSubscript:(NSUInteger)key;
-(void)setObject:(id<ORActivity>)newValue atIndexedSubscript:(NSUInteger)idx;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end

@protocol ORActivityMatrix <ORObject>
-(id) flat:(ORInt)i;
-(id<ORActivity>) at: (ORInt) i1 : (ORInt) i2;
-(id<ORActivity>) at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(void) setFlat:(id<ORActivity>) x at:(ORInt)i;
-(void) set: (id<ORActivity>) x at: (ORInt) i1 : (ORInt) i2;
-(void) set: (id<ORActivity>) x at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(ORInt) arity;
-(id<ORIntRange>) range: (ORInt) i;
-(NSUInteger)count;
-(NSString*) description;
-(id<ORTracker>) tracker;
-(id<ORActivityArray>) flatten;
@end

@protocol ORDisjunctiveResource <ORObject>
-(void) isRequiredBy: (id<ORActivity>) act;
-(id<ORActivityArray>) activities;
@end

@interface ORDisjunctiveResource : ORObject<ORDisjunctiveResource>
-(id<ORDisjunctiveResource>) initORDisjunctiveResource: (id<ORTracker>) tracker;
-(void) isRequiredBy: (id<ORActivity>) act;
-(id<ORActivityArray>) activities;
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
