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

@protocol CPActivity <ORObject>
-(ORInt) getId;
-(id<CPIntVar>)   startLB;
-(id<CPIntVar>)   startUB;
-(id<CPIntVar>)   duration;
-(id<CPIntVar>)   top;
-(BOOL)           isOptional;
-(BOOL)           isPresent;
-(BOOL)           isAbsent;
-(BOOL)           implyPresent: (id<CPActivity>) act;
-(id<ORIntRange>) startRange;
-(void) updateStartMin: (ORInt) v;
-(void) updateStartMax: (ORInt) v;
@end

@interface CPActivity : ORObject<CPActivity>
-(id<CPActivity>) initCPActivity: (id<CPIntVar>) start duration: (id<CPIntVar>) duration;
-(id<CPActivity>) initCPOptionalActivity: (id<CPIntVar>) top startLB: (id<CPIntVar>) startLB startUB: (id<CPIntVar>) startUB startRange: (id<ORIntRange>) startRange duration: (id<CPIntVar>) duration;
@end

@protocol CPActivityArray <ORObject>
-(id<CPActivity>) at: (ORInt) idx;
-(void) set: (id<CPActivity>) value at: (ORInt)idx;
-(id<CPActivity>)objectAtIndexedSubscript:(NSUInteger)key;
-(void)setObject:(id<CPActivity>)newValue atIndexedSubscript:(NSUInteger)idx;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end

@protocol CPDisjunctiveResource <ORObject>
-(id<CPActivityArray>) activities;
@end

@interface CPDisjunctiveResource : ORObject<CPDisjunctiveResource>
-(id<CPDisjunctiveResource>) initCPDisjunctiveResource: (id<ORTracker>) tracker activities: (id<CPActivityArray>) activities;
-(id<CPActivityArray>) activities;
@end
