/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORConstraint.h>
#import <ORFoundation/ORVar.h>

// [pvh] need to clean this; it must be opaque but for the objective function

@protocol ORSnapshot
-(ORInt)  intValue;
-(ORBool) boolValue;
-(ORFloat) floatValue;
@end

@protocol ORQueryIntVar
-(ORInt) value;
-(ORBool) bound;
@end;

@protocol ORQueryFloatVar
-(ORFloat) value;
-(ORBool) bound;
@end;

@protocol ORSolution <NSObject>
-(id) value: (id) var;
-(ORInt) intValue: (id<ORIntVar>) var;
-(ORBool) boolValue: (id<ORIntVar>) var;
-(ORFloat) floatValue: (id<ORFloatVar>) var;
-(id<ORObjectiveValue>) objectiveValue;
@end

@protocol ORSolutionPool <NSObject>
-(void) addSolution: (id<ORSolution>) s;
-(void) enumerateWith: (void(^)(id<ORSolution>)) block;
-(id<ORSolution>) objectAtIndexedSubscript: (NSUInteger) key;
-(id<ORInformer>) solutionAdded;
-(id<ORSolution>) best;
-(NSUInteger) count;
@end
