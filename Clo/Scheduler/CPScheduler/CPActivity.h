/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>

@protocol CPActivity <ORObject>
-(ORInt) getId;
-(id<CPIntVar>) start;
-(id<CPIntVar>) duration;
-(id<CPIntVar>) end;
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

@interface CPActivity : ORObject<CPActivity>
-(id<CPActivity>) initCPActivity: (id<CPIntVar>) start duration: (id<CPIntVar>) duration end: (id<CPIntVar>) end;
@end

@protocol CPDisjunctiveResource <ORObject>
-(id<CPActivityArray>) activities;
@end

@interface CPDisjunctiveResource : ORObject<CPDisjunctiveResource>
-(id<CPDisjunctiveResource>) initCPDisjunctiveResource: (id<ORTracker>) tracker activities: (id<CPActivityArray>) activities;
-(id<CPActivityArray>) activities;
@end