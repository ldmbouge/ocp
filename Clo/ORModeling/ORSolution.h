/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFOundation/ORModel.h>

@protocol ORSolution <ORObject>
-(id<ORSnapshot>) value:(id)var;
-(ORInt) intValue: (id) var;
-(BOOL) boolValue: (id) var;
-(NSUInteger) count;
-(id<ORObjectiveValue>)objectiveValue;
@end

@protocol ORSolutionPool <NSObject>
-(void)addSolution:(id<ORSolution>)s;
-(void)enumerateWith:(void(^)(id<ORSolution>))block;
-(id<ORSolution>)best;
@end